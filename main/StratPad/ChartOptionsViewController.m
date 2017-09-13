//
//  ChartOptionsViewController.m
//  StratPad
//
//  Created by Julian Wood on 12-03-29.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "ChartOptionsViewController.h"
#import "RootViewController.h"
#import "BooleanTableViewCell.h"
#import "Metric.h"
#import "ChartOptionsCell.h"
#import "StratFileManager.h"
#import "ColorCell.h"
#import "DataManager.h"
#import "NSString-Expanded.h"
#import "EventManager.h"

// these need to match the positions in the options_ array
#define titleCellRowIndex 0
#define chartTypeCellRowIndex 1
#define chartMaxValueCellRowIndex 2
#define colorCellRowIndex 5
#define overlayCellRowIndex 6

@interface ChartOptionsViewController ()
@end

@implementation ChartOptionsViewController
@synthesize tblOptions;

- (id)initWithChart:(Chart*)chart andRedrawableChart:(id<RedrawableChart>)redrawableChart
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.title = LocalizedString(@"CHART_OPTIONS_TITLE", nil);
        chart_ = chart;
        redrawableChart_ = redrawableChart;
        cellBuilder_ = [[ChartOptionsCellBuilder alloc] initWithChart:chart_ andTableView:tblOptions];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSAssert(chart_ != nil, @"You have to provide a valid chart object in the init.");
    DLog(@"chart: %@", chart_);

    tblOptions.clipsToBounds = YES;
    
    // any changes here (ie. reordering) must be reflected in #defines
    options_ = [NSArray arrayWithObjects:
                
                // only 1 section
                [NSMutableDictionary dictionaryWithObjectsAndKeys:
                 [NSArray arrayWithObjects:
                  [NSDictionary dictionaryWithObjectsAndKeys:
                   @"cellForTitle", @"constructor",
                   @"selectTitleCell:", @"action",
                   nil],
                  [NSDictionary dictionaryWithObjectsAndKeys:
                   @"cellForChartType", @"constructor",
                   @"selectChartTypeCell:", @"action",
                   nil],
                  [NSDictionary dictionaryWithObjectsAndKeys:
                   @"cellForChartMaxValue", @"constructor",
                   @"selectChartMaxValueCell:", @"action",
                   nil],
                  [NSDictionary dictionaryWithObjectsAndKeys:
                   @"cellForTrend", @"constructor",
                   nil],
                  [NSDictionary dictionaryWithObjectsAndKeys:
                   @"cellForTarget", @"constructor",
                   nil],
                  [NSDictionary dictionaryWithObjectsAndKeys:
                   @"cellForColor", @"constructor",
                   @"selectColorCell:", @"action",
                   nil],
                  [NSDictionary dictionaryWithObjectsAndKeys:
                   @"cellForOverlay", @"constructor",
                   @"selectOverlayCell:", @"action",
                   nil],
                  nil], @"rows",
                 nil, @"sectionTitle",
                 nil],
                
                nil];
    
    [options_ retain];
    
    self.navigationItem.backBarButtonItem =
    [[[UIBarButtonItem alloc] initWithTitle:LocalizedString(@"CHART_OPTIONS_BACK_TITLE", nil)
                                      style:UIBarButtonItemStyleBordered
                                     target:nil
                                     action:nil] autorelease];
}

- (void)viewDidUnload
{
    [self setTblOptions:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)dealloc
{
    [cellBuilder_ release];
    [popoverController_ release];
    [tblOptions release];
    [super dealloc];
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {

    if (viewController == self) {
        // deselect the selected row
        [tblOptions deselectRowAtIndexPath:[tblOptions indexPathForSelectedRow] animated:YES];
        
        // hack: this resize only works properly *after* the initial load
        if (doResize_) {
            CGSize contentSize = [self contentSizeForViewInPopover];
            contentSize = CGSizeMake(contentSize.width, contentSize.height+40);
            [popoverController_ setPopoverContentSize:contentSize animated:YES];
        } else {
            doResize_ = YES;
        }
    } 
    else if ([viewController isKindOfClass:[OverlayOptionsViewController class]]) {
        OverlayOptionsViewController *vc = (OverlayOptionsViewController*)viewController;
        [vc.tblOverlayOptions deselectRowAtIndexPath:[vc.tblOverlayOptions indexPathForSelectedRow] animated:YES];
        
        [popoverController_ setPopoverContentSize:[vc contentSizeForViewInPopover] animated:YES];
    } 
    else if ([viewController isKindOfClass:[ChartTypeViewController class]]) {
        ChartTypeViewController *vc = (ChartTypeViewController*)viewController;        
        [popoverController_ setPopoverContentSize:[vc contentSizeForViewInPopover] animated:YES];
    } 
    else if ([viewController isKindOfClass:[ChartMaxValueViewController class]]) {
        ChartMaxValueViewController *vc = (ChartMaxValueViewController*)viewController;        
        [popoverController_ setPopoverContentSize:[vc contentSizeForViewInPopover] animated:YES];
    }
    
}

#pragma mark - UIPopoverControllerDelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    // catch all
    [[StratFileManager sharedManager] saveCurrentStratFile];

    [popoverController_ release];
	popoverController_ = nil;	    
}

// @override: this will make it so that the popover doesn't expand to full height
-(CGSize)contentSizeForViewInPopover
{
    // see hack in navigationController:didShowViewController:animated: for how we deal with inconsistent display of contentSize
    CGFloat rowHeight = [self tableView:tblOptions heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    NSInteger numRows = [self tableView:tblOptions numberOfRowsInSection:0];
    return CGSizeMake(self.view.bounds.size.width, numRows*rowHeight);
}

#pragma mark - Public

- (void)showPopoverInView:(UIView*)view fromRect:(CGRect)rect
{		    
    if (popoverController_) {
        [popoverController_ release]; popoverController_ = nil;		
    }
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self];
    navController.delegate = self;
    popoverController_ = [[UIPopoverController alloc] initWithContentViewController:navController];
    [navController release];
    popoverController_.delegate = self;
    [popoverController_ presentPopoverFromRect:rect
                                        inView:view
                      permittedArrowDirections:UIPopoverArrowDirectionUp
                                      animated:YES];	
}

- (void)dismissPopover
{
    // catch all
    [[StratFileManager sharedManager] saveCurrentStratFile];

    [popoverController_ dismissPopoverAnimated:YES];
	[popoverController_ release];
	popoverController_ = nil;
}

#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    NSDictionary *sectionDict = [options_ objectAtIndex:[indexPath section]];
    NSArray *rows = [sectionDict objectForKey:@"rows"];
    NSDictionary *rowDict = [rows objectAtIndex:[indexPath row]];
    
    SEL action = NSSelectorFromString([rowDict objectForKey:@"action"]);
    if (action) {
        [self performSelector:action withObject:indexPath];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return [options_ count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[options_ objectAtIndex:section] objectForKey:@"rows"] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[options_ objectAtIndex:section] objectForKey:@"sectionTitle"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{  
    NSArray *sectionItems = [[options_ objectAtIndex:[indexPath section]] objectForKey:@"rows"];
    NSDictionary *rowDict = [sectionItems objectAtIndex:[indexPath row]];
    
    SEL cellConstructor = NSSelectorFromString([rowDict objectForKey:@"constructor"]);
    UITableViewCell *cell = [self performSelector:cellConstructor];
    return cell;    
}

#pragma mark - Cell Construction

- (UITableViewCell*)cellForTitle
{
    return [cellBuilder_ cellForTitle];
}

- (UITableViewCell*)cellForChartType
{
    return [cellBuilder_ cellForChartType];
}

- (UITableViewCell*)cellForChartMaxValue
{
    return [cellBuilder_ cellForChartMaxValue];
}

- (BooleanTableViewCell*)cellForTrend
{
    return [cellBuilder_ booleanCellWithTitle:LocalizedString(@"SHOW_TREND", nil)
                                      binding:@"showTrend"
                                       onText:LocalizedString(@"SWITCH_YES", nil)
                                      offText:LocalizedString(@"SWITCH_NO", nil)
                                       target:self
                                       action:@selector(saveSwitchSetting:)];
}

- (BooleanTableViewCell*)cellForTarget
{
    return [cellBuilder_ booleanCellWithTitle:LocalizedString(@"SHOW_TARGET", nil)
                                      binding:@"showTarget"
                                       onText:LocalizedString(@"SWITCH_YES", nil)
                                      offText:LocalizedString(@"SWITCH_NO", nil)
                                       target:self
                                       action:@selector(saveSwitchSetting:)];
}

- (ColorCell*)cellForColor
{
    return [cellBuilder_ cellForColor];
}

- (UITableViewCell*)cellForOverlay
{
    return [cellBuilder_ cellForOverlay];
}

#pragma mark - Actions

- (void)saveSwitchSetting:(MBBindableRoundSwitch*)sender
{
    NSNumber *currVal = [chart_ valueForKey:sender.binding];
    NSNumber *newVal = [NSNumber numberWithBool:sender.isOn];
    
    if (!currVal || [currVal compare:newVal] != NSOrderedSame) {
        // save param
        [chart_ setValue:[NSNumber numberWithBool:sender.isOn] forKey:sender.binding];
        [[StratFileManager sharedManager] saveCurrentStratFile];
        
        // redraw chart
        [self updateChart];
    }
}

- (void)selectTitleCell:(NSIndexPath*)indexPath
{
    TitleViewController *vc = [[TitleViewController alloc] initWithChart:chart_ andTitleChooser:self];
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
}

- (void)selectColorCell:(NSIndexPath*)indexPath
{
    ColorChooserViewController *vc = [[ColorChooserViewController alloc] initWithChart:chart_ andColorChooser:self];
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
}

- (void)selectChartTypeCell:(NSIndexPath*)indexPath
{
    ChartTypeViewController *vc = [[ChartTypeViewController alloc] initWithChart:chart_ andChartTypeChooser:self];
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
}

- (void)selectChartMaxValueCell:(NSIndexPath*)indexPath
{
    ChartMaxValueViewController *vc = [[ChartMaxValueViewController alloc] initWithChart:chart_ andChartMaxValueChooser:self];
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
}

- (void)selectOverlayCell:(NSIndexPath*)indexPath
{
    // stratfiles may have a reference to an overlay that doesn't exist
    // this happens if you create an overlay, and then go back to using no overlay (charttype = None), so need to be defensive
    // we need to keep it around, because it is the backing store for the options that you're looking at if you change to None
    // make sure primary chart has an overlay
    Chart *overlay = [Chart chartWithUUID:chart_.overlay];
    if (!overlay) {
        Chart *chartOverlay = (Chart*)[DataManager createManagedInstance:NSStringFromClass([Chart class])];
        chartOverlay.zLayer = overlayChartLayer;
        chartOverlay.title = nil;
        chartOverlay.chartType = [NSNumber numberWithInt:ChartTypeNone];
        chartOverlay.showTrend = [NSNumber numberWithBool:NO];
        chartOverlay.colorScheme = [NSNumber numberWithInt:0];
        chartOverlay.showTarget = [NSNumber numberWithBool:NO];
        chartOverlay.metric = nil; // we haven't chosen it yet
        chartOverlay.order = nil; // not relevant
        chartOverlay.uuid = [NSString stringWithUUID];
        
        chart_.overlay = chartOverlay.uuid;
        [DataManager saveManagedInstances];
    }
    
    OverlayOptionsViewController *vc = [[OverlayOptionsViewController alloc] initWithChart:chart_ andOverlayChooser:self];
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];    
}

#pragma mark - ColorChooser

- (void)colorSelected
{
    NSIndexPath *selectedRow = [NSIndexPath indexPathForRow:colorCellRowIndex inSection:0];
    [tblOptions reloadRowsAtIndexPaths:[NSArray arrayWithObject:selectedRow] withRowAnimation:UITableViewRowAnimationFade];
    [tblOptions selectRowAtIndexPath:selectedRow animated:NO scrollPosition:UITableViewScrollPositionNone];
    [self updateChart];
}

#pragma mark - ChartTypeChooser

- (void)chartTypeSelected
{
    NSIndexPath *selectedRow = [NSIndexPath indexPathForRow:chartTypeCellRowIndex inSection:0];
    [tblOptions reloadRowsAtIndexPaths:[NSArray arrayWithObject:selectedRow] withRowAnimation:UITableViewRowAnimationFade];
    [tblOptions selectRowAtIndexPath:selectedRow animated:NO scrollPosition:UITableViewScrollPositionNone];
    [self updateChart];
}

#pragma mark - OverlayChooser

- (void)overlayUpdated
{
    NSIndexPath *selectedRow = [NSIndexPath indexPathForRow:overlayCellRowIndex inSection:0];
    [tblOptions reloadRowsAtIndexPaths:[NSArray arrayWithObject:selectedRow] withRowAnimation:UITableViewRowAnimationFade];
    [tblOptions selectRowAtIndexPath:selectedRow animated:NO scrollPosition:UITableViewScrollPositionNone];
    [self updateChart];    
}

#pragma mark - TitleChooser

- (void)titleChosen
{
    NSIndexPath *selectedRow = [NSIndexPath indexPathForRow:titleCellRowIndex inSection:0];
    [tblOptions reloadRowsAtIndexPaths:[NSArray arrayWithObject:selectedRow] withRowAnimation:UITableViewRowAnimationFade];
    [tblOptions selectRowAtIndexPath:selectedRow animated:NO scrollPosition:UITableViewScrollPositionNone];
    [self updateChart];    
}

#pragma mark - ChartMaxValueChooser

- (void)maxValueEntered
{
    NSIndexPath *selectedRow = [NSIndexPath indexPathForRow:chartMaxValueCellRowIndex inSection:0];
    [tblOptions reloadRowsAtIndexPaths:[NSArray arrayWithObject:selectedRow] withRowAnimation:UITableViewRowAnimationFade];
    [tblOptions selectRowAtIndexPath:selectedRow animated:NO scrollPosition:UITableViewScrollPositionNone];
    [self updateChart];    
}

#pragma mark - Private

-(void)updateChart
{
    [redrawableChart_ redrawChart];
    
    // send notification to stratboard that charts have updated, so that mini-charts can update (eg color)
    [EventManager fireChartOptionsChangedEvent:chart_];
}

@end
