//
//  MeasurementEditorCell.m
//  StratPad
//
//  Created by Julian Wood on 12-04-21.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "MeasurementEditorCell.h"
#import "StratFileManager.h"
#import "NSNumber-StratPad.h"

@implementation NSNumber (MeasurementViewController)

- (NSString*)formattedNumberForValue
{        
    if ([self doubleValue] == 0) {
        return @"";
    }
    
    // max is 123456789
    if ([self doubleValue] >= maxDisplayableValue || [self doubleValue] <= minDisplayableValue) {
        return @"############";
    }
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setMaximumFractionDigits:2];
    
    NSString *formattedNumber = [formatter stringFromNumber:self];
    [formatter release];
    
    return formattedNumber;
}

@end

@interface MeasurementEditorCell ()
@property (nonatomic, retain) NSCharacterSet *digitSet;
@end

@implementation MeasurementEditorCell
@synthesize textFieldValue;
@synthesize textFieldComment;
@synthesize btnDate;

@synthesize measurement;

- (void)textFieldDidEndEditing:(PropertyTextField *)textField
{
    if ([textField.property isEqualToString:@"comment"]) {
        // anything is good for comment field
        [measurement setValue:textField.text forKey:textField.property];
        
    } else {
        // value field
        NSString *val = [textField.text stringByReplacingOccurrencesOfString:@"," withString:@""];
        NSDecimalNumber* value = [NSDecimalNumber decimalNumberWithString:val];
        
        if (value == nil || [value doubleValue] == 0 || [value compare:[NSDecimalNumber notANumber]] == NSOrderedSame) {
            [measurement setValue:nil forKey:textField.property];
            textField.text = @"";
        } else {
            [measurement setValue:value forKey:textField.property];
            textField.text = [value formattedNumberForValue];
        }        
    }
    
    [[StratFileManager sharedManager] saveCurrentStratFile];    
}

- (void)textFieldDidBeginEditing:(PropertyTextField *)textField
{
    if ([textField.property isEqualToString:@"value"]) {
        // remove commas, spaces or any non-digit
        textField.text = [[textField.text componentsSeparatedByCharactersInSet:[_digitSet invertedSet]] componentsJoinedByString:@""];
    }
}

- (BOOL)textField:(PropertyTextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)replacementString
{       
    // anything is good for comment field, up to maxCommentLength chars
    if ([textField.property isEqualToString:@"comment"]) {

        // we want to truncate anything pasted at maxCommentLength chars        
        // if typing, we're going to limit to maxCommentLength
        return (range.location + replacementString.length < maxCommentLength);
        
    } // else value field    
    
    // we will allow 99,999,999 = 8 chars
    if (textField.text.length == 9 && [replacementString length] > 0) {
        return NO;
    }
    else if ([replacementString length] == 1) {
        // as long as replacementString (what the user typed) contains valid chars, return yes
        NSCharacterSet * set = [NSCharacterSet characterSetWithCharactersInString:@"0123456789.-"];
        return [replacementString rangeOfCharacterFromSet:set].location != NSNotFound;
    }
    else if ([replacementString length] == 0) {
        // just blanking out
        return YES;
    } 
    else 
    {
        return NO;
    }
}

// user pressed return
- (BOOL)textFieldShouldReturn:(PropertyTextField *)textField {
    if ([textField.property isEqualToString:@"comment"]) {
        // done key - dismiss keyboard
        [textField resignFirstResponder];
    } else {
        // next key
        [textFieldComment becomeFirstResponder];
    }    
    
    // don't do the default action (of nothing)
    return NO;
}

-(void)awakeFromNib
{
    self.digitSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789.-"];

    textFieldValue.delegate = self;
    textFieldComment.delegate = self;
    textFieldComment.actions = EditActionCopy | EditActionCut | EditActionDelete | EditActionPaste | EditActionSelect | EditActionSelectAll;
    
    btnDate.textColor = [UIColor blackColor];
    btnDate.textSize = 14.f;
    btnDate.roundedRectBackgroundColor = [UIColor clearColor];
    btnDate.nextResponder = textFieldValue;
}

- (void)dealloc {
    [_digitSet release];
    [measurement release];
    [datePicker_ release];
    [textFieldValue release];
    [textFieldComment release];
    [btnDate release];
    [super dealloc];
}

- (IBAction)showDatePicker:(id)sender {
    if (!datePicker_) {
        datePicker_ = [[MBDateSelectionViewController alloc] initWithCalendarButton:btnDate andTitle:LocalizedString(@"MEASUREMENT_DATE_PICKER_TITLE", nil)];                                    
        datePicker_.delegate = self;        
    }
    [datePicker_ showDatePicker];
}

#pragma mark - DateSelectionDelegate

- (void)dateSelected:(NSDate*)date forCalendarButton:(MBCalendarButton*)button
{
    measurement.date = date;
    [[StratFileManager sharedManager] saveCurrentStratFile];    
}

- (BOOL)isValid:(NSDate*)date forCalendarButton:(MBCalendarButton*)button
{
    return YES;
}

- (NSDate*)suggestedDateForCalendarButton:(MBCalendarButton*)button proposedDate:(NSDate*)proposedDate
{
    return proposedDate;
}


@end
