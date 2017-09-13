//
//  SalesTaxViewController.m
//  StratPad
//
//  Created by Julian Wood on 2013-04-25.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//

#import "SalesTaxViewController.h"
#import "MBRoundedRectView.h"
#import "SkinManager.h"
#import "Financials.h"
#import "SalesTax.h"
#import "UIView+ObjectTagAdditions.h"
#import "NSCalendar+Expanded.h"
#import "UILabelVAlignment.h"
#import "NSDate-StratPad.h"
#import "HonedSlider.h"
#import "PropertyTextField.h"
#import "UIColor-Expanded.h"
#import "NSString-Expanded.h"
#import "PermissionChecker.h"

@interface SalesTaxViewController ()
@property (retain, nonatomic) IBOutlet UILabel *lblTitle;
@property (retain, nonatomic) IBOutlet UILabel *lblSubtitle;
@property (retain, nonatomic) IBOutlet MBRoundedRectView *viewRoundedRect;
@property (retain, nonatomic) IBOutlet UITableView *tblRemittanceFrequency;
@property (retain, nonatomic) IBOutlet UITableView *tblRemittanceMonth;
@property (retain, nonatomic) IBOutlet HonedSlider *sliderPercentageTaxable;
@property (retain, nonatomic) IBOutlet PropertyTextField *txtRate;
@property (retain, nonatomic) IBOutlet UILabelVAlignment *lblRemittanceMonth;

@property (retain, nonatomic) SalesTax *salesTax;

@property (retain, nonatomic) NSArray *frequencyMapping;

@property (retain, nonatomic) PermissionChecker *permissionChecker;

// 2 decimals for rate
@property (nonatomic, retain) NSNumberFormatter *rateFormatter;

@end

@implementation SalesTaxViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.frequencyMapping = [NSArray arrayWithObjects:
                                 [NSNumber numberWithInteger:FrequencyCategoryMonthly],
                                 [NSNumber numberWithInteger:FrequencyCategoryQuarterly],
                                 [NSNumber numberWithInteger:FrequencyCategoryAnnually],
                                 nil];
        
        // rate
        NSNumberFormatter * formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle: NSNumberFormatterDecimalStyle];
        [formatter setMinimumFractionDigits:2];
        self.rateFormatter = formatter;
        [formatter release];
        
        PermissionChecker *checker = [[PermissionChecker alloc] initWithStratFile:[stratFileManager_ currentStratFile]];
        self.permissionChecker = checker;
        [checker release];

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _tblRemittanceFrequency.backgroundColor = [UIColor clearColor];
    _tblRemittanceFrequency.opaque = NO;
    _tblRemittanceFrequency.backgroundView = nil;
    _tblRemittanceFrequency.clipsToBounds = YES;
    
    // because we are making the background transparent, and because we have a grouped table, and because we have padding around the cells, compensate by adjusting the frame
    CGRect f = _tblRemittanceFrequency.frame;
    //_tblRemittanceFrequency.frame = CGRectMake(f.origin.x-10, f.origin.y-10, f.size.width+20, f.size.height+20);

    _tblRemittanceMonth.backgroundColor = [UIColor clearColor];
    _tblRemittanceMonth.opaque = NO;
    _tblRemittanceMonth.backgroundView = nil;
    _tblRemittanceMonth.clipsToBounds = YES;
    
    // because we are making the background transparent, and because we have a grouped table, and because we have padding around the cells, compensate by adjusting the frame
    f = _tblRemittanceMonth.frame;
    //_tblRemittanceMonth.frame = CGRectMake(f.origin.x-10, f.origin.y-10, f.size.width+20, f.size.height+20);

    SkinManager *skinMan = [SkinManager sharedManager];
    _lblTitle.textColor = [skinMan colorForProperty:kSkinSection2TitleFontColor];
    _lblSubtitle.textColor = [skinMan colorForProperty:kSkinSection2SubtitleFontColor];
    
    _viewRoundedRect.roundedRectBackgroundColor = [skinMan colorForProperty:kSkinSection2FormBackgroundColor];
    
    for (UIView *subview in _viewRoundedRect.subviews) {
        if ([subview isKindOfClass:[UILabel class]]) {
            [(UILabel*)subview setTextColor:[skinMan colorForProperty:kSkinSection2FieldLabelFontColor]];
        }
    }

    // our primary backing data
    self.salesTax = [stratFileManager_ currentStratFile].financials.salesTax;

    NSString *percentFormat = LocalizedString(@"PERCENT_MESSAGE_FORMAT", nil);

    // percentageTaxable
    _sliderPercentageTaxable.objectTag = @"percentRevenuesIsTaxable";
    _sliderPercentageTaxable.value = _salesTax.percentRevenuesIsTaxable.floatValue;
    [(UILabel*)[self.view viewWithTag:_sliderPercentageTaxable.tag+1] setText:[NSString stringWithFormat:percentFormat, _salesTax.percentRevenuesIsTaxable]];

    // rate
    [self configureField:_txtRate property:@"rate"];
    _txtRate.text = [NSString stringWithFormat:percentFormat, [_rateFormatter stringFromNumber:_salesTax.rate]];
    
    // remittance month is only enabled if we have chosen a remittance frequency of yearly
    BOOL enabled = _salesTax.remittanceFrequency.intValue == FrequencyCategoryAnnually;
    _lblRemittanceMonth.alpha = enabled;
    _tblRemittanceMonth.alpha = enabled;
    
    // place a transparent button over top of the slider to do our permission check
    if (![_permissionChecker isReadWrite]) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, _sliderPercentageTaxable.frame.size.width, _sliderPercentageTaxable.frame.size.height);
        btn.tag = 888;
        [btn addTarget:_permissionChecker action:@selector(checkReadWrite) forControlEvents:UIControlEventTouchUpInside];
        [_sliderPercentageTaxable addSubview:btn];
    }
    else {
        [[_sliderPercentageTaxable viewWithTag:888] removeFromSuperview];
    }

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
}


-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [stratFileManager_ saveCurrentStratFile];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // make sure we can see the saved, chosen month
    [_tblRemittanceMonth scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_salesTax.remittanceMonth.integerValue inSection:0]
                               atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

- (IBAction)sliderChanged:(HonedSlider*)slider
{
    NSNumber *val = [NSNumber numberWithInt:[slider honedIntegerValue]];
    [_salesTax setValue:val forKey:slider.objectTag];
    
    UILabel *lbl = (UILabel*)[self.view viewWithTag:slider.tag+1];
    NSString *percentFormat = LocalizedString(@"PERCENT_MESSAGE_FORMAT", nil);
    lbl.text = [NSString stringWithFormat:percentFormat, val];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_permissionChecker checkReadWrite] && tableView == _tblRemittanceFrequency) {
        FrequencyCategory frequency = [[self.frequencyMapping objectAtIndex:indexPath.row] intValue];
        _salesTax.remittanceFrequency = [NSNumber numberWithInt:frequency];
        
        // reset the old selected cell as well as check the new cell
        [_tblRemittanceFrequency reloadData];

        // if we select annually, fire up remittance month
        BOOL enabled = frequency == FrequencyCategoryAnnually;
        [UIView animateWithDuration:0.5
                         animations:^{
                             _tblRemittanceMonth.alpha = enabled;
                             _lblRemittanceMonth.alpha = enabled;
                         }];

    }
    else {
        _salesTax.remittanceMonth = [NSNumber numberWithInteger:indexPath.row];
        
        // reset the old selected cell as well as check the new cell
        [_tblRemittanceMonth reloadData];
        
    }
}



#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 38;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _tblRemittanceFrequency) {
        return 3;
    }
    else {
        return 12;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"SalesTaxCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        SkinManager *skinMan = [SkinManager sharedManager];
        cell.textLabel.textColor = [skinMan colorForProperty:kSkinSection2TableCellFontColor];
        cell.backgroundColor = [skinMan colorForProperty:kSkinSection2TableCellBackgroundColor forMediaType:MediaTypeScreen];
    }
    
    if (tableView == _tblRemittanceFrequency) {
        // 3,4, or 6
        FrequencyCategory frequency = [[self.frequencyMapping objectAtIndex:indexPath.row] integerValue];

        if (_salesTax.remittanceFrequency != nil && _salesTax.remittanceFrequency.integerValue == frequency) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        NSString *key = [NSString stringWithFormat:@"FREQUENCY_%d", frequency];
        cell.textLabel.text = LocalizedString(key, nil);
        
    }
    else {
        if (_salesTax.remittanceMonth != nil && _salesTax.remittanceMonth.integerValue == indexPath.row) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }

        // get localized month name
        NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
        [dateComponents setDay:15];
        [dateComponents setMonth:indexPath.row+1];
        [dateComponents setYear:2000];
        
        NSDate *date = [[NSCalendar cachedGregorianCalendar] dateFromComponents:dateComponents];
        NSString *month = [date monthName];
        [dateComponents release];
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@", month];
    }
    
    return cell;
}

#pragma mark - lifecycle

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_permissionChecker release];
    [_rateFormatter release];
    [_salesTax release];
    [_lblTitle release];
    [_lblSubtitle release];
    [_viewRoundedRect release];
    [_tblRemittanceFrequency release];
    [_tblRemittanceMonth release];
    [_sliderPercentageTaxable release];
    [_lblRemittanceMonth release];
    [_txtRate release];
    [super dealloc];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return [_permissionChecker checkReadWrite];
}

- (void)textFieldDidEndEditing:(PropertyTextField *)textField
{
    if ([textField.property isEqualToString:@"rate"]) {
        NSString *rateString = textField.text;
        if ([rateString isBlank]) {
            _salesTax.rate = [NSDecimalNumber zero];
        }
        else {
            NSDecimalNumber *rate = [NSDecimalNumber decimalNumberWithString:textField.text];
            _salesTax.rate = rate;
        }
        
        // add Percent
        NSString *percentFormat = LocalizedString(@"PERCENT_MESSAGE_FORMAT", nil);
        _txtRate.text = [NSString stringWithFormat:percentFormat, [_rateFormatter stringFromNumber:_salesTax.rate]];
    }
}

- (void)textFieldDidBeginEditing:(PropertyTextField *)textField
{
    if ([textField.property isEqualToString:@"rate"]) {
        // remove commas, spaces or any non-digit
        NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"0123456789."];
        textField.text = [[textField.text componentsSeparatedByCharactersInSet:[set invertedSet]] componentsJoinedByString:@""];
    }
}


- (BOOL)textField:(PropertyTextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)replacementString
{    
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

    [textField resignFirstResponder];
    
    // don't do the default action (of nothing)
    return NO;
}


@end
