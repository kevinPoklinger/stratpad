//
//  MeasurementList.m
//  StratPad
//
//  Created by Julian Wood on 12-04-20.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "MeasurementList.h"
#import "Measurement.h"
#import "MeasurementEditorCell.h"
#import "NSDate-StratPad.h"
#import "StratFileManager.h"
#import "DataManager.h"
#import "MeasurementViewController.h"


@implementation MeasurementList

@synthesize metric = metric_;

- (id)initWithMetric:(Metric*)metric measurementVC:(MeasurementViewController*)measurementVC
{
    self = [super init];
    if (self) {
        measurementVC_ = measurementVC;
        metric_ = metric;
        NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]];
        measurements_ = [[NSMutableArray arrayWithCapacity:100] retain];
        for (Measurement *measurement in metric.measurements) {
            [measurements_ addObject:measurement];
        }
        [measurements_ sortUsingDescriptors:sortDescriptors];        
    }
    return self;
}

- (void)dealloc
{
    [measurements_ release];
    [super dealloc];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return [measurements_ count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{  
    
    static NSString *CellIdentifier = @"MeasurementEditorCell";    
    MeasurementEditorCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        NSArray *topLevelObjects = [[[LocalizedManager sharedManager] currentBundle] loadNibNamed:CellIdentifier owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    Measurement *measurement = [measurements_ objectAtIndex:[indexPath row]];
    cell.measurement = measurement;
        
    cell.btnDate.date = measurement.date;
    cell.textFieldValue.text = [measurement.value formattedNumberForValue];
    cell.textFieldValue.property = @"value";
    cell.textFieldComment.text = measurement.comment;
    cell.textFieldComment.property = @"comment";
    
    return cell;    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {                
        Measurement *measurement = [measurements_ objectAtIndex:[indexPath row]];
        [measurements_ removeObjectAtIndex:[indexPath row]];
        [DataManager deleteManagedInstance:measurement];
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] 
                         withRowAnimation:UITableViewRowAnimationRight];            
                        
        // if we deleted last row, put in the add theme row
        if ([measurements_ count] == 0) {
            tableView.tableHeaderView = [self tableHeaderView:tableView];
            
            // remove the checkmark from the chosen metric
            NSIndexPath *indexPath = [measurementVC_.tblMetrics indexPathForSelectedRow];
            UITableViewCell *cell = [measurementVC_.tblMetrics cellForRowAtIndexPath:indexPath];
            cell.accessoryType = UITableViewCellAccessoryNone;        
        }          
    }    
}


#pragma mark - Public

-(UIView*)tableHeaderView:(UITableView*)tableView
{
    UILabel *lblHeader = [[UILabel alloc] init];
    lblHeader.font = [UIFont boldSystemFontOfSize:15.f];
    lblHeader.backgroundColor = [UIColor clearColor];
    lblHeader.textColor = [UIColor darkGrayColor];
    lblHeader.numberOfLines = 0;
    lblHeader.text = LocalizedString(@"ADD_MEASUREMENT_INSTRUCTIONS_ROW", nil);
    lblHeader.textAlignment = UITextAlignmentCenter;
    lblHeader.frame = CGRectMake(30, 20, tableView.frame.size.width-60, 100);
    return [lblHeader autorelease];
}

- (void)populateWithMetric:(Metric*)metric tableView:(UITableView*)tableView
{
    metric_ = metric;

    [measurements_ removeAllObjects];
    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]];
    for (Measurement *measurement in metric.measurements) {
        [measurements_ addObject:measurement];
    }
    [measurements_ sortUsingDescriptors:sortDescriptors];        

    [tableView reloadData];
}

-(void)scrollToSelectedRow:(UITableView*)tableView
{
    // we don't actually know the selected row, because taps in a textfield don't register in the table delegate
    // iterate each cell, see if either of it's textfields are editing, then scroll to it
    
    // problem here is that the visible rows after keyboard is shown doesn't included the "selected" row
    // we don't want to go through all the measurements, which could be hundreds
    // so lets just look at 12 of them
    NSArray *visibleCellPaths = [tableView indexPathsForVisibleRows];    
    NSUInteger firstRowIdx = visibleCellPaths.count ? [[visibleCellPaths objectAtIndex:0] row] : 0;
    for (int i=0; i<12; ++i) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:firstRowIdx+i inSection:0];
        MeasurementEditorCell *cell = (MeasurementEditorCell*)[tableView cellForRowAtIndexPath:indexPath];
        if ([cell.textFieldComment isEditing] || [cell.textFieldValue isEditing]) {
            [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
            return;
        }        
    }
}

-(void)addNewMeasurement:(UITableView*)tableView
{    
    // add a new row to the top of the table and take first responder in value
    Measurement *measurement = (Measurement*)[DataManager createManagedInstance:NSStringFromClass([Measurement class])];
    measurement.date = [NSDate dateWithZeroedTime];
    [metric_ addMeasurementsObject:measurement];

    [measurements_ insertObject:measurement atIndex:0];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
    
    // save
    [[StratFileManager sharedManager] saveCurrentStratFile];
 
    // scroll
    [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];

    // seems to be contention between scrolling and keyboard coming up, (which also scrolls), so delay it
    [self performSelector:@selector(respond:) withObject:tableView afterDelay:0.5];
}

#pragma mark - Private

- (void)respond:(UITableView*)tableView
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    MeasurementEditorCell *cell = (MeasurementEditorCell*)[tableView cellForRowAtIndexPath:indexPath];
    [cell.textFieldValue becomeFirstResponder];    
}




@end
