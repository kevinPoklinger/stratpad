//
//  MeasurementList.h
//  StratPad
//
//  Created by Julian Wood on 12-04-20.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//
//  For use as a delegate and datasource (for MeasurementsVC) to handle table ops for the list of measurements

#import <UIKit/UIKit.h>
#import "Metric.h"

@class MeasurementViewController;

@interface MeasurementList : NSObject<UITableViewDelegate,UITableViewDataSource>
{
    @private
    NSMutableArray *measurements_;
    Metric *metric_;
    
    MeasurementViewController *measurementVC_;
}

@property (nonatomic,retain) Metric *metric;

- (id)initWithMetric:(Metric*)metric measurementVC:(MeasurementViewController*)measurementVC;
- (void)populateWithMetric:(Metric*)metric tableView:(UITableView*)tableView;
- (void)scrollToSelectedRow:(UITableView*)tableView;
- (void)addNewMeasurement:(UITableView*)tableView;
-(UIView*)tableHeaderView:(UITableView*)tableView;

@end
