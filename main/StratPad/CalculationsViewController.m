//
//  CalculationsViewController.m
//  StratPad
//
//  Created by Julian Wood on 12-01-31.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "CalculationsViewController.h"
#import "SkinManager.h"
#import "MBRoundedTextField.h"
#import "StratFileManager.h"
#import "NSNumber-StratPad.h"
#import "SkinManager.h"
#import "PermissionChecker.h"

@interface CalculationsViewController ()
@property (nonatomic,retain) PermissionChecker *permissionChecker;
@property (nonatomic,retain) Theme *theme;
@property (nonatomic,retain) NSArray *fields;

@end

@implementation NSNumber (Calculations)

- (NSString*)formattedNumberForAdjustmentCalculation
{
    if ([self doubleValue] == 0) {
        return @"";
    }
    
    if ([self doubleValue] > 1000 || [self doubleValue] <= -1000) {
        return @"####";
    }
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setMaximumFractionDigits:2];
    
    NSString *formattedNumber = [NSString stringWithFormat:@"%@%%", [formatter stringFromNumber:self]];
    [formatter release];
    
    return formattedNumber;
}

@end

@implementation CalculationsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andTheme:(Theme*)theme
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.theme = theme;
        self.fields = [NSArray arrayWithObjects:
                    @"revenueMonthlyAdjustment", @"revenueQuarterlyAdjustment", @"revenueAnnuallyAdjustment",
                    @"cogsMonthlyAdjustment", @"cogsQuarterlyAdjustment", @"cogsAnnuallyAdjustment",
                    @"researchAndDevelopmentMonthlyAdjustment", @"researchAndDevelopmentQuarterlyAdjustment", @"researchAndDevelopmentAnnuallyAdjustment",
                    @"generalAndAdminMonthlyAdjustment", @"generalAndAdminQuarterlyAdjustment", @"generalAndAdminAnnuallyAdjustment",
                    @"salesAndMarketingMonthlyAdjustment", @"salesAndMarketingQuarterlyAdjustment", @"salesAndMarketingAnnuallyAdjustment",
                    nil];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    SkinManager *skinMan = [SkinManager sharedManager];
    
    PermissionChecker *checker = [[PermissionChecker alloc] initWithStratFile:_theme.stratFile];
    self.permissionChecker = checker;
    [checker release];

    self.view.backgroundColor = [[SkinManager sharedManager] colorForProperty:kSkinSection2FormBackgroundColor forMediaType:MediaTypeScreen];
    
    _titleItem.title = [NSString stringWithFormat:LocalizedString(@"CALCULATIONS_TITLE", nil), _theme.title];
    
    // bind and populate fields
    for (uint i=0, ct=_fields.count; i<ct; ++i) {
        MBRoundedTextField *textField = (MBRoundedTextField*)[self.view viewWithTag:100+i];
        [textField setBindingWithEntity:_theme andProperty:[_fields objectAtIndex:i]];
        textField.text = [[_theme valueForKey:[_fields objectAtIndex:i]] formattedNumberForAdjustmentCalculation];
        textField.roundedRectBackgroundColor = [skinMan colorForProperty:kSkinSection2TextFieldBackgroundColor forMediaType:MediaTypeScreen];
        textField.textColor = [skinMan colorForProperty:kSkinSection2TextValueFontColor forMediaType:MediaTypeScreen];
    }
    
    // label size and font doesn't change among skins, but color does
    for (UIView *lbl in [self.view subviews]) {
        if ([lbl isKindOfClass:[UILabel class]]) {
            [(UILabel*)lbl setTextColor:[skinMan colorForProperty:kSkinSection2FieldLabelFontColor forMediaType:MediaTypeScreen]];
        }
    }
    
}

- (IBAction)done:(id)sender {
    [_delegate editingCalculationsComplete];
}

- (void)dealloc {
    [_permissionChecker release];
    [_delegate release];
    [_titleItem release];
    [_theme release];
    [_fields release];
    [super dealloc];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    BOOL shouldReturn = [super textFieldShouldReturn:textField];

    // if we're on the last textfield, we can dismiss the view too
    if (textField.returnKeyType == UIReturnKeyDone) {
        [self done:nil];
    }
    
    return shouldReturn;
}

- (void)textFieldDidEndEditing:(MBRoundedTextField *)textField
{
    NSDecimalNumber* value = [NSDecimalNumber decimalNumberWithString:textField.text];
    
    if (value == nil || [value doubleValue] == 0 || [value compare:[NSDecimalNumber notANumber]] == NSOrderedSame) {
        [_theme setValue:nil forKey:textField.boundProperty];
        textField.text = @"";
    } else {
        [_theme setValue:value forKey:textField.boundProperty];
        textField.text = [value formattedNumberForAdjustmentCalculation];
    }
    
    [[StratFileManager sharedManager] saveCurrentStratFile];    
}

- (BOOL)textFieldShouldBeginEditing:(MBRoundedTextField *)textField
{
    // when we hit tab, on a remote keyboard, this method is invoked for every textfield on the page, as part of canBecomeFirstResponder
    // thus, any changes we make on the textfield must happen after we start editing
    return [_permissionChecker checkReadWrite];
}

- (void)textFieldDidBeginEditing:(MBRoundedTextField *)textField
{
    // clear out the percent sign and any ### signs
    NSString *val = textField.text;
    if ([val rangeOfString:@"#"].location != NSNotFound) {
        textField.text = [[_theme valueForKey:textField.boundProperty] stringValue];
    }
    else if ([val rangeOfString:@"%"].location != NSNotFound)
    {
        textField.text = [val substringToIndex:[val length]-1];
    }
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)replacementString
{    
    // we will allow 999.99 = 6 digits; can't paste so don't worry about that, no select all
    if (textField.text.length == 6 && [replacementString length] > 0) {
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


-(void)configureResponderChain
{
    // textfields are tagged from 100-111
    responderChain_ = [[NSArray arrayWithObjects:
                        [self.view viewWithTag:100],
                        [self.view viewWithTag:101],
                        [self.view viewWithTag:102],
                        [self.view viewWithTag:103],
                        [self.view viewWithTag:104],
                        [self.view viewWithTag:105],
                        [self.view viewWithTag:106],
                        [self.view viewWithTag:107],
                        [self.view viewWithTag:108],
                        [self.view viewWithTag:109],
                        [self.view viewWithTag:110],
                        [self.view viewWithTag:111],
                        [self.view viewWithTag:112],
                        [self.view viewWithTag:113],
                        [self.view viewWithTag:114],
                        nil] retain];
    
    // all text fields (ie keyboard up) use next button in KB
    for (int i=0, ct = [responderChain_ count]; i<ct; ++i) {
        UIResponder *responder = [responderChain_ objectAtIndex:i];
        if ([responder isKindOfClass:[UITextField class]]) {
            // if a textfield is last, it can use done button in KB, which will dismiss the keyboard
            [(UITextField*)responder setReturnKeyType:(i == ct-1) ? UIReturnKeyDone : UIReturnKeyNext];
            [(UITextField*)responder setDelegate:self];
        }            
    }
}

@end
