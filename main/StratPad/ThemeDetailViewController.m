//
//  ThemeDetailViewController.m
//  StratPad
//
//  Created by Eric Rogers on August 11, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "ThemeDetailViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "DataManager.h"
#import "NSString-Expanded.h"
#import "NSDate-StratPad.h"
#import "NSNumber-StratPad.h"
#import "Objective.h"
#import "Activity.h"
#import "EventManager.h"
#import "NSCalendar+Expanded.h"
#import "Responsible.h"
#import "ThemeRevenueCalculator.h"
#import "ThemeCOGSCalculator.h"
#import "ThemeRADCalculator.h"
#import "ThemeGAACalculator.h"
#import "ThemeSAMCalculator.h"
#import "Settings.h"
#import "ApplicationSkin.h"
#import "UIColor-Expanded.h"
#import "EditionManager.h"
#import "Metric.h"
#import "PermissionChecker.h"


const static NSInteger PERCENT_FIELD = 909090;

@interface ThemeDetailViewController ()

@property (retain, nonatomic) Theme *theme;

@property (retain, nonatomic) IBOutlet UILabel *lblTheme;
@property (retain, nonatomic) IBOutlet UILabel *lblStartDate;
@property (retain, nonatomic) IBOutlet UILabel *lblEndDate;
@property (retain, nonatomic) IBOutlet ThemeDetailTextField *txtNumberOfEmployeesAtThemeStart;
@property (retain, nonatomic) IBOutlet ThemeDetailTextField *txtNumberOfEmployeesAtThemeEnd;

@property(nonatomic, retain) IBOutlet MBRoundedTextField *txtRevenueOneTime;
@property(nonatomic, retain) IBOutlet ThemeDetailTextField *txtRevenueMonthly;
@property(nonatomic, retain) IBOutlet ThemeDetailTextField *txtRevenueQuarterly;
@property(nonatomic, retain) IBOutlet ThemeDetailTextField *txtRevenueAnnually;

@property(nonatomic, retain) IBOutlet MBRoundedTextField *txtCogsOneTime;
@property(nonatomic, retain) IBOutlet ThemeDetailTextField *txtCogsMonthly;
@property(nonatomic, retain) IBOutlet ThemeDetailTextField *txtCogsQuarterly;
@property(nonatomic, retain) IBOutlet ThemeDetailTextField *txtCogsAnnually;
@property (retain, nonatomic) IBOutlet MBRoundedTextField *txtCogsPayrollPercent;

@property(nonatomic, retain) IBOutlet MBRoundedTextField *txtExpensesOneTime;
@property(nonatomic, retain) IBOutlet ThemeDetailTextField *txtExpensesMonthly;
@property(nonatomic, retain) IBOutlet ThemeDetailTextField *txtExpensesQuarterly;
@property(nonatomic, retain) IBOutlet ThemeDetailTextField *txtExpensesAnnually;
@property (retain, nonatomic) IBOutlet MBRoundedTextField *txtRDPayrollPercent;

@property(nonatomic, retain) IBOutlet MBRoundedTextField *txtCostsOneTime;
@property(nonatomic, retain) IBOutlet ThemeDetailTextField *txtCostsMonthly;
@property(nonatomic, retain) IBOutlet ThemeDetailTextField *txtCostsQuarterly;
@property(nonatomic, retain) IBOutlet ThemeDetailTextField *txtCostsAnnually;
@property (retain, nonatomic) IBOutlet MBRoundedTextField *txtGAPayrollPercent;

@property (retain, nonatomic) IBOutlet MBRoundedTextField *txtSMOneTime;
@property (retain, nonatomic) IBOutlet ThemeDetailTextField *txtSMMonthly;
@property (retain, nonatomic) IBOutlet ThemeDetailTextField *txtSMQuarterly;
@property (retain, nonatomic) IBOutlet ThemeDetailTextField *txtSMAnnually;
@property (retain, nonatomic) IBOutlet MBRoundedTextField *txtSMPayrollPercent;

@property(nonatomic, retain) IBOutlet UILabel *lblTotalNetBenefit;
@property(nonatomic, retain) IBOutlet UILabel *lblNetBenefitOneTime;
@property(nonatomic, retain) IBOutlet UILabel *lblNetBenefitMonthly;
@property(nonatomic, retain) IBOutlet UILabel *lblNetBenefitQuarterly;
@property(nonatomic, retain) IBOutlet UILabel *lblNetBenefitAnnually;

@property(nonatomic, retain) IBOutlet UILabel *lblTitle;
@property(nonatomic, retain) IBOutlet UILabel *lblSubTitle;
@property(nonatomic, retain) IBOutlet MBRoundedScrollView *fieldsetView;
@property(nonatomic, retain) IBOutlet MBDropDownButton *btnTheme;
@property(nonatomic, retain) IBOutlet MBAutoSuggestTextField *txtResponsible;
@property (retain, nonatomic) IBOutlet UIButton *btnCalculations;

@property (nonatomic, retain) NSCharacterSet * digitSet;
@property (nonatomic, retain) PermissionChecker *permissionChecker;

@end


@implementation NSNumber (ThemeDetail)

- (NSString*)netBenefitFormattedNumber
{
    return [self decimalFormattedNumberForCurrencyDisplay];
}


@end

@implementation ThemeDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andThemeOrNil:(Theme*)theme
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        self.theme = theme;
        
        // listen for optimistic setting changes
        [[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(optimisticSettingChanged)
													 name:kEVENT_OPTIMISTIC_SETTING_CHANGED
												   object:nil];
        
        [self.theme addObserver:self forKeyPath:@"title" options:0 context:nil];
        
        self.digitSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789-"];
        
        PermissionChecker *checker = [[PermissionChecker alloc] initWithStratFile:theme.stratFile];
        self.permissionChecker = checker;
        [checker release];

    }
    return self;
}

#pragma mark - Memory Management

- (void)dealloc
{
    [_permissionChecker release];
    [_theme removeObserver:self forKeyPath:@"title"];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_theme release];
    [_digitSet release];
    
    [_lblTitle release];
    [_lblSubTitle release];
    [_fieldsetView release];
    [_btnTheme release];
    [_txtResponsible release];
    [_btnStartDate release];
    [_btnEndDate release];
    [_btnCalculations release];
    
    [_txtRevenueOneTime release];
    [_txtRevenueMonthly release];
    [_txtRevenueQuarterly release];
    [_txtRevenueAnnually release];
    
    [_txtCogsOneTime release];
    [_txtCogsMonthly release];
    [_txtCogsQuarterly release];
    [_txtCogsAnnually release];

    [_txtExpensesOneTime release];
    [_txtExpensesMonthly release];
    [_txtExpensesQuarterly release];
    [_txtExpensesAnnually release];

    [_txtCostsOneTime release];
    [_txtCostsMonthly release];
    [_txtCostsQuarterly release];
    [_txtCostsAnnually release];

    [_lblTotalNetBenefit release];
    [_lblNetBenefitOneTime release];
    [_lblNetBenefitMonthly release];
    [_lblNetBenefitQuarterly release];
    [_lblNetBenefitAnnually release];
    
    [themeDropDownController_ release];
    [autoSuggestController_ release];
    [startDateController_ release];
    [endDateController_ release];
    
    [calculationsVC_ release];
        
    [_lblTheme release];
    [_lblStartDate release];
    [_lblEndDate release];
    [_txtNumberOfEmployeesAtThemeStart release];
    [_txtNumberOfEmployeesAtThemeEnd release];
    [_txtCogsPayrollPercent release];
    [_txtRDPayrollPercent release];
    [_txtGAPayrollPercent release];
    [_txtSMPayrollPercent release];
    [_txtSMAnnually release];
    [_txtSMQuarterly release];
    [_txtSMMonthly release];
    [_txtSMOneTime release];
    [super dealloc];
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    ApplicationSkin *skin = [ApplicationSkin currentSkin];
    self.fieldsetView.roundedRectBackgroundColor = [UIColor colorWithHexString:skin.section2FormBackgroundColor];
    
    self.lblTitle.font = [UIFont fontWithName:skin.section2TitleFontName size:[skin.section2TitleFontSize floatValue]];
    self.lblTitle.textColor = [UIColor colorWithHexString:skin.section2TitleFontColor];
    
    self.lblSubTitle.font = [UIFont fontWithName:skin.section2SubtitleFontName size:[skin.section2SubtitleFontSize floatValue]];
    self.lblSubTitle.textColor = [UIColor colorWithHexString:skin.section2SubtitleFontColor];
    
    _lblTheme.textColor = [UIColor colorWithHexString:skin.section2FieldLabelFontColor];

    for (UIView *subview in [self.fieldsetView subviews]) {

        // all the labels
        if ([subview isKindOfClass:[UILabel class]]) {
            ((UILabel*)subview).textColor = [UIColor colorWithHexString:skin.section2FieldLabelFontColor];
        }
        
        // the grid cells
        if ([subview isKindOfClass:[MBRoundedTextField class]]) {
            MBRoundedTextField *field = (MBRoundedTextField*) subview;
            field.textColor = [UIColor colorWithHexString:skin.section2TextValueFontColor];
            field.roundedRectBackgroundColor = [UIColor colorWithHexString:skin.section2TextFieldBackgroundColor];
            field.font = [UIFont systemFontOfSize:15];
        }
        
        // the totals at the bottom
        if ([subview isKindOfClass:[MBRoundedLabel class]]) {
            MBRoundedLabel *lbl = (MBRoundedLabel*) subview;
            lbl.textColor = [UIColor colorWithHexString:skin.section2FieldLabelFontColor];
            lbl.font = [UIFont systemFontOfSize:15];
        }
    }
    
    self.btnTheme.label.textColor = [UIColor colorWithHexString:skin.section2TextValueFontColor];
    self.btnTheme.roundedRectBackgroundColor = [UIColor colorWithHexString:skin.section2FormBackgroundColor];
    
    self.txtResponsible.textColor = [UIColor colorWithHexString:skin.section2TextValueFontColor];
    self.txtResponsible.roundedRectBackgroundColor = [UIColor colorWithHexString:skin.section2TextFieldBackgroundColor];
        
    self.btnStartDate.textColor = [UIColor colorWithHexString:skin.section2TextValueFontColor];
    self.btnStartDate.roundedRectBackgroundColor = [UIColor colorWithHexString:skin.section2TextFieldBackgroundColor];
    self.btnStartDate.enabledBackgroundColor = [UIColor colorWithHexString:skin.section2TextFieldBackgroundColor];
  
    self.btnEndDate.textColor = [UIColor colorWithHexString:skin.section2TextValueFontColor];
    self.btnEndDate.roundedRectBackgroundColor = [UIColor colorWithHexString:skin.section2TextFieldBackgroundColor];
    self.btnEndDate.enabledBackgroundColor = [UIColor colorWithHexString:skin.section2TextFieldBackgroundColor];
    
    if (!themeDropDownController_) {
        themeDropDownController_ = [[MBDropDownController alloc] initWithDropDownButton:self.btnTheme andSelectedValueOrNil:_theme];
        themeDropDownController_.delegate = self;        
    }
    
    if (!autoSuggestController_) {
        autoSuggestController_ = [[MBAutoSuggestController alloc] initWithAutoSuggestTextField:self.txtResponsible];
        autoSuggestController_.delegate = self;
    }
    
    
    UIImage *btnImage = [[UIImage imageNamed:@"button-grey-keyboard.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:0];
    [_btnCalculations setBackgroundImage:btnImage forState:UIControlStateNormal];
    [_btnCalculations setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_btnCalculations setTitleShadowColor:[[UIColor blackColor] colorWithAlphaComponent:0.3] forState:UIControlStateNormal];
    [_btnCalculations.titleLabel setShadowOffset:CGSizeMake(0, -1)];

    [self bindFields];
    
    [self loadValues];
            
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    // if the title changes on the theme (ie in F4), we catch that using KVO
    // if themes are added or removed, we catch that here
    [themeDropDownController_ removeAllDropDownValues];
    NSArray *sortedThemes = [stratFileManager_.currentStratFile themesSortedByOrder];
    for (Theme *theme in sortedThemes) {
        [themeDropDownController_ addDropDownValue:theme withDisplayValue:theme.title];
    }  
    [themeDropDownController_ setSelectedValue:_theme];
    self.btnTheme.label.text = _theme.title;
    
    [self updateAutoSuggestValuesForResponsible];    

    [super viewWillAppear:animated];
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return [_permissionChecker checkReadWrite];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)replacementString
{
    if (textField == self.txtResponsible) {
        NSString *searchValue = [textField.text stringByReplacingCharactersInRange:range withString:replacementString];
        [autoSuggestController_ showWithSearchString:searchValue];
        return YES;
    }

    else {
        // just digits for all the other fields
        
        // we will allow -99 999 999 or 999 999 999 = 9 chars
        if (textField.text.length ==  9 && [replacementString length] > 0) {
            return NO;
        }
        else if ([replacementString length] == 1) {
            // as long as replacementString (what the user typed) contains valid chars, return yes
            BOOL isValidChar = (textField == _txtNumberOfEmployeesAtThemeEnd || textField == _txtNumberOfEmployeesAtThemeStart) ?
            [replacementString rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]].location != NSNotFound :
            [replacementString rangeOfCharacterFromSet:_digitSet].location != NSNotFound;
            
            // before we return YES, restrict to 100
            if (isValidChar && textField.tag == PERCENT_FIELD) {
                NSString *requestedText = [textField.text stringByReplacingCharactersInRange:range withString:replacementString];
                return (requestedText.integerValue <= 100);
            }
            
            
            return isValidChar;
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
}

- (void)textFieldDidBeginEditing:(MBRoundedTextField *)textField
{
    if (textField != self.txtResponsible) {
        // remove commas, spaces or any non-digit
        textField.text = [[textField.text componentsSeparatedByCharactersInSet:[_digitSet invertedSet]] componentsJoinedByString:@""];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.txtResponsible) {
        [autoSuggestController_ hideAutoSuggest];
        [self saveAndUpdateResponsibleField];
    }
    else if (textField.tag == PERCENT_FIELD) {
        [self saveGridTextField:(MBRoundedTextField*)textField];
        [self showPercentValue:(MBRoundedTextField *)textField];
    }
    else if (textField == _txtNumberOfEmployeesAtThemeEnd || textField == _txtNumberOfEmployeesAtThemeStart) {
        NSNumber *value = [NSNumber numberWithInteger:textField.text.integerValue];
        [_theme setValue:value forKey:((MBRoundedTextField*)textField).boundProperty];
        [stratFileManager_ saveCurrentStratFile];
    } else {
        [self saveGridTextField:(MBRoundedTextField*)textField];
        NSDictionary *netBenefits = [self calculateNetBenefits];
        [self updateNetBenefits:netBenefits];
    }
    
}


#pragma mark - Support

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"title"] && [object isKindOfClass:[Theme class]]) {        
       
        // if the title changes on the theme (ie in F4), update the dropdown
        // if themes are added or removed, we catch that in viewWillAppear
        [themeDropDownController_ removeAllDropDownValues];
        NSArray *sortedThemes = [stratFileManager_.currentStratFile themesSortedByOrder];
        for (Theme *theme in sortedThemes) {
            [themeDropDownController_ addDropDownValue:theme withDisplayValue:theme.title];
        }  
        [themeDropDownController_ setSelectedValue:_theme];
        self.btnTheme.label.text = _theme.title;
    }
}

- (void)optimisticSettingChanged
{
    NSDictionary *netBenefits = [self calculateNetBenefits];
    [self updateNetBenefits:netBenefits];
}

- (void)bindFields
{
    [self.txtResponsible setBindingWithEntity:_theme andProperty:@"responsible"];
    
    [self.txtNumberOfEmployeesAtThemeStart setBindingWithEntity:_theme andProperty:@"numberOfEmployeesAtThemeStart"];
    [self.txtNumberOfEmployeesAtThemeEnd setBindingWithEntity:_theme andProperty:@"numberOfEmployeesAtThemeEnd"];
    
    [self.txtRevenueOneTime setBindingWithEntity:_theme andProperty:@"revenueOneTime"];
    [self.txtRevenueMonthly setBindingWithEntity:_theme andProperty:@"revenueMonthly"];
    [self.txtRevenueQuarterly setBindingWithEntity:_theme andProperty:@"revenueQuarterly"];
    [self.txtRevenueAnnually setBindingWithEntity:_theme andProperty:@"revenueAnnually"];
    // no payroll here
    
    [self.txtCogsOneTime setBindingWithEntity:_theme andProperty:@"cogsOneTime"];
    [self.txtCogsMonthly setBindingWithEntity:_theme andProperty:@"cogsMonthly"];
    [self.txtCogsQuarterly setBindingWithEntity:_theme andProperty:@"cogsQuarterly"];
    [self.txtCogsAnnually setBindingWithEntity:_theme andProperty:@"cogsAnnually"];
    [self.txtCogsPayrollPercent setBindingWithEntity:_theme andProperty:@"percentCogsIsPayroll"];
    
    [self.txtExpensesOneTime setBindingWithEntity:_theme andProperty:@"researchAndDevelopmentOneTime"];
    [self.txtExpensesMonthly setBindingWithEntity:_theme andProperty:@"researchAndDevelopmentMonthly"];
    [self.txtExpensesQuarterly setBindingWithEntity:_theme andProperty:@"researchAndDevelopmentQuarterly"];
    [self.txtExpensesAnnually setBindingWithEntity:_theme andProperty:@"researchAndDevelopmentAnnually"];
    [self.txtRDPayrollPercent setBindingWithEntity:_theme andProperty:@"percentResearchAndDevelopmentIsPayroll"];
    
    [self.txtCostsOneTime setBindingWithEntity:_theme andProperty:@"generalAndAdminOneTime"];
    [self.txtCostsMonthly setBindingWithEntity:_theme andProperty:@"generalAndAdminMonthly"];
    [self.txtCostsQuarterly setBindingWithEntity:_theme andProperty:@"generalAndAdminQuarterly"];
    [self.txtCostsAnnually setBindingWithEntity:_theme andProperty:@"generalAndAdminAnnually"];
    [self.txtGAPayrollPercent setBindingWithEntity:_theme andProperty:@"percentGeneralAndAdminIsPayroll"];
    
    [self.txtSMOneTime setBindingWithEntity:_theme andProperty:@"salesAndMarketingOneTime"];
    [self.txtSMMonthly setBindingWithEntity:_theme andProperty:@"salesAndMarketingMonthly"];
    [self.txtSMQuarterly setBindingWithEntity:_theme andProperty:@"salesAndMarketingQuarterly"];
    [self.txtSMAnnually setBindingWithEntity:_theme andProperty:@"salesAndMarketingAnnually"];
    [self.txtSMPayrollPercent setBindingWithEntity:_theme andProperty:@"percentSalesAndMarketingIsPayroll"];
}

- (void)loadValues
{
    // load the values for the theme drop down
    [themeDropDownController_ removeAllDropDownValues];
    NSArray *sortedThemes = [stratFileManager_.currentStratFile themesSortedByOrder];
    for (Theme *theme in sortedThemes) {
        [themeDropDownController_ addDropDownValue:theme withDisplayValue:theme.title];
    }
    
    self.fieldsetView.contentSize = CGSizeMake(self.fieldsetView.frame.size.width, self.fieldsetView.frame.size.height);
    
    if (_theme) {
        self.btnTheme.label.text = _theme.title;
        
        self.txtResponsible.text = _theme.responsible.summary;
        
        [self.btnStartDate setDate:_theme.startDate];
        
        // end date is illegal if no start date
        [self.btnEndDate setDate:_theme.endDate];
        self.btnEndDate.enabled = _theme.startDate != nil;
                
        NSNumber *value = [_theme valueForKey:self.txtNumberOfEmployeesAtThemeStart.boundProperty];
        _txtNumberOfEmployeesAtThemeStart.text = [value decimalFormattedNumberWithZeroDisplay:YES];

        value = [_theme valueForKey:self.txtNumberOfEmployeesAtThemeEnd.boundProperty];
        _txtNumberOfEmployeesAtThemeEnd.text = [value decimalFormattedNumberWithZeroDisplay:YES];
        
        [self showCellValue:self.txtRevenueOneTime];
        [self showCellValue:self.txtRevenueMonthly];
        [self showCellValue:self.txtRevenueQuarterly];
        [self showCellValue:self.txtRevenueAnnually];
        // payroll percent doesn't apply to revenue
        
        [self showCellValue:self.txtCogsOneTime];
        [self showCellValue:self.txtCogsMonthly];
        [self showCellValue:self.txtCogsQuarterly];
        [self showCellValue:self.txtCogsAnnually];
        [self showPercentValue:self.txtCogsPayrollPercent];
        
        [self showCellValue:self.txtExpensesOneTime];
        [self showCellValue:self.txtExpensesMonthly];
        [self showCellValue:self.txtExpensesQuarterly];
        [self showCellValue:self.txtExpensesAnnually];
        [self showPercentValue:self.txtRDPayrollPercent];
        
        [self showCellValue:self.txtCostsOneTime];
        [self showCellValue:self.txtCostsMonthly];
        [self showCellValue:self.txtCostsQuarterly];
        [self showCellValue:self.txtCostsAnnually];
        [self showPercentValue:self.txtGAPayrollPercent];
        
        [self showCellValue:self.txtSMOneTime];
        [self showCellValue:self.txtSMMonthly];
        [self showCellValue:self.txtSMQuarterly];
        [self showCellValue:self.txtSMAnnually];
        [self showPercentValue:self.txtSMPayrollPercent];
        
        self.txtCogsPayrollPercent.tag = PERCENT_FIELD;
        self.txtRDPayrollPercent.tag = PERCENT_FIELD;
        self.txtGAPayrollPercent.tag = PERCENT_FIELD;
        self.txtSMPayrollPercent.tag = PERCENT_FIELD;
        
        NSDictionary *netBenefits = [self calculateNetBenefits];
        [self updateNetBenefits:netBenefits];
    }
    
}


// this is a dict of NSNumber-wrapped doubles
- (void)updateNetBenefits:(NSDictionary*)netBenefits
{
    // update totals row
    self.lblNetBenefitOneTime.text = [self formatNetBenefitValueForDisplay:[netBenefits objectForKey:@"oneTime"]];  
    self.lblNetBenefitMonthly.text = [self formatNetBenefitValueForDisplay:[netBenefits objectForKey:@"monthly"]]; 
    self.lblNetBenefitQuarterly.text = [self formatNetBenefitValueForDisplay:[netBenefits objectForKey:@"quarterly"]]; 
    self.lblNetBenefitAnnually.text = [self formatNetBenefitValueForDisplay:[netBenefits objectForKey:@"annually"]]; 
    self.lblTotalNetBenefit.text = [self formatNetBenefitValueForDisplay:[netBenefits objectForKey:@"total"]];
    
    // let the textfields know if they should add a little mark to represent an adjustment
    self.txtRevenueMonthly.hasAdjustment = [_theme.revenueMonthlyAdjustment compare:[NSDecimalNumber zero]] != NSOrderedSame;
    self.txtRevenueQuarterly.hasAdjustment = [_theme.revenueQuarterlyAdjustment compare:[NSDecimalNumber zero]] != NSOrderedSame;
    self.txtRevenueAnnually.hasAdjustment = [_theme.revenueAnnuallyAdjustment compare:[NSDecimalNumber zero]] != NSOrderedSame;
    
    self.txtCogsMonthly.hasAdjustment = [_theme.cogsMonthlyAdjustment compare:[NSDecimalNumber zero]] != NSOrderedSame;
    self.txtCogsQuarterly.hasAdjustment = [_theme.cogsQuarterlyAdjustment compare:[NSDecimalNumber zero]] != NSOrderedSame;
    self.txtCogsAnnually.hasAdjustment = [_theme.cogsAnnuallyAdjustment compare:[NSDecimalNumber zero]] != NSOrderedSame;
    
    self.txtExpensesMonthly.hasAdjustment = [_theme.researchAndDevelopmentMonthlyAdjustment compare:[NSDecimalNumber zero]] != NSOrderedSame;
    self.txtExpensesQuarterly.hasAdjustment = [_theme.researchAndDevelopmentQuarterlyAdjustment compare:[NSDecimalNumber zero]] != NSOrderedSame;
    self.txtExpensesAnnually.hasAdjustment = [_theme.researchAndDevelopmentAnnuallyAdjustment compare:[NSDecimalNumber zero]] != NSOrderedSame;
    
    self.txtCostsMonthly.hasAdjustment = [_theme.generalAndAdminMonthlyAdjustment compare:[NSDecimalNumber zero]] != NSOrderedSame;
    self.txtCostsQuarterly.hasAdjustment = [_theme.generalAndAdminQuarterlyAdjustment compare:[NSDecimalNumber zero]] != NSOrderedSame;
    self.txtCostsAnnually.hasAdjustment = [_theme.generalAndAdminAnnuallyAdjustment compare:[NSDecimalNumber zero]] != NSOrderedSame;
    
    self.txtSMMonthly.hasAdjustment = [_theme.salesAndMarketingMonthlyAdjustment compare:[NSDecimalNumber zero]] != NSOrderedSame;
    self.txtSMQuarterly.hasAdjustment = [_theme.salesAndMarketingQuarterlyAdjustment compare:[NSDecimalNumber zero]] != NSOrderedSame;
    self.txtSMAnnually.hasAdjustment = [_theme.salesAndMarketingAnnuallyAdjustment compare:[NSDecimalNumber zero]] != NSOrderedSame;
}

- (NSDictionary*)calculateNetBenefits
{
    //total benefit for each column (one time, monthly, quarterly, and annually) is calculated as follows:
    // (revenueBenefit - cogsBenefit) - (expenseBenefit + costBenefit)
    
    // the requirements call to carry full precision, and round for display only
    // we will explain the discrepancies to the user
    
    NSMutableDictionary *netBenefitsDict = [NSMutableDictionary dictionary];
        
    Settings *settings = (Settings*)[DataManager objectForEntity:NSStringFromClass([Settings class]) sortDescriptorsOrNil:nil predicateOrNil:nil];
    BOOL optimistic = [settings.isCalculationOptimistic boolValue];
    
    ThemeRevenueCalculator *revenueCalculator = [[ThemeRevenueCalculator alloc] initWithTheme:_theme andIsOptimistic:optimistic];
    ThemeCOGSCalculator *cogsCalculator = [[ThemeCOGSCalculator alloc] initWithTheme:_theme andIsOptimistic:optimistic];
    ThemeRADCalculator *radCalculator = [[ThemeRADCalculator alloc] initWithTheme:_theme andIsOptimistic:optimistic];
    ThemeGAACalculator *gaaCalculator = [[ThemeGAACalculator alloc] initWithTheme:_theme andIsOptimistic:optimistic];
    ThemeSAMCalculator *samCalculator = [[ThemeSAMCalculator alloc] initWithTheme:_theme andIsOptimistic:optimistic];
                                                                                                                         
    NSUInteger numMonths = [[revenueCalculator oneTimeValues] count];
    numMonths = numMonths < 12 ? numMonths : 12;
    
    // one time benefit
    double oneTimeRevenueBenefit = 0;
    double oneTimeCOGSBenefit = 0;
    double oneTimeRadBenefit = 0;
    double oneTimeGaaBenefit = 0;
    double oneTimeSamBenefit = 0;
    
    // presumably this was done for convenience or consistency? only the first index of this array should have a value
    for (uint i = 0; i < numMonths; i++) {
        oneTimeRevenueBenefit   += [[revenueCalculator.oneTimeValues objectAtIndex:i] doubleValue];        
        oneTimeCOGSBenefit      += [[cogsCalculator.oneTimeValues objectAtIndex:i] doubleValue];        
        oneTimeRadBenefit   += [[radCalculator.oneTimeValues objectAtIndex:i] doubleValue];        
        oneTimeGaaBenefit      += [[gaaCalculator.oneTimeValues objectAtIndex:i] doubleValue];
        oneTimeSamBenefit       += [[samCalculator.oneTimeValues objectAtIndex:i] doubleValue];
    }
    
    // there's a difference between all values being nil or 0, and the sum of several numbers ending up at 0
    // we would like to show 0 when the sum is 0, otherwise blank
    BOOL isBlank = oneTimeRevenueBenefit == 0 && oneTimeCOGSBenefit == 0 && oneTimeRadBenefit == 0 && oneTimeGaaBenefit == 0 && oneTimeSamBenefit == 0;
    double oneTimeBenefit = (oneTimeRevenueBenefit - oneTimeCOGSBenefit) - (oneTimeRadBenefit + oneTimeGaaBenefit + oneTimeSamBenefit);
    [netBenefitsDict setValue:(isBlank ? nil : [NSNumber numberWithDouble:oneTimeBenefit]) forKey:@"oneTime"];


    // monthly benefit
    double monthlyRevenueBenefit = 0;
    double monthlyCOGSBenefit = 0;
    double monthlyExpenseBenefit = 0;
    double monthlyCostBenefit = 0;
    double monthlySamBenefit = 0;
    
    for (uint i = 0; i < numMonths; i++) {
        monthlyRevenueBenefit   += [[revenueCalculator.monthlyValues objectAtIndex:i] doubleValue];        
        monthlyCOGSBenefit      += [[cogsCalculator.monthlyValues objectAtIndex:i] doubleValue];        
        monthlyExpenseBenefit   += [[radCalculator.monthlyValues objectAtIndex:i] doubleValue];        
        monthlyCostBenefit      += [[gaaCalculator.monthlyValues objectAtIndex:i] doubleValue];
        monthlySamBenefit      += [[samCalculator.monthlyValues objectAtIndex:i] doubleValue];
    }
    
    isBlank = monthlyRevenueBenefit == 0 && monthlyCOGSBenefit == 0 && monthlyExpenseBenefit == 0 &&  monthlyCostBenefit == 0 && monthlySamBenefit == 0;
    double monthlyBenefit = (monthlyRevenueBenefit - monthlyCOGSBenefit) - (monthlyExpenseBenefit + monthlyCostBenefit + monthlySamBenefit);
    [netBenefitsDict setValue:(isBlank ? nil : [NSNumber numberWithDouble:monthlyBenefit]) forKey:@"monthly"];
    
    
    // quarterly benefit
    double quarterlyRevenueBenefit = 0;
    double quarterlyCOGSBenefit = 0;
    double quarterlyExpenseBenefit = 0;
    double quarterlyCostBenefit = 0;
    double quarterlySamBenefit = 0;
    
    for (uint i = 0; i < numMonths; i++) {
        quarterlyRevenueBenefit   += [[revenueCalculator.quarterlyValues objectAtIndex:i] doubleValue];        
        quarterlyCOGSBenefit      += [[cogsCalculator.quarterlyValues objectAtIndex:i] doubleValue];        
        quarterlyExpenseBenefit   += [[radCalculator.quarterlyValues objectAtIndex:i] doubleValue];        
        quarterlyCostBenefit      += [[gaaCalculator.quarterlyValues objectAtIndex:i] doubleValue];
        quarterlySamBenefit       += [[samCalculator.quarterlyValues objectAtIndex:i] doubleValue];
    }
    
    isBlank = quarterlyRevenueBenefit == 0 && quarterlyCOGSBenefit == 0 && quarterlyExpenseBenefit == 0 &&  quarterlyCostBenefit == 0 && quarterlySamBenefit == 0;
    double quarterlyBenefit = (quarterlyRevenueBenefit - quarterlyCOGSBenefit) - (quarterlyExpenseBenefit + quarterlyCostBenefit + quarterlySamBenefit);
    [netBenefitsDict setValue:(isBlank ? nil : [NSNumber numberWithDouble:quarterlyBenefit]) forKey:@"quarterly"];
    
    // annual benefit
    double annualRevenueBenefit = 0;
    double annualCOGSBenefit = 0;
    double annualExpenseBenefit = 0;
    double annualCostBenefit = 0;
    double annualSamBenefit = 0;
    
    for (uint i = 0; i < numMonths; i++) {
        annualRevenueBenefit   += [[revenueCalculator.annualValues objectAtIndex:i] doubleValue];        
        annualCOGSBenefit      += [[cogsCalculator.annualValues objectAtIndex:i] doubleValue];        
        annualExpenseBenefit   += [[radCalculator.annualValues objectAtIndex:i] doubleValue];        
        annualCostBenefit      += [[gaaCalculator.annualValues objectAtIndex:i] doubleValue];
        annualSamBenefit       += [[samCalculator.annualValues objectAtIndex:i] doubleValue];
    }
    
    isBlank = annualRevenueBenefit == 0 && annualCOGSBenefit == 0 && annualCostBenefit == 0 &&  annualCostBenefit == 0 && annualSamBenefit == 0;
    double annualBenefit = (annualRevenueBenefit - annualCOGSBenefit) - (annualExpenseBenefit + annualCostBenefit + annualSamBenefit);
    [netBenefitsDict setValue:(isBlank ? nil : [NSNumber numberWithDouble:annualBenefit]) forKey:@"annually"];

    [revenueCalculator release];
    [cogsCalculator release];
    [radCalculator release];
    [gaaCalculator release];
    [samCalculator release];

    // net benefits (sum of the bottom row of totals)
    double sum = 0;
    sum = sum + [[netBenefitsDict objectForKey:@"oneTime"] doubleValue];
    sum = sum + [[netBenefitsDict objectForKey:@"monthly"] doubleValue];
    sum = sum + [[netBenefitsDict objectForKey:@"quarterly"] doubleValue];
    sum = sum + [[netBenefitsDict objectForKey:@"annually"] doubleValue];
    
    // 0's are added to the dict, nils (no calcs) are not
    isBlank = [netBenefitsDict count] == 0;
    [netBenefitsDict setValue:(isBlank ? nil : [NSNumber numberWithDouble:sum]) forKey:@"total"];
    
    return netBenefitsDict;
}


-(void)showCellValue:(MBRoundedTextField*)textField
{
    NSNumber *value = [_theme valueForKey:textField.boundProperty];
    textField.text = [value decimalFormattedNumberWithZeroDisplay:NO];
}

-(void)showPercentValue:(MBRoundedTextField*)textField
{
    NSNumber *value = [_theme valueForKey:textField.boundProperty];
    if (value) textField.text = [NSString stringWithFormat:@"%@%%", [value decimalFormattedNumberWithZeroDisplay:NO]];
}

- (NSString*)formatNetBenefitValueForDisplay:(NSNumber*)value
{    
    return value ? [value netBenefitFormattedNumber] : @"";
}

- (void)saveGridTextField:(MBRoundedTextField*)textField
{
    NSNumber *value = [textField.text isBlank] ? nil : [NSNumber numberWithInteger:textField.text.integerValue];
    [_theme setValue:value forKey:textField.boundProperty];
    textField.text = [value decimalFormattedNumberWithZeroDisplay:NO];
    [stratFileManager_ saveCurrentStratFile];    
}

#pragma mark - responsible auto suggest field

- (void)updateAutoSuggestValuesForResponsible
{
    NSArray *responsibles = [stratFileManager_.currentStratFile.responsibles allObjects];
    NSMutableArray *responsibleSummaries = [NSMutableArray arrayWithCapacity:responsibles.count];
    
    for (Responsible *responsible in responsibles) {
        [responsibleSummaries addObject:responsible.summary];
    }    
    
    autoSuggestController_.autoSuggestValues = responsibleSummaries;    
}

- (void)saveAndUpdateResponsibleField
{
    // check to see if a responsible entity already exists for this Strat File.
    Responsible *selectedResponsible = nil;
    NSArray *responsibles = [stratFileManager_.currentStratFile.responsibles allObjects];    
    for (Responsible *responsible in responsibles) {
        if ([responsible.summary isEqualToString:self.txtResponsible.text]) {
            selectedResponsible = responsible;
        }
    }
    
    if (!selectedResponsible) {
        // no matching responsible, so see if we should create one...
        NSString *responsibleText = self.txtResponsible.text;
        if (responsibleText && ![responsibleText isBlank]) {
            selectedResponsible = (Responsible*)[DataManager createManagedInstance:NSStringFromClass([Responsible class])];
            selectedResponsible.summary = responsibleText;
            selectedResponsible.stratFile = stratFileManager_.currentStratFile;            
        }
    }    
    
    _theme.responsible = selectedResponsible;
    [stratFileManager_ saveCurrentStratFile];
    
    [self updateAutoSuggestValuesForResponsible];
}


#pragma mark - Actions

- (IBAction)showDatePicker:(id)sender
{
    if ([_permissionChecker checkReadWrite]) {

        MBCalendarButton *button = (MBCalendarButton*)sender;
        
        if (button == self.btnStartDate) {
            if (!startDateController_) {
                startDateController_ = [[MBDateSelectionViewController alloc] initWithCalendarButton:button andTitle:_lblStartDate.text];
                startDateController_.delegate = self;
            }
            [startDateController_ showDatePicker];
            
        } else if (button == self.btnEndDate) {
            if (!endDateController_) {
                endDateController_ = [[MBDateSelectionViewController alloc] initWithCalendarButton:button andTitle:_lblEndDate.text];
                endDateController_.delegate = self;
            }
            [endDateController_ showDatePicker];
        }
        
    }
    
}

- (IBAction)showCalculations
{
    // we'll bring up our standard detail window
    [calculationsVC_ release];
    calculationsVC_ = [[CalculationsViewController alloc] initWithNibName:nil bundle:nil andTheme:_theme];
    calculationsVC_.delegate = self;

    // button is on the fieldsetView, but we're adding to self.view
    UIView *calcView = calculationsVC_.view;
    calcView.center = [self.fieldsetView convertPoint:_btnCalculations.center toView:self.view];
    calcView.transform = CGAffineTransformMakeScale(0.2, 0.2);
    
    [calculationsVC_ viewWillAppear:YES];
    [self.view addSubview:calcView];
    
    [UIView animateWithDuration:0.2
                     animations:^{
                         calcView.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
                         calcView.transform = CGAffineTransformMakeScale(1.0, 1.0);                         
                     } completion:^(BOOL finished) {                         
                         [calculationsVC_ viewDidAppear:YES];
                     }
     ];    
}

#pragma mark - CalculationsViewControllerDelegate

- (void)editingCalculationsComplete {    
    [calculationsVC_ viewWillDisappear:YES];
    
    UIView *calcView = calculationsVC_.view; 
    
    [UIView animateWithDuration:0.2
                     animations:^{
                         calcView.transform = CGAffineTransformMakeScale(0.2, 0.2);
                         calcView.center = [self.fieldsetView convertPoint:_btnCalculations.center toView:self.view];
                     } completion:^(BOOL finished) {
                         [calcView removeFromSuperview];                         
                         [calculationsVC_ viewDidDisappear:YES];
                         [calculationsVC_ release], calculationsVC_ = nil;
                     }
     ]; 
    
    NSDictionary *netBenefits = [self calculateNetBenefits];
    [self updateNetBenefits:netBenefits];
}

#pragma mark - DropDownDelegate

- (void)valueSelected:(id)value forDropDownButton:(MBDropDownButton *)button
{
    [EventManager fireJumpToThemeEventWithTheme:(Theme*)value fromViewController:self];
}


#pragma mark - DateSelectionDelegate

- (void)dateSelected:(NSDate*)date forCalendarButton:(MBCalendarButton *)button
{
    if (button == self.btnStartDate) {
        _theme.startDate = date;                
    } else {
        _theme.endDate = date;
    }
    
    // now update the other button, based on our response
    if (_theme.startDate != nil) {
        [_btnEndDate setEnabled:YES];
    } else {
        [_theme setEndDate:nil];
        [_btnEndDate setDate:nil];
        [_btnEndDate setEnabled:NO];
    }
    [stratFileManager_ saveCurrentStratFile];
    NSDictionary *netBenefits = [self calculateNetBenefits];
    [self updateNetBenefits:netBenefits];
    [EventManager fireThemeDateChangedEvent];
}

- (BOOL)isValid:(NSDate*)date forCalendarButton:(MBCalendarButton*)button
{
    NSDate *now = [NSDate date];

    if (button == self.btnStartDate) {
        
        // must be lte than endDate, if end is not nil        
        BOOL isValid = _theme.endDate == nil || [date isBeforeOrEqual:_theme.endDate];
        if (!isValid) {
            // either now if end is nil, or the day before enddate
            suggestedDate_ = _theme.endDate == nil ? now : _theme.endDate;
            dateValidationMessage_ = [NSString stringWithFormat:LocalizedString(@"DATE_SELECTION_FOR_THEME_INVALID_START_GT_END", nil), [suggestedDate_ formattedDateForDateSelection]];
            return NO;
        }
        
        for (Objective *objective in _theme.objectives) {
            
            // check to make sure we aren't making a metric date illegal
            for (Metric *metric in objective.metrics) {
                
                // new startDate cannot exceed existing targetDate
                if (metric.targetDate && [date isAfter:metric.targetDate]) {
                    suggestedDate_ = objective.earliestDate;
                    dateValidationMessage_ = [NSString stringWithFormat:LocalizedString(@"DATE_SELECTION_FOR_THEME_INVALID_START_GT_METRIC", nil), [date formattedDateForDateSelection], [metric.targetDate formattedDateForDateSelection], metric.summary, [metric.targetDate formattedDateForDateSelection], metric.summary, [suggestedDate_ formattedDateForDateSelection]];
                    return NO;
                }
            }
            
            // check to make sure we aren't making an activity date illegal
            for (Activity *activity in objective.activities) {
                
                // theme start date must be before or equal to the activity start date if it exists, and before the activity end date if it exists
                if (activity.startDate && activity.endDate) {
                    BOOL lteStart = [date isBeforeOrEqual:activity.startDate];
                    if (!lteStart) {
                        suggestedDate_ = _theme.startDate ? _theme.startDate : objective.earliestDate;
                        dateValidationMessage_ = [NSString stringWithFormat:LocalizedString(@"DATE_SELECTION_FOR_THEME_INVALID_START_INSIDE_ACTIVITY", nil), activity.action, [suggestedDate_ formattedDateForDateSelection], [suggestedDate_ formattedDateForDateSelection]]; 
                        return NO;
                    }                    
                }
                else if (activity.startDate) {
                    BOOL lteStart = [date isBeforeOrEqual:activity.startDate];
                    if (!lteStart) {
                        suggestedDate_ = _theme.startDate ? _theme.startDate : objective.earliestDate;
                        dateValidationMessage_ = [NSString stringWithFormat:LocalizedString(@"DATE_SELECTION_FOR_THEME_INVALID_START_INSIDE_ACTIVITY", nil), activity.action, [suggestedDate_ formattedDateForDateSelection], [suggestedDate_ formattedDateForDateSelection]]; 
                        return NO;
                    }                                        
                }
                else if (activity.endDate) {
                    BOOL ltEnd = [date isBefore:activity.endDate];
                    if (!ltEnd) {
                        suggestedDate_ = _theme.endDate ? _theme.endDate : activity.endDate;
                        dateValidationMessage_ = [NSString stringWithFormat:LocalizedString(@"DATE_SELECTION_FOR_THEME_INVALID_START_INSIDE_ACTIVITY", nil), activity.action, [suggestedDate_ formattedDateForDateSelection], [suggestedDate_ formattedDateForDateSelection]]; 
                        return NO;
                    }                    
                }
            }
        }
                
    } 
    else { // button == self.btnEndDate
                
        // must be gt startDate, if start is not nil        
        BOOL isValid = _theme.startDate == nil || [date isAfterOrEqual:_theme.startDate];
        if (!isValid) {
            suggestedDate_ = _theme.startDate == nil ? now : _theme.startDate;
            dateValidationMessage_ = [NSString stringWithFormat:LocalizedString(@"DATE_SELECTION_FOR_THEME_INVALID_END_LT_START", nil), [suggestedDate_ formattedDateForDateSelection]];
            return NO;
        }
        
        for (Objective *objective in _theme.objectives) {
            
            // theme dates are allowed to precede (and obviously exceed) the metric target date, so don't check
            
            // check to make sure we aren't making an activity date illegal
            for (Activity *activity in objective.activities) {
                                
                // theme end date must exceed or equal the activity end date and exceed the activity start date
                if (activity.startDate && activity.endDate) {
                    if ([date isBefore:activity.endDate]) {
                        suggestedDate_ = _theme.endDate ? _theme.endDate : objective.latestDate;
                        dateValidationMessage_ = [NSString stringWithFormat:LocalizedString(@"DATE_SELECTION_FOR_THEME_INVALID_END_INSIDE_ACTIVITY", nil), activity.action, [suggestedDate_ formattedDateForDateSelection], [suggestedDate_ formattedDateForDateSelection]]; 
                        return NO;
                    }                    
                }
                else if (activity.startDate) {
                    if ([date isBefore:activity.startDate]) {
                        suggestedDate_ = _theme.endDate ? _theme.endDate : objective.latestDate;
                        dateValidationMessage_ = [NSString stringWithFormat:LocalizedString(@"DATE_SELECTION_FOR_THEME_INVALID_END_INSIDE_ACTIVITY", nil), activity.action, [suggestedDate_ formattedDateForDateSelection], [suggestedDate_ formattedDateForDateSelection]]; 
                        return NO;
                    }                    
                }
                else if (activity.endDate) {
                    if ([date isBefore:activity.endDate]) {
                        suggestedDate_ = _theme.endDate ? _theme.endDate : objective.latestDate;
                        dateValidationMessage_ = [NSString stringWithFormat:LocalizedString(@"DATE_SELECTION_FOR_THEME_INVALID_END_INSIDE_ACTIVITY", nil), activity.action, [suggestedDate_ formattedDateForDateSelection], [suggestedDate_ formattedDateForDateSelection]]; 
                        return NO;
                    }                    
                }
            }
        }

    }

    return YES;
}

- (NSDate*)suggestedDateForCalendarButton:(MBCalendarButton*)button proposedDate:(NSDate *)proposedDate
{
    if ([self isValid:proposedDate forCalendarButton:button]) {
        return proposedDate;
    } else {
        return suggestedDate_;
    }
}

- (NSString*)messageForDate:(NSDate*)date forCalendarButton:(MBCalendarButton*)button isValid:(BOOL)isValid
{
    if (isValid) {
        return [NSString stringWithFormat:LocalizedString(@"DATE_SELECTION_VALID", nil), [date formattedDateForDateSelectionMessage]];
    } else {
        return dateValidationMessage_;          
    }
}


#pragma mark - AutoSuggestDelegate

- (void)valueSelected:(NSString *)value forAutoSuggestTextField:(MBAutoSuggestTextField *)textField
{
    [self saveAndUpdateResponsibleField];
}

#pragma mark - overrides

- (BOOL)isEnabled
{
    return ([stratFileManager_.currentStratFile.themes count] > 0);
}

- (NSString*)messageWhenDisabled
{
    return LocalizedString(@"MSG_NO_THEMES", nil);
}

- (void)configureResponderChain
{    
    // all of the input fields on this page
    responderChain_ = [[NSArray arrayWithObjects:
                        self.txtResponsible,
                        self.btnStartDate,
                        self.btnEndDate,
                        self.txtNumberOfEmployeesAtThemeStart, // @since 1.6
                        self.txtNumberOfEmployeesAtThemeEnd, // @since 1.6
                        self.txtRevenueOneTime,
                        self.txtRevenueMonthly,
                        self.txtRevenueQuarterly,
                        self.txtRevenueAnnually,
                        self.txtCogsOneTime,
                        self.txtCogsMonthly,
                        self.txtCogsQuarterly,
                        self.txtCogsAnnually,
                        self.txtCogsPayrollPercent, //@since 1.6
                        self.txtExpensesOneTime,
                        self.txtExpensesMonthly,
                        self.txtExpensesQuarterly,
                        self.txtExpensesAnnually,
                        self.txtRDPayrollPercent, // @since 1.6 (refactored)
                        self.txtCostsOneTime,
                        self.txtCostsMonthly,
                        self.txtCostsQuarterly,
                        self.txtCostsAnnually,
                        self.txtGAPayrollPercent, // @since 1.6 (refactored)
                        self.txtSMOneTime, // @since 1.6
                        self.txtSMMonthly, // @since 1.6
                        self.txtSMQuarterly, // @since 1.6
                        self.txtSMAnnually, // @since 1.6
                        self.txtSMPayrollPercent, // @since 1.6
                        nil] retain];
    
    // all text fields (ie keyboard up) use next button in KB
    for (int i=0, ct = [responderChain_ count]; i<ct; ++i) {
        UIResponder *responder = [responderChain_ objectAtIndex:i];
        if ([responder isKindOfClass:[UITextField class]]) {
            // if a textfield is last, it can use done button in KB, which will dismiss the keyboard
            [(UITextField*)responder setReturnKeyType:(i == ct-1) ? UIReturnKeyDone : UIReturnKeyNext];
        }            
    }
    
    // set up the date field with it's nextResponder and dateSelection properties
    self.btnStartDate.nextResponder = self.btnEndDate;
    self.btnStartDate.delegate = self;
    self.btnStartDate.titleForDateSelectionPopover = _lblStartDate.text;
    
    self.btnEndDate.nextResponder = self.txtRevenueOneTime;
    self.btnEndDate.delegate = self;
    self.btnEndDate.titleForDateSelectionPopover = _lblEndDate.text;
    
}

#pragma mark - Help Video

-(BOOL)hasVideo
{
    return [[[LocalizedManager sharedManager] localeIdentifier] hasPrefix:@"en"];
}

-(NSString*)helpVideoURL
{
    //return @"http://player.vimeo.com/external/70574882.m3u8?p=high,standard,mobile&s=63775122062de3825bef21c2b7d0a6e8";
    NSString* path = [[NSBundle mainBundle] pathForResource:@"SP iPad F5.mov" ofType:@"mp4"];
    return path;
}


@end
