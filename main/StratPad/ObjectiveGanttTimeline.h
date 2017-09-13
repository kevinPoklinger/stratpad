//
//  ObjectiveGanttTimeline.h
//  StratPad
//
//  Created by Eric on 11-09-22.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "GanttTimeline.h"
#import "Objective.h"

@interface ObjectiveGanttTimeline : GanttTimeline {
@private
    NSString *title_;
    BOOL shouldDrawMetricMilestones_;
    Objective *objective_;
}

@property(nonatomic, readonly) NSString *title;
@property(nonatomic, retain) Objective *objective;

// for R9 Gantt only, if an objective has a metric which has a date but not a value, show the diamond
// if multiple metrics, no values, show last date if it exists
@property(nonatomic, assign) BOOL shouldDrawMetricMilestones;

- (id)initWithObjective:(Objective *)objective;

@end
