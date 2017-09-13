//
//  MetricChooserViewController.m
//  StratPad
//
//  Created by Julian Wood on 12-04-04.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "MetricChooserViewController.h"
#import "Metric.h"
#import "Objective.h"
#import "Theme.h"

@interface MetricChooserViewController ()

@end

@implementation MetricChooserViewController

@synthesize tblMetrics;

- (id)initWithMetrics:(NSArray*)metrics chosenMetric:(Metric*)chosenMetric andMetricChooser:(id<MetricChooser>)metricChooser
{
    self = [super initWithNibName:NSStringFromClass([MetricChooserViewController class]) bundle:nil];
    if (self) {
        delegate_ = [[MetricChooserDelegate alloc] initWithMetrics:metrics chosenMetric:chosenMetric andMetricChooser:metricChooser];
        
        self.title = LocalizedString(@"METRIC", nil);
    }
    return self;
}

- (void)viewDidLoad
{
    tblMetrics.dataSource = delegate_;
    tblMetrics.delegate = delegate_;

    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [self setTblMetrics:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc
{
    [delegate_ release];
    [tblMetrics release];
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

// @override: this will make it so that the popover doesn't expand to full height
-(CGSize)contentSizeForViewInPopover
{
    CGFloat height = [delegate_ heightForAllRows:tblMetrics];
    
    if ([self.navigationController.viewControllers objectAtIndex:0] == self) {
        height += 40; // add in the navbar
    }
    
    return CGSizeMake(self.view.bounds.size.width, height);
}

@end
