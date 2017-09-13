//
//  EquityCell.m
//  StratPad
//
//  Created by Julian Wood on 2013-04-23.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//

#import "EquityCell.h"
#import <QuartzCore/QuartzCore.h>
#import "SkinManager.h"
#import "UIColor-Expanded.h"
#import "UserNotificationDisplayManager.h"

#define maxDescriptionLength    100
#define tagForBackgroundView    877

@interface EquityCell ()
@property (nonatomic, retain) NSArray *responders;
@property (nonatomic, retain) NSNumberFormatter *groupingFormatter;
@end

@implementation EquityCell

-(void)awakeFromNib
{
    SkinManager *skinMan = [SkinManager sharedManager];
    
    self.responders = [NSArray arrayWithObjects:_txtName, _txtDate, _txtValue, nil];
    
    [self configureField:_txtName property:@"name"];
    [self configureField:_txtDate property:@"date"];
    [self configureField:_txtValue property:@"value"];
    
    // date
    _txtDate.desc = LocalizedString(@"EquityDate", nil);
    [_txtDate addTarget:self action:@selector(updateDate:) forControlEvents:UIControlEventValueChanged];
        
    // rows should have a rounded rect appearance
    UIView *view = [[UIView alloc] initWithFrame:self.contentView.frame];
    UIView *subview =[[UIView alloc] initWithFrame:CGRectMake(0, 2, view.frame.size.width-20, 40)];
    subview.tag = tagForBackgroundView;
    subview.backgroundColor = [skinMan colorForProperty:kSkinSection2TableCellBackgroundColor forMediaType:MediaTypeScreen];
    subview.layer.cornerRadius = 8.0;
    [view addSubview:subview];
    self.backgroundView = view;
    
    self.backgroundColor = [UIColor clearColor];
    
    [view release];
    [subview release];

    NSNumberFormatter * formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle: NSNumberFormatterDecimalStyle];
    [formatter setMaximumFractionDigits:0];
    self.groupingFormatter = formatter;
    [formatter release];

}

-(void)configureField:(PropertyTextField*)textField property:(NSString*)property
{
    SkinManager *skinMan = [SkinManager sharedManager];
    UIColor *textColor = [skinMan colorForProperty:kSkinSection2FieldLabelFontColor];
    UIColor *pColor = [UIColor colorWithHexString:@"A3A3A3"];
    
    textField.placeHolderColor = pColor;
    textField.textColor = textColor;
    textField.delegate = self;
    textField.property = property;
    
    // allow us to click directly between all fields, straight from a popover
    LinkedFieldOrganizer *lfo = [[LinkedFieldOrganizer alloc] init];
    lfo.linkedFields = _responders;
    textField.linkedFieldOrganizer = lfo;
    [lfo release];
}

-(void)updateDate:(NSNumber*)value
{
    // YYYYMM
    _equity.date = value;
    [self showValidation];
    //[_validator check];
}

-(void)loadValues:(Equity*)equity
{
    self.equity = equity;
    _txtName.text = _equity.name;
    _txtDate.value = _equity.date;
    _txtValue.text = [_groupingFormatter stringFromNumber:_equity.value];
    [self showValidation];
//    [_validator check];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(PropertyTextField *)textField
{
    if (textField == _txtName) {
        _equity.name = textField.text;
    }
    else if (textField == _txtValue) {
        NSNumber *amount = [NSNumber numberWithInteger:textField.text.integerValue];
        [_equity setValue:amount forKey:textField.property];
        
        // add grouping
        textField.text = [_groupingFormatter stringFromNumber:amount];
    }
    else {
        ELog(@"Unknown property: %@", textField.property);
    }
    [self showValidation];
    //[_validator check];
}

- (void)textFieldDidBeginEditing:(PropertyTextField *)textField
{
    if (textField == _txtValue) {
        // remove commas, spaces or any non-digit
        textField.text = [[textField.text componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
    }
}


- (BOOL)textField:(PropertyTextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)replacementString
{
    // anything is good for name field, up to maxCommentLength chars
    if (textField == _txtName) {
        
        // we want to truncate anything pasted at maxCommentLength chars
        // if typing, we're going to limit to maxDescriptionLength
        return (range.location + replacementString.length < maxDescriptionLength);
        
    } // else value field
    
    // we will allow 99,999,999 = 8 chars
    if (textField.text.length == 10 && [replacementString length] > 0) {
        return NO;
    }
    else if ([replacementString length] == 1) {
        // as long as replacementString (what the user typed) contains valid chars, return yes
        NSCharacterSet * set = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
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
    
    if (textField == _txtValue) {
        // done
        [textField resignFirstResponder];
    } else {
        // next
        int idx = [_responders indexOfObject:textField];
        [[_responders objectAtIndex:idx+1] becomeFirstResponder];
    }
    
    // don't do the default action (of nothing)
    return NO;
}


- (void)dealloc {
    [_validator release];
    [_groupingFormatter release];
    [_equity release];
    [_txtName release];
    [_txtDate release];
    [_txtValue release];
    [super dealloc];
}

#pragma mark - Validation

-(void)showValidation
{
    if ([_equity isNew] || [_equity isValid]) {
        UIView *view = [self.backgroundView viewWithTag:tagForBackgroundView];
        view.layer.borderWidth = 0.f;        
    }
    else {
        // red border around cell
        UIView *view = [self.backgroundView viewWithTag:tagForBackgroundView];
        view.layer.borderColor = [[UIColor colorWithHexString:@"800000"] CGColor];
        view.layer.borderWidth = 1.f;
        [view.layer setNeedsDisplay];
    }
}


@end
