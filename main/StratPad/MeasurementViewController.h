//
//  MeasurementViewController.h
//  StratPad
//
//  Created by Julian Wood on 12-04-20.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//
//  Master/Detail view with MetricList -> MeasurementList

#import <UIKit/UIKit.h>
#import "MetricList.h"
#import "MeasurementList.h"
#import "NoRowsTableDataSource.h"

@interface MeasurementViewController : UIViewController <UIPopoverControllerDelegate,UINavigationControllerDelegate,MetricChooser>
{
    @private
    UIPopoverController *popoverController_;
    MetricList *metricList_;
    MeasurementList *measurementList_;
    
    NoRowsTableDataSource *noMetricsTableDataSource_;
    NoRowsTableDataSource *noMeasurementsTableDataSource_;
    
    CGSize originalViewSize_;
}
@property (retain, nonatomic) IBOutlet UITableView *tblMetrics;
@property (retain, nonatomic) IBOutlet UITableView *tblMeasurements;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *btnAddMeasurement;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *btnManageMeasurements;

// if chart is nil, then we'll select the first row
- (void)showPopoverInView:(UIView*)view fromRect:(CGRect)rect forChart:(Chart*)chart;
- (void)dismissPopover;

- (IBAction)manageMeasurements:(id)sender;
- (IBAction)addMeasurement:(id)sender;

@end
