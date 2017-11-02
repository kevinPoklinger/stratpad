//
//  LoanCell.m
//  StratPad
//
//  Created by Julian Wood on 2013-04-16.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//
//  We'll use UITextFields to represent all our values.
//  They each have a placeholder value.
//  When tapped, they will either behave as a normal textfield, or they will prevent direct editing and show a popover control.

#import "LoanCell.h"
#import "UIColor-Expanded.h"
#import "SkinManager.h"
#import <QuartzCore/QuartzCore.h>
#import "LinkedFieldOrganizer.h"
#import "NSString-Expanded.h"
#import "UserNotificationDisplayManager.h"

#define maxDescriptionLength    100
#define tagForBackgroundView    877

static NSArray *frequencyMapping;

@interface LoanCell ()

// 2 decimals for rate
@property (nonatomic, retain) NSNumberFormatter *rateFormatter;

// control the order for next responder
@property (nonatomic,retain) NSArray *responders;

@property (nonatomic, retain) NSNumberFormatter *groupingFormatter;

@end

@implementation LoanCell

+(void)initialize
{
    [super initialize];
    frequencyMapping = [[NSArray arrayWithObjects:
                        [NSNumber numberWithInteger:FrequencyCategoryMonthly],
                        [NSNumber numberWithInteger:FrequencyCategoryQuarterly],
                        [NSNumber numberWithInteger:FrequencyCategoryAnnually],
                        nil] retain]; // never dealloc
}

+(NSArray*)indexForFrequency:(FrequencyCategory)frequency
{
    return [frequencyMapping indexOfObject:[NSNumber numberWithInteger:frequency]];
}

-(void)awakeFromNib
{
    SkinManager *skinMan = [SkinManager sharedManager];
    
    self.responders = [NSArray arrayWithObjects:_txtName, _txtDate, _txtAmount, _txtTerm, _txtRate, _txtType, _txtFrequency, nil];
    
    [self configureField:_txtName property:@"name"];
    [self configureField:_txtDate property:@"date"];
    [self configureField:_txtAmount property:@"amount"];
    [self configureField:_txtTerm property:@"term"];
    [self configureField:_txtRate property:@"rate"];
    [self configureField:_txtType property:@"type"];
    [self configureField:_txtFrequency property:@"frequency"];
    
    // name
    
    // date
    _txtDate.desc = LocalizedString(@"LoanDate", nil);
    [_txtDate addTarget:self action:@selector(updateDate:) forControlEvents:UIControlEventValueChanged];

    // amount
    
    // term
    _txtTerm.desc = LocalizedString(@"LoanTerm", nil);
    [_txtTerm addTarget:self action:@selector(updateTerm:) forControlEvents:UIControlEventValueChanged];

    // rate
    NSNumberFormatter * formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle: NSNumberFormatterDecimalStyle];
    [formatter setMinimumFractionDigits:2];
    self.rateFormatter = formatter;
    [formatter release];
    
    // type
    _txtType.desc = LocalizedString(@"LoanType", nil);
    _txtType.dismissOnSelection = YES;
    _txtType.options = [Loan loanTypes];
    _txtType.displayBlock = ^(OptionsTextField *textField, NSNumber *value)
    {
        NSString *key = [NSString stringWithFormat:@"LoanTypeAbbr_%@", value];
        textField.text = LocalizedString(key, nil);
    };
    [_txtType addTarget:self action:@selector(updateType:) forControlEvents:UIControlEventValueChanged];
    
    // frequency
    _txtFrequency.desc = LocalizedString(@"LoanPaymentFrequency", nil);
    _txtFrequency.dismissOnSelection = YES;
    _txtFrequency.options = [LoanCell localizedPaymentFrequencies];
    [_txtFrequency addTarget:self action:@selector(updateFrequency:) forControlEvents:UIControlEventValueChanged];

    // commas for number fields
    NSNumberFormatter * gFormatter = [[NSNumberFormatter alloc] init];
    [gFormatter setNumberStyle: NSNumberFormatterDecimalStyle];
    [gFormatter setMaximumFractionDigits:0];
    self.groupingFormatter = gFormatter;
    [gFormatter release];
    
    // rows should have a rounded rect appearance
    UIView *view = [[UIView alloc] initWithFrame:self.contentView.frame];
    UIView *subview =[[UIView alloc] initWithFrame:CGRectMake(0, 2, view.frame.size.width-20, 40)];
    subview.backgroundColor = [skinMan colorForProperty:kSkinSection2TableCellBackgroundColor forMediaType:MediaTypeScreen];
    subview.layer.cornerRadius = 8.0;
    subview.tag = tagForBackgroundView;
    [view addSubview:subview];
    self.backgroundView = view;
    
    self.backgroundColor = [UIColor clearColor];
    [view release];
    [subview release];    
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

-(void)loadValues:(Loan*)loan
{
    self.loan = loan;

    NSString *percentFormat = LocalizedString(@"PERCENT_MESSAGE_FORMAT", nil);

    _txtName.text = loan.name;
    _txtDate.value = loan.date;
    _txtAmount.text = [_groupingFormatter stringFromNumber:loan.amount];
    if (loan.rate != nil) {
        _txtRate.text = [NSString stringWithFormat:percentFormat, [_rateFormatter stringFromNumber:loan.rate]];
    }
    _txtTerm.value = loan.term;
    _txtType.value = loan.type;
    
    if (loan.frequency != nil) {
        int idx = [LoanCell indexForFrequency:loan.frequency.intValue];
        _txtFrequency.value = [NSNumber numberWithInt:idx];
    }
    
    [self showValidation];
//    [_validator check];
}

#pragma mark - handlers for data changed listeners


-(void)updateType:(NSNumber*)value
{
    _loan.type = value;
    [self showValidation];
//    [_validator check];
}

-(void)updateFrequency:(NSNumber*)value
{
    FrequencyCategory frequency = [[frequencyMapping objectAtIndex:value.intValue] intValue];
    _loan.frequency = [NSNumber numberWithInt:frequency];
    [self showValidation];
//    [_validator check];
}

-(void)updateTerm:(NSNumber*)value
{
    _loan.term = value;
    [self showValidation];
//    [_validator check];
}

-(void)updateDate:(NSNumber*)value
{
    // YYYYMM
    _loan.date = value;
    [self showValidation];
//    [_validator check];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(PropertyTextField *)textField
{
    if ([textField.property isEqualToString:@"name"]) {
        _loan.name = textField.text;
    }
    else if ([textField.property isEqualToString:@"amount"]) {
        NSNumber *amount = [NSNumber numberWithInteger:textField.text.integerValue];
        _loan.amount = amount;
        
        // add grouping
        _txtAmount.text = [_groupingFormatter stringFromNumber:amount];
    }
    else if ([textField.property isEqualToString:@"rate"]) {
        NSString *rateString = textField.text;
        if ([rateString isBlank]) {
            _loan.rate = [NSDecimalNumber zero];
        }
        else {
            NSDecimalNumber *rate = [NSDecimalNumber decimalNumberWithString:textField.text];
            _loan.rate = rate;
        }
        
        // add Percent
        NSString *percentFormat = LocalizedString(@"PERCENT_MESSAGE_FORMAT", nil);
        _txtRate.text = [NSString stringWithFormat:percentFormat, [_rateFormatter stringFromNumber:_loan.rate]];

    }
    else {
        ELog(@"Unknown property: %@", textField.property);
    }
    [self showValidation];
//    [_validator check];
}

- (void)textFieldDidBeginEditing:(PropertyTextField *)textField
{
    if ([textField.property isEqualToString:@"amount"]) {
        // remove commas, spaces or any non-digit
        textField.text = [[textField.text componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
    }
    else if ([textField.property isEqualToString:@"rate"]) {
        // remove commas, spaces or any non-digit
        NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"0123456789."];
        textField.text = [[textField.text componentsSeparatedByCharactersInSet:[set invertedSet]] componentsJoinedByString:@""];
    }

}


- (BOOL)textField:(PropertyTextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)replacementString
{
    // anything is good for description field, up to maxCommentLength chars
    if ([textField.property isEqualToString:@"name"]) {
        
        // we want to truncate anything pasted at maxCommentLength chars
        // if typing, we're going to limit to maxDescriptionLength
        return (range.location + replacementString.length < maxDescriptionLength);
        
    } // else amount/rate field
    
    int len = 10;
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    if ([textField.property isEqualToString:@"rate"]) {
        len = 5;
        set = [NSCharacterSet characterSetWithCharactersInString:@"0123456789."];
    }
    
    // we will allow 99,999,999 = 8 chars
    if (textField.text.length == len && [replacementString length] > 0) {
        return NO;
    }
    else if ([replacementString length] == 1) {
        // as long as replacementString (what the user typed) contains valid chars, return yes
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
    
    if (textField == _txtFrequency) {
        // done
        [textField resignFirstResponder];
    } else {
        // next (we don't have nexts for all controls, but doesn't matter)
        int idx = [_responders indexOfObject:textField];
        [[_responders objectAtIndex:idx+1] becomeFirstResponder];
    }
    
    // don't do the default action (of nothing)
    return NO;
}

#pragma mark - Private

+(NSArray*) localizedPaymentFrequencies
{
    NSMutableArray *ary = [NSMutableArray array];
    for (NSNumber *frequency in frequencyMapping) {
        NSString * key = [NSString stringWithFormat:@"FREQUENCY_%d", frequency.intValue];
        [ary addObject:LocalizedString(key, nil)];
    }
    return ary;
}

- (void)dealloc {
    [_validator release];
    [_responders release];
    [_rateFormatter release];
    [_txtName release];
    [_txtAmount release];
    [_loan release];
    [_txtDate release];
    [_txtTerm release];
    [_txtRate release];
    [_txtType release];
    [_txtFrequency release];
    [super dealloc];
}

#pragma mark - Validation

-(void)showValidation
{
    if ([_loan isNew] || [_loan isValid]) {
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
