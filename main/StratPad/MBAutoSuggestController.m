//
//  AutoSuggestController.m
//  StratPad
//
//  Created by Eric Rogers on August 14, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "MBAutoSuggestController.h"
#import "NSString-Expanded.h"

@interface MBAutoSuggestController (Private)
- (void)showAutoSuggest;
- (IBAction)showAllAutoSuggestValues:(id)sender;
@end


@implementation MBAutoSuggestController

@synthesize tableView = tableView_;
@synthesize autoSuggestValues = autoSuggestValues_;
@synthesize delegate = delegate_;

- (id)initWithAutoSuggestTextField:(MBAutoSuggestTextField*)textField
{
    if ((self = [super initWithNibName:@"MBAutoSuggestView" bundle:nil])) {
        textField_ = textField;
        textField_.autocorrectionType = UITextAutocorrectionTypeNo;
        [textField_.btnArrow addTarget:self action:@selector(showAllAutoSuggestValues:) forControlEvents:UIControlEventTouchUpInside];
        
        filteredValues_ = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)setAutoSuggestValues:(NSArray *)autoSuggestValues
{
    [autoSuggestValues_ release];
    autoSuggestValues_ = [autoSuggestValues retain];
            
    textField_.btnArrow.hidden = autoSuggestValues_.count == 0;   
}

#pragma mark - View Lifecycle

- (void)viewDidUnload
{
    self.tableView = nil;
    
    [super viewDidUnload];    
}


#pragma mark - Memory Management

- (void)dealloc
{
    [popoverController_ release];
    [tableView_ release];
    [filteredValues_ release];
    [autoSuggestValues_ release];
    
    [super dealloc];
}


#pragma - Public

- (void)showWithSearchString:(NSString *)query
{    
    [filteredValues_ removeAllObjects];
    
    if (!query || [query isBlank]) {
        [filteredValues_ addObjectsFromArray:autoSuggestValues_];
        
    } else {
        for(NSString *curString in autoSuggestValues_) {
            NSRange substringRange;
            if (query.length == 1) {
                // if we have a single letter, don't just show all matches with an 'm' in it, for example
                substringRange = [curString rangeOfString:query options:NSCaseInsensitiveSearch | NSAnchoredSearch];
            } else {
                // convenient to show substring matches from anywhere in the string
                substringRange = [curString rangeOfString:query options:NSCaseInsensitiveSearch];
            }
            if (substringRange.location != NSNotFound) {
                [filteredValues_ addObject:curString];  
            }                
        }
    }
    
    if (filteredValues_.count > 0) {
        [self.tableView reloadData];
        [self showAutoSuggest];
        
        // select the first exact match, or none
        NSString *curVal = textField_.text;
        for (int i=0, ct=filteredValues_.count; i<ct; ++i) {
            NSString *val = [filteredValues_ objectAtIndex:i];
            if ([val isEqualToString:curVal]) {
                [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] 
                                            animated:NO 
                                      scrollPosition:UITableViewScrollPositionMiddle];                
                break;
            }
        }
        
        
    } else {
        [self hideAutoSuggest];        
    }
}

- (void)hideAutoSuggest
{
    [popoverController_ dismissPopoverAnimated:YES];
    [popoverController_ release];
    popoverController_ = nil;
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return filteredValues_.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"AutoSuggestCell"];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AutoSuggestCell"] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.textLabel.font = textField_.font;
    }
    
    NSUInteger row = [indexPath row];
    cell.textLabel.text = [filteredValues_ objectAtIndex:row];
    
    return cell;        
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return textField_.frame.size.height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    NSString *value = [filteredValues_ objectAtIndex:row];
    textField_.text = value;
    [textField_ resignFirstResponder];
    [self hideAutoSuggest];    
    [self.delegate valueSelected:value forAutoSuggestTextField:textField_];
}


#pragma mark - Actions

- (IBAction)showAllAutoSuggestValues:(id)sender
{
    if (popoverController_.popoverVisible) {
        [self hideAutoSuggest];
    } else {
        [self showWithSearchString:@""];    
    }    
}


#pragma mark - Support

- (void)showAutoSuggest
{    
    const NSUInteger maxRowsToDisplay = 5;
    NSUInteger numRowsToDisplay = filteredValues_.count <= maxRowsToDisplay ? filteredValues_.count : maxRowsToDisplay;
	
    if (!popoverController_) {
        popoverController_ = [[UIPopoverController alloc] initWithContentViewController: self];
        popoverController_.delegate = self;
    }
    
    // resize the popover controller on the fly to accommodate the dynamic height of the table.
	popoverController_.popoverContentSize = CGSizeMake(textField_.frame.size.width, textField_.frame.size.height * numRowsToDisplay);    
    
    if (!popoverController_.popoverVisible) {
        [popoverController_ presentPopoverFromRect:textField_.frame	
                                            inView:[textField_ superview]
                          permittedArrowDirections:UIPopoverArrowDirectionAny
                                          animated:YES];    
    }
    
    if (filteredValues_.count > maxRowsToDisplay) {
        [self.tableView flashScrollIndicators];
    }
}

@end
