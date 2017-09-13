//
//  OpeningBalanceCell.m
//  StratPad
//
//  Created by Julian Wood on 2013-04-26.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//

#import "OpeningBalanceCell.h"
#import "UIColor-Expanded.h"
#import "SkinManager.h"
#import "UIView+ObjectTagAdditions.h"
#import "PermissionChecker.h"
#import "StratFileManager.h"

@interface OpeningBalanceCell ()
@property (nonatomic, retain) NSNumberFormatter *formatter;
@property (retain, nonatomic) PermissionChecker *permissionChecker;
@property (retain, nonatomic) NSCharacterSet *numberSet;
@end

@implementation OpeningBalanceCell

-(void)awakeFromNib
{
    SkinManager *skinMan = [SkinManager sharedManager];
    UIColor *textColor = [skinMan colorForProperty:kSkinSection2FieldLabelFontColor];
    UIColor *pColor = [UIColor colorWithHexString:@"A3A3A3"];
    
    _txtValue.placeHolderColor = pColor;
    _txtValue.textColor = textColor;
    _txtValue.delegate = self;
    
    self.backgroundColor = [skinMan colorForProperty:kSkinSection2TableCellBackgroundColor];
    _lblName.textColor = [skinMan colorForProperty:kSkinSection2TableCellFontColor];
    _lblDifference.textColor = [skinMan colorForProperty:kSkinSection2TableCellFontColor];
    _lblCalculated.textColor = [skinMan colorForProperty:kSkinSection2TableCellFontColor];
    
    // grouping formatter
    NSNumberFormatter * formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle: NSNumberFormatterDecimalStyle];
    [formatter setMaximumFractionDigits:0];
    self.formatter = formatter;
    [formatter release];
    
    // assign property in VC
    // assign openingBalances in VC
    
    PermissionChecker *checker = [[PermissionChecker alloc] initWithStratFile:[[StratFileManager sharedManager] currentStratFile]];
    self.permissionChecker = checker;
    [checker release];
    
    self.numberSet = [NSCharacterSet characterSetWithCharactersInString:@"-0123456789"];
}

-(void)reloadData
{
    // add grouping
    _txtValue.text = [_formatter stringFromNumber:[_openingBalances valueForKey:_txtValue.property]];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return [_permissionChecker checkReadWrite];
}

- (void)textFieldDidEndEditing:(PropertyTextField *)textField
{
    NSNumber *amount = [NSNumber numberWithInteger:textField.text.integerValue];
    [_openingBalances setValue:amount forKey:textField.property];
    
    // add grouping
    textField.text = [_formatter stringFromNumber:amount];
    
}

- (void)textFieldDidBeginEditing:(PropertyTextField *)textField
{
    // remove commas, spaces or any non-digit
    textField.text = [[textField.text componentsSeparatedByCharactersInSet:[_numberSet invertedSet]] componentsJoinedByString:@""];
    
    [_delegate scrollToRow:_row];
}


- (BOOL)textField:(PropertyTextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)replacementString
{
    // we will allow 99,999,999 = 8 chars
    if (textField.text.length == 10 && [replacementString length] > 0) {
        return NO;
    }
    else if ([replacementString length] == 1) {
        // as long as replacementString (what the user typed) contains valid chars, return yes
        return [replacementString rangeOfCharacterFromSet:_numberSet].location != NSNotFound;
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
    UIResponder *nextField = [_delegate nextField:_row];
    
    if (nextField) {
        [nextField becomeFirstResponder];
    } else {
        // done
        [_txtValue resignFirstResponder];
    }
    
    // don't do the default action (of nothing)
    return NO;
}


- (void)dealloc {
    [_numberSet release];
    [_permissionChecker release];
    [_openingBalances release];
    
    [_lblName release];
    [_txtValue release];
    [_lblDifference release];
    [_lblCalculated release];
    [super dealloc];
}
@end
