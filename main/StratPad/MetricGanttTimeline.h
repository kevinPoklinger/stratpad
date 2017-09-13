//
//  MetricGanttTimeline.h
//  StratPad
//
//  Created by Eric on 11-09-22.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "GanttTimeline.h"
#import "Objective.h"

@interface MetricGanttTimeline : GanttTimeline {
@private
    NSString *title_;
    NSDate *date_;
}

@property(nonatomic, readonly) NSString *title;
@property(nonatomic, readonly) NSDate *date;

- (id)initWithMetric:(Metric*)metric;

@end
