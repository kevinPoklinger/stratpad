//
//  SinglePageReachTheseGoalsChartBuilder.m
//  StratPad
//
//  Created by Eric on 11-09-29.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "ReachTheseGoalsChartBuilder.h"
#import "Theme.h"
#import "ReachTheseGoalsDataSource.h"
#import "Objective.h"
#import "UIColor-Expanded.h"
#import "NSString-Expanded.h"
#import "NSDate-StratPad.h"
#import "Metric.h"

@interface ReachTheseGoalsChartBuilder (Private)

- (BOOL)shouldCreateGoalForMetric:(Metric*)metric inDataSource:(ReachTheseGoalsDataSource*)dataSource;

@end

@implementation ReachTheseGoalsChartBuilder

@synthesize rect = rect_;
@synthesize stratFile = stratFile_;
@synthesize fontName = fontName_;
@synthesize boldFontName = boldFontName_;
@synthesize fontSize = fontSize_;
@synthesize headingFontColor = headingFontColor_;
@synthesize fontColor = fontColor_;
@synthesize lineColor = lineColor_;
@synthesize alternatingRowColor = alternatingRowColor_;
@synthesize diamondColor = diamondColor_;

#pragma mark - Memory Management

- (void)dealloc
{
    [stratFile_ release];
    [headingFontColor_ release];
    [fontColor_ release];
    [lineColor_ release];
    [alternatingRowColor_ release];
    [diamondColor_ release];
    [super dealloc];
}

- (ReachTheseGoalsChart*)build
{
    NSDate *startDate = [stratFile_ dateOfEarliestThemeOrToday];   
    NSUInteger duration = [stratFile_ strategyDurationInMonths];
    NSUInteger interval = [ChartDataSource columnIntervalForStrategyDuration:duration];
    ReachTheseGoalsDataSource *dataSource = [[ReachTheseGoalsDataSource alloc] initWithStartDate:startDate forIntervalInMonths:interval];
    id<Goal> goal;
    
    for (Theme *theme in stratFile_.themes) {
        for (Objective *objective in theme.objectives) {        
            for (Metric *metric in objective.metrics) {
                if ([self shouldCreateGoalForMetric:metric inDataSource:dataSource]) {
                    goal = [metric newGoal];
                    [dataSource addGoal:goal];
                    [goal release];
                }            
            }
            
        }
    }        
    
    UIFont *chartFont = [UIFont fontWithName:self.fontName size:self.fontSize];
    UIFont *chartBoldFont = [UIFont fontWithName:self.boldFontName size:self.fontSize];
    
    ReachTheseGoalsChart *reachTheseGoalsChart = [[ReachTheseGoalsChart alloc] initWithRect:self.rect 
                                                                                       font:chartFont 
                                                                                   boldFont:chartBoldFont 
                                                                              andDataSource:dataSource];
    reachTheseGoalsChart.headingFontColor = self.headingFontColor;
    reachTheseGoalsChart.fontColor = self.fontColor;    
    reachTheseGoalsChart.lineColor = self.lineColor;
    reachTheseGoalsChart.alternatingRowColor = self.alternatingRowColor;
    reachTheseGoalsChart.diamondColor = self.diamondColor;    
    [reachTheseGoalsChart sizeToFit];
    [dataSource release];
    
    return [reachTheseGoalsChart autorelease];
}


#pragma mark - Private

- (BOOL)shouldCreateGoalForMetric:(Metric*)metric inDataSource:(ReachTheseGoalsDataSource*)dataSource
{        
    // ensure we have a metric value.
    if (!metric.summary || [metric.summary isBlank]) {
        return NO;
    }
    
    // ensure we have a target date, and it occurs within the date range of the chart.
    if (metric.targetDate 
        && ([metric.targetDate compareDayMonthAndYearTo:[dataSource.columnDates objectAtIndex:0]] == NSOrderedAscending
            || [metric.targetDate compareDayMonthAndYearTo:[dataSource.columnDates lastObject]] == NSOrderedDescending)) {
            return NO;
        }
    
    // ensure we have a target value.
    if (!metric.targetValue || [metric.targetValue isBlank]) {
        return NO;
    }
    
    return YES;
}

@end
