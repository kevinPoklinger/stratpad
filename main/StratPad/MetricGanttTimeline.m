//
//  MetricGanttTimeline.m
//  StratPad
//
//  Created by Eric on 11-09-22.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "MetricGanttTimeline.h"
#import "NSString-Expanded.h"
#import "Metric.h"


@interface MetricGanttTimeline (Private)
- (NSString*)generateMetricDescriptionForObjective:(Objective*)objective;
@end

@implementation MetricGanttTimeline

@synthesize title = title_;
@synthesize date = date_;

- (id)initWithMetric:(Metric*)metric
{
    if ((self = [super init])) {
        ganttChartDetailRowClass_ = NSClassFromString(@"GanttChartMetricRow");
        title_ = [[self generateMetricDescription:metric] copy];
        date_ = [metric.targetDate copy];
    }
    return self;
}

- (void)dealloc
{
    [title_ release];
    [date_ release];
    [super dealloc];
}


- (NSString*)generateMetricDescription:(Metric*)metric
{
    // 1. metric with no target value: show "Achieve '[metric]'" eg. Achieve 'Increased revenue' 
    // 2. metric with target value: show "Reach [target value] in '[metric]'" eg. Reach $300,000 in 'Revenue' 
    NSString *metricSummary = metric.summary ? metric.summary : @"";
    
    if (!metric.targetValue || [metric.targetValue isBlank]) {
        return [NSString stringWithFormat:LocalizedString(@"ACHIEVE_METRIC_TEMPLATE", nil), metricSummary];
    } else {
        NSString *targetValue = metric.targetValue ? metric.targetValue : @"";
        return [NSString stringWithFormat:LocalizedString(@"REACH_METRIC_TEMPLATE", nil), targetValue, metricSummary];
    }    
}

@end
