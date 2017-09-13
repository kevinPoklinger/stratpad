//
//  AddChartViewController.m
//  StratPad
//
//  Created by Julian Wood on 12-04-12.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "AddChartViewController.h"
#import "MetricChooserViewController.h"
#import "StratFileManager.h"
#import "Metric.h"
#import "DataManager.h"
#import "NSString-Expanded.h"
#import "EventManager.h"

@interface AddChartViewController ()

@end

@implementation AddChartViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark - UIPopoverControllerDelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    [popoverController_ release];
	popoverController_ = nil;	    
}

#pragma mark - Public

- (void)showPopoverfromBarButtonItem:(UIBarButtonItem*)barButtonItem withMetricChooser:(id<MetricChooser>)metricChooser
{		    
    if (popoverController_) {
        [self dismissPopover];
    }
    
    StratFile *stratFile = [[StratFileManager sharedManager] currentStratFile];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"objective.theme.stratFile=%@ && summary!=nil", stratFile];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"summary" ascending:YES];
    NSArray *metrics = [DataManager arrayForEntity:NSStringFromClass([Metric class]) sortDescriptorsOrNil:[NSArray arrayWithObject:sortDescriptor] predicateOrNil:predicate];
    
    MetricChooserViewController *metricVC = [[MetricChooserViewController alloc] initWithMetrics:metrics 
                                                                                    chosenMetric:nil 
                                                                                andMetricChooser:metricChooser];
    metricVC.title = LocalizedString(@"CHOOSE_METRIC_FOR_ADD_CHART", nil);
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:metricVC];
    [metricVC release];
    navController.delegate = self;
    popoverController_ = [[UIPopoverController alloc] initWithContentViewController:navController];
    [navController release];
    popoverController_.delegate = self;
    
    CGSize contentSize = [metricVC contentSizeForViewInPopover];
    
    if ([((MetricChooserDelegate*)metricVC.tblMetrics.dataSource) numberOfSectionsInTableView:metricVC.tblMetrics] == 0) {
        UILabel *lblFooter = [[UILabel alloc] init];
        lblFooter.font = [UIFont boldSystemFontOfSize:15.f];
        lblFooter.backgroundColor = [UIColor clearColor];
        lblFooter.textColor = [UIColor darkGrayColor];
        lblFooter.numberOfLines = 0;
        lblFooter.text = LocalizedString(@"ADD_METRIC_INSTRUCTIONS_FOR_ADD_CHART", nil);
        lblFooter.textAlignment = UITextAlignmentCenter;
        lblFooter.frame = CGRectMake(0, 0, popoverController_.popoverContentSize.width, 100);
        metricVC.tblMetrics.tableFooterView = lblFooter;
        [lblFooter release];
        contentSize = CGSizeMake(contentSize.width, contentSize.height+100);
    }    
    
    popoverController_.popoverContentSize = contentSize;
    [popoverController_ presentPopoverFromBarButtonItem:barButtonItem
                               permittedArrowDirections:UIPopoverArrowDirectionUp
                                               animated:YES];
}

- (void)dismissPopover
{
    [popoverController_ dismissPopoverAnimated:YES];
	[popoverController_ release];
	popoverController_ = nil;
}

@end
