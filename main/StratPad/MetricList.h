//
//  MetricList.h
//  StratPad
//
//  Created by Julian Wood on 12-04-24.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//
//  Shows the master view on the MeasurementVC
//  Checkmarks for all cells with data
//  Shows target?
//  Uses blue highlight for current selection

#import "MetricChooserDelegate.h"
#import "Chart.h"

@interface MetricList : MetricChooserDelegate

- (NSIndexPath*)indexPathForChart:(Chart*)chart;

@end
