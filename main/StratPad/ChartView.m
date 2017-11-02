//
//  ChartView.m
//  StratPad
//
//  Created by Julian Wood on 12-03-29.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "ChartView.h"
#import "Measurement.h"
#import "Metric.h"
#import "NSDate-StratPad.h"
#import "NSCalendar+Expanded.h"
#import "UIColor-Expanded.h"
#import "UIColor-HSVAdditions.h"
#import "GridSupport.h"
#import "DataManager.h"
#import "CommentBox.h"
#import "LinearRegression.h"

@interface NSDate (ChartView)
-(NSDate*)dateAtEndOfInterval:(NSUInteger)interval;
@end

@implementation NSDate (ChartView)

-(NSDate*)dateAtEndOfInterval:(NSUInteger)interval
{
    NSDate *dateAtFirstDayOfMonthOfInterval = [NSDate dateSetToFirstDayOfMonthOfInterval:interval forDate:self];
    
    // add interval months
    NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];    
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setMonth:interval];
    NSDate *dateAtFirstDayOfMonthOfNextInterval = [gregorian dateByAddingComponents:comps toDate:dateAtFirstDayOfMonthOfInterval options:0];
    [comps release];

    return dateAtFirstDayOfMonthOfNextInterval;
}

@end

@implementation ChartView

@synthesize scale = scale_;
@synthesize mediaType = mediaType_;

#pragma mark - Chart drawing

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        scale_ = 1.0;
        mediaType_ = MediaTypeScreen;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        scale_ = 1.0;
        mediaType_ = MediaTypeScreen;
    }
    return self;
}

-(void)drawLineChart:(CGRect)gridRect chart:(Chart*)chart
{
    NSArray *measurements = [ChartView measurementsForChart:chart];    
    if (!measurements.count) {
        return;
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    CGFloat gh = gridRect.size.height;
    CGFloat gw = gridRect.size.width;
    CGFloat x, y;
            
    // move the path to the starting point - x=firstDay and y=firstVal
    Measurement *measurement = [measurements objectAtIndex:0];
    CGFloat val = [[measurement value] floatValue];
    
    NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];    
    NSDateComponents *components = [gregorian components:NSDayCalendarUnit
                              fromDate:chartStartDate_
                                toDate:measurement.date options:0];
    NSInteger dayOfYear = [components day];
    
    x = gridRect.origin.x+(CGFloat)dayOfYear/xMax_*gw;
    y = gridRect.origin.y+gh-gh*val/yMax_;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, x, y);
    
    for (int i=0, ct=measurements.count; i<ct; ++i) {
        measurement = [measurements objectAtIndex:i];
        
        // need the number of days since the starting month (ie Jan 1, 2011 in our example) of this measurement        
        components = [gregorian components:NSDayCalendarUnit
                                  fromDate:chartStartDate_
                                    toDate:measurement.date options:0];
        dayOfYear = [components day];
        
        x = gridRect.origin.x+(CGFloat)dayOfYear/xMax_*gw;
        val = [[measurement value] floatValue];
        y = gridRect.origin.y+gh-gh*val/yMax_;
        CGPathAddLineToPoint(path, NULL, x, y);
    }
    
    CGContextSetShouldAntialias(context, YES);
    CGContextSetStrokeColorWithColor(context, [[chart colorForGradientStart] CGColor]);
    CGContextSetLineWidth(context, 4.0*scale_);
    
    // add shadow to line if it's an overlay
    if (chart.zLayer == overlayChartLayer && mediaType_ == MediaTypeScreen) {
        UIColor *shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        CGContextSetShadowWithColor(context, CGSizeMake(0, -1.f), 5.f*scale_, [shadowColor CGColor]);    
    }    
    
    CGContextAddPath(context, path);
    CGContextStrokePath(context);
    CGPathRelease(path);
    
    CGContextRestoreGState(context);
}

-(void)drawBarChart:(CGRect)gridRect chart:(Chart*)chart
{
    // considerations:
    // what if you put 20 vals in 1 month? currently we just draw the highest one, as a byproduct of drawing them overtop of each other
    // we need to do the same thing if we are compressing more time into a column
    // for example a 26 mo. set of measurements spans 3y, 18 cols, 2 mo/col

    NSArray *measurements = [ChartView measurementsForChart:chart];    
    if (!measurements.count) {
        return;
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    CGFloat gh = gridRect.size.height;
    CGFloat gw = gridRect.size.width;
    
    // figure out grid params
    uint gridDuration = [Chart gridDurationForChartDuration:chartDuration_];
    uint monthsPerCol = [Chart intervalForDuration:gridDuration];
    int numColumns = gridDuration/monthsPerCol;
    CGFloat colWidth = gw/numColumns;

    // plot bars
    CGMutablePathRef path = CGPathCreateMutable();
    NSDateComponents *components;
    NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar]; 
    CGFloat x, y, yMin = gridRect.origin.y+gh;
    for (int i=0, ct=measurements.count; i<ct; ++i) {
        Measurement *measurement = [measurements objectAtIndex:i];
        
        // need the number of months since the starting month of this measurement        
        components = [gregorian components:NSMonthCalendarUnit
                                  fromDate:chartStartDate_
                                    toDate:measurement.date options:0];
        NSInteger month = [components month]; 
        
        // need to compress this into a single column
        month = month/monthsPerCol;
        
        CGFloat margin = colWidth*0.15;
        x = gridRect.origin.x + (CGFloat)month/numColumns*gw + margin;
        CGFloat val = [[measurement value] floatValue];
        y = gridRect.origin.y+gh-gh*val/yMax_;
        yMin = MIN(yMin, y);
        
        CGPathAddRect(path, NULL, CGRectMake(x, y, colWidth-margin*2, gh*val/yMax_));
    }
    
    // add a shadow - not important until we see this as an overlay
    // remember that shadows are not drawn until a fill is applied
    // remember also that once a fill is applied, the path is removed from the context (so add twice)
    if (mediaType_ == MediaTypeScreen) {
        CGContextSetShadowWithColor(context, CGSizeMake(0, -1.f), 5.f*scale_, [[[UIColor blackColor] colorWithAlphaComponent:0.5] CGColor]);    
        CGContextAddPath(context, path);
        CGContextSetFillColorWithColor(context, [[[UIColor blackColor] colorWithAlphaComponent:1.f] CGColor]);
        CGContextFillPath(context);        
    }
        
    // gradient colors
    UIColor *colorStart = [chart colorForGradientStart];
    UIColor *colorEnd = [chart colorForGradientEnd];
    if (mediaType_ == MediaTypePrint) {
        // lighten up the start color so it's not quite white, for stratcard
        struct hsv_color hsv;
        struct rgb_color rgb;
        rgb.r = [colorStart red];
        rgb.g = [colorStart green];
        rgb.b = [colorStart blue];
        hsv = [UIColor HSVfromRGB: rgb];
        colorEnd = [UIColor colorWithHue:hsv.hue/360 
                              saturation:0.1
                              brightness:0.95
                                   alpha:1.0];        
    }
    
    CGFloat colors [] = { 
        colorStart.red, colorStart.green, colorStart.blue, 0.9,
        colorEnd.red, colorEnd.green, colorEnd.blue, 0.9
    };
    
    CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, colors, NULL, 2);
    CGColorSpaceRelease(baseSpace), baseSpace = NULL;

    // figure out gradient start and end
    NSArray *gradientPoints;
    if (measurements.count >= 2) {        
        NSDate *endDate = [[[measurements lastObject] date] dateAtEndOfInterval:monthsPerCol];
        gradientPoints = [self gradientPoints:chart gridRect:(CGRect)gridRect lastMeasurementDate:endDate];
    } else {
        CGPoint startPoint = CGPointMake(CGRectGetMidX(gridRect), yMin);
        CGPoint endPoint = CGPointMake(CGRectGetMidX(gridRect), CGRectGetMaxY(gridRect));
        gradientPoints = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:startPoint], [NSValue valueWithCGPoint:endPoint], nil];
    }

    // clip to path
    CGContextAddPath(context, path);
    CGContextClip(context);
    CGPathRelease(path);
        
    // draw the gradient in our clipped area
    CGPoint startPoint = [[gradientPoints objectAtIndex:0] CGPointValue];
    CGPoint endPoint = [[gradientPoints objectAtIndex:1] CGPointValue];
    
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGGradientRelease(gradient), gradient = NULL; 
        
    CGContextRestoreGState(context);
}

-(void)drawAreaChart:(CGRect)gridRect chart:(Chart*)chart
{
    // draw a path and fill it in with a gradient
    // NB. ULO coordinate system
    
    NSArray *measurements = [ChartView measurementsForChart:chart];    
    if (!measurements.count) {
        return;
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    CGFloat gh = gridRect.size.height;
    CGFloat gw = gridRect.size.width;
    CGFloat x, y;
        
    // move the path to the starting point - x=0 and y=firstVal
    Measurement *measurement = [measurements objectAtIndex:0];
    CGFloat val = [[measurement value] floatValue];
    CGMutablePathRef path = CGPathCreateMutable();
    
    // need the number of days since the starting month (ie Jan 1, 2011 in our example) of this measurement        
    NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];    
    NSDateComponents *components = [gregorian components:NSDayCalendarUnit
                              fromDate:chartStartDate_
                                toDate:measurement.date options:0];
    NSInteger dayOfYear = [components day];

    x = gridRect.origin.x+(CGFloat)dayOfYear/xMax_*gw;
    y = gridRect.origin.y+gh-gh*val/yMax_;
    CGPathMoveToPoint(path, NULL, x, y);
    
    CGFloat yMin = y; // remember ULO (so this is actually like a max)
    for (int i=0, ct=measurements.count; i<ct; ++i) {
        measurement = [measurements objectAtIndex:i];
        
        // need the number of days since the starting month (ie Jan 1, 2011 in our example) of this measurement        
        components = [gregorian components:NSDayCalendarUnit
                                  fromDate:chartStartDate_
                                    toDate:measurement.date options:0];
        dayOfYear = [components day];
        
        x = gridRect.origin.x+(CGFloat)dayOfYear/xMax_*gw;
        CGFloat val = [[measurement value] floatValue];
        y = gridRect.origin.y+gh-gh*val/yMax_;
        CGPathAddLineToPoint(path, NULL, x, y);
        yMin = MIN(yMin, y);
    }

    // go straight down to the x-axis, and then back to the chart origin
    CGPathAddLineToPoint(path, NULL, x, gridRect.origin.y+gh);

    // grab the first date again
    measurement = [measurements objectAtIndex:0];
    components = [gregorian components:NSDayCalendarUnit
                                                fromDate:chartStartDate_
                                                  toDate:measurement.date options:0];
    dayOfYear = [components day];
    x = gridRect.origin.x+(CGFloat)dayOfYear/xMax_*gw;    
    CGPathAddLineToPoint(path, NULL, x, gridRect.origin.y+gh);
    CGPathCloseSubpath(path);
    
    // figure out gradient start and end
    NSArray *gradientPoints = [self gradientPoints:chart gridRect:(CGRect)gridRect lastMeasurementDate:[[measurements lastObject] date]];

    // clip to path
    CGContextAddPath(context, path);
    CGContextClip(context);
    CGPathRelease(path);
    
    // gradient colors
    UIColor *colorStart = [chart colorForGradientStart];
    UIColor *colorEnd = (mediaType_ == MediaTypeScreen) ? [chart colorForGradientEnd] : [UIColor whiteColor];
        
    CGFloat colors [] = { 
        colorStart.red, colorStart.green, colorStart.blue, 0.9,
        colorEnd.red, colorEnd.green, colorEnd.blue, 0.9
    };
    
    CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, colors, NULL, 2);
    CGColorSpaceRelease(baseSpace), baseSpace = NULL;
    
    // draw the gradient in our clipped area
    CGPoint startPoint = [[gradientPoints objectAtIndex:0] CGPointValue];
    CGPoint endPoint = [[gradientPoints objectAtIndex:1] CGPointValue];
    
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGGradientRelease(gradient), gradient = NULL;
    
    CGContextRestoreGState(context);
}

#pragma mark - Comments chart drawing

-(void)drawCommentsChart:(CGRect)gridRect chart:(Chart*)chart
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat gh = gridRect.size.height;
    CGFloat gw = gridRect.size.width;
    CGFloat x, y;
    
    // for the text inside its box
    CGFloat padding = 5.f*scale_;
    
    // find measurements with comments
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"metric=%@ && comment!=nil && comment!=''", chart.metric];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
    NSArray *measurements = [DataManager arrayForEntity:NSStringFromClass([Measurement class]) 
                                   sortDescriptorsOrNil:[NSArray arrayWithObject:sortDescriptor] 
                                         predicateOrNil:predicate];
    
    // make the gradient
    UIColor *colorStart = [chart colorForGradientStart];
    UIColor *colorEnd = [chart colorForGradientEnd];
    
    CGFloat colors [] = { 
        colorStart.red, colorStart.green, colorStart.blue, 0.9,
        colorEnd.red, colorEnd.green, colorEnd.blue, 0.9
    };
    
    CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, colors, NULL, 2);
    CGColorSpaceRelease(baseSpace), baseSpace = NULL;
    
    // just need to draw a box, up to 3 lines high, 80px wide, for each comment, at the date
    [commentBoxen_ removeAllObjects];
    NSDateComponents *components;
    NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar]; 
    uint level = 0;
    for (int i=0, ct=[measurements count]; i<ct; ++i) {
        Measurement *measurement = [measurements objectAtIndex:i];
        
        // need the number of days since the starting month (ie Jan 1, 2011 in our example) of this measurement        
        components = [gregorian components:NSDayCalendarUnit
                                  fromDate:chartStartDate_
                                    toDate:measurement.date options:0];
        NSInteger dayOfYear = [components day];
        
        x = gridRect.origin.x+(CGFloat)dayOfYear/xMax_*gw;
        
        // starting y for comment bubbles
        y = gridRect.origin.y+gh-70*scale_;
        
        // draw a box centered around x,y pointing down to x        
        // figure out height needed by comment abbrev
        NSString *abbrev = [ChartView abbreviationForComment:i];
        CGSize preferredSize = [abbrev sizeWithFont:[UIFont systemFontOfSize:12*scale_] 
                                  constrainedToSize:CGSizeMake(80*scale_, 50*scale_)
                                      lineBreakMode:UILineBreakModeWordWrap];
        CGRect textRect = CGRectMake(x-(preferredSize.width/2), y-(preferredSize.height/2), preferredSize.width, preferredSize.height);
        
        // readjust boxRect given preferredSize
        CGRect boxRect = CGRectInset(textRect, -padding, -padding);
        
        // check to see if this box overlaps the last box, and if it does, increase y by some height
        // we count from latest to earliest measurement, such that A is on far right
        if (i>0) {
            // check for intersection on level 0 box
            uint j = 1;
            CommentBox *lastLevelZeroBox = [commentBoxen_ objectAtIndex:i-j++];
            level = lastLevelZeroBox.level;
            while (lastLevelZeroBox.level != 0) {
                lastLevelZeroBox = [commentBoxen_ objectAtIndex:i-j++];
            }
            BOOL intersects = CGRectIntersectsRect(boxRect, lastLevelZeroBox.hitRect);
            if (intersects) {
                // we have to push it up a multiple of level
                level++;
                boxRect = CGRectMake(boxRect.origin.x, lastLevelZeroBox.hitRect.origin.y-(boxRect.size.height+2)*level, boxRect.size.width, boxRect.size.height);
            } else {
                level = 0;
            }
        }
        
        // store the boxRect for testing hits, along with the appropriate comment
        CommentBox *commentBox = [[CommentBox alloc] initWithHitRect:boxRect comment:measurement.comment chart:chart level:level];
        [commentBoxen_ addObject:commentBox];
        [commentBox release];            
        
    }
    
    CGContextSaveGState(context);
    
    // draw in reverse order (from Z->A), with A of the far right
    for (int i=[commentBoxen_ count]-1; i>=0; i--) {
        CommentBox *commentBox = [commentBoxen_ objectAtIndex:i];
        CGRect boxRect = commentBox.hitRect;
        CGRect textRect = CGRectInset(boxRect, padding, padding);
        
        // don't draw if we go off-screen
        if (boxRect.origin.y < gridRect.origin.y) {
            continue;
        }
        
        x = CGRectGetMinX(boxRect) + boxRect.size.width/2;
        
        // for the text
        if (mediaType_ == MediaTypeScreen) {
            UIColor *shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
            CGContextSetShadowWithColor(context, CGSizeMake(0, -1.f), 2.f*scale_, [shadowColor CGColor]);    
        }
        
        // in order to reset the paths
        CGContextSaveGState(context);
        
        // rounded rect
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:boxRect 
                                                   byRoundingCorners:UIRectCornerAllCorners
                                                         cornerRadii:CGSizeMake(3, 3)];
        
        // remember that shadows are not drawn until a fill is applied
        // remember also that once a fill is applied, the path is removed from the context (so add twice)
        CGContextAddPath(context, path.CGPath);
        CGContextSetFillColorWithColor(context, [[[UIColor blackColor] colorWithAlphaComponent:1.f] CGColor]);
        CGContextFillPath(context);
        
        // clip to rounded rect
        CGContextAddPath(context, path.CGPath);
        CGContextClip(context);
        
        // draw the gradient in our clipped area
        CGPoint startPoint = CGPointMake(CGRectGetMidX(boxRect), CGRectGetMinY(boxRect));
        CGPoint endPoint = CGPointMake(CGRectGetMidX(boxRect), CGRectGetMaxY(boxRect));
        CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
        
        // draw the label
        CGContextSetFillColorWithColor(context, [[UIColor colorWithHexString:@"FFFFFF"] CGColor]);
        NSString *abbrev = [ChartView abbreviationForComment:i];
        [abbrev drawInRect:textRect 
                  withFont:[UIFont systemFontOfSize:12*scale_]
             lineBreakMode:UILineBreakModeWordWrap
                 alignment:UITextAlignmentCenter];
        
        CGContextRestoreGState(context);
        
        // now draw a line down to the x-axis - 5
        CGContextSetLineWidth(context, 3.0*scale_);
        CGContextSetFillColorWithColor(context, [colorStart darkerColor].CGColor);
        CGContextSetStrokeColorWithColor(context, [colorStart darkerColor].CGColor);
        CGContextMoveToPoint(context, x, CGRectGetMaxY(boxRect));
        CGContextAddLineToPoint(context, x, CGRectGetMaxY(gridRect)-5*scale_);
        CGContextStrokePath(context);
        
        CGPoint p1 = CGPointMake(x, CGRectGetMaxY(boxRect));
        CGPoint p2 = CGPointMake(x, CGRectGetMaxY(gridRect));
        
        // calculate points for arrow (triangle)
        CGFloat arrowLength = 15*scale_;
        static CGFloat arrowAngle = degreesToRadians(27);
        CGFloat theta = atanf((p2.y-p1.y)/(p2.x-p1.x)) * -1;
        CGFloat gamma = degreesToRadians(90)-theta-arrowAngle;
        CGPoint p3 = CGPointMake(p2.x-arrowLength*sinf(gamma), p2.y+arrowLength*cosf(gamma));
        CGPoint p4 = CGPointMake(p2.x-arrowLength*cos(theta-arrowAngle), p2.y+arrowLength*sin(theta-arrowAngle));
        
        CGFloat shaft = arrowLength*cosf(arrowAngle)*0.8;
        CGPoint p5 = CGPointMake(p2.x-shaft*cosf(theta), p2.y+shaft*sinf(theta));
        
        // plot arrow
        CGMutablePathRef triangle = CGPathCreateMutable();
        CGPathMoveToPoint(triangle, NULL, p4.x, p4.y);
        CGPathAddLineToPoint(triangle, NULL, p2.x, p2.y);
        CGPathAddLineToPoint(triangle, NULL, p3.x, p3.y);
        CGPathAddLineToPoint(triangle, NULL, p5.x, p5.y);
        CGPathCloseSubpath(triangle);
        CGContextAddPath(context, triangle);
        CGContextFillPath(context);
        CGPathRelease(triangle);
    }
    CGContextRestoreGState(context);
    CGGradientRelease(gradient), gradient = NULL;
}

#pragma mark - Utility

-(NSArray*)gradientPoints:(Chart*)chart gridRect:(CGRect)gridRect lastMeasurementDate:(NSDate*)lastMeasurementDate
{
    CGFloat gh = gridRect.size.height;
    CGFloat gw = gridRect.size.width;

    // make the gradient
    
    // draw gradient from a point on the best fit line to (lastMeasurement.x,0), such that this line is perpendicular
    // we need to offset the line by at least the distance of the greatest positive deviation, in order to get the gradient to fill it    
    
    // best fit line
    LinearRegression *lr = [[LinearRegression alloc] initWithChart:chart
                                                    chartStartDate:chartStartDate_];
    
    // we have to calculate the angles using grid coordinates, since they change significantly from using real values
    // figure out two points on the line and convert to real coords - use that for y=mx+b
    CGPoint p10 = CGPointMake(0, [lr yVal:0]);
    CGPoint p11 = CGPointMake(xMax_, [lr yVal:xMax_]);
    
    p10 = CGPointMake(gridRect.origin.x+p10.x/xMax_*gw, gridRect.origin.y+gh-gh*p10.y/yMax_);
    p11 = CGPointMake(gridRect.origin.x+p11.x/xMax_*gw, gridRect.origin.y+gh-gh*p11.y/yMax_);
    
    // l1
    CGFloat slope = (p11.y-p10.y)/(p11.x-p10.x);
    CGFloat yint = p10.y - slope*p10.x;
    
    // defensive
    slope = isnan(slope) ? 0 : slope;
    yint = isnan(yint) ? 0 : yint;
    
    // we have to transpose the y-intercept along the y-axis until it covers the max deviation from the trend line
    yint -= gh*lr.devY/yMax_;
    
    // little extra room; we need more for the bar chart because the bars extend on either side of the actual x coord
    if (chart.chartType.intValue == ChartTypeBar) {
        uint gridDuration = [Chart gridDurationForChartDuration:chartDuration_];
        uint monthsPerCol = [Chart intervalForDuration:gridDuration];
        int numColumns = gridDuration/monthsPerCol;
        CGFloat colWidth = gw/numColumns;
        yint -= colWidth/2*scale_;
    } else {
        yint -= 5.f*scale_;
    }
    
    // calculate perp slope and y-intercept
    // use point at lastMeasurement.x, 0 to define end point
    // figure out the point on this line which intersects the offset trendline
    
    // if negative slope (remember TLO), then p2 is where y=0 at lastMeasurement.x, otherwise use (day 0, val 0)
    CGPoint p2;
    if (slope < 0) {
        NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar]; 
        NSDateComponents *components = [gregorian components:NSDayCalendarUnit
                                  fromDate:chartStartDate_
                                    toDate:lastMeasurementDate options:0];
        NSInteger dayOfYear = [components day];
        CGFloat p2x = gridRect.origin.x+(CGFloat)dayOfYear/xMax_*gw;
        p2 = CGPointMake(p2x, CGRectGetMaxY(gridRect));        
        
    } else {
        p2 = CGPointMake(gridRect.origin.x, CGRectGetMaxY(gridRect));
        
    }
    
    // the slope of the perpendicular line l2 is -1/slope
    CGFloat perpSlope = -1.f/slope;
    CGFloat perpYint = p2.y - perpSlope*p2.x;
    
    // just above the trend line
    CGPoint pt1 = CGPointMake(0, slope*0+yint);
    CGPoint pt2 = CGPointMake(800, slope*800+yint);
    
    // perp line l2
    CGPoint pt3 = CGPointMake(0, perpSlope*0+perpYint);
    CGPoint pt4 = CGPointMake(800, perpSlope*800+perpYint);
    
    CGPoint p1 = lineIntersection(pt1, pt2, pt3, pt4);
        
#if DEBUG
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // draw line from p1 to p2 (should = line 2)
    CGContextSetStrokeColorWithColor(context, [[UIColor redColor] CGColor]);
    CGContextMoveToPoint(context, p1.x, p1.y);
    CGContextAddLineToPoint(context, p2.x, p2.y);
    CGContextStrokePath(context);
    
    // draw p2
    CGContextSetFillColorWithColor(context, [[UIColor orangeColor] CGColor]);
    CGContextFillEllipseInRect(context, CGRectMake(p2.x-5, p2.y-5, 10, 10));
    
    // draw line 1
    CGContextSetStrokeColorWithColor(context, [[UIColor greenColor] CGColor]);
    CGContextMoveToPoint(context, pt1.x, pt1.y);
    CGContextAddLineToPoint(context, pt2.x, pt2.y);
    CGContextStrokePath(context);
    
    // draw line 2
    CGContextMoveToPoint(context, pt3.x, pt3.y);
    CGContextAddLineToPoint(context, pt4.x, pt4.y);
    CGContextStrokePath(context);
#endif
    
    [lr release];

    return [NSArray arrayWithObjects:[NSValue valueWithCGPoint:p1], [NSValue valueWithCGPoint:p2], nil];
}

-(void)drawColorWellWithGradientColorStart:(UIColor*)gradientColorStart gradientColorEnd:(UIColor*)gradientColorEnd inRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    // draw a rounded rect background in grey that will appear like a stroke
    CGContextSetFillColorWithColor(context, [[UIColor colorWithHexString:@"4c4c4c"] CGColor]);
    UIBezierPath *bgpath = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(3, 3)];
    [bgpath fill];
    
    // make the gradient
    CGFloat colors [] = { 
        gradientColorStart.red, gradientColorStart.green, gradientColorStart.blue, 0.9,
        gradientColorEnd.red, gradientColorEnd.green, gradientColorEnd.blue, 0.9
    };
    
    CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, colors, NULL, 2);
    CGColorSpaceRelease(baseSpace), baseSpace = NULL;
    
    // clip to rounded rect path
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(rect, 1, 1) byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(2, 2)];
    [path addClip];
    
    // draw the gradient in our clipped area
    CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
    
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGGradientRelease(gradient), gradient = NULL; 
    
    CGContextRestoreGState(context);

}

+(NSString*)abbreviationForComment:(NSUInteger)index
{
    // go A, B, C, ..., AA, BB, ...
    static NSString *alphabet = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    
    int i = index % 26; // eg. 43%25=18 -> S
    int m = floorf(index / 26.f); // eg. ceil(43/25.f)=2
    
    unichar c = [alphabet characterAtIndex:i];
    NSString *word = [NSString stringWithFormat:@"%C",c];
    for (int j=0; j<m; ++j) {
        word = [word stringByAppendingFormat:@"%C",c];  
    }

    return word;
}

+(NSArray*)measurementsForChart:(Chart*)chart
{
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"metric=%@ && value!=nil", chart.metric];
    return [DataManager arrayForEntity:NSStringFromClass([Measurement class])
                                   sortDescriptorsOrNil:[NSArray arrayWithObject:sortDescriptor]
                                         predicateOrNil:predicate];
}

- (void)dealloc
{
    [chartStartDate_ release];
    [super dealloc];
}


@end
