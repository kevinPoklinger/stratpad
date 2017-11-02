//
//  MeasurementViewController.m
//  StratPad
//
//  Created by Julian Wood on 12-04-20.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "MeasurementViewController.h"
#import "StratFile.h"
#import "StratFileManager.h"
#import "DataManager.h"
#import "MeasurementEditorCell.h"
#import "NSDate-StratPad.h"
#import "EventManager.h"

@interface MeasurementViewController ()

@end

@implementation MeasurementViewController

@synthesize tblMetrics;
@synthesize tblMeasurements;
@synthesize btnAddMeasurement;
@synthesize btnManageMeasurements;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {                        
        StratFile *stratFile = [[StratFileManager sharedManager] currentStratFile];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"objective.theme.stratFile=%@ && summary!=nil", stratFile];
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"summary" ascending:YES];
        NSArray *metrics = [DataManager arrayForEntity:NSStringFromClass([Metric class]) sortDescriptorsOrNil:[NSArray arrayWithObject:sortDescriptor] predicateOrNil:predicate];

        // load up UI for listing metrics and measurements - selection is done when we show the popup
        metricList_ = [[MetricList alloc] initWithMetrics:metrics chosenMetric:nil andMetricChooser:self];
        measurementList_ = [[MeasurementList alloc] initWithMetric:nil measurementVC:self];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didShowKeyboard:)
                                                     name:UIKeyboardDidShowNotification
                                                   object:nil];	
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // if there are no metrics
    NSString *noMetricsTitle = LocalizedString(@"ADD_METRIC_INSTRUCTIONS_ROW", nil);
    noMetricsTableDataSource_ = [[NoRowsTableDataSource alloc] initWithTitle:noMetricsTitle];
    noMetricsTableDataSource_.isRounded = NO;
    
    // tableview delegate always MetricList
    tblMetrics.delegate = metricList_;    
    
    // datasource switches if there are no metrics
    if ([metricList_ numberOfSectionsInTableView:tblMetrics] == 0) {
        tblMetrics.dataSource = noMetricsTableDataSource_;
        btnManageMeasurements.enabled = NO;
        btnAddMeasurement.enabled = NO;
    } else {
        tblMetrics.dataSource = metricList_;
        btnManageMeasurements.enabled = YES;
        btnAddMeasurement.enabled = YES;
    }
    
    tblMeasurements.delegate = measurementList_;    
    tblMeasurements.dataSource = measurementList_;
    
    // if there are no measurements
    NSString *noMeasurementsTitle = LocalizedString(@"ADD_MEASUREMENT_INSTRUCTIONS_ROW", nil);
    noMeasurementsTableDataSource_ = [[NoRowsTableDataSource alloc] initWithTitle:noMeasurementsTitle];
    noMeasurementsTableDataSource_.isRounded = YES;
    
    //originalViewSize_ = self.view.bounds.size;
    originalViewSize_ = CGSizeMake(950, 600);
}

- (void)viewDidUnload
{
    [noMetricsTableDataSource_ release], noMetricsTableDataSource_ = nil;
    [noMeasurementsTableDataSource_ release], noMeasurementsTableDataSource_ = nil;
    [self setTblMetrics:nil];
    [self setTblMeasurements:nil];
    [self setBtnAddMeasurement:nil];
    [self setBtnManageMeasurements:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self dismissPopover];
    [measurementList_ release];
    [metricList_ release];
    [tblMetrics release];
    [tblMeasurements release];
    [noMetricsTableDataSource_ release];
    [noMeasurementsTableDataSource_ release];
    [btnAddMeasurement release];
    [btnManageMeasurements release];
    [super dealloc];
}

#pragma mark - Public

- (void)showPopoverInView:(UIView*)view fromRect:(CGRect)rect forChart:(Chart*)chart
{		    
    if (popoverController_) {
        [popoverController_ release]; popoverController_ = nil;		
    }
    
    popoverController_ = [[UIPopoverController alloc] initWithContentViewController:self];
    popoverController_.delegate = self;
    popoverController_.popoverContentSize = CGSizeMake(950, 600);
    [popoverController_ presentPopoverFromRect:rect
                                        inView:view
                      permittedArrowDirections:UIPopoverArrowDirectionUp
                                      animated:YES];
	
    // auto-select the first metric and it's measurements; there is always one row because we switch data models if no metrics
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    if (chart) {
        // select the metric representing the chart
        indexPath = [metricList_ indexPathForChart:chart];
    }

    // select metric row and its measurements
    [tblMetrics selectRowAtIndexPath:indexPath
                            animated:NO 
                      scrollPosition:UITableViewScrollPositionNone];
    if (tblMetrics.numberOfSections > 0) {
        [metricList_ tableView:tblMetrics didSelectRowAtIndexPath:indexPath];  
    }            
}


- (void)dismissPopover
{
    [popoverController_ dismissPopoverAnimated:YES];
	[popoverController_ release];
	popoverController_ = nil;
}

#pragma mark - Actions

- (IBAction)manageMeasurements:(id)sender {
    UIBarButtonItem *button = (UIBarButtonItem*)sender;
    
    // want to stop editing textfield too
    NSArray *visibleCellPaths = [tblMeasurements indexPathsForVisibleRows];
    for (NSIndexPath *indexPath in visibleCellPaths) {
        MeasurementEditorCell *cell = (MeasurementEditorCell*)[tblMeasurements cellForRowAtIndexPath:indexPath];
        if ([cell.textFieldComment isEditing] || [cell.textFieldValue isEditing]) {
            [cell.textFieldComment endEditing:NO];
            [cell.textFieldValue endEditing:NO];
            break;
        }        
    }

    if (tblMeasurements.editing) {
        // switch off editing mode.
        [button setTitle:LocalizedString(@"MANAGE", nil)];
        [tblMeasurements setEditing:NO animated:YES];        
    } else {
        [button setTitle:LocalizedString(@"DONE", nil)];
        [tblMeasurements setEditing:YES animated:YES];        
    }
}

- (IBAction)addMeasurement:(id)sender {  
    tblMeasurements.tableHeaderView = nil;

    [measurementList_ addNewMeasurement:tblMeasurements];

    // show the checkmark
    NSIndexPath *selRow = [tblMetrics indexPathForSelectedRow];
    [[tblMetrics cellForRowAtIndexPath:selRow] setAccessoryType:UITableViewCellAccessoryCheckmark];
}

#pragma mark - MetricChooser

- (void)metricSelected:(Metric*)chosenMetric
{
    // if there are no measurements, want to show a message
    if (chosenMetric.hasMeasurements) {
        tblMeasurements.tableHeaderView = nil;
    } else {
        tblMeasurements.tableHeaderView = [measurementList_ tableHeaderView:tblMeasurements];
    }

    [tblMeasurements setEditing:NO animated:YES];
    [btnManageMeasurements setTitle:LocalizedString(@"MANAGE", nil)];

    [measurementList_ populateWithMetric:chosenMetric tableView:tblMeasurements];
}

-(int)metricFilters
{
    // metrics shown when tapping add must have a summary (and be part of the current stratfile)
    return MetricFilterSummary;
}

#pragma mark - Notifications

- (void)didShowKeyboard:(NSNotification*)notification
{
    // metrics table
    [tblMetrics scrollToRowAtIndexPath:tblMetrics.indexPathForSelectedRow atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    
    // measurements table
    [measurementList_ scrollToSelectedRow:tblMeasurements];    
}

#pragma mark - UIPopoverControllerDelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    // update the mini-charts
    [EventManager fireChartMeasurementsChangedEvent];
}


@end
