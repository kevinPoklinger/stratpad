//
//  MetricChooserDelegate.h
//  StratPad
//
//  Created by Julian Wood on 12-04-20.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Metric.h"

typedef enum {
    MetricFilterMeasurements  = 1, // only include metrics with measurements
    MetricFilterSummary       = 2, // only include metrics with a summary (title)
} MetricFilter;

@protocol MetricChooser <NSObject>
@required
- (void)metricSelected:(Metric*)chosenMetric;
- (int)metricFilters;
@end

@interface MetricChooserDelegate : NSObject<UITableViewDelegate,UITableViewDataSource> {
@protected
    // Theme -> NSArray of Metric
    NSMutableDictionary *metricsDict_;
    
    // the object wishing to be notified of the metric choice
    id<MetricChooser> metricChooser_;
    
    // nil or the metric chosen for the chart
    Metric *chosenMetric_;

}

- (id)initWithMetrics:(NSArray*)metrics chosenMetric:(Metric*)chosenMetric andMetricChooser:(id<MetricChooser>)metricChooser;
-(CGFloat)heightForAllRows:(UITableView*)tblMetrics;
@end
