//
//  ChartSelectionViewController.m
//  StratPad
//
//  Created by Julian Wood on 12-06-19.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "ChartSelectionViewController.h"
#import "UIColor-Expanded.h"
#import "Chart.h"
#import "StratFileManager.h"
#import "ObjectiveType.h"
#import "Metric.h"
#import "Objective.h"
#import "ChartSelectionCell.h"
#import "Theme.h"
#import "ActionsMenuViewController.h"
#import "NSUserDefaults+StratPad.h"

@interface ChartSelectionViewController ()

@end

@implementation ChartSelectionViewController

@synthesize tblCharts;
@synthesize btnAction;

#pragma mark - Lifecycle

- (id)initWithAction:(StratCardAction)stratCardAction
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        stratCardAction_ = stratCardAction;
        
        // popover window title
        self.title = LocalizedString(@"SELECT_CHARTS", nil);
        
        [self loadChartsDict];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // there is a view on top of the clear background, so let the view color show through
    tblCharts.backgroundView = nil;
    tblCharts.clipsToBounds = YES;
            
    UIImage *btnBlue = [[UIImage imageNamed:@"btn-large-blue.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:0];
    [btnAction setBackgroundImage:btnBlue forState:UIControlStateNormal];
    [btnAction setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnAction setTitleShadowColor:[[UIColor blackColor] colorWithAlphaComponent:0.3] forState:UIControlStateNormal];
    [btnAction.titleLabel setShadowOffset:CGSizeMake(0, -1)];
    [btnAction.titleLabel setFont:[UIFont boldSystemFontOfSize:19]];
    
    // could be print or email
    NSString *key = [NSString stringWithFormat:@"STRATCARD_ACTION_%i", stratCardAction_];
    NSString *actionString = LocalizedString(key, nil);
    [btnAction setTitle:[NSString stringWithFormat:@"%@ %@", actionString, LocalizedString(@"REPORT_CARD", nil)] forState:UIControlStateNormal];
        
    // check mark button in nav
    UIBarButtonItem *barBtnItemToggleCheckAll = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"check-white.png"] 
                                                                                 style:UIBarButtonItemStyleBordered
                                                                                target:self
                                                                                action:@selector(toggleCheckAll)];
    // use the tag to indicate state; >0 means all checked
    barBtnItemToggleCheckAll.tag = 1;
    [self.navigationItem setRightBarButtonItem:barBtnItemToggleCheckAll];
    [barBtnItemToggleCheckAll release];    
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


- (void)viewDidUnload
{
    [self setTblCharts:nil];
    [self setBtnAction:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // add a fade at the bottom of the tableview
    if (!maskLayer_)
    {
        maskLayer_ = [CAGradientLayer layer];
        
        CGColorRef outerColor = [[UIColor colorWithHexString:@"E1E4E9"] colorWithAlphaComponent:1.f].CGColor;
        CGColorRef innerColor = [UIColor colorWithWhite:1.0 alpha:0.0].CGColor;
        
        maskLayer_.colors = [NSArray arrayWithObjects:      (id)innerColor,                 (id)outerColor,                 nil];
        maskLayer_.locations = [NSArray arrayWithObjects:   [NSNumber numberWithFloat:0.9], [NSNumber numberWithFloat:1.0], nil];
        
        maskLayer_.bounds = CGRectMake(0, 0,
                                      tblCharts.frame.size.width,
                                      tblCharts.frame.size.height);
        maskLayer_.anchorPoint = CGPointZero;
        
        [self.view.layer addSublayer:maskLayer_];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [tblCharts flashScrollIndicators];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)dealloc {
    [tblCharts release];
    [btnAction release];
    [super dealloc];
}

// @override: this will make it so that the popover doesn't expand to full height
-(CGSize)contentSizeForViewInPopover
{
    return CGSizeMake(self.view.bounds.size.width, 100);
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChartSelectionCell *cell = (ChartSelectionCell*)[tableView cellForRowAtIndexPath:indexPath];
    BOOL isSelected = cell.accessoryType == UITableViewCellAccessoryCheckmark;
    BOOL willBeSelected = !isSelected;
    [self setShouldPrintChart:cell.uuid shouldPrintChart:willBeSelected];
    cell.accessoryType = willBeSelected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSArray *sortedSections = [[chartDict_ allKeys] sortedArrayUsingSelector:@selector(compare:)];
    if (![sortedSections count]) {
        return nil;
    }
    NSNumber *cat = [sortedSections objectAtIndex:section];
    
    ObjectiveType *objectiveTypeForSection = [ObjectiveType objectiveTypeForCategory:[cat intValue]];
    NSString *sectionName = [objectiveTypeForSection nameForCurrentLocale];
    return sectionName;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64.f;
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *chartSelectionCellIdentifier = @"ChartSelectionCell";
        
    NSArray *sortedSections = [[chartDict_ allKeys] sortedArrayUsingSelector:@selector(compare:)];
    NSNumber *cat = [sortedSections objectAtIndex:[indexPath section]];
    NSArray *charts = [chartDict_ objectForKey:cat];
    
    ChartSelectionCell *cell = [tableView dequeueReusableCellWithIdentifier:chartSelectionCellIdentifier];
    if (cell == nil) {
        // not localized
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:chartSelectionCellIdentifier owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    
    Chart *chart = [charts objectAtIndex:[indexPath row]];
    cell.lblChartTitle.text = chart.title;
    cell.lblChartTheme.text = chart.metric.objective.theme.title;
    cell.lblChartObjective.text = chart.metric.objective.summary;
    cell.uuid = chart.uuid;
    
    // see if this chart is selected by grabbing a bool from defaults for this chart
    BOOL isSelected = [self shouldPrintChart:chart.uuid];

    cell.accessoryType = isSelected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    return cell;
}


#pragma mark - Actions

-(void)toggleCheckAll
{
    // let's abuse the tag; if non-zero then that means we've checked all
    UIBarButtonItem *btnCheck = self.navigationItem.rightBarButtonItem;
    BOOL areAllChecked = btnCheck.tag > 0;
    btnCheck.tag = areAllChecked ? 0 : 1;
    
    // update the user defaults, and then reload the table
    NSMutableDictionary *chartPrintingDict = [NSMutableDictionary dictionary];
    NSArray *sections = [chartDict_ allKeys];
    for (NSNumber *cat in sections) {
        NSArray *charts = [chartDict_ objectForKey:cat];
        for (Chart *chart in charts) {
            [chartPrintingDict setObject:[NSNumber numberWithBool:!areAllChecked] forKey:chart.uuid];
        }
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:chartPrintingDict forKey:keyChartPrinting];
    
    [tblCharts reloadData];
}

- (IBAction)printOrEmailFile 
{
    // activity indicator
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    CGSize aSize = indicator.frame.size;
    
    indicator.frame = CGRectMake(btnAction.frame.size.width - aSize.width - 10,
                                 (btnAction.frame.size.height-aSize.height)/2,
                                 indicator.frame.size.width, indicator.frame.size.height);
    
    [btnAction addSubview:indicator];
    [indicator startAnimating];
    [indicator release];
    
    // just send this back to the actionMenuVC
    ActionsMenuViewController *amvc = (ActionsMenuViewController*)[[self.navigationController viewControllers] objectAtIndex:0];
    if (stratCardAction_ == StratCardActionEmail) {
        [amvc performSelector:@selector(emailStratCard) withObject:nil afterDelay:0.1];
    } else {
        [amvc performSelector:@selector(printStratCard) withObject:nil afterDelay:0.1];
    }
}

#pragma mark - Private

-(BOOL)shouldPrintChart:(NSString*)chartUUID
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *chartPrintingDict = [defaults objectForKey:keyChartPrinting];

    NSNumber *isSelectedValue = [chartPrintingDict objectForKey:chartUUID];
    
    BOOL isSelected;
    if (isSelectedValue) {
        isSelected = [isSelectedValue boolValue];
    } else {
        // no value recorded yet, so default to YES and update NSUserDefaults
        isSelected = YES;
        [self setShouldPrintChart:chartUUID shouldPrintChart:YES];
    }

    return isSelected;
}

-(void)setShouldPrintChart:(NSString*)chartUUID shouldPrintChart:(BOOL)shouldPrintChart
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *chartPrintingDict = [defaults objectForKey:keyChartPrinting];
    if (!chartPrintingDict) {
        chartPrintingDict = [NSDictionary dictionary];
    }
    NSMutableDictionary *mdict = [chartPrintingDict mutableCopy];
    [mdict setObject:[NSNumber numberWithBool:shouldPrintChart] forKey:chartUUID];
    [defaults setObject:mdict forKey:keyChartPrinting];
    [mdict release];
}

@end
