//
//  MiniChartView.m
//  StratPad
//
//  Created by Julian Wood on 12-03-14.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "MiniChartView.h"
#import "UIColor-Expanded.h"
#import "Measurement.h"
#import "NSCalendar+Expanded.h"
#import "NSDate-StratPad.h"
#import "GridSupport.h"
#import "Metric.h"
#import "StratFileManager.h"
#import "DataManager.h"

@interface MiniChartView (Private)
-(void)initChartParams;
-(void)drawGridUnderlay:(CGRect)rect;
-(void)drawGridOverlay:(CGRect)rect;
@end

@implementation MiniChartView

@synthesize chart=chart_;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}



- (void)initChartParams
{
    chartStartDate_ = [[MiniChartView startDate] retain];
    chartDuration_ = 24; // always the last 2 years
    
    NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setYear:2];
    NSDate *chartEndDate = [gregorian dateByAddingComponents:offsetComponents
                                                    toDate:chartStartDate_ options:0];
    [offsetComponents release];
    
    // figure out the y-axis scale
    CGFloat maxVal = 0;
    for (Measurement *measurement in chart_.metric.measurements) {
        maxVal = MAX(maxVal, measurement.value.floatValue);
    }
    
    // figure out suitable y-max - this is a value, not pixels
    yMax_ = maxVal;
    
    // figure out the x-axis scale
    NSDateComponents *components = [gregorian components:NSDayCalendarUnit
                                                fromDate:chartStartDate_
                                                  toDate:chartEndDate options:0];
    xMax_ = [components day];
    
}

-(void)drawGridUnderlay:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);    
    
    // lines should be precise
    CGContextSetShouldAntialias(context, NO);
    
    // context params
    CGContextSetStrokeColorWithColor(context, [[UIColor colorWithHexString:@"4c4c4c"] CGColor]);
    CGContextSetLineWidth(context, 1.0);
    
    // draw lines
    CGFloat interval = 65.f/4;
    for (int i=0; i<5; ++i) {
        drawHorizontalLine(context, CGPointMake(0, interval*i), CGRectGetMaxX(rect), i<5?0.5:-0.5);
    }
    CGContextStrokePath(context);
    
    // restore
    CGContextRestoreGState(context);
}

-(void)drawGridOverlay:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context); 
    
    CGFloat w = rect.size.width;

    // draw ticks on x-axis
    CGContextSetStrokeColorWithColor(context, [[UIColor colorWithHexString:@"4c4c4c"] CGColor]);
    CGContextSetLineWidth(context, 1.0);
    
    // redraw x-axis
    drawHorizontalLine(context, CGPointMake(0, CGRectGetMaxY(rect)), CGRectGetMaxX(rect), -0.5);
    
    // ticks
    static CGFloat tickHeight = 3;
    for (int i=0, ct=24; i<ct; ++i) {
        drawVerticalLine(context, CGPointMake(i*w/24, CGRectGetMaxY(rect)-tickHeight), tickHeight, 0.5);
    }
    drawVerticalLine(context, CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect)-tickHeight), tickHeight, -0.5);
    
    CGContextStrokePath(context);
    
    // restore
    CGContextRestoreGState(context);
}


- (void)drawRect:(CGRect)rect
{    
    [self initChartParams];
    [self drawGridUnderlay:rect];
    
    // shift the rect so that the plot doesn't reach the top
    CGRect gridRect = CGRectMake(rect.origin.x, rect.origin.y+5, rect.size.width, rect.size.height-5);
    
    // plot the chart in the grid
    if (chart_.chartType.intValue == ChartTypeBar) {
        [self drawBarChart:gridRect chart:chart_];
    } 
    else if (chart_.chartType.intValue == ChartTypeArea) {
        [self drawAreaChart:gridRect chart:chart_];        
    } 
    else if (chart_.chartType.intValue == ChartTypeLine) {
        [self drawLineChart:gridRect chart:chart_];
    } else {
        ELog(@"Unknown chart type: %i", chart_.chartType.intValue);
    }
    
    [self drawGridOverlay:rect];
}

+ (NSDate*)startDate
{
    // need to grab the latest date for a measurement which belongs to this stratfile
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"metric.objective.theme.stratFile=%@", [[StratFileManager sharedManager] currentStratFile]];
    Measurement *lastMeasurement = (Measurement*)[DataManager objectForEntity:NSStringFromClass([Measurement class])
                                                         sortDescriptorsOrNil:[NSArray arrayWithObject:sortDescriptor]
                                                               predicateOrNil:predicate];
    NSDate *endDate;
    if (!lastMeasurement) {
        // use 2 years preceding now - of course there will be no actual plots
        endDate = [NSDate dateSetToFirstDayOfNextMonthForDate:[NSDate date]];
    } else {
        // we want to include the current month in the chart
        endDate = [NSDate dateSetToFirstDayOfNextMonthForDate:lastMeasurement.date];
    }
    
    NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setYear:-2];
    NSDate *startDate = [gregorian dateByAddingComponents:offsetComponents
                                             toDate:endDate options:0];
    [offsetComponents release];
    return startDate;
}

@end
