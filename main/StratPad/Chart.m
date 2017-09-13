//
//  Chart.m
//  StratPad
//
//  Created by Julian Wood on 12-02-27.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "Chart.h"
#import "Metric.h"
#import "Objective.h"
#import "ObjectiveType.h"
#import "Theme.h"
#import "DataManager.h"
#import "StratFile.h"
#import "UIColor-Expanded.m"
#import "NSDate-StratPad.h"
#import "NSCalendar+Expanded.h"
#import "DataManager.h"
#import "Measurement.h"

static NSArray *colorSchemes;

@implementation Chart

@dynamic title;
@dynamic zLayer;
@dynamic chartType;
@dynamic showTrend;
@dynamic colorScheme;
@dynamic showTarget;
@dynamic metric;
@dynamic order;
@dynamic overlay;
@dynamic uuid;
@dynamic yAxisMax;

@dynamic yammerPublishedReport;

+(void)initialize
{
    if (!colorSchemes) {
        colorSchemes = [[NSArray arrayWithObjects:
                         [NSDictionary dictionaryWithObjectsAndKeys:@"C00023", @"color1", @"380001", @"color2", @"Red", @"name", nil],
                         [NSDictionary dictionaryWithObjectsAndKeys:@"C4691E", @"color1", @"482403", @"color2", @"Orange", @"name", nil],
                         [NSDictionary dictionaryWithObjectsAndKeys:@"EED635", @"color1", @"473F07", @"color2", @"Yellow", @"name", nil],
                         [NSDictionary dictionaryWithObjectsAndKeys:@"7FCF51", @"color1", @"204F07", @"color2", @"Green", @"name", nil],
                         [NSDictionary dictionaryWithObjectsAndKeys:@"1F5092", @"color1", @"051A2F", @"color2", @"Royal", @"name", nil],
                         [NSDictionary dictionaryWithObjectsAndKeys:@"3B636C", @"color1", @"02151E", @"color2", @"Turquoise", @"name", nil],
                         [NSDictionary dictionaryWithObjectsAndKeys:@"A1A9AD", @"color1", @"1E2C33", @"color2", @"Grey", @"name", nil],
                         [NSDictionary dictionaryWithObjectsAndKeys:@"5BB0C6", @"color1", @"1D2C33", @"color2", @"Sky", @"name", nil],
                         nil] retain];
    }
}

- (NSNumber*)yAxisMaxFromChartOrMeasurement
{
    if (self.yAxisMax != nil) {
        return self.yAxisMax; 
    } else {        
        CGFloat yMax = [self yAxisMaxFromMeasurements];
        yMax = [Chart getYMax:yMax]; 
        return [NSNumber numberWithFloat:yMax];
    }
}

- (CGFloat)yAxisMaxFromMeasurements
{
    CGFloat yMax = 0.f;
    
    // grab measurement with greatest value
    Measurement *m1 = (Measurement*)[DataManager objectForEntity:NSStringFromClass([Measurement class]) 
                                            sortDescriptorsOrNil:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"value" ascending:NO]] 
                                                  predicateOrNil:[NSPredicate predicateWithFormat:@"metric = %@", self.metric]];    
    if (m1) {
        yMax = m1.value.floatValue;
    }
    
    // have to include the target value in yMax_
    if ([self.metric isNumeric]) {
        NSNumber *targetVal = [self.metric parseNumberFromTargetValue];
        yMax = MAX(yMax, targetVal.floatValue);
    }
        
    return yMax;
}

+ (NSArray*)chartsSortedByOrderForStratFile:(StratFile*)stratFile
{
    // this is the same order as charts displayed in StratBoard
    NSArray *sortDescriptors = [NSArray arrayWithObjects:
                                [NSSortDescriptor sortDescriptorWithKey:@"metric.objective.objectiveType.category" ascending:YES],
                                [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES],
                                nil];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"metric.objective.theme.stratFile=%@ && zLayer=%@", stratFile, primaryChartLayer];
    
    NSArray *sortedCharts = [DataManager arrayForEntity:NSStringFromClass([Chart class])
                                   sortDescriptorsOrNil:sortDescriptors 
                                         predicateOrNil:predicate];
    return sortedCharts;
}

+ (Chart*)chartAtPage:(NSUInteger)pageNumber stratFile:(StratFile*)stratFile
{
    NSArray *charts = [Chart chartsSortedByOrderForStratFile:stratFile];
    // remember that at page 0 is the stratcard, so page 4 (ie 5th page) has chart[3]
    if (pageNumber == 0) {
        WLog(@"No charts at index position (page) 0. Returning nil.");
        return nil;
    }
    return [charts objectAtIndex:pageNumber-1];
}

+ (Chart*)chartWithUUID:(NSString*)uuid
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uuid=%@", uuid];
    return (Chart*)[DataManager objectForEntity:NSStringFromClass([Chart class]) 
                   sortDescriptorsOrNil:nil 
                         predicateOrNil:predicate];
}

- (UIColor*)colorForGradientStart
{
    NSDictionary *colorScheme = [colorSchemes objectAtIndex:self.colorScheme.intValue];
    if (!colorScheme) {
        WLog(@"No colorScheme with the name: %@. Using Yellow instead.", self.colorScheme);
        colorScheme = [colorSchemes objectAtIndex:ColorSchemeYellow];
    }
    NSString *hex = [colorScheme objectForKey:@"color1"];
    return [UIColor colorWithHexString:hex];
}

- (UIColor*)colorForGradientEnd
{
    NSDictionary *colorScheme = [colorSchemes objectAtIndex:self.colorScheme.intValue];
    if (!colorScheme) {
        WLog(@"No colorScheme with the name: %@. Using Yellow instead.", self.colorScheme);
        colorScheme = [colorSchemes objectAtIndex:ColorSchemeYellow];
    }
    NSString *hex = [colorScheme objectForKey:@"color2"];
    return [UIColor colorWithHexString:hex];
}

+ (NSString*)colorSchemeNameForColorScheme:(ColorScheme)colorScheme
{
    return [[colorSchemes objectAtIndex:colorScheme] objectForKey:@"name"];
}

+ (NSArray*)colorSchemeNames
{
    NSMutableArray *names = [NSMutableArray array];
    for (NSDictionary *dict in colorSchemes) {
        [names addObject:[dict objectForKey:@"name"]];
    }
    return names;
}

+ (UIColor*)colorForColorScheme:(ColorScheme)colorScheme gradientPosition:(GradientPosition)gradientPosition
{
    switch (gradientPosition) {
        case GradientPositionStart:
            return [UIColor colorWithHexString:[[colorSchemes objectAtIndex:colorScheme] objectForKey:@"color1"]];
        case GradientPositionEnd:
            return [UIColor colorWithHexString:[[colorSchemes objectAtIndex:colorScheme] objectForKey:@"color2"]];            
        default:
            WLog(@"No color for gradient position: %i", gradientPosition);
            return [UIColor blueColor];
    }
}

- (BOOL)shouldDrawOverlay
{
    if (self.overlay) {
        Chart *overlayChart = [Chart chartWithUUID:self.overlay];
        BOOL hasMetricAndChartType = overlayChart.metric.summary && overlayChart.chartType.intValue > ChartTypeNone;
        BOOL isCommentsType = (overlayChart.chartType.intValue == ChartTypeComments);
        if (overlayChart && (hasMetricAndChartType || isCommentsType)) {
            return YES;
        }
    }    
    return NO;
}

- (NSDate*)startDate
{    
    // rather than just taking self.metric.measurements and sorting it by date to get the first measurement, do a much more efficient fetch
    Measurement *m1 = (Measurement*)[DataManager objectForEntity:NSStringFromClass([Measurement class]) 
                                            sortDescriptorsOrNil:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]] 
                                                  predicateOrNil:[NSPredicate predicateWithFormat:@"metric = %@", self.metric]];

    // make sure we account for the target date
    NSDate *targetDate = self.metric.targetDate;
    NSDate *startDate;
    if (targetDate && m1.date) {
        startDate = [m1.date isAfter:targetDate] ? targetDate : m1.date;
    } else if (targetDate) {
        startDate = targetDate;
    } else if (m1.date) {
        startDate = m1.date;
    } else {
        startDate = [NSDate dateWithZeroedTime];
    }
        
    // we don't just want the first day of the month, cause we may not hit january, which is where we write the year in the UI
    // need to get the first month of the appropriate interval
    int duration = [self durationInMonths];
    int interval = [Chart intervalForDuration:duration];
    
    return [NSDate dateSetToFirstDayOfMonthOfInterval:interval forDate:startDate];
}

- (NSUInteger)durationInMonths
{
    Measurement *m1 = (Measurement*)[DataManager objectForEntity:NSStringFromClass([Measurement class]) 
                                            sortDescriptorsOrNil:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]] 
                                                  predicateOrNil:[NSPredicate predicateWithFormat:@"metric = %@", self.metric]];
    Measurement *m2 = (Measurement*)[DataManager objectForEntity:NSStringFromClass([Measurement class]) 
                                            sortDescriptorsOrNil:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]] 
                                                  predicateOrNil:[NSPredicate predicateWithFormat:@"metric = %@", self.metric]];
    
    NSDate *startDate, *endDate;
    NSDate *targetDate = m1.metric.targetDate;
    if (targetDate) {
        startDate = [m1.date isAfter:targetDate] ? targetDate : m1.date;
        endDate = [m2.date isAfter:targetDate] ? m2.date : targetDate;        
    } else {
        startDate = m1.date;
        endDate = m2.date;
    }
    
    // if we have 1 or no measurements, just return 1 month
    if (startDate == nil || endDate == nil) {
        return 1;
    }
    
    NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];    
    NSDateComponents *components = [gregorian components:NSMonthCalendarUnit | NSDayCalendarUnit
                                                fromDate:[NSDate dateSetToFirstDayOfMonthForDate:startDate]
                                                  toDate:[NSDate dateSetToFirstDayOfNextMonthForDate:endDate] options:0];
    return [components month] + ([components day] > 0 ? 1 : 0);
}

+ (NSUInteger)intervalForDuration:(NSUInteger)durationInMonths
{
    // not quite the same intervals as in ChartDataSource
    // we're returning a number of months
    if (durationInMonths <= 2*12) {
        return 1;
    }
    else if (durationInMonths <= 4*12) {
        return 2;
    }
    else if (durationInMonths <= 6*12) {
        return 3;
    }
    else if (durationInMonths <= 8*12) {
        return 4;
    }
    else if (durationInMonths <= 12*12) {
        return 6;
    }
    else {
        return 8;
    }    
}

+ (NSUInteger)gridDurationForChartDuration:(NSUInteger)durationInMonths
{
    //  1y - 12 segs - 1 mo interval
    //  2y - 24 segs - 1 mo
    //  3y - 18 segs - 2 mo
    //  4y - 24 segs - 2 mo
    //  5y - 20 segs - 3 mo
    //  6y - 24 segs - 3 mo
    //  7y - 21 segs - 4 mo
    //  8y - 24 segs - 4 mo
    //  9y - 18 segs - 6 mo
    //  10y- 20 segs - 6 mo
    //  11y- 22 segs - 6 mo
    //  12y- 24 segs - 6 mo
    //  13y- 26 segs - 6 mo
    //  14y- 21 segs - 8 mo
    
    return ceilf(durationInMonths/12.f)*12;
}

+(CGFloat)getYMax:(CGFloat)maxVal
{
    // add 10%
    // bring it down to a number between 1 and 10 (1<n<=10), recording magnitude
    // round to 2, 4, 5, 8, 10
    // multiply by magnitude to restore correct scale
    // eg. 7200 -> 7.2 -> 7.92 -> 8 -> 8000
    // eg. 135 -> 1.35 -> 1.485 -> 2 -> 200
    
    CGFloat n = maxVal * 1.10;
    uint magnitude = 0;
    while (n > 10) {
        n /= 10;
        magnitude++;
    }
    
    uint i = 0;
    CGFloat rounds [] = {2,4,5,8,10};
    CGFloat round = 0;
    while (round < n) {
        round = rounds[i++];
    }
    
    return round * powf(10, magnitude);
}

@end
