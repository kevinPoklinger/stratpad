//
//  MetricChooserViewController.h
//  StratPad
//
//  Created by Julian Wood on 12-04-04.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//
//  Will show a list of metrics to be chosen. Notifies its delegate MetricChooser when a metric is selected.
//  Metrics without a summary or any measurements will be filtered out. Metrics are grouped by their theme,
//  rather than by ObjectiveType.

#import <UIKit/UIKit.h>
#import "Chart.h"
#import "MetricChooserDelegate.h"

@interface MetricChooserViewController : UIViewController {
    @private
    MetricChooserDelegate *delegate_;
}

@property (retain, nonatomic) IBOutlet UITableView *tblMetrics;

- (id)initWithMetrics:(NSArray*)metrics chosenMetric:(Metric*)chosenMetric andMetricChooser:(id<MetricChooser>)metricChooser;

@end
