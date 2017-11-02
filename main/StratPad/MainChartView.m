//
//  ChartView.m
//  StratPad
//
//  Created by Julian Wood on 12-03-15.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "MainChartView.h"
#import "Measurement.h"
#import "Metric.h"
#import "NSDate-StratPad.h"
#import "NSCalendar+Expanded.h"
#import "UIColor-Expanded.h"
#import "GridSupport.h"
#import "MBDrawableReportHeader.h"
#import "SkinManager.h"
#import "LinearRegression.h"
#import "DataManager.h"
#import <QuartzCore/QuartzCore.h>
#import "CommentLabel.h"
#import "Chart.h"
#import "CommentBox.h"
#import "MBDrawableLabel.h"
#import "Drawable.h"
#import "ColorWell.h"

#define yAxisNameSpacer     7.f
#define yAxisLabelSpacer    5.f
#define yAxisTitleFontSize        15.f

@interface MainChartView (Private)
- (void)initChartParams:(Chart*)chart;
-(void)drawTargetForChart:(Chart*)chart;
-(void)drawGrid;
-(void)drawTrendLineForChart:(Chart*)chart;
-(void)drawOverlay;
-(void)drawOverlayAxisLabelsForChart:(Chart*)chart;
-(void)setChartStartDateAndDuration:(Chart*)chart;
@end

@implementation MainChartView

@synthesize chart = chart_;
@synthesize padding = padding_;
@synthesize readyForPrint;

- (id)initWithFrame:(CGRect)frame chart:(Chart*)chart
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setRect:frame];
        chart_ = [chart retain];
        reportHelper_ = [[ReportHelper alloc] init];
        skinMan_ = [SkinManager sharedManager];
        commentBoxen_ = [[NSMutableArray arrayWithCapacity:20] retain];
        scale_ = 1.0;

        // left and right insets: 15px y-axis label + 5px margin + 70px tick label + 5px margin
        padding_ = UIEdgeInsetsMake(50, 95, 50, 95);
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        reportHelper_ = [[ReportHelper alloc] init];
        skinMan_ = [SkinManager sharedManager];
        UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(expandComment:)];
        [self addGestureRecognizer:gestureRecognizer];
        [gestureRecognizer release];
        commentBoxen_ = [[NSMutableArray arrayWithCapacity:20] retain];
        scale_ = 1.0;

        // left and right insets: 15px y-axis label + 5px margin + 70px tick label + 5px margin
        padding_ = UIEdgeInsetsMake(50, 95, 50, 95);
    }
    return self;
}

- (void)dealloc
{
    [chart_ release];
    [reportHelper_ release];
    [commentBoxen_ release];
    [super dealloc];
}

-(void)setChartStartDateAndDuration:(Chart*)chart
{
    NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    
    // chart start and end
    NSDate *chartStartDate = [chart startDate];
    NSUInteger chartDuration = [chart durationInMonths];
    [offsetComponents setMonth:chartDuration];
    NSDate *chartEndDate = [gregorian dateByAddingComponents:offsetComponents
                                                      toDate:chartStartDate options:0];
    
    // overlay start and end
    Chart *overlay = [Chart chartWithUUID:chart.overlay];
    NSDate *overlayStartDate = [overlay startDate];
    NSUInteger overlayDuration = [overlay durationInMonths];
    [offsetComponents setMonth:overlayDuration];
    NSDate *overlayEndDate = [gregorian dateByAddingComponents:offsetComponents
                                                        toDate:overlayStartDate options:0];
    [offsetComponents release];
    
    // overall start and end
    NSDate *combinedStartDate = [chartStartDate isBefore:overlayStartDate] ? chartStartDate : overlayStartDate;
    NSDate *combinedEndDate = [chartEndDate isAfter:overlayEndDate] ? chartEndDate : overlayEndDate;
    chartStartDate_ = [combinedStartDate retain];
    
    // duration
    NSDateComponents *components = [gregorian components:NSMonthCalendarUnit
                                                fromDate:combinedStartDate
                                                  toDate:combinedEndDate options:0];
    chartDuration_ = [Chart gridDurationForChartDuration:[components month]];
    
}

- (void)initChartParams:(Chart*)chart
{
    // for the overlay, we need to keep the x-axis the same as the primary
    
    // if we are a primary, check to see if we're drawing an overlay
    //   if so, then we need to get the earliest start date and the latest chartDuration
    if (chart.zLayer == primaryChartLayer) {
        
        if ([chart shouldDrawOverlay]) {
            [self setChartStartDateAndDuration:chart];
        } else {
            chartStartDate_ = [[chart startDate] retain];
            chartDuration_ = [Chart gridDurationForChartDuration:[chart durationInMonths]];        
        }
                
    } else {
        // must be an overlay, which we must have been looking to draw
        // so find the primary and do it's date calculation from there
        // note that a primary chart can only ever have a single, unique overlay (and vice-versa)
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"overlay=%@", chart.uuid];
        Chart *primaryChart = (Chart*)[DataManager objectForEntity:NSStringFromClass([Chart class]) 
                                              sortDescriptorsOrNil:nil 
                                                    predicateOrNil:predicate];
        [self setChartStartDateAndDuration:primaryChart];
        
    }
           
    NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setMonth:chartDuration_];
    NSDate *chartEndDate = [gregorian dateByAddingComponents:offsetComponents
                                                    toDate:chartStartDate_ options:0];
    [offsetComponents release];
        
    // figure out suitable y-max - this is a value, not pixels
    yMax_ = [[chart yAxisMaxFromChartOrMeasurement] floatValue];
    
    // figure out the x-axis scale
    NSDateComponents *components = [gregorian components:NSDayCalendarUnit
                                                fromDate:chartStartDate_
                                                  toDate:chartEndDate options:0];
    xMax_ = [components day];
}

- (void)drawRect:(CGRect)rect
{
    TLog(@"chart: %@", chart_);
    TLog(@"measurements: %@", chart_.metric.measurements);
    
    mediaType_ = MediaTypeScreen;
    contentRect_ = rect;
        
    [self drawAll];
}

- (void)drawAll
{
    // mediaType_ and contentRect_ need to be set at this point
    
    // figure out params    
    [self initChartParams:chart_];  
    
    // inset the rect for the actual grid
    gridRect_ = CGRectMake(contentRect_.origin.x + padding_.left, 
                           contentRect_.origin.y + padding_.top, 
                           contentRect_.size.width-padding_.left-padding_.right, 
                           contentRect_.size.height-padding_.top-padding_.bottom);
    
    
    // get rid of any Comment Labels
    for (int i=[[self subviews] count]-1; i>=0; i--) {
        [[[self subviews] objectAtIndex:i] removeFromSuperview];
    }
    
    // lines, labels
    [self drawGrid];
    
    // plot the chart in the grid
    if (chart_.chartType.intValue == ChartTypeBar) {
        [self drawBarChart:gridRect_ chart:chart_];
    } 
    else if (chart_.chartType.intValue == ChartTypeArea) {
        [self drawAreaChart:gridRect_ chart:chart_];        
    } 
    else if (chart_.chartType.intValue == ChartTypeLine) {
        [self drawLineChart:gridRect_ chart:chart_];
    } else {
        ELog(@"Unknown chart type: %i", chart_.chartType.intValue);
    }
    
    [self drawTargetForChart:chart_];
    [self drawTrendLineForChart:chart_];
    
    [self drawOverlay];
    [self cleanup];
    
}

-(void)cleanup
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    CGFloat gh = gridRect_.size.height;
    CGFloat gw = gridRect_.size.width;

    // want to make sure the axes are visible, in case something drew over them, either fully or partially (ie bottom of bar charts)

    // line color and width
    CGContextSetShouldAntialias(context, NO);
    CGContextSetStrokeColorWithColor(context, [[skinMan_ colorForProperty:kSkinSection4GridColor forMediaType:mediaType_] CGColor]);
    CGContextSetLineWidth(context, 1.0*scale_);
    
    // re-draw x-axis
    drawHorizontalLine(context, CGPointMake(gridRect_.origin.x, CGRectGetMaxY(gridRect_)), gw, 0);

    // re-draw y-axis
    // protect our comment bubbles
    if (![chart_ shouldDrawOverlay]) {
        drawVerticalLine(context, CGPointMake(gridRect_.origin.x, gridRect_.origin.y), gh, 0);        
    }

    CGContextStrokePath(context);

    CGContextRestoreGState(context);
    
}

-(void)drawOverlay
{
    if ([chart_ shouldDrawOverlay]) {
        
        // init the overlay chart
        Chart *overlayChart = [Chart chartWithUUID:chart_.overlay];
        [self initChartParams:overlayChart];
        
        // plot
        if (overlayChart.chartType.intValue == ChartTypeBar) {
            [self drawBarChart:gridRect_ chart:overlayChart];
        } 
        else if (overlayChart.chartType.intValue == ChartTypeArea) {
            [self drawAreaChart:gridRect_ chart:overlayChart];        
        } 
        else if (overlayChart.chartType.intValue == ChartTypeLine) {
            [self drawLineChart:gridRect_ chart:overlayChart];
        } 
        else if (overlayChart.chartType.intValue == ChartTypeComments) {
            [self drawCommentsChart:gridRect_ chart:overlayChart];
        } 
        else {
            ELog(@"Unknown chart type: %i", chart_.chartType.intValue);
        }      
        
        // target, trend and labels for the overlay
        [self drawTargetForChart:overlayChart];
        [self drawTrendLineForChart:overlayChart];
        [self drawOverlayAxisLabelsForChart:overlayChart];
    }
}

-(void)drawOverlayAxisLabelsForChart:(Chart*)chart
{
    // no y-axis labels for comments
    if (chart.chartType.intValue == ChartTypeComments) return;
    
    // draw labels for new y-axis
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextSetShouldAntialias(context, YES);
    CGContextSetFillColorWithColor(context, [[skinMan_ colorForProperty:kSkinSection4FontColor forMediaType:mediaType_] CGColor]);
    
    CGFloat gh = gridRect_.size.height;
    CGFloat gw = gridRect_.size.width;
    CGFloat interval = gh/4;
    CGFloat maxTickLabelWidth = 0;
    for (int i=0; i<4; ++i) {
        CGFloat val = yMax_-i*yMax_/4;
        NSString *tickLabel;
        if (val-floorf(val) == 0) {
            tickLabel = [NSString stringWithFormat:@"%i", (int)val];
        } else {
            tickLabel = [NSString stringWithFormat:@"%.1f", val];
        }
        CGSize tickLabelSize = [tickLabel sizeWithFont:[UIFont systemFontOfSize:14*scale_] 
                                     constrainedToSize:CGSizeMake(70, 14*scale_)
                                         lineBreakMode:UILineBreakModeClip];
        maxTickLabelWidth = MAX(tickLabelSize.width, maxTickLabelWidth);
        [tickLabel drawInRect:CGRectMake(gridRect_.origin.x+gw+5, gridRect_.origin.y-10*scale_+interval*i, 70, 14*scale_) 
                 withFont:[UIFont systemFontOfSize:14*scale_]
            lineBreakMode:UILineBreakModeClip
                alignment:UITextAlignmentLeft];
    }
      
    // mostly so that we don't draw when doing the stratcard, but could be for other small size situations
    if (scale_ == 1.f) {

        // draw the y-axis title
        CGContextSaveGState(context);
                
        // text color
        CGContextSetFillColorWithColor(context, [[skinMan_ colorForProperty:kSkinSection4FontColor forMediaType:mediaType_] CGColor]);

        // push it all the way to the right
        CGContextTranslateCTM(context, self.bounds.size.width, 0);
        
        // rotates cw about the origin
        CGContextRotateCTM(context, degreesToRadians(90));

        // origin is now in the top,right with x increasing down the page, y increasing left across the page

        // figure out the area beside the gridrect, stretching to the edge of the contentRect
        // since tick labels can be up to 70px wide + 5px margin, and y-axis label is 15px wide + 5px margin, then we can add some padding to x to get it closer to the tick labels if we are less than 70px
        CGFloat originX = gridRect_.origin.y;
        CGFloat originY = self.bounds.size.width - contentRect_.size.width - contentRect_.origin.x;        
        CGRect yLabelArea = CGRectMake(originX, originY, gridRect_.size.height, padding_.right);

        // we're interested in the width, so we can center the label
        CGSize yAxisTitleSize = [chart.metric.summary sizeWithFont:[UIFont systemFontOfSize:15.f]
                                                  constrainedToSize:CGSizeMake(yLabelArea.size.width, 20.f)
                                                      lineBreakMode:UILineBreakModeTailTruncation];
        
        // colorwell is 15 + 5 spacing
        CGFloat x = yLabelArea.origin.x + (yLabelArea.size.width-(yAxisTitleSize.width+20))/2 + 20;
        CGFloat y = yLabelArea.origin.y + padding_.right - (yAxisLabelSpacer + maxTickLabelWidth + yAxisNameSpacer + yAxisTitleSize.height);

        [chart.metric.summary drawAtPoint:CGPointMake(x, y) 
                                  forWidth:yAxisTitleSize.width
                                  withFont:[UIFont systemFontOfSize:15]
                             lineBreakMode:UILineBreakModeTailTruncation];
        
        // draw a colorwell
        ColorWell *colorWell = [[ColorWell alloc] initWithRect:CGRectMake(x-20, y+2, 15, 15) color:[chart colorForGradientStart]];
        [colorWell draw];
        [colorWell release];
        
        // end of y-axis title
        CGContextRestoreGState(context); 
    }    
    
    CGContextRestoreGState(context);    
}

-(void)drawGrid
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    CGFloat gh = gridRect_.size.height;
    CGFloat gw = gridRect_.size.width;

    // line color and width
    CGContextSetShouldAntialias(context, NO);
    CGContextSetStrokeColorWithColor(context, [[skinMan_ colorForProperty:kSkinSection4GridColor forMediaType:mediaType_] CGColor]);
    CGContextSetLineWidth(context, 1.0*scale_);
    
    // draw horizontal lines
    CGFloat interval = gh/4;
    for (int i=0; i<5; ++i) {
        drawHorizontalLine(context, CGPointMake(gridRect_.origin.x, gridRect_.origin.y+interval*i), gw, 0);
    }
    CGContextStrokePath(context);
    
    // horizontal dotted lines
    CGContextSaveGState(context);    
    CGFloat dashPattern[1] = { 1 };
    size_t dashCount = 1;	
    CGContextSetLineDash(context, 0, dashPattern, dashCount);
    interval = gh/4;
    for (int i=0; i<4; ++i) {
        drawHorizontalLine(context, CGPointMake(gridRect_.origin.x, gridRect_.origin.y+interval*i+interval/2), gw, 0);
    }
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
    
    // draw vertical lines
    uint gridDuration = [Chart gridDurationForChartDuration:chartDuration_];
    uint monthsPerInterval = [Chart intervalForDuration:gridDuration];
    int numColumns = gridDuration/monthsPerInterval;
    interval = gw/numColumns;
    for (int i=0; i<=numColumns; ++i) {
        drawVerticalLine(context, CGPointMake(gridRect_.origin.x+interval*i, gridRect_.origin.y), gh, 0);
    }
    CGContextStrokePath(context);    
        
    // draw text
    CGContextSetShouldAntialias(context, YES);
    CGContextSetFillColorWithColor(context, [[skinMan_ colorForProperty:kSkinSection4FontColor forMediaType:mediaType_] CGColor]);
    
    if (scale_ == 1.f) {
        [chart_.title drawInRect:CGRectMake(contentRect_.origin.x+20, contentRect_.origin.y+10, contentRect_.size.width-40, 25)
                        withFont:[UIFont boldSystemFontOfSize:20] 
                   lineBreakMode:UILineBreakModeTailTruncation
                       alignment:UITextAlignmentCenter];        
    }
    
    // y-axis
    CGFloat maxTickLabelWidth = 0;
    CGFloat yAxisNameSpacerScaled = yAxisNameSpacer*scale_;
    CGFloat yAxisLabelSpacerScaled = yAxisLabelSpacer*scale_;
    CGFloat yAxisTitleWidthScaled = yAxisTitleFontSize*scale_;
    interval = gh/4;
    
    for (int i=0; i<4; ++i) {
        CGFloat val = yMax_-i*yMax_/4;

        // don't draw any tick labels if no values
        if (val == 0) {
            continue;
        }
        
        NSString *tickLabel;
        if (val-floorf(val) == 0) {
            tickLabel = [NSString stringWithFormat:@"%i", (int)val];
        } else {
            tickLabel = [NSString stringWithFormat:@"%.1f", val];
        }
        CGSize tickLabelSize = [tickLabel sizeWithFont:[UIFont systemFontOfSize:14*scale_] 
                                     constrainedToSize:CGSizeMake(padding_.left-yAxisTitleWidthScaled-yAxisNameSpacerScaled-yAxisLabelSpacerScaled, 14*scale_)
                                         lineBreakMode:UILineBreakModeClip];
        maxTickLabelWidth = MAX(tickLabelSize.width, maxTickLabelWidth);
        [tickLabel drawInRect:CGRectMake(contentRect_.origin.x+yAxisTitleWidthScaled+yAxisNameSpacerScaled, 
                                         gridRect_.origin.y-10*scale_+interval*i, 
                                         padding_.left-yAxisTitleWidthScaled-yAxisNameSpacerScaled-yAxisLabelSpacerScaled, 
                                         14*scale_) 
                 withFont:[UIFont systemFontOfSize:14*scale_]
            lineBreakMode:UILineBreakModeClip
                alignment:UITextAlignmentRight];
    }

    //--------------------------
    // draw the y-axis title
    
    if (scale_ == 1.f) {

        CGContextSaveGState(context);
        
        CGContextSetFillColorWithColor(context, [[skinMan_ colorForProperty:kSkinSection4FontColor forMediaType:mediaType_] CGColor]);
        
        // move origin to the bottom left corner (NB. the order of CTM modifications matters)
        CGContextTranslateCTM(context, 0, self.bounds.size.height);

        // rotates ccw about the origin (bottom,left)
        CGContextRotateCTM(context, degreesToRadians(-90));
        
        // if contentRect_ is not the same as our context rect, we need to find out where it's origin has been moved
        CGFloat originX = self.bounds.size.height - contentRect_.size.height - contentRect_.origin.y;
        CGFloat originY = contentRect_.origin.x;
                
        // we're interested in the width, so we can center the label
        CGSize yAxisTitleSize = [chart_.metric.summary sizeWithFont:[UIFont systemFontOfSize:15.f*scale_]
                                                  constrainedToSize:CGSizeMake(gridRect_.size.height, 20.f*scale_)
                                                      lineBreakMode:UILineBreakModeTailTruncation];
            
        // remember that our context is now rotated -90, with the origin in the bottom left
        CGFloat xOffset = MAX(0, padding_.left-yAxisTitleWidthScaled-yAxisNameSpacerScaled-maxTickLabelWidth-yAxisLabelSpacerScaled);    

        // since tick labels can be up to 70px wide + 5px margin, and y-axis title is 15px wide + 5px margin, then we can add some padding to x to get it closer to the tick labels if we are less than 70px
        // colorwell is 15+5=20
        CGFloat x = originX + padding_.bottom + (gridRect_.size.height-(yAxisTitleSize.width+20))/2 + 20;
        CGFloat y = originY + xOffset;
        [chart_.metric.summary drawAtPoint:CGPointMake(x, y) 
                                  forWidth:gridRect_.size.height
                                  withFont:[UIFont systemFontOfSize:15*scale_]
                             lineBreakMode:UILineBreakModeTailTruncation];
        
        // draw a colorwell
        ColorWell *colorWell = [[ColorWell alloc] initWithRect:CGRectMake(x-20, y+2, 15, 15) color:[chart_ colorForGradientStart]];
        [colorWell draw];
        [colorWell release];


        CGContextRestoreGState(context); 
    }

    // end of y-axis title
    // ------------------------
    
    // determine the labels for the x-axis from the start-date
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];
    interval = gw/numColumns;
    for (int i=0; i<numColumns; i++) {
        
        // add a month to date
        [offsetComponents setMonth:i*monthsPerInterval];
        NSDate *lblDate = [gregorian dateByAddingComponents:offsetComponents
                                                     toDate:chartStartDate_
                                                    options:0
                           ];
        
        // draw the month abbrev
        [[lblDate monthNameChar] drawInRect:CGRectMake(gridRect_.origin.x+i*interval, CGRectGetMaxY(gridRect_)+5*scale_, interval, 14*scale_) 
                                    withFont:[UIFont systemFontOfSize:14*scale_]
                               lineBreakMode:UILineBreakModeClip
                                   alignment:UITextAlignmentCenter];
        
        // draw the year under all January's
        NSDateComponents *monthYearComponent = [gregorian components:(NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:lblDate];
        if ([monthYearComponent month] == 1) {
            NSString *year = [NSString stringWithFormat:@"%i", [monthYearComponent year]];
            [year drawInRect:CGRectMake(gridRect_.origin.x+i*interval+8*scale_, CGRectGetMaxY(gridRect_)+25*scale_, 50*scale_, 14*scale_) 
                    withFont:[UIFont systemFontOfSize:14*scale_]
               lineBreakMode:UILineBreakModeClip
                   alignment:UITextAlignmentLeft];            
        }
        
    }
    [offsetComponents release];
    
    CGContextRestoreGState(context);
}

-(void)drawTargetForChart:(Chart*)chart
{
    if ([chart.showTarget boolValue]) {
        
        if (chart.metric.targetValue && chart.metric.targetDate) {
            
            NSNumber *target = [chart.metric parseNumberFromTargetValue];
            
            NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];    
            NSDateComponents *components = [gregorian components:NSDayCalendarUnit
                                                        fromDate:chartStartDate_
                                                          toDate:chart.metric.targetDate options:0];
            NSInteger dayOfYear = [components day];
            
            // draw
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSaveGState(context);
            
            CGFloat gh = gridRect_.size.height;
            CGFloat gw = gridRect_.size.width;
            
            CGFloat x = gridRect_.origin.x+(CGFloat)dayOfYear/xMax_*gw;
            NSInteger val = [target integerValue];
            CGFloat y = gridRect_.origin.y+gh-gh*val/yMax_;
            
            CGContextSetShouldAntialias(context, YES);
            CGContextSetStrokeColorWithColor(context, [[chart colorForGradientStart] CGColor]);
            CGContextSetFillColorWithColor(context, [[chart colorForGradientStart] CGColor]);
            CGContextSetLineWidth(context, 1.0*scale_);
            
            CGFloat dashPattern[1] = { 2 };
            size_t dashCount = 1;	
            CGContextSetLineDash(context, 0, dashPattern, dashCount);
            
            drawHorizontalLine(context, CGPointMake(gridRect_.origin.x, y), gw, 0);
            drawVerticalLine(context, CGPointMake(x, gridRect_.origin.y), gh, 0);
            CGContextStrokePath(context);
            
            CGFloat diameter = (mediaType_ == MediaTypeScreen) ? 20*scale_ : 15*scale_;
            CGContextAddEllipseInRect(context, CGRectMake(x-diameter/2, y-diameter/2, diameter, diameter));
            CGContextFillPath(context);
            
            CGContextRestoreGState(context);
            
        } else {
            WLog(@"Not showing target despite being asked. Show target: %@, targetValue: %@, targetDate: %@", chart.showTarget, chart.metric.targetValue, chart.metric.targetDate);
        }
    }

}

-(void)drawTrendLineForChart:(Chart*)chart
{
    if ([chart.showTrend boolValue]) {
        CGFloat gw = gridRect_.size.width;
        CGFloat gh = gridRect_.size.height;
                                
        LinearRegression *lr = [[LinearRegression alloc] initWithChart:chart
                                                        chartStartDate:chartStartDate_];
        CGFloat day, val;
        
        // for x = 0;
        day = 0.f;
        val = [lr yVal:day];
        if (val < 0) {
            // we need to move over to the x-intercept so we don't draw below the x-axis
            val = yMax_/gh; // instead of 0, move it just above 0 to 1px so that we don't get bleed over into the negative x-axis
            day = [lr xVal:val];
        }
        CGPoint p1 = [self gridCoordinateForDay:day andValue:val];

        // for x = xMax
        // don't draw all the way to the end - let the arrow do that
        CGFloat trim = 5.f/gw*xMax_;
        day = xMax_-trim;
        val = [lr yVal:day];
        CGPoint p2 = [self gridCoordinateForDay:day andValue:val];
        
        if (p2.y < gridRect_.origin.y) {
            // we have a problem - we are drawing above the bounds of the chart
            // so figure out the x value when y == yMax_
            day = [lr xVal:yMax_];
            val = [lr yVal:day];
            p2 = [self gridCoordinateForDay:day andValue:val];

        } else if (p2.y > gridRect_.origin.y + gh) {
            // drawing below the bounds of the chart
            // so figure out the x value when y == 0
            day = [lr xVal:0];
            val = [lr yVal:day];
            p2 = [self gridCoordinateForDay:day andValue:val];
        }
        
        // now plot trend line
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSaveGState(context);
                
        CGContextSetShouldAntialias(context, YES);
        CGContextSetStrokeColorWithColor(context, [[chart colorForGradientStart] CGColor]);
        CGContextSetLineWidth(context, 2.0*scale_);
        
        CGFloat dashPattern[2] = { 5, 3 };
        size_t dashCount = 2;	
        CGContextSetLineDash(context, 0, dashPattern, dashCount);
        
        CGContextMoveToPoint(context, p1.x, p1.y);
        CGContextAddLineToPoint(context, p2.x, p2.y);            

        CGContextStrokePath(context);
        
        // now make a triangle at the end
        CGContextSetLineDash(context, 0, NULL, 0);
        CGContextSetLineWidth(context, 1.0);
        CGContextSetFillColorWithColor(context, [[chart colorForGradientStart] CGColor]);
        
        // redo p2 without trim for use in calculating triangle
        day = xMax_;
        val = [lr yVal:day];
        p2 = [self gridCoordinateForDay:day andValue:val];
        
        if (p2.y < gridRect_.origin.y) {
            day = [lr xVal:yMax_];
            val = [lr yVal:day];
            p2 = [self gridCoordinateForDay:day andValue:val];            
        } else if (p2.y > gridRect_.origin.y + gh) {
            day = [lr xVal:0];
            val = [lr yVal:day];
            p2 = [self gridCoordinateForDay:day andValue:val];
        }
        
        // calculate points for arrow (triangle)
        CGFloat arrowLength = 15*scale_;
        static CGFloat arrowAngle = degreesToRadians(27);
        CGFloat theta = atanf((p2.y-p1.y)/(p2.x-p1.x)) * -1;
        CGFloat gamma = degreesToRadians(90)-theta-arrowAngle;
        CGPoint p3 = CGPointMake(p2.x-arrowLength*sinf(gamma), p2.y+arrowLength*cosf(gamma));
        CGPoint p4 = CGPointMake(p2.x-arrowLength*cos(theta-arrowAngle), p2.y+arrowLength*sin(theta-arrowAngle));

        CGFloat shaft = arrowLength*cosf(arrowAngle)*0.8;
        CGPoint p5 = CGPointMake(p2.x-shaft*cosf(theta), p2.y+shaft*sinf(theta));
        
        TLog(@"theta: %f, gamma: %f", radiansToDegrees(theta), radiansToDegrees(gamma));
        TLog(@"p1: %@, p2: %@, p3: %@, p4: %@, p5: %@", NSStringFromCGPoint(p1), NSStringFromCGPoint(p2), NSStringFromCGPoint(p3), NSStringFromCGPoint(p4), NSStringFromCGPoint(p5));
        
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
                
        CGContextRestoreGState(context);
        
        [lr release];
    }
    
}

#pragma mark - Utility

-(CGPoint)gridCoordinateForDay:(CGFloat)dayOfYear andValue:(CGFloat)value
{
    CGFloat gh = gridRect_.size.height;
    CGFloat gw = gridRect_.size.width;
    CGFloat x = gridRect_.origin.x+dayOfYear/xMax_*gw;
    CGFloat y = gridRect_.origin.y+gh-gh*value/yMax_;    
    return CGPointMake(x, y);
}


#pragma mark - Comments

- (void)expandComment:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint point = [gestureRecognizer locationInView:self];
    
    for (CommentBox *commentBox in commentBoxen_) {
        BOOL opened = NO;
        if (CGRectContainsPoint(commentBox.hitRect, point) && !commentBox.commentLabel.isShowing) {

            // display a larger box with the comment            
            CommentLabel *commentLabel = [[CommentLabel alloc] initWithChartRect:self.bounds
                                                                  commentBoxRect:commentBox.hitRect
                                                                         andText:commentBox.comment
                                                              gradientStartColor:[commentBox.chart colorForGradientStart]
                                                                gradientEndColor:[commentBox.chart colorForGradientEnd]];
            
            commentBox.commentLabel = commentLabel;
            [self addSubview:commentLabel];
            [commentLabel showComment];
            [commentLabel release];
            
            opened = YES;
        }
        
        // close any others
        if (commentBox.commentLabel.isShowing && !opened) {
            [commentBox.commentLabel dismissComment];
        }
    }
}

-(void)closeAllComments
{
    for (CommentBox *commentBox in commentBoxen_) {
        [commentBox.commentLabel dismissComment];
    }
}

#pragma mark - Drawable

- (void)draw
{    
    // printing main charts or report card charts comes through here (on screen uses drawRect)
    
    mediaType_ = MediaTypePrint;
    contentRect_ = self.frame;
    
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextSetStrokeColorWithColor(context, [[[UIColor blueColor] colorWithAlphaComponent:0.05] CGColor]);
//    CGContextStrokeRect(context, contentRect_);
        
    [self drawAll];    
}

// we're not using this at all
- (void)setRect:(CGRect)rect
{
    self.frame = rect;
}
// we're not using this at all
- (CGRect)rect
{
    return self.frame;
}

@end
