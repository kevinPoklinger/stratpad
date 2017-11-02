//
//  InventoryViewController.m
//  StratPad
//
//  Created by Julian Wood on 2013-04-16.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//

#import "InventoryViewController.h"
#import "MBRoundedRectView.h"
#import "SkinManager.h"
#import "UILabelVAlignment.h"
#import "Financials.h"
#import "EmployeeDeductions.h"
#import "COGSValidator.h"
#import "HonedSlider.h"
#import "PermissionChecker.h"

@interface InventoryViewController ()
@property (retain, nonatomic) IBOutlet UILabel *lblTitle;
@property (retain, nonatomic) IBOutlet UILabel *lblSubtitle;
@property (retain, nonatomic) IBOutlet MBRoundedRectView *viewRoundedRect;

@property (retain, nonatomic) IBOutlet UILabel *lblQuestion1;
@property (retain, nonatomic) IBOutlet UILabelVAlignment *lblInstructions1;
@property (retain, nonatomic) IBOutlet HonedSlider *slider1;
@property (retain, nonatomic) IBOutlet UILabel *lblPercentage;

@property (retain, nonatomic) IBOutlet UILabel *lblQuestion2;
@property (retain, nonatomic) IBOutlet UILabelVAlignment *lblInstructions2;
@property (retain, nonatomic) IBOutlet HonedSlider *slider2;
@property (retain, nonatomic) IBOutlet UILabel *lblDays;

@property (retain, nonatomic) NSString *daysTextFormat;

@property (retain, nonatomic) Financials *financials;

@property (retain, nonatomic) COGSValidator *cogsValidator;

@property (retain, nonatomic) PermissionChecker *permissionChecker;

@end

@implementation InventoryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        PermissionChecker *checker = [[PermissionChecker alloc] initWithStratFile:[stratFileManager_ currentStratFile]];
        self.permissionChecker = checker;
        [checker release];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    SkinManager *skinMan = [SkinManager sharedManager];
    _lblTitle.textColor = [skinMan colorForProperty:kSkinSection2TitleFontColor];
    _lblSubtitle.textColor = [skinMan colorForProperty:kSkinSection2SubtitleFontColor];
    
    _viewRoundedRect.roundedRectBackgroundColor = [skinMan colorForProperty:kSkinSection2FormBackgroundColor];
    
    _lblQuestion1.textColor = [skinMan colorForProperty:kSkinSection2FieldLabelFontColor];
    _lblInstructions1.textColor = [skinMan colorForProperty:kSkinSection2FieldLabelFontColor];
    _lblPercentage.textColor = [skinMan colorForProperty:kSkinSection2FieldLabelFontColor];

    _lblQuestion2.textColor = [skinMan colorForProperty:kSkinSection2FieldLabelFontColor];
    _lblInstructions2.textColor = [skinMan colorForProperty:kSkinSection2FieldLabelFontColor];
    _lblDays.textColor = [skinMan colorForProperty:kSkinSection2FieldLabelFontColor];

    
    // use the value in the nib for localization of the days label
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^\\d+\\s+(.+)$" options:0 error:nil];
        
    self.daysTextFormat = [regex stringByReplacingMatchesInString:_lblDays.text
                                                          options:0
                                                            range:NSMakeRange(0, [_lblDays.text length])
                                                     withTemplate:@"%i $1"];

    // load up saved/default value
    NSString *percentFormat = LocalizedString(@"PERCENT_MESSAGE_FORMAT", nil);
    self.financials = [stratFileManager_ currentStratFile].financials;
    _slider1.value = _financials.percentCogsIsInventory.floatValue;
    [_lblPercentage setText:[NSString stringWithFormat:percentFormat, _financials.percentCogsIsInventory]];

    // load up saved/default value
    _slider2.value = _financials.accountsPayableTerm.floatValue;
    [_lblDays setText:[NSString stringWithFormat:_daysTextFormat, _financials.accountsPayableTerm.integerValue]];
    
    COGSValidator *validator = [[COGSValidator alloc] initWithSlider:_slider1];
    self.cogsValidator = validator;
    [validator release];
    
    // place a transparent button over top of the slider to do our permission check
    if (![_permissionChecker isReadWrite]) {
        UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
        btn1.frame = CGRectMake(0, 0, _slider1.frame.size.width, _slider1.frame.size.height);
        btn1.tag = 888;
        [btn1 addTarget:_permissionChecker action:@selector(checkReadWrite) forControlEvents:UIControlEventTouchUpInside];
        [_slider1 addSubview:btn1];

        UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
        btn2.frame = CGRectMake(0, 0, _slider2.frame.size.width, _slider2.frame.size.height);
        btn2.tag = 999;
        [btn2 addTarget:_permissionChecker action:@selector(checkReadWrite) forControlEvents:UIControlEventTouchUpInside];
        [_slider2 addSubview:btn2];
        
    }
    else {
        [[_slider1 viewWithTag:888] removeFromSuperview];
        [[_slider2 viewWithTag:999] removeFromSuperview];
    }
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSNumber *invPercentage = [stratFileManager_ currentStratFile].financials.percentCogsIsInventory;
    NSNumber *wagesPercentage = [stratFileManager_ currentStratFile].financials.employeeDeductions.percentCogsAreWages;
    
    [_cogsValidator validateCOGS:invPercentage wagePercentage:wagesPercentage];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [_cogsValidator dismissWarning];
    
    [stratFileManager_ saveCurrentStratFile];    
}

- (IBAction)percentageChanged:(id)sender {
    NSString *percentFormat = LocalizedString(@"PERCENT_MESSAGE_FORMAT", nil);
    NSInteger honedValue = [_slider1 honedIntegerValue];
    NSNumber *val = [NSNumber numberWithInteger:honedValue];

    [_lblPercentage setText:[NSString stringWithFormat:percentFormat, val]];
    _financials.percentCogsIsInventory = val;
    
    NSNumber *wagePercentage = [stratFileManager_ currentStratFile].financials.employeeDeductions.percentCogsAreWages;
    
    [_cogsValidator validateCOGS:val wagePercentage:wagePercentage];
}

- (IBAction)daysChanged:(id)sender {
    NSInteger honedValue = [_slider2 honedIntegerValue];
    [_lblDays setText:[NSString stringWithFormat:_daysTextFormat, honedValue]];
    _financials.inventoryLeadTime = [NSNumber numberWithInteger:honedValue];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_permissionChecker release];
    [_cogsValidator release];
    [_financials release];
    [_lblTitle release];
    [_lblSubtitle release];
    [_viewRoundedRect release];
    [_lblQuestion1 release];
    [_lblInstructions1 release];
    [_slider1 release];
    [_lblQuestion2 release];
    [_lblInstructions2 release];
    [_slider2 release];
    [_lblPercentage release];
    [_lblDays release];
    [_daysTextFormat release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setLblTitle:nil];
    [self setLblSubtitle:nil];
    [self setViewRoundedRect:nil];
    [self setLblQuestion1:nil];
    [self setLblInstructions1:nil];
    [self setSlider1:nil];
    [self setLblQuestion2:nil];
    [self setLblInstructions2:nil];
    [self setSlider2:nil];
    [self setLblPercentage:nil];
    [self setLblDays:nil];
    [self setDaysTextFormat:nil];
    [super viewDidUnload];
}
@end
