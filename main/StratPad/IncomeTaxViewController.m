//
//  IncomeTaxViewController.m
//  StratPad
//
//  Created by Julian Wood on 2013-04-26.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//

#import "IncomeTaxViewController.h"
#import "MBRoundedRectView.h"
#import "SkinManager.h"
#import "IncomeTax.h"
#import "NSCalendar+Expanded.h"
#import "UIView+ObjectTagAdditions.h"
#import "Frequency.h"
#import "UILabelVAlignment.h"
#import "NSDate-StratPad.h"
#import "Financials.h"
#import "UIColor-Expanded.h"
#import "PropertyTextField.h"
#import "HonedSlider.h"
#import "PermissionChecker.h"

@interface IncomeTaxViewController ()

@property (retain, nonatomic) IBOutlet UILabel *lblTitle;
@property (retain, nonatomic) IBOutlet UILabel *lblSubtitle;
@property (retain, nonatomic) IBOutlet MBRoundedRectView *viewRoundedRect;

@property (retain, nonatomic) IBOutlet PropertyTextField *txtAmountTier1;
@property (retain, nonatomic) IBOutlet PropertyTextField *txtAmountTier2;
@property (retain, nonatomic) IBOutlet PropertyTextField *txtAmountTier3;

@property (retain, nonatomic) IBOutlet HonedSlider *sliderTaxPercentageTier1;
@property (retain, nonatomic) IBOutlet HonedSlider *sliderTaxPercentageTier2;
@property (retain, nonatomic) IBOutlet HonedSlider *sliderTaxPercentageTier3;
@property (retain, nonatomic) IBOutlet HonedSlider *sliderTaxCarryForwardYears;
@property (retain, nonatomic) IBOutlet UILabel *lblTaxCarryForwardYears;

@property (retain, nonatomic) IBOutlet UITableView *tblRemittanceFrequency;
@property (retain, nonatomic) IBOutlet UITableView *tblRemittanceMonth;
@property (retain, nonatomic) IBOutlet UILabelVAlignment *lblRemittanceMonth;

@property (retain, nonatomic) IncomeTax *incomeTax;

@property (retain, nonatomic) NSArray *frequencyMapping;
@property (retain, nonatomic) NSString *yearsTextFormat;

@property (retain, nonatomic) NSNumberFormatter *groupedFormatter;

@property (retain, nonatomic) PermissionChecker *permissionChecker;

@end

@implementation IncomeTaxViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.frequencyMapping = [NSArray arrayWithObjects:
                                 [NSNumber numberWithInteger:FrequencyCategoryMonthly],
                                 [NSNumber numberWithInteger:FrequencyCategoryQuarterly],
                                 [NSNumber numberWithInteger:FrequencyCategoryAnnually],
                                 nil];
        NSNumberFormatter * formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle: NSNumberFormatterDecimalStyle];
        [formatter setMaximumFractionDigits:0];
        self.groupedFormatter = formatter;
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
        else if ([subview isKindOfClass:[UISlider class]]) {
            // place a transparent button over top of the slider to do our permission check
            if (![_permissionChecker isReadWrite]) {
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                btn.frame = CGRectMake(0, 0, subview.frame.size.width, subview.frame.size.height);
                btn.tag = 888;
                [btn addTarget:_permissionChecker action:@selector(checkReadWrite) forControlEvents:UIControlEventTouchUpInside];
                [subview addSubview:btn];
            }
            else {
                [[subview viewWithTag:888] removeFromSuperview];
            }
        }
    }
    
    self.incomeTax = [stratFileManager_ currentStratFile].financials.incomeTax;
    
    // use the value in the nib for localization of the years label
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^\\d+\\s+(.+)$" options:0 error:nil];
    
    self.yearsTextFormat = [regex stringByReplacingMatchesInString:_lblTaxCarryForwardYears.text
                                                          options:0
                                                            range:NSMakeRange(0, [_lblTaxCarryForwardYears.text length])
                                                     withTemplate:@"%@ $1"];

    
    // bind to core data properties
    _sliderTaxPercentageTier1.objectTag = @"rate1";
    _sliderTaxPercentageTier2.objectTag = @"rate2";
    _sliderTaxPercentageTier3.objectTag = @"rate3";
    _sliderTaxCarryForwardYears.objectTag = @"yearsCarryLossesForward";
    

    // initial value - set default in core data
    _sliderTaxPercentageTier1.value = _incomeTax.rate1.floatValue;
    _sliderTaxPercentageTier2.value = _incomeTax.rate2.floatValue;
    _sliderTaxPercentageTier3.value = _incomeTax.rate3.floatValue;
    _sliderTaxCarryForwardYears.value = _incomeTax.yearsCarryLossesForward.floatValue;
    
    // update corresponding label
    NSString *percentFormat = LocalizedString(@"PERCENT_MESSAGE_FORMAT", nil);
    [(UILabel*)[self.view viewWithTag:_sliderTaxPercentageTier1.tag+1] setText:[NSString stringWithFormat:percentFormat, _incomeTax.rate1]];
    [(UILabel*)[self.view viewWithTag:_sliderTaxPercentageTier2.tag+1] setText:[NSString stringWithFormat:percentFormat, _incomeTax.rate2]];
    [(UILabel*)[self.view viewWithTag:_sliderTaxPercentageTier3.tag+1] setText:[NSString stringWithFormat:percentFormat, _incomeTax.rate3]];
    [(UILabel*)[self.view viewWithTag:_sliderTaxCarryForwardYears.tag+1] setText:[NSString stringWithFormat:_yearsTextFormat, _incomeTax.yearsCarryLossesForward]];
    
    // remittance month is only enabled if we have chosen a remittance frequency of yearly
    BOOL enabled = _incomeTax.remittanceFrequency.intValue == FrequencyCategoryAnnually;
    _lblRemittanceMonth.alpha = enabled;
    _tblRemittanceMonth.alpha = enabled;
    
    // number fields - note that #3 is just a copy of 2
    [self configureField:_txtAmountTier1 property:@"salaryLimit1"];
    [self configureField:_txtAmountTier2 property:@"salaryLimit2"];
    [self configureField:_txtAmountTier3 property:@"salaryLimit2"];
    
    // initial value
    _txtAmountTier1.text = [_groupedFormatter stringFromNumber:_incomeTax.salaryLimit1];
    _txtAmountTier2.text = [_groupedFormatter stringFromNumber:_incomeTax.salaryLimit2];
    _txtAmountTier3.text = [_groupedFormatter stringFromNumber:_incomeTax.salaryLimit2];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_permissionChecker release];
    [_groupedFormatter release];
    [_incomeTax release];
    [_frequencyMapping release];
    [_yearsTextFormat release];
    
    [_lblTitle release];
    [_lblSubtitle release];
    [_viewRoundedRect release];
    [_txtAmountTier1 release];
    [_txtAmountTier2 release];
    [_txtAmountTier3 release];
    [_sliderTaxPercentageTier1 release];
    [_sliderTaxPercentageTier2 release];
    [_sliderTaxPercentageTier3 release];
    [_sliderTaxCarryForwardYears release];
    [_tblRemittanceFrequency release];
    [_tblRemittanceMonth release];
    [_lblRemittanceMonth release];
    [_lblTaxCarryForwardYears release];
    [super dealloc];
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
    [_tblRemittanceMonth scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_incomeTax.remittanceMonth.integerValue inSection:0]
                               atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

#pragma mark - Actions

- (IBAction)sliderChanged:(HonedSlider*)slider
{
    NSNumber *val = [NSNumber numberWithInt:[slider honedIntegerValue]];
    [_incomeTax setValue:val forKey:slider.objectTag];
    
    NSString *percentFormat = LocalizedString(@"PERCENT_MESSAGE_FORMAT", nil);
    UILabel *lbl = (UILabel*)[self.view viewWithTag:slider.tag+1];
    NSString *format = ([slider.objectTag isEqualToString:@"yearsCarryLossesForward"]) ? _yearsTextFormat : percentFormat;
    lbl.text = [NSString stringWithFormat:format, val];
}

- (IBAction)editingChanged:(PropertyTextField*)textField {
    _txtAmountTier3.text =textField.text;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_permissionChecker checkReadWrite] && tableView == _tblRemittanceFrequency) {
        FrequencyCategory frequency = [[self.frequencyMapping objectAtIndex:indexPath.row] intValue];
        _incomeTax.remittanceFrequency = [NSNumber numberWithInt:frequency];
        
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
        _incomeTax.remittanceMonth = [NSNumber numberWithInteger:indexPath.row];
        
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
    static NSString *cellIdentifier = @"IncomeTaxCell";
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
        
        if (_incomeTax.remittanceFrequency != nil && _incomeTax.remittanceFrequency.integerValue == frequency) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        NSString *key = [NSString stringWithFormat:@"FREQUENCY_%d", frequency];
        cell.textLabel.text = LocalizedString(key, nil);
        
    }
    else {
        if (_incomeTax.remittanceMonth != nil && _incomeTax.remittanceMonth.integerValue == indexPath.row) {
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

#pragma mark - UITextFieldDelegate

-(void)configureField:(PropertyTextField*)textField property:(NSString*)property
{
    SkinManager *skinMan = [SkinManager sharedManager];
    UIColor *textColor = [skinMan colorForProperty:kSkinSection2FieldLabelFontColor];
    
    textField.textColor = textColor;
    textField.delegate = self;
    textField.property = property;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return [_permissionChecker checkReadWrite];
}

- (void)textFieldDidEndEditing:(PropertyTextField *)textField
{
    NSNumber *amount = [NSNumber numberWithInteger:textField.text.integerValue];
    [_incomeTax setValue:amount forKey:textField.property];
    
    // add grouping
    textField.text = [_groupedFormatter stringFromNumber:amount];
    
    if ([textField.property isEqualToString:@"salaryLimit2"]) {
        _incomeTax.salaryLimit2 = amount;
        _txtAmountTier3.text =[_groupedFormatter stringFromNumber:amount];
    }
    
}

- (void)textFieldDidBeginEditing:(PropertyTextField *)textField
{
    // remove commas, spaces or any non-digit
    textField.text = [[textField.text componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
}

- (BOOL)textField:(PropertyTextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)replacementString
{
    // go up to 12 digits
    if (textField.text.length == 12 && [replacementString length] > 0) {
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
    
    if (textField == _txtAmountTier2) {
        // done
        [textField resignFirstResponder];
    } else {
        // next
        [_txtAmountTier2 becomeFirstResponder];
    }
    
    // don't do the default action (of nothing)
    return NO;
}



@end
