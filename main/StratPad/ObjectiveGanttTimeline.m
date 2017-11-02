//
//  ObjectiveGanttTimeline.m
//  StratPad
//
//  Created by Eric on 11-09-22.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "ObjectiveGanttTimeline.h"
#import "Metric.h"

@implementation ObjectiveGanttTimeline

@synthesize title = title_;
@synthesize shouldDrawMetricMilestones = shouldDrawMetricMilestones_;
@synthesize objective = objective_;

- (id)initWithObjective:(Objective *)objective
{
    if ((self = [super init])) {   
        ganttChartDetailRowClass_ = NSClassFromString(@"GanttChartObjectiveRow");

        objective_ = [objective retain];
        title_ = objective.summary;
        shouldDrawMetricMilestones_ = NO;
    }
    return self;
}

- (BOOL)shouldDraw 
{
    // old rule: for R9C only, if an objective has >= 1 metric, and all the metrics have a numeric value and a date, don't show the objective
    
    // new rule: R9C, if obj has >= 1 metric, and at least 1 metric has a date, show it
    // use the latest date
    if (objective_.metrics.count) {
        for (Metric *metric in objective_.metrics) {
            if (metric.targetDate) return YES;
        }
        return NO;
    } else {
        return NO;
    }
}

- (void)dealloc {
    [objective_ release];
    [super dealloc];
}

@end
