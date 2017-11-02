//
//  AssetCell.m
//  StratPad
//
//  Created by Julian Wood on 2013-04-22.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//

#import "AssetCell.h"
#import <QuartzCore/QuartzCore.h>
#import "SkinManager.h"
#import "UIColor-Expanded.h"
#import "UserNotificationDisplayManager.h"

#define maxDescriptionLength    100
#define tagForBackgroundView    877

@interface AssetCell ()
// control the order for next responder
@property (nonatomic,retain) NSArray *responders;
@property (nonatomic,retain) NSNumberFormatter *groupingFormatter;
@end

@implementation AssetCell

-(void)awakeFromNib
{
    SkinManager *skinMan = [SkinManager sharedManager];
    
    self.responders = [NSArray arrayWithObjects:_txtName, _txtDate, _txtValue, _txtDepreciationTerm, _txtSalvageValue, _txtType, _txtDepreciationType, nil];
    
    [self configureField:_txtName property:@"name"];
    [self configureField:_txtDate property:@"date"];
    [self configureField:_txtValue property:@"value"];
    [self configureField:_txtDepreciationTerm property:@"depreciationTerm"];
    [self configureField:_txtSalvageValue property:@"salvageValue"];
    [self configureField:_txtType property:@"depreciationType"];
    [self configureField:_txtDepreciationType property:@"type"];
    
    // term slider
    _txtDepreciationTerm.desc = LocalizedString(@"AssetTerm", nil);
    _txtDepreciationTerm.minimumValue = 0;
    _txtDepreciationTerm.maximumValue = 40;
    _txtDepreciationTerm.valueFormatter = ^(NSNumber *value) {
        // show closest int
        int term = round(floor(value.floatValue));
        NSString *key = LocalizedString(@"YEAR_MESSAGE_FORMAT", nil);
        return [NSString stringWithFormat:key, term];
    };
    [_txtDepreciationTerm addTarget:self action:@selector(updateDepreciationTerm:) forControlEvents:UIControlEventValueChanged];

    // date
    _txtDate.desc = LocalizedString(@"AssetDate", nil);
    [_txtDate addTarget:self action:@selector(updateDate:) forControlEvents:UIControlEventValueChanged];

    // type selector
    _txtType.desc = LocalizedString(@"AssetTypes", nil);
    _txtType.dismissOnSelection = YES;
    _txtType.options = [Asset types];
    [_txtType addTarget:self action:@selector(updateType:) forControlEvents:UIControlEventValueChanged];

    // depreciationtype selector
    _txtDepreciationType.desc = LocalizedString(@"AssetDepreciationTypes", nil);
    _txtDepreciationType.dismissOnSelection = YES;
    _txtDepreciationType.options = [Asset depreciationTypes];
    [_txtDepreciationType addTarget:self action:@selector(updateDepreciationType:) forControlEvents:UIControlEventValueChanged];
    
    // add commas to numbers
    NSNumberFormatter * formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle: NSNumberFormatterDecimalStyle];
    [formatter setMaximumFractionDigits:0];
    self.groupingFormatter = formatter;
    [formatter release];

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
    
}

- (void)dealloc {
    [_validator release];
    [_groupingFormatter release];
    [_responders release];
    [_txtName release];
    [_txtDate release];
    [_txtValue release];
    [_txtDepreciationTerm release];
    [_txtSalvageValue release];
    [_txtType release];
    [_txtDepreciationType release];
    [super dealloc];
}

-(void)loadValues:(Asset*)asset
{
    self.asset = asset;
    _txtName.text = asset.name;
    _txtDate.value = asset.date;
    _txtValue.text = [_groupingFormatter stringFromNumber:asset.value];
    _txtDepreciationTerm.value = asset.depreciationTerm;
    _txtSalvageValue.text = [_groupingFormatter stringFromNumber:asset.salvageValue];
    _txtType.value = asset.type;
    _txtDepreciationType.value = asset.depreciationType;
    
    [self showValidation];
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

-(void)updateDepreciationTerm:(NSNumber*)value
{
    // slider field
    int term = round(floor(value.floatValue));    
    _asset.depreciationTerm = [NSNumber numberWithInt:term];
    [self showValidation];
    //[_validator check];
}

-(void)updateDate:(NSNumber*)value
{
    // YYYYMM
    _asset.date = value;
    [self showValidation];
    //[_validator check];
}

-(void)updateType:(NSNumber*)value
{
    _asset.type = value;
    [self showValidation];
    //[_validator check];
}

-(void)updateDepreciationType:(NSNumber*)value
{
    _asset.depreciationType = value;
    [self showValidation];
    //[_validator check];
}


#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(PropertyTextField *)textField
{
    if (textField == _txtName) {
        _asset.name = textField.text;
    }
    else if (textField == _txtValue || textField == _txtSalvageValue) {
        NSNumber *amount = [NSNumber numberWithInteger:textField.text.integerValue];
        [_asset setValue:amount forKey:textField.property];
        
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
    if (textField == _txtValue || textField == _txtSalvageValue) {
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
        
    } // else value or salvageValue field
    
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

    if (textField == _txtDepreciationType) {
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

#pragma mark - Validation

-(void)showValidation
{
    // called when we first load up the cell
    // called when we finish a field in the cell
    if ([_asset isNew] || [_asset isValid]) {
        UIView *view = [self.backgroundView viewWithTag:tagForBackgroundView];
        view.layer.borderWidth = 0.f;

        // it could be that finishing off this cell should remove the validation error message, but we don't have enough info here though to make a judgement call
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
