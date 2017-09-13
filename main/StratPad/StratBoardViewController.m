//
//  StratBoardViewController.m
//  StratPad
//
//  Created by Julian Wood on 12-03-08.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "StratBoardViewController.h"
#import "EditionManager.h"
#import "Chart.h"
#import "StratFileManager.h"
#import "Metric.h"
#import "Objective.h"
#import "ObjectiveType.h"
#import "MBGradientView.h"
#import "UIColor-Expanded.h"
#import "ChartCell.h"
#import "Theme.h"
#import "MiniChartView.h"
#import "Measurement.h"
#import "RootViewController.h"
#import "EventManager.h"
#import "LinearRegression.h"
#import "NSDate-StratPad.h"
#import "NSCalendar+Expanded.h"
#import "DataManager.h"
#import "NSString-Expanded.h"
#import "ReportCardPrinter.h"
#import "UpgradeManager.h"
#import "Reachability.h"
#import "NSUserDefaults+StratPad.h"
#import "YammerCommentManager.h"
#import "UserNotificationDisplayManager.h"

@interface StratBoardViewController ()
@property (nonatomic, retain) SKProduct *productStratBoard;

@property (retain, nonatomic) IBOutlet UIButton *btnData;
@property (retain, nonatomic) IBOutlet MonthYearHeaderView *monthYearHeaderView;
@property (retain, nonatomic) IBOutlet UITableView *tblViewCharts;
@property (retain, nonatomic) IBOutlet MBReportHeaderView *headerView;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *btnAddChart;
@property (retain, nonatomic) IBOutlet UIButton *btnPlayHelpVideo;

@property (retain, nonatomic) IBOutlet UIView *upgradeView;
@property (retain, nonatomic) IBOutlet MBReportHeaderView *upgradeHeaderView;
@property (retain, nonatomic) IBOutlet YouTubeView *youTubeView;
@property (retain, nonatomic) IBOutlet UIButton *btnBuyStratBoard;

@end

@implementation StratBoardViewController
@synthesize youTubeView;
@synthesize btnBuyStratBoard;
@synthesize upgradeView;
@synthesize upgradeHeaderView;
@synthesize btnData;
@synthesize monthYearHeaderView;
@synthesize tblViewCharts;
@synthesize headerView;
@synthesize btnAddChart;
@synthesize productStratBoard;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(refreshMiniCharts:)
													 name:kEVENT_CHART_OPTIONS_CHANGED
												   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(refreshMiniCharts:)
													 name:kEVENT_CHART_MEASUREMENTS_CHANGED
												   object:nil];
        
        // show the yammer icon if we published something
        [[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(addYammerCommentsButton)
													 name:kEVENT_YAMMER_NEW_PUBLICATION
												   object:nil];
        
        // yammer comments
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateYammerCommentCounts:)
                                                     name:kEVENT_YAMMER_COMMENTS_UPDATED
                                                   object:nil];
        
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // customize the report header view to be black
    [headerView setBackgroundImage:nil];
    [headerView setTextInsetLeft:20.f];
    [headerView setReportTitle:LocalizedString(@"STRATBOARD", nil)];
    [headerView setShouldDrawLogo:NO];
    
    if (![[EditionManager sharedManager] isFeatureEnabled:FeatureHasStratBoard]) {
        // remove all subviews from view, and add the ad
        for (UIView *subview in self.view.subviews) {
            [subview removeFromSuperview];
        } 

        [self.view addSubview:upgradeView];
        
        [upgradeHeaderView setBackgroundImage:nil];
        [upgradeHeaderView setTextInsetLeft:20.f];
        [upgradeHeaderView setReportTitle:LocalizedString(@"STRATBOARD", nil)];
        
        // just get it to black; load it up in viewDidAppear
        youTubeView.useBorderHack = YES;
        [youTubeView loadVideo:nil];
        youTubeView.delegate = self;
        
        UIImage *btnGrey = [[UIImage imageNamed:@"button-grey.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:0];
        [btnBuyStratBoard setBackgroundImage:btnGrey forState:UIControlStateNormal];
        [btnBuyStratBoard setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnBuyStratBoard setTitleShadowColor:[[UIColor blackColor] colorWithAlphaComponent:0.3] forState:UIControlStateNormal];
        [btnBuyStratBoard.titleLabel setShadowOffset:CGSizeMake(0, -1)];
        btnBuyStratBoard.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
        btnBuyStratBoard.titleLabel.textAlignment = UITextAlignmentCenter;
        [self showProgress];
                
        purchaseIndicator_ = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        CGSize indicatorSize = purchaseIndicator_.bounds.size;
        
        purchaseIndicator_.frame = CGRectMake((btnBuyStratBoard.bounds.size.width - indicatorSize.width)/2,
                                     (btnBuyStratBoard.bounds.size.height - indicatorSize.height)/2,
                                     purchaseIndicator_.frame.size.width, purchaseIndicator_.frame.size.height);
        
        [btnBuyStratBoard addSubview:purchaseIndicator_];

        // have to go get the price; grab our IAPs
        storeManager_ = [[StoreManager alloc] initWithStoreManagerDelegate:self productIds:[NSArray arrayWithObject:[self stratBoardProductId]]];
        
    }
        
    [self loadChartsDict];
    
    // if there are no charts
    
    NSString *noRowsTitle = LocalizedString(@"ADD_CHART_INSTRUCTIONS_ROW", nil);
    noRowsTableDataSource_ = [[NoRowsTableDataSource alloc] initWithTitle:noRowsTitle];
    noRowsTableDataSource_.isRounded = NO;
    
    if ([chartDict_ count] == 0) {
        tblViewCharts.dataSource = noRowsTableDataSource_;        
    } else {
        tblViewCharts.dataSource = self;
    }
    
    tblViewCharts.clipsToBounds = YES;
    
    // data button
    UIImage *btnGrey = [[UIImage imageNamed:@"button-grey.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:0];
    [btnData setBackgroundImage:btnGrey forState:UIControlStateNormal];
    [btnData setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnData setTitleShadowColor:[[UIColor blackColor] colorWithAlphaComponent:0.3] forState:UIControlStateNormal];
    [btnData.titleLabel setShadowOffset:CGSizeMake(0, -1)];
    
    
    if ([self hasVideo]) {
        [self.btnPlayHelpVideo setBackgroundImage:btnGrey forState:UIControlStateNormal];
        [self.btnPlayHelpVideo setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.btnPlayHelpVideo setTitleShadowColor:[[UIColor blackColor] colorWithAlphaComponent:0.3] forState:UIControlStateNormal];
        [self.btnPlayHelpVideo.titleLabel setShadowOffset:CGSizeMake(0, -1)];
        
        [self.btnPlayHelpVideo setTitle:LocalizedString(@"HelpVideoButtonText", nil) forState:UIControlStateNormal];
    }
    else {
        [self.btnPlayHelpVideo setHidden:YES];
    }

    
}

// refreshes the underlying model
- (void)loadChartsDict
{
    [chartDict_ release];
    chartDict_ = [[NSMutableDictionary dictionary] retain];
    NSArray *chartList = [Chart chartsSortedByOrderForStratFile:[[StratFileManager sharedManager] currentStratFile]];
    
    for (Chart *chart in chartList) {
        ObjectiveType *objType = chart.metric.objective.objectiveType;
        NSMutableArray *charts = [chartDict_ objectForKey:objType.category];
        if (!charts) {
            charts = [NSMutableArray array];
            [chartDict_ setObject:charts forKey:objType.category];
        }
        [charts addObject:chart];
    }    
}


- (void)viewDidAppear:(BOOL)animated
{
    [self addYammerCommentsButton];
    [tblViewCharts flashScrollIndicators];
    [self refresh];
}


- (void)viewDidDisappear:(BOOL)animated
{
    [btnBuyStratBoard setTitle:@"" forState:UIControlStateNormal];
    [btnBuyStratBoard setEnabled:NO];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [headerView release];
    [chartDict_ release];
    [tblViewCharts release];
    [noRowsTableDataSource_ release];
    [btnAddChart release];
    [addChartVC_ release];
    [monthYearHeaderView release];
    [btnData release];

    [youTubeView release];
    [upgradeHeaderView release];
    [upgradeView release];
    [btnBuyStratBoard release];
    [storeManager_ release];
    [purchaseIndicator_ release];
    [btnTitle_ release];
    [productStratBoard release];
    [_btnPlayHelpVideo release];
    [super dealloc];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return [chartDict_ count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *sortedSections = [[chartDict_ allKeys] sortedArrayUsingSelector:@selector(compare:)];
    NSNumber *cat = [sortedSections objectAtIndex:section];    
    return [[chartDict_ objectForKey:cat] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {    
    static NSString *chartCellIdentifier = @"ChartCell";

    NSArray *sortedSections = [[chartDict_ allKeys] sortedArrayUsingSelector:@selector(compare:)];
    NSNumber *cat = [sortedSections objectAtIndex:[indexPath section]];
    NSArray *charts = [chartDict_ objectForKey:cat];

    ChartCell *cell = [tableView dequeueReusableCellWithIdentifier:chartCellIdentifier];
    if (cell == nil) {
        // not localized
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:chartCellIdentifier owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    
    Chart *chart = [charts objectAtIndex:[indexPath row]];
    cell.lblChartTitle.text = chart.title;
    cell.lblThemeName.text = chart.metric.objective.theme.title;
    cell.lblObjectiveName.text = chart.metric.objective.summary;
    
    StratFile *stratFile = [stratFileManager_ currentStratFile];
    if ([stratFile isChartPublishedToYammer:chart]) {
        cell.lblUnreadMessageCount.hidden = NO;
        
        // update yammer message count, looking at all networks
        NSUInteger unreadMsgCt = [[YammerCommentManager sharedManager] unreadMessageCountForChart:chart stratFile:stratFile];

        // we'll just use an empty rounded rect to indicate published for now
        cell.lblUnreadMessageCount.text = unreadMsgCt ? [NSString stringWithFormat:@"%i", unreadMsgCt] : @"";
        if (!unreadMsgCt) {
            // add a yammer icon if empty
            UIImage *img = [UIImage imageNamed:@"yammer-y"];
            UIImageView *view = [[UIImageView alloc] initWithImage:img];
            view.frame = CGRectMake(5, 3, 11, 11);
            view.alpha = 0.7;
            view.tag = 789789;
            [cell.lblUnreadMessageCount addSubview:view];
            [view release];
        } else {
            [[cell.lblUnreadMessageCount viewWithTag:789789] removeFromSuperview];
        }
    } else {
        cell.lblUnreadMessageCount.hidden = YES;
    }

    // first and last value
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"metric=%@ && value != nil && value != ''", chart.metric];
    NSArray *measurements = [DataManager arrayForEntity:NSStringFromClass([Measurement class]) 
                                   sortDescriptorsOrNil:[NSArray arrayWithObject:sortDescriptor] 
                                         predicateOrNil:predicate];        
    if (measurements.count == 1) {
        Measurement *m = (Measurement*)[measurements objectAtIndex:0];
        cell.lblFirstValue.text = [m.value stringValue];
        cell.lblMostRecent.text = [m.value stringValue];        
    } else if (measurements.count >= 2) {
        Measurement *m1 = (Measurement*)[measurements objectAtIndex:0];
        cell.lblFirstValue.text = [m1.value stringValue];
        Measurement *m2 = (Measurement*)[measurements lastObject];
        cell.lblMostRecent.text = [m2.value stringValue];        
    } else {
        cell.lblFirstValue.text = nil;
        cell.lblMostRecent.text = nil;                
    }
    
    // mini chart
    cell.miniChartView.chart = chart;
    [cell.miniChartView setNeedsDisplay];
                    
    // figure out if the trendline will exceed the target (or in some cases it is supposed to be less)
    NSDateComponents *components;
    NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];    
    NSDate *chartStartDate = [chart startDate];
    LinearRegression *lr = [[LinearRegression alloc] initWithChart:chart chartStartDate:chartStartDate];
    if (chart.metric.targetDate && [chart.metric isNumeric]) {

        // need the number of days since the starting month (ie Jan 1, 2011 in our example) of this measurement        
        components = [gregorian components:NSDayCalendarUnit
                                  fromDate:chartStartDate
                                    toDate:chart.metric.targetDate options:0];
        NSInteger dayOfYear = [components day];
        CGFloat trendVal = [lr yVal:(CGFloat)dayOfYear];
        CGFloat targetVal = chart.metric.parseNumberFromTargetValue.floatValue;

        if (chart.metric.successIndicator.intValue == SuccessIndicatorMeetOrExceed) {
            
            if (trendVal >= targetVal) {
                cell.lblOnTarget.textColor = [UIColor colorWithHexString:@"00FF00"]; // green
                cell.lblOnTarget.text = LocalizedString(@"YES", nil);
            } else {
                cell.lblOnTarget.textColor = [UIColor colorWithHexString:@"FF0000"]; // red
                cell.lblOnTarget.text = LocalizedString(@"NO", nil);
            }

        } else { // SuccessIndicatorMeetOrSubcede

            if (trendVal <= targetVal) {
                cell.lblOnTarget.textColor = [UIColor colorWithHexString:@"00FF00"]; // green
                cell.lblOnTarget.text = LocalizedString(@"YES", nil);
            } else {
                cell.lblOnTarget.textColor = [UIColor colorWithHexString:@"FF0000"]; // red
                cell.lblOnTarget.text = LocalizedString(@"NO", nil);
            }                
            
        }
        
    } else {
        cell.lblOnTarget.textColor = [UIColor whiteColor];
        cell.lblOnTarget.text = LocalizedString(@"NA", nil);
    }
    [lr release];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    NSUInteger oldPosition = [fromIndexPath row];
    NSUInteger newPosition = [toIndexPath row];
    
    if (oldPosition != newPosition) {        
        // get the charts for this section (moves are restricted to section)
        NSArray *sortedSections = [[chartDict_ allKeys] sortedArrayUsingSelector:@selector(compare:)];
        NSNumber *cat = [sortedSections objectAtIndex:[fromIndexPath section]];
        NSArray *charts = [chartDict_ objectForKey:cat];
        
        Chart *oldChart = [charts objectAtIndex:oldPosition];
        Chart *newChart = [charts objectAtIndex:newPosition];
        
        // just swap order numbers
        NSNumber *newOrder = newChart.order;
        newChart.order = oldChart.order;
        oldChart.order = newOrder;

        // save and notify
        [stratFileManager_ saveCurrentStratFile];

        // update our model 
        [self loadChartsDict];

        // need to update paging just for first chart to the right (in the cache)
        [EventManager fireChartsReorderedEvent];
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    // only permit moving a row within its own section and not into position 0, since there will be a header cell there.    
    NSUInteger row = [proposedDestinationIndexPath row] == 0 ? [sourceIndexPath row] : [proposedDestinationIndexPath row];
    return [NSIndexPath indexPathForRow:row inSection:[sourceIndexPath section]];
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {        
        NSArray *sortedSections = [[chartDict_ allKeys] sortedArrayUsingSelector:@selector(compare:)];
        NSNumber *cat = [sortedSections objectAtIndex:[indexPath section]];
        NSArray *charts = [chartDict_ objectForKey:cat];
        BOOL removeSection = ([charts count] == 1);
        
        Chart *chart = [charts objectAtIndex:[indexPath row]];
        [DataManager deleteManagedInstance:chart];
        [self loadChartsDict];
        
        // comments can be attached to charts, so we have to update counts
        [[YammerCommentManager sharedManager] updateCommentCounts];
        
        if (removeSection) {
            [tblViewCharts deleteSections:[NSIndexSet indexSetWithIndex:[indexPath section]] withRowAnimation:UITableViewRowAnimationRight];
        } else {
            [tblViewCharts deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];            
        }
        
        // save
        [stratFileManager_ saveCurrentStratFile];
        
        // Event - have to update paging
        [EventManager fireChartDeletedEvent];
        
        // if we deleted last row, put in the add theme row
        if ([chartDict_ count] == 0) {
            tblViewCharts.dataSource = noRowsTableDataSource_;
            [tblViewCharts reloadData];
        }          
    }    
}

#pragma mark - UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSArray *sortedSections = [[chartDict_ allKeys] sortedArrayUsingSelector:@selector(compare:)];
    if (![sortedSections count]) {
        return nil;
    }
    NSNumber *cat = [sortedSections objectAtIndex:section];
    
    ObjectiveType *objectiveTypeForSection = [ObjectiveType objectiveTypeForCategory:[cat intValue]];
    NSString *sectionName = [objectiveTypeForSection nameForCurrentLocale];
    
    CGRect f = CGRectMake(0, 0, tableView.bounds.size.width, 25);
    MBGradientView *gradientView = [[[MBGradientView alloc] initWithFrame:f] autorelease];
    gradientView.color1 = [UIColor colorWithHexString:@"8b8b8b"];
    gradientView.color2 = [UIColor colorWithHexString:@"444444"];
    gradientView.gradientStartPoint = [NSValue valueWithCGPoint:CGPointMake(CGRectGetMidX(f), 0)];
    gradientView.gradientEndPoint = [NSValue valueWithCGPoint:CGPointMake(CGRectGetMidX(f), 25)];
    
    f = CGRectMake(10, 3, tableView.bounds.size.width - 10, 19);
    UILabel *label = [[UILabel alloc] initWithFrame:f];
    label.font = [UIFont systemFontOfSize:16];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor blackColor];
    label.text = sectionName;
    [gradientView addSubview:label];
    [label release];
    
    return gradientView;        
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return ([self numberOfSectionsInTableView:tblViewCharts] > 0) ? 25 : 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (tblViewCharts.dataSource == noRowsTableDataSource_) {
        [self addChart];
        
    } else {
        // jump to correct chart page
        NSArray *sortedSections = [[chartDict_ allKeys] sortedArrayUsingSelector:@selector(compare:)];
        NSNumber *cat = [sortedSections objectAtIndex:[indexPath section]];
        
        NSArray *charts = [chartDict_ objectForKey:cat];    
        Chart *chart = [charts objectAtIndex:[indexPath row]];
        
        [self jumpToPageWithChart:chart];        
    }
        
}

#pragma mark - Actions

- (void)jumpToPageWithChart:(Chart*)chart
{    
    NSArray *chartList = [Chart chartsSortedByOrderForStratFile:[[StratFileManager sharedManager] currentStratFile]];
    NSInteger pageIndex = [chartList indexOfObject:chart] + 1;
    
    Chapter *chapter = [[[NavigationConfig sharedManager] chapters] objectAtIndex:ChapterIndexStratBoard];
    RootViewController *rootViewController = (RootViewController*)[[[UIApplication sharedApplication] keyWindow] rootViewController];
    [rootViewController.pageViewController loadPage:[chapter.pages objectAtIndex:pageIndex] inChapter:chapter];
}

- (IBAction)manage:(id)sender {
    UIBarButtonItem *button = (UIBarButtonItem*)sender;
    
    if (tblViewCharts.editing) {
        // switch off editing mode.
        [button setTitle:LocalizedString(@"MANAGE", nil)];
        [tblViewCharts setEditing:NO animated:YES];        
    } else {
        [button setTitle:LocalizedString(@"DONE", nil)];
        [tblViewCharts setEditing:YES animated:YES];        
    }
}

- (IBAction)addChart
{
    if (!addChartVC_) {
        addChartVC_ = [[AddChartViewController alloc] initWithNibName:nil bundle:nil];
    }
    [addChartVC_ showPopoverfromBarButtonItem:btnAddChart withMetricChooser:self];
}

- (IBAction)showMeasurements {
    // show big popover with metrics and measurements
    if (!measurementVC_) {
        measurementVC_ = [[MeasurementViewController alloc] initWithNibName:nil bundle:nil];
    }
    [measurementVC_ showPopoverInView:self.view fromRect:btnData.frame forChart:nil];    
}


- (IBAction)buyStratBoard:(id)sender {
    [storeManager_ purchaseUpgrade:productStratBoard];
    
    // don't need to worry about progress indicator, disabling, etc
}

- (IBAction)showHelpVideo:(id)sender {
    [self playHelpVideo:(UIButton*)sender];
}

#pragma mark - ContentVC overrides

- (BOOL)isEnabled
{
    // always enabled - we show an ad if no IAP
    return YES;
}

- (void)exportToPDF
{   
    // portrait
    CGRect paperRect = CGRectMake(0, 0, 72*8.5, 72*11);
    
    // each chart is a separate page, but comment reports can have multiple pages by themselves
    // the first chart is page 1, because stratboard is page 0
    
    ReportCardPrinter *printer = [[ReportCardPrinter alloc] init];
    
    // these are just local pageNumbers for the current chart
    int pageNumber = 0;
    while ([printer hasMorePages]) {
        UIGraphicsBeginPDFPageWithInfo(paperRect, nil);
        [printer drawPage:pageNumber++ inRect:paperRect];
    }
    [printer release];
}


#pragma mark - Notification handlers

- (void)refreshMiniCharts:(NSNotification*)notification
{
    [monthYearHeaderView setNeedsDisplay];
    [tblViewCharts reloadData];
}

-(void)updateYammerCommentCounts:(NSNotification*)notification
{
    [self.tblViewCharts reloadData];
}


#pragma mark - MetricChooser

- (void)metricSelected:(Metric*)chosenMetric 
{
    // we've selected a metric with which to use for adding a new chart
    
    // first order of business is to switch datasource
    tblViewCharts.dataSource = self;
    [tblViewCharts reloadData];
    
    // get rid of metric chooser
    [addChartVC_ dismissPopover];
    
    // create the new chart object
    Chart *chart = (Chart*)[DataManager createManagedInstance:NSStringFromClass([Chart class])];
    chart.metric = chosenMetric;
    
    chart.title = chosenMetric.summary;
    chart.chartType = [NSNumber numberWithInt:ChartTypeBar];
    chart.showTrend = [NSNumber numberWithBool:NO];
    chart.colorScheme = [NSNumber numberWithInt:0];
    // show the target by default, if there is a target to show
    chart.showTarget = [NSNumber numberWithBool:chosenMetric.isNumeric && chosenMetric.targetDate];
    chart.uuid = [NSString stringWithUUID];
    
    // want to add the chart to the end of the section, so we need an order number > max (chart.order) for charts in section
    NSArray *sortedSections = [[chartDict_ allKeys] sortedArrayUsingSelector:@selector(compare:)];
    NSNumber *cat = chosenMetric.objective.objectiveType.category;
    if ([sortedSections indexOfObject:cat] == NSNotFound) {
        chart.order = [NSNumber numberWithInt:0];
    } else {
        NSArray *charts = [chartDict_ objectForKey:cat];
        NSInteger maxOrder = 0;
        for (Chart *chart in charts) {
            maxOrder = MAX(maxOrder, chart.order.intValue);
        }
        chart.order = [NSNumber numberWithInt:maxOrder+1];        
    }
    
    [DataManager saveManagedInstances];
        
    // figure out if a section needs adding, or just a row
    NSSet *oldSections = [NSSet setWithArray:[chartDict_ allKeys]];
    [self loadChartsDict];
    NSInteger numSections = [self numberOfSectionsInTableView:tblViewCharts];
    if (numSections != [oldSections count]) {
        // we're adding a section - which section was added?
        NSMutableSet *newSections = [NSMutableSet setWithArray:[chartDict_ allKeys]];
        [newSections minusSet:oldSections];
        NSNumber *newSection = [newSections anyObject]; // should only be one at this point
        
        // now which section index is this?
        NSArray *sortedSections = [[chartDict_ allKeys] sortedArrayUsingSelector:@selector(compare:)];
        NSUInteger idx = [sortedSections indexOfObject:newSection];
        [tblViewCharts insertSections:[NSIndexSet indexSetWithIndex:idx] withRowAnimation:UITableViewRowAnimationMiddle];
        
        NSIndexPath *insertedRow = [NSIndexPath indexPathForRow:0 inSection:idx];        
        [tblViewCharts selectRowAtIndexPath:insertedRow animated:YES scrollPosition:UITableViewScrollPositionMiddle];
        [self performSelector:@selector(deselectRow:) withObject:insertedRow afterDelay:1.f];
    } else {
        // locate the section which contains this new chart
        NSArray *sortedSections = [[chartDict_ allKeys] sortedArrayUsingSelector:@selector(compare:)];
        NSNumber *cat = chart.metric.objective.objectiveType.category;
        NSArray *charts = [chartDict_ objectForKey:cat];
        NSIndexPath *insertedRow = [NSIndexPath indexPathForRow:[charts count]-1 
                                                      inSection:[sortedSections indexOfObject:cat]
                                    ];
        [tblViewCharts insertRowsAtIndexPaths:[NSArray arrayWithObject:insertedRow] withRowAnimation:UITableViewRowAnimationMiddle];
        [tblViewCharts selectRowAtIndexPath:insertedRow animated:YES scrollPosition:UITableViewScrollPositionMiddle];
        [self performSelector:@selector(deselectRow:) withObject:insertedRow afterDelay:1.f];
    }
    
    // update paging    
    [EventManager fireChartAddedEvent];
}
         
 -(void)deselectRow:(NSIndexPath*)indexPath
 {
     [tblViewCharts deselectRowAtIndexPath:indexPath animated:YES];
 }

-(int)metricFilters
{
    // metrics shown when tapping add must have a summary (and be part of the current stratfile)
    return MetricFilterSummary;
}

#pragma mark - StoreManagerDelegate

- (void)productTransactionStarting:(NSString *)productIdentifier
{
	DLog(@"starting: %@", productIdentifier);
	[self showProgress];
}

- (void)productTransactionFinishing:(NSString*)productIdentifier withSuccess:(BOOL)success
{
	DLog(@"finished: %@; success: %d", productIdentifier, success);
	
    if (([productIdentifier isEqualToString:kProductIdPlus_StratBoardUpgrade] ||
         [productIdentifier isEqualToString:kProductIdPlusToPremium_StratBoardUpgrade] ||
         [productIdentifier isEqualToString:kProductIdPremium_StratBoardUpgrade]
         ) && success) {
        
        // this is what controls look for throughout the app
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults]; 
        [userDefaults setValue:productIdentifier forKey:keyStratboard];
        
        // have to reload the nav, so that we can see the StratBoard
        [UpgradeManager upgradeToStratBoard];
        
        // make sure we end up on StratBoard
        RootViewController *rootViewController = (RootViewController*)[[[UIApplication sharedApplication] keyWindow] rootViewController];
        PageViewController *pageVC = rootViewController.pageViewController;
        
        Chapter *chapter = [[[NavigationConfig sharedManager] chapters] objectAtIndex:ChapterIndexStratBoard];
        [pageVC loadPage:[chapter.pages objectAtIndex:0] inChapter:chapter];
        
        [[UserNotificationDisplayManager sharedManager] showMessage:LocalizedString(@"UPGRADE_THANKS", nil)];
        
    } else if ([productIdentifier isEqualToString:kProductIdFree_Plus_Stratboard_ComboUpgrade] && success) {
        // to plus and stratboard
        
        // this is what controls look for throughout the app
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        // have to reload the nav, so that we can see the StratBoard
        [userDefaults setValue:productIdentifier forKey:keyStratboard];
        [userDefaults setValue:kProductIdFreeToPlusUpgrade forKey:keyProductId];
        
        [UpgradeManager upgradeToPlusWithStratBoard];
        
        // make sure we end up on StratBoard
        RootViewController *rootViewController = (RootViewController*)[[[UIApplication sharedApplication] keyWindow] rootViewController];
        PageViewController *pageVC = rootViewController.pageViewController;

        Chapter *chapter = [[[NavigationConfig sharedManager] chapters] objectAtIndex:ChapterIndexStratBoard];
        [pageVC loadPage:[chapter.pages objectAtIndex:0] inChapter:chapter];

        [[UserNotificationDisplayManager sharedManager] showMessage:LocalizedString(@"UPGRADE_THANKS", nil)];
    }
	
	[self hideProgress];
}


- (void)productsReceived:(NSArray*)products withError:(NSError *)error
{
    if (error == nil) {
                
        // these are all the IAPs for the relevant edition (ie Free)
        NSSet *iaps = [NSSet setWithArray:[[EditionManager sharedManager] inAppPurchasesForProduct]];
        
        // some of them may/may not apply if we have upgraded/not upgraded
        for (SKProduct *product in products) {
            DLog(@"prod: %@, %@, %@, %@", product.productIdentifier, product.localizedTitle, product.localizedDescription, [StoreManager priceAsString:product]);
            
            // only add a product id if it also exists in iaps; there should only be one
            if ([iaps containsObject:product.productIdentifier]) {
                self.productStratBoard = product;
                btnTitle_ = [[NSString stringWithFormat:LocalizedString(@"BUY_STRATBOARD", nil), [StoreManager priceAsString:product]] retain];
                [self hideProgress];
                break;
            }
        }
                
    } else {
        // couldn't connect to app store
        btnTitle_ = LocalizedString(@"OFFLINE", nil);
        [self hideProgress];
        [btnBuyStratBoard setEnabled:NO];
        
        // show message
        [youTubeView loadErrorText:LocalizedString(@"OFFLINE_INSTRUCTIONS", nil)];

        NSString *errorText = error.localizedDescription;
        NSString *format = [errorText hasSuffix:@"."] ? @" %@" : @". %@";
        errorText = [errorText stringByAppendingFormat:format, LocalizedString(@"UPGRADE_TRY_LATER", nil)];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"ERROR", nil)
														message:errorText
													   delegate:nil
											  cancelButtonTitle:LocalizedString(@"OK", nil)
											  otherButtonTitles:nil];
		[alert show];
		[alert release];

    }
    
}

- (void)restoreFailed
{
    // can't restore from this UI
}

- (void)restoreCompleted
{
    // don't do anything here either
}

- (void)showProgress
{
    [btnBuyStratBoard setTitle:@"" forState:UIControlStateNormal];
    [btnBuyStratBoard setEnabled:NO];
    [purchaseIndicator_ startAnimating];
}

- (void)hideProgress
{
    [btnBuyStratBoard setTitle:btnTitle_ forState:UIControlStateNormal];
    [btnBuyStratBoard setEnabled:YES];
    [purchaseIndicator_ stopAnimating];    
}

- (NSString*)stratBoardProductId
{
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return [evaluatedObject hasSuffix:@"stratbord"];
    }];
    NSArray *productIds = [[[EditionManager sharedManager] inAppPurchasesForProduct] filteredArrayUsingPredicate:predicate];
    return [productIds lastObject];
}

#pragma mark - UIWebViewDelegate (from Youtube view)

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([request.URL.scheme isEqualToString:@"refresh"]) {
        [self refresh];
        return NO;
    } else {
        return YES;
    }
}

#pragma mark - Private

- (void)refresh
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    if (reachability.isReachable) {
        [youTubeView loadVideo:@"http://www.youtube.com/embed/dOSJ16Gxvdw?hd=1&rel=0"];
        [storeManager_ requestProductData];
        [self showProgress];        
    } else {
        NSError *error = [NSError errorWithDomain:@"com.stratpad.error.offline" 
                                             code:503 
                                         userInfo:[NSDictionary dictionaryWithObject:LocalizedString(@"ERROR_NO_NETWORK", nil) 
                                                                              forKey:NSLocalizedDescriptionKey]];
        [self productsReceived:nil withError:error];
    }

}

-(void)addYammerCommentsButton
{
    [self addYammerCommentsButtonToView:headerView];
}


# pragma mark - Help Video

// @override
-(BOOL)hasVideo
{
    return [[[LocalizedManager sharedManager] localeIdentifier] hasPrefix:@"en"];
}

// @override
-(NSString*)helpVideoURL
{
    //return @"http://player.vimeo.com/external/70704175.m3u8?p=high,standard,mobile&s=e049eb75a0460121fe09683557eae8d5";
    NSString* path = [[NSBundle mainBundle] pathForResource:@"SP_Train" ofType:@"mp4"];
    return path;
}



@end
