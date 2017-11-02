//
//  OverlayOptionsViewController.m
//  StratPad
//
//  Created by Julian Wood on 12-04-03.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "OverlayOptionsViewController.h"
#import "StratFileManager.h"
#import "DataManager.h"
#import "StratFile.h"
#import "UIColor-Expanded.h"

#define chartTypeCellRowIndex 0
#define metricCellRowIndex 1
#define chartMaxValueCellRowIndex 2
#define colorCellRowIndex 5

#define disabledColor [UIColor colorWithHexString:@"E6E6E6"]


@interface OverlayOptionsViewController ()

@end

@implementation OverlayOptionsViewController

@synthesize tblOverlayOptions;

- (id)initWithChart:(Chart*)chart andOverlayChooser:(id<OverlayChooser>)overlayChooser;
{
    self = [super initWithNibName:NSStringFromClass([OverlayOptionsViewController class]) bundle:nil];
    if (self) {
        chart_ = chart;
        NSAssert(chart_ != nil, @"You have to provide a valid chart object in the init.");

        chartOverlay_ = [Chart chartWithUUID:chart.overlay];
        NSAssert(chartOverlay_ != nil, @"You have to provide a valid chart.overlay string in the chart.");

        overlayChooser_ = overlayChooser;
        NSAssert(overlayChooser_ != nil, @"You have to provide a valid OverlayChooser object in the init.");
        
        cellBuilder_ = [[ChartOptionsCellBuilder alloc] initWithChart:chartOverlay_ andTableView:tblOverlayOptions];
        self.title = LocalizedString(@"OVERLAY_OPTIONS_TITLE", nil);
    }
    return self;
}

- (void)viewDidLoad
{    
    options_ = [NSArray arrayWithObjects:
                
                // only 1 section
                [NSMutableDictionary dictionaryWithObjectsAndKeys:
                 [NSArray arrayWithObjects:
                  [NSDictionary dictionaryWithObjectsAndKeys:
                   @"cellForChartType", @"constructor",
                   @"selectChartTypeCell:", @"action",
                   nil],
                  [NSDictionary dictionaryWithObjectsAndKeys:
                   @"cellForMetric", @"constructor",
                   @"selectMetricCell:", @"action",
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
                  nil], @"rows",
                 nil, @"sectionTitle",
                 nil],
                
                nil];
    
    [options_ retain];
    
    self.navigationItem.backBarButtonItem =
    [[[UIBarButtonItem alloc] initWithTitle:LocalizedString(@"OVERLAY_OPTIONS_BACK_TITLE", nil)
                                      style:UIBarButtonItemStyleBordered
                                     target:nil
                                     action:nil] autorelease];


    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [self setTblOverlayOptions:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

// @override: this will make it so that the popover doesn't expand to full height
-(CGSize)contentSizeForViewInPopover
{
    CGFloat rowHeight = [self tableView:tblOverlayOptions heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    NSInteger numRows = [self tableView:tblOverlayOptions numberOfRowsInSection:0];
    return CGSizeMake(self.view.bounds.size.width, numRows*rowHeight + 40);
}

- (void)dealloc {
    [cellBuilder_ release];
    [tblOverlayOptions release];
    [super dealloc];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL disabled = (chartOverlay_.chartType.intValue == ChartTypeComments);
    if (disabled && ([indexPath row] == metricCellRowIndex || [indexPath row] == chartMaxValueCellRowIndex)) {
        return;
    }
    
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

- (UITableViewCell*)cellForMetric
{
    UITableViewCell *cell = [cellBuilder_ cellForMetric];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    BOOL disabled = (chartOverlay_.chartType.intValue == ChartTypeComments);
    if (disabled) {
        UIView *disabledView = [[UIView alloc] initWithFrame:cell.frame];
        disabledView.backgroundColor = disabledColor;
        cell.backgroundView = disabledView;
        [disabledView release];

        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else {
        cell.backgroundView = nil;
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    
    return cell;
}

- (UITableViewCell*)cellForChartType
{
    return [cellBuilder_ cellForChartType];
}

- (UITableViewCell*)cellForChartMaxValue
{
    UITableViewCell *cell = [cellBuilder_ cellForChartMaxValue];
    
    BOOL disabled = (chartOverlay_.chartType.intValue == ChartTypeComments);
    if (disabled) {
        UIView *disabledView = [[UIView alloc] initWithFrame:cell.frame];
        disabledView.backgroundColor = disabledColor;
        cell.backgroundView = disabledView;
        [disabledView release];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.detailTextLabel.text = LocalizedString(@"NA", nil);
    } else {
        cell.backgroundView = nil;
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    
    return cell;
}

- (BooleanTableViewCell*)cellForTrend
{
    BooleanTableViewCell *cell = [cellBuilder_ booleanCellWithTitle:LocalizedString(@"SHOW_TREND", nil)
                                                            binding:@"showTrend"
                                                             onText:LocalizedString(@"SWITCH_YES", nil)
                                                            offText:LocalizedString(@"SWITCH_NO", nil)
                                                             target:self
                                                             action:@selector(saveSwitchSetting:)];
    BOOL disabled = (chartOverlay_.chartType.intValue == ChartTypeComments);
    cell.switchOption.disabled = disabled;
    cell.contentView.backgroundColor = disabled ? disabledColor: [UIColor clearColor];
    return cell;
}

- (BooleanTableViewCell*)cellForTarget
{
    BooleanTableViewCell *cell = [cellBuilder_ booleanCellWithTitle:LocalizedString(@"SHOW_TARGET", nil)
                                                            binding:@"showTarget"
                                                             onText:LocalizedString(@"SWITCH_YES", nil)
                                                            offText:LocalizedString(@"SWITCH_NO", nil)
                                                             target:self
                                                             action:@selector(saveSwitchSetting:)];
    BOOL disabled = (chartOverlay_.chartType.intValue == ChartTypeComments);
    cell.switchOption.disabled = disabled;
    cell.contentView.backgroundColor = disabled ? disabledColor: [UIColor clearColor];
    return cell;
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
    NSNumber *currVal = [chartOverlay_ valueForKey:sender.binding];
    NSNumber *newVal = [NSNumber numberWithBool:sender.isOn];
    
    if (!currVal || [currVal compare:newVal] != NSOrderedSame) {
        // save param
        [chartOverlay_ setValue:[NSNumber numberWithBool:sender.isOn] forKey:sender.binding];
        [[StratFileManager sharedManager] saveCurrentStratFile];
        
        // notify && redraw
        [overlayChooser_ overlayUpdated];
    }
}

- (void)selectMetricCell:(NSIndexPath*)indexPath
{    
    // get the relevant metrics for this stratfile
    StratFile *stratFile = [[StratFileManager sharedManager] currentStratFile];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"objective.theme.stratFile=%@ && summary!=nil", stratFile];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"summary" ascending:YES];
    NSArray *metrics = [DataManager arrayForEntity:NSStringFromClass([Metric class]) sortDescriptorsOrNil:[NSArray arrayWithObject:sortDescriptor] predicateOrNil:predicate];
    
    MetricChooserViewController *vc = [[MetricChooserViewController alloc] initWithMetrics:metrics 
                                                                              chosenMetric:chartOverlay_.metric 
                                                                          andMetricChooser:self];
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
}

- (void)selectColorCell:(NSIndexPath*)indexPath
{
    ColorChooserViewController *vc = [[ColorChooserViewController alloc] initWithChart:chartOverlay_ andColorChooser:self];
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
}

- (void)selectChartTypeCell:(NSIndexPath*)indexPath
{
    ChartTypeViewController *vc = [[ChartTypeViewController alloc] initWithChart:chartOverlay_ andChartTypeChooser:self];
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
}

- (void)selectChartMaxValueCell:(NSIndexPath*)indexPath
{
    ChartMaxValueViewController *vc = [[ChartMaxValueViewController alloc] initWithChart:chartOverlay_ andChartMaxValueChooser:self];
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
}


#pragma mark - ColorChooser

- (void)colorSelected
{
    // notify && redraw cell in parent
    [overlayChooser_ overlayUpdated];

    // update cell and reselect it so we can have a nice deselection
    NSIndexPath *selectedRow = [NSIndexPath indexPathForRow:colorCellRowIndex inSection:0];
    [tblOverlayOptions reloadRowsAtIndexPaths:[NSArray arrayWithObject:selectedRow] withRowAnimation:UITableViewRowAnimationFade];
    [tblOverlayOptions selectRowAtIndexPath:selectedRow animated:NO scrollPosition:UITableViewScrollPositionNone];
}

#pragma mark - ChartTypeChooser

- (void)chartTypeSelected
{
    // if we chose comments, then disable other cells except for color
    // also auto-select the parent metric - but display none
    if (chartOverlay_.chartType.intValue == ChartTypeComments) {
        chartOverlay_.metric = chart_.metric;
        chartOverlay_.showTrend = NO;
        chartOverlay_.showTarget = NO;
        chartOverlay_.yAxisMax = nil;
    }
    
    // notify && redraw cell in parent
    [overlayChooser_ overlayUpdated];

    // update cell and reselect it so we can have a nice deselection
    NSIndexPath *selectedRow = [NSIndexPath indexPathForRow:chartTypeCellRowIndex inSection:0];
    [tblOverlayOptions reloadData];
    [tblOverlayOptions selectRowAtIndexPath:selectedRow animated:NO scrollPosition:UITableViewScrollPositionNone];
}

#pragma mark - MetricChooser

-(void)metricSelected:(Metric*)chosenMetric
{
    // update entity
    [chartOverlay_ setMetric:chosenMetric];
    [[StratFileManager sharedManager] saveCurrentStratFile];
    
    // notify && redraw
    [overlayChooser_ overlayUpdated];
    
    // update UI
    NSIndexPath *selectedRow = [NSIndexPath indexPathForRow:metricCellRowIndex inSection:0];
    NSIndexPath *maxValueRow = [NSIndexPath indexPathForRow:chartMaxValueCellRowIndex inSection:0];
    [tblOverlayOptions reloadRowsAtIndexPaths:[NSArray arrayWithObjects:selectedRow, maxValueRow, nil] withRowAnimation:UITableViewRowAnimationFade];
    [tblOverlayOptions selectRowAtIndexPath:selectedRow animated:NO scrollPosition:UITableViewScrollPositionNone];
}

-(int)metricFilters
{
    // metrics shown for choosing an overlay metric must have a summary (and be part of the current stratfile)
    return MetricFilterSummary;
}

#pragma mark - ChartMaxValueChooser

- (void)maxValueEntered
{
    // update UI
    NSIndexPath *selectedRow = [NSIndexPath indexPathForRow:chartMaxValueCellRowIndex inSection:0];
    [tblOverlayOptions reloadRowsAtIndexPaths:[NSArray arrayWithObject:selectedRow] withRowAnimation:UITableViewRowAnimationFade];
    [tblOverlayOptions selectRowAtIndexPath:selectedRow animated:NO scrollPosition:UITableViewScrollPositionNone];
    
    // notify && redraw
    [overlayChooser_ overlayUpdated];    
}

@end
