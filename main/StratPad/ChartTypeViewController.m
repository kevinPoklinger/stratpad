//
//  ChartTypeViewController.m
//  StratPad
//
//  Created by Julian Wood on 12-04-02.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "ChartTypeViewController.h"
#import "DataManager.h"

@interface ChartTypeViewController ()

@end

@implementation ChartTypeViewController
@synthesize tblChartTypes;

- (id)initWithChart:(Chart*)chart andChartTypeChooser:(id<ChartTypeChooser>)chartTypeChooser;
{
    self = [super initWithNibName:NSStringFromClass([ChartTypeViewController class]) bundle:nil];
    if (self) {
        chart_ = chart;
        chartTypeChooser_ = chartTypeChooser;

        // we only want 3 of the 5 ChartTypes for the primary chart
        if (chart.zLayer == primaryChartLayer) {
            chartTypes_ = [[NSArray arrayWithObjects:
                            [NSNumber numberWithInt:ChartTypeArea],
                            [NSNumber numberWithInt:ChartTypeBar],
                            [NSNumber numberWithInt:ChartTypeLine],
                            nil] retain];            
        } else {
            chartTypes_ = [[NSArray arrayWithObjects:
                            [NSNumber numberWithInt:ChartTypeNone],
                            [NSNumber numberWithInt:ChartTypeArea],
                            [NSNumber numberWithInt:ChartTypeBar],
                            [NSNumber numberWithInt:ChartTypeLine],
                            [NSNumber numberWithInt:ChartTypeComments],
                            nil] retain];
        }
        
        self.title = LocalizedString(@"CHART_TYPE", nil);
    }
    return self;
}

- (void)viewDidLoad
{
    NSAssert(chart_ != nil, @"You have to provide a valid chart object in the init.");
    NSAssert(chartTypeChooser_ != nil, @"You have to provide a valid ChartTypeChooser object in the init.");
        
    [super viewDidLoad];
    tblChartTypes.clipsToBounds = YES;
}

- (void)viewDidUnload
{
    [self setTblChartTypes:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

// @override: this will make it so that the popover doesn't expand to full height
-(CGSize)contentSizeForViewInPopover
{
    CGFloat rowHeight = [self tableView:tblChartTypes heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    NSInteger numRows = [self tableView:tblChartTypes numberOfRowsInSection:0];
    return CGSizeMake(self.view.bounds.size.width, numRows*rowHeight + 40);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int idx = [chartTypes_ indexOfObject:[NSNumber numberWithInt:chart_.chartType.intValue]];
    NSIndexPath *oldSelection = [NSIndexPath indexPathForRow:idx inSection:0];
    NSIndexPath *newSelection = indexPath;
    
    ChartType newChartType = [[chartTypes_ objectAtIndex:[indexPath row]] intValue];
    
    // deselect the old row
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // update the chart entity
    [chart_ setChartType:[NSNumber numberWithInt:newChartType]];
    [DataManager saveManagedInstances];
    
    // notify delegate so that the chart can be updated
    [chartTypeChooser_ chartTypeSelected];
    
    // update checkmarks
    [[tableView cellForRowAtIndexPath:oldSelection] setAccessoryType:UITableViewCellAccessoryNone];
    [[tableView cellForRowAtIndexPath:newSelection] setAccessoryType:UITableViewCellAccessoryCheckmark];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [chartTypes_ count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{  
    static NSString *CellIdentifier = @"ChartTypeCell";    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];        
        cell.textLabel.font = [UIFont boldSystemFontOfSize:18];
    }

    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    
    ChartType chartType = [[chartTypes_ objectAtIndex:[indexPath row]] intValue];
    if (chart_.chartType.intValue == chartType) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    NSString *key = [NSString stringWithFormat:@"CHART_TYPE_%i", chartType];
    cell.textLabel.text = LocalizedString(key, nil);
        
    return cell;    
}



- (void)dealloc {
    [chartTypes_ release];
    [tblChartTypes release];
    [super dealloc];
}
@end
