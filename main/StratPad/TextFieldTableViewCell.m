//
//  TextFieldTableViewCell.m
//  StratPad
//
//  Created by Julian Wood on 11-08-18.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "TextFieldTableViewCell.h"
#import "DataManager.h"
#import "EventManager.h"

@implementation TextFieldTableViewCell

@synthesize label = label_;
@synthesize textField = textField_;
@synthesize boundEntity = boundEntity_;
@synthesize boundProperty = boundProperty_;
@synthesize maxLength = maxLength_;
@synthesize tableView = tableView_;
@synthesize indexPath = indexPath_;

- (void) awakeFromNib
{
    self.textField.returnKeyType = UIReturnKeyDone;
    self.textField.delegate = self;    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    // save it
    [boundEntity_ setValue:textField.text forKey:boundProperty_];
    [DataManager saveManagedInstances];    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (tableView_ && indexPath_) {
        [tableView_ scrollToRowAtIndexPath:indexPath_ atScrollPosition:UITableViewScrollPositionMiddle animated:YES];    
    }
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (maxLength_ != nil) {
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        return (newLength > [maxLength_ integerValue]) ? NO : YES;        
    }
    return YES;
}

- (void)dealloc
{
    [boundEntity_ release];
    [boundProperty_ release];
    [label_ release];
    [textField_ release];
    [tableView_ release];
    [indexPath_ release];
    [maxLength_ release];
    [super dealloc];
}

@end
