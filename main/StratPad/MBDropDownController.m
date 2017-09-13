//
//  MBDropDownController.m
//  StratPad
//
//  Created by Eric Rogers on August 21, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "MBDropDownController.h"
#import "UIColor-Expanded.h"

@interface DropDownValue : NSObject {
@private
    id value_;
    NSString *displayValue_;
}

@property(nonatomic, assign) id value;
@property(nonatomic, copy) NSString *displayValue;

@end

@implementation DropDownValue

@synthesize value = value_;
@synthesize displayValue = displayValue_;

@end


@implementation MBDropDownController

@synthesize tableView = tableView_;
@synthesize selectedValue = selectedValue_;
@synthesize delegate = delegate_;


- (id)initWithDropDownButton:(MBDropDownButton*)button andSelectedValueOrNil:(id)value
{
    if ((self = [super initWithNibName:@"MBDropDownView" bundle:nil])) {
        self.selectedValue = value;
        dropDownButton_ = button;
        [dropDownButton_ addTarget:self action:@selector(show) forControlEvents:UIControlEventTouchUpInside];
        dropDownValues_ = [[NSMutableArray array] retain];
    }
    return self;
}


#pragma mark - View Lifecycle

- (void)viewDidUnload
{
    self.tableView = nil;
    self.selectedValue = nil;
    
    [super viewDidUnload];    
}


#pragma mark - Memory Management

- (void)dealloc
{
    [popoverController_ release];
    [tableView_ release];
    [dropDownValues_ release];
    [selectedValue_ release];
    
    [super dealloc];
}


#pragma - Public

- (void)addDropDownValue:(id)value withDisplayValue:(NSString*)displayValue;
{
    DropDownValue *dropDownValue = [[DropDownValue alloc] init];
    dropDownValue.value = value;
    dropDownValue.displayValue = displayValue;
    [dropDownValues_ addObject: dropDownValue];
    [dropDownValue release];
}

- (void)removeAllDropDownValues
{
    [dropDownValues_ removeAllObjects];
}

- (void)hide
{
    [popoverController_ dismissPopoverAnimated:YES];
    [popoverController_ release];
    popoverController_ = nil;
}

- (void)show
{
    if (popoverController_.popoverVisible) {
        [self hide];
        return;
    }    
    
    const NSUInteger maxRowsToDisplay = 5;
    NSUInteger numRowsToDisplay = dropDownValues_.count <= maxRowsToDisplay ? dropDownValues_.count : maxRowsToDisplay;
	
    if (!popoverController_) {
        popoverController_ = [[UIPopoverController alloc] initWithContentViewController: self];
        popoverController_.delegate = self;
    }
    
    // resize the popover controller on the fly to accommodate the dynamic height of the table.
	popoverController_.popoverContentSize = CGSizeMake(dropDownButton_.frame.size.width, dropDownButton_.frame.size.height * numRowsToDisplay);    
    
    if (!popoverController_.popoverVisible) {
        // show from right side
        CGRect f = dropDownButton_.frame;
        CGRect rect = CGRectMake(f.origin.x+f.size.width-35, f.origin.y, 5, f.size.height);
        [popoverController_ presentPopoverFromRect:rect	
                                            inView:[dropDownButton_ superview]
                          permittedArrowDirections:UIPopoverArrowDirectionUp
                                          animated:YES];    
    }
    
    if (dropDownValues_.count > maxRowsToDisplay) {
        [self.tableView flashScrollIndicators];
    }
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dropDownValues_.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"DropDownCell"];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DropDownCell"] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:17.f];
    }
        
    NSUInteger row = [indexPath row];
    cell.textLabel.text = ((DropDownValue*)[dropDownValues_ objectAtIndex:row]).displayValue;
    
    if  ([((DropDownValue*)[dropDownValues_ objectAtIndex:row]).value isEqual:selectedValue_])
    {
        selectedRow_ = [NSNumber numberWithInteger:row];
        cell.contentView.backgroundColor = [UIColor colorWithHexString:@"DCDCDC"]; 
    }
    else
    {
        cell.contentView.backgroundColor = [UIColor whiteColor]; 
    }
    
    return cell;        
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return dropDownButton_.frame.size.height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    NSUInteger section = [indexPath section];
    selectedValue_ = ((DropDownValue*)[dropDownValues_ objectAtIndex:row]).value;
    
    // Remove selected background from previously selected row    
    if (selectedRow_) {
        NSIndexPath *previousSelection = [NSIndexPath indexPathForRow:[selectedRow_ integerValue] inSection:section];
        [tableView_ reloadRowsAtIndexPaths:[NSArray arrayWithObject:previousSelection] withRowAnimation:UITableViewRowAnimationNone];        
    }
    
    // Add background to currently selected row
    selectedRow_ = [NSNumber numberWithInteger:row];
    [tableView_ reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
    DropDownValue *selectedValue = (DropDownValue*)[dropDownValues_ objectAtIndex:row];
    dropDownButton_.label.text = selectedValue.displayValue;
    [self hide];    
    [self.delegate valueSelected:selectedValue.value forDropDownButton:dropDownButton_];
}

@end
