//
//  ChartViewController.m
//  StratPad
//
//  Created by Julian Wood on 12-03-12.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "ChartViewController.h"
#import "UIColor-Expanded.h"
#import "Theme.h"
#import "Objective.h"
#import "Metric.h"
#import "Measurement.h"
#import "EventManager.h"
#import "ChartViewPrinter.h"
#import "PageSpooler.h"

@interface ChartViewController (Private)
@end

@implementation ChartViewController

@synthesize chart = chart_;

@synthesize viewHeader;
@synthesize lblThemeObjective;
@synthesize btnOptions;
@synthesize btnMeasurements;
@synthesize viewChart;

- (id)initWithChart:(Chart*)chart andPageNumber:(NSUInteger)pageNumber
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.chart = chart;
        pageNumber_ = pageNumber;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(refreshPage:)
													 name:kEVENT_CHARTS_REORDERED
												   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(refreshChart:)
													 name:kEVENT_CHART_MEASUREMENTS_CHANGED
												   object:nil];
        
        // show the yammer icon if we published something
        [[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(addYammerCommentsButton)
													 name:kEVENT_YAMMER_NEW_PUBLICATION
												   object:nil];
    }
    return self;
}

- (IBAction)showOptions
{
    ChartOptionsViewController *optionsVC = [[ChartOptionsViewController alloc] initWithChart:self.chart andRedrawableChart:self];
    [optionsVC showPopoverInView:self.view fromRect:btnOptions.frame];
    [optionsVC release];
}

- (IBAction)showMeasurements 
{
    // show big popover with metrics and measurements
    if (!measurementVC_) {
        measurementVC_ = [[MeasurementViewController alloc] initWithNibName:nil bundle:nil];
    }
    [measurementVC_ showPopoverInView:self.view fromRect:btnMeasurements.frame forChart:chart_];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    @throw [NSException exceptionWithName:@"Unsupported message" reason:@"You must supply a Chart for this ViewController" userInfo:nil];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];    
    [chart_ release];
    [viewHeader release];
    [lblThemeObjective release];
    [btnOptions release];
    [viewChart release];
    [btnMeasurements release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // NB. this view can load at the same time as the stratboard screen, which is where we can do config, so don't do much here
    // actually might do measurements and config right here
    
    viewHeader.color1=[UIColor colorWithHexString:@"31373a"];
    viewHeader.color2=[UIColor blackColor];
    
    viewHeader.gradientStartPoint = [NSValue valueWithCGPoint:CGPointMake(viewHeader.bounds.size.width/2, 0)];
    viewHeader.gradientEndPoint = [NSValue valueWithCGPoint:CGPointMake(viewHeader.bounds.size.width/2, 75)];
    
    lblThemeObjective.text = [NSString stringWithFormat:LocalizedString(@"CHART_THEME_OBJECTIVE", nil), chart_.metric.objective.theme.title, chart_.metric.objective.summary];
    
    viewChart.chart = chart_;
    
    // options button
    UIImage *btnGrey = [[UIImage imageNamed:@"button-grey.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:0];
    [btnOptions setBackgroundImage:btnGrey forState:UIControlStateNormal];
    [btnOptions setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnOptions setTitleShadowColor:[[UIColor blackColor] colorWithAlphaComponent:0.3] forState:UIControlStateNormal];
    [btnOptions.titleLabel setShadowOffset:CGSizeMake(0, -1)];
    
    // data button
    [btnMeasurements setBackgroundImage:btnGrey forState:UIControlStateNormal];
    [btnMeasurements setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnMeasurements setTitleShadowColor:[[UIColor blackColor] colorWithAlphaComponent:0.3] forState:UIControlStateNormal];
    [btnMeasurements.titleLabel setShadowOffset:CGSizeMake(0, -1)];
}

-(void)viewDidAppear:(BOOL)animated
{
    DLog(@"chart: %@", chart_);
    [self addYammerCommentsButton];
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [viewChart closeAllComments];
    [super viewDidDisappear:animated];
}

- (void)viewDidUnload
{
    [self setViewHeader:nil];
    [self setLblThemeObjective:nil];
    [self setBtnOptions:nil];
    [self setViewChart:nil];
    [self setBtnMeasurements:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark - ContentVC overrides

- (void)exportToPDF
{   
    // normally we would tell our pdfview to draw to a pdf context, which in turn tells its print delegate (set here in the vc) to draw as well
    // we've built R1 using UIKit and some custom CG graphics - want to keep the screen portion
    CGRect paperRect = CGRectMake(0, 0, 72*11, 72*8.5);
    
    // each chart is a separate page, but comment reports can have multiple pages by themselves
    // the first chart is page 1, because stratboard is page 0

    ChartViewPrinter *printer = [[ChartViewPrinter alloc] initWithChart:chart_];
    
    // these are just local pageNumbers for the current chart
    int pageNumber = 0;
    while ([printer hasMorePages]) {
        UIGraphicsBeginPDFPageWithInfo(paperRect, nil);
        [printer drawPage:pageNumber++ inRect:paperRect];
    }
    [printer release];
}

#pragma mark - RedrawableChart

-(void)redrawChart
{
    // called by ChartOptionsViewController every time an option changes
    [self.viewChart setNeedsDisplay];
}

#pragma mark - Notification handlers

-(void)refreshChart:(NSNotification*)notification
{
    [self.viewChart setNeedsDisplay];
}

-(void)refreshPage:(NSNotification*)notification
{
    // update chart based on pagenumber
    NSArray *chartList = [Chart chartsSortedByOrderForStratFile:[[StratFileManager sharedManager] currentStratFile]];
    self.chart = [chartList objectAtIndex:pageNumber_-1];
    viewChart.chart = chart_;
    
    [self.viewChart setNeedsDisplay];
    lblThemeObjective.text = [NSString stringWithFormat:LocalizedString(@"CHART_THEME_OBJECTIVE", nil), chart_.metric.objective.theme.title, chart_.metric.objective.summary];
}

#pragma mark - Private

-(void)addYammerCommentsButton
{
    [self addYammerCommentsButtonToView:self.viewHeader];
}


@end
