//
//  GanttChartBuilder.m
//  StratPad
//
//  Created by Eric Rogers on September 30, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "GanttChartBuilder.h"
#import "UIColor-Expanded.h"
#import "NSString-Expanded.h"
#import "NSDate-StratPad.h"
#import "Metric.h"

@interface GanttChartBuilder (Private)

// returns NO if the theme's start date is more than 60 months after the start date of the Gantt Chart,
// returns YES otherwise.
+ (BOOL)shouldIncludeTheme:(Theme*)theme inGanttDataSource:(GanttDataSource*)ganttChart;

// returns NO if the activity's start date is more than 60 months after the start date of the Gantt Chart,
// or if the activity has no start date, and the end date for the activity is more than 24 months after 
// the start date of the Gantt Chart. Returns YES otherwise.
+ (BOOL)shouldIncludeActivity:(Activity*)activity inGanttDataSource:(GanttDataSource*)ganttChart;

// returns NO if the metric's target date is outside the date limits of the Gantt Chart, or if it has no summary
// returns YES otherwise.
+ (BOOL)shouldIncludeMetric:(Metric*)metric inGanttDataSource:(GanttDataSource*)ganttChart;

@end


@implementation GanttChartBuilder

@synthesize rect = rect_;
@synthesize stratFile = stratFile_;
@synthesize fontName = fontName_;
@synthesize boldFontName = boldFontName_;
@synthesize obliqueFontName = obliqueFontName_;
@synthesize fontSize = fontSize_;
@synthesize headingFontColor = headingFontColor_;
@synthesize fontColor = fontColor_;
@synthesize lineColor = lineColor_;
@synthesize alternatingRowColor = alternatingRowColor_;
@synthesize mediaType = mediaType_;
@synthesize hideMetricsRow = hideMetricsRow_;
@synthesize showMetricMilestoneForObjective = showMetricMilestoneForObjective_;
@synthesize shouldFilterBlankObjectives = shouldFilterBlankObjectives_;


#pragma mark - Memory Management

- (void)dealloc
{
    [stratFile_ release];
    [headingFontColor_ release];
    [fontColor_ release];
    [lineColor_ release];
    [alternatingRowColor_ release];

    [super dealloc];
}


#pragma mark - Public

- (MBDrawableGanttChart*)build
{
    //  - Ordering
    //      - Themes go in the order they are presented in F4 and F5
    //      - Objectives should go in the order of their date
    //          - if an objective doesn't have a date, grab it from the start (or end) date in its Activities
    //      - Activities should go in order of date
    //          - by start date if available, then by end date

    NSDate *startDate = [stratFile_ dateOfEarliestThemeOrToday];
    NSUInteger duration = [stratFile_ strategyDurationInMonths];
    NSUInteger interval = [ChartDataSource columnIntervalForStrategyDuration:duration];
    GanttDataSource *dataSource = [[GanttDataSource alloc] initWithStartDate:startDate forIntervalInMonths:interval];
        
    NSDate *ganttStartDate = [dataSource.columnDates objectAtIndex:0];
    
    NSArray *sortedThemes = [stratFile_ themesSortedByStartDate];
    
    for (Theme *theme in sortedThemes) {
        if ([GanttChartBuilder shouldIncludeTheme:theme inGanttDataSource:dataSource]) {
            
            ThemeGanttTimeline *themeTimeline = [[ThemeGanttTimeline alloc] initWithTheme:theme andStrategyStartDate:ganttStartDate];
            [dataSource.timelines addObject:themeTimeline];
            [themeTimeline release];
            
            NSArray *sortedObjectives = [theme objectivesSortedByActivityAndMetricDates];
            for (Objective *objective in sortedObjectives) {
                
                ObjectiveGanttTimeline *objectiveTimeline = [[ObjectiveGanttTimeline alloc] initWithObjective:objective];
                objectiveTimeline.shouldDrawMetricMilestones = showMetricMilestoneForObjective_;   
                
                // we only want to check if shouldFilter = true (R9C), otherwise draw
                if (shouldFilterBlankObjectives_) {
                    // in some cases, we may want to skip drawing the row
                    // eg. for R9C only, if an objective has >= 1 metric, and all the metrics have a numeric value and a date, don't show the objective                
                    if ([objectiveTimeline shouldDraw]) {
                        [dataSource.timelines addObject:objectiveTimeline];                    
                    }
                } 
                else
                {
                    [dataSource.timelines addObject:objectiveTimeline];                    
                }
                [objectiveTimeline release];
                
                NSArray *sortedActivities = [objective activitiesSortedByDate];
                
                for (Activity *activity in sortedActivities) {
                    
                    if ([GanttChartBuilder shouldIncludeActivity:activity inGanttDataSource:dataSource]) {
                        
                        ActivityGanttTimeline *activityTimeline = [[ActivityGanttTimeline alloc] initWithActivity:activity andStrategyStartDate:ganttStartDate];
                        [dataSource.timelines addObject:activityTimeline];
                        [activityTimeline release];
                    }                    
                }
                
                if (!self.hideMetricsRow) {
                    for (Metric *metric in objective.metrics) {
                        if ([GanttChartBuilder shouldIncludeMetric:metric inGanttDataSource:dataSource]) {
                            MetricGanttTimeline *metricTimeline = [[MetricGanttTimeline alloc] initWithMetric:metric];
                            [dataSource.timelines addObject:metricTimeline];
                            [metricTimeline release];                                                    
                        }
                    }
                }                
            }            
        }        
    }

    UIFont *font = [UIFont fontWithName:fontName_ size:fontSize_];
    UIFont *boldFont = [UIFont fontWithName:boldFontName_ size:fontSize_];
    UIFont *obliqueFont = [UIFont fontWithName:obliqueFontName_ size:fontSize_];
    
    MBDrawableGanttChart *ganttChart = [[MBDrawableGanttChart alloc] initWithRect:self.rect 
                                                                             font:font 
                                                                         boldFont:boldFont 
                                                                      obliqueFont:obliqueFont 
                                                               andGanttDataSource:dataSource];
    ganttChart.headingFontColor = self.headingFontColor;
    ganttChart.fontColor = self.fontColor;
    ganttChart.lineColor = self.lineColor;
    ganttChart.alternatingRowColor = self.alternatingRowColor;
    ganttChart.mediaType = mediaType_;
    [dataSource release];
    [ganttChart sizeToFit];
    return [ganttChart autorelease];
}


#pragma mark - Private

+ (BOOL)shouldIncludeTheme:(Theme*)theme inGanttDataSource:(GanttDataSource*)dataSource
{    
    NSDate *ganttEndDate = [dataSource.columnDates lastObject];    
    
    if (theme.startDate && [theme.startDate compareDayMonthAndYearTo:ganttEndDate] == NSOrderedDescending) {
        // start date of the theme is after the end date of the chart.
        return NO;
    }         
    return YES;
}

+ (BOOL)shouldIncludeActivity:(Activity*)activity inGanttDataSource:(GanttDataSource*)ganttChart
{    
    NSDate *ganttEndDate = [ganttChart.columnDates lastObject];    
    
    if (activity.startDate && [activity.startDate compareDayMonthAndYearTo:ganttEndDate] == NSOrderedDescending) {
        // start date of the activity is after the end date of the chart.
        return NO;
    }
    
    if (!activity.startDate && activity.endDate && [activity.endDate compareDayMonthAndYearTo:ganttEndDate] == NSOrderedDescending) {
        // no start date, and the end date of the activity is after the end date of the chart.
        return NO;
    }
    
    return YES;
}

+ (BOOL)shouldIncludeMetric:(Metric*)metric inGanttDataSource:(GanttDataSource*)ganttChart
{
    NSDate *ganttStartDate = [ganttChart.columnDates objectAtIndex:0];
    NSDate *ganttEndDate = [ganttChart.columnDates lastObject];    
        
    if (!metric.summary || [metric.summary isBlank]) {
        return NO;
    }
        
    if (metric.targetDate 
        && ([metric.targetDate compareDayMonthAndYearTo:ganttStartDate] == NSOrderedAscending
            || [metric.targetDate compareDayMonthAndYearTo:ganttEndDate] == NSOrderedDescending)) {
            return NO;
        }
    return YES;
}

@end
