//
//  AccountsPayableViewController.m
//  StratPad
//
//  Created by Julian Wood on 2013-04-16.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//

#import "AccountsPayableViewController.h"
#import "UILabelVAlignment.h"
#import "SkinManager.h"
#import "MBRoundedRectView.h"
#import "Financials.h"
#import "HonedSlider.h"
#import "PermissionChecker.h"

@interface AccountsPayableViewController ()
@property (retain, nonatomic) IBOutlet UILabel *lblTitle;
@property (retain, nonatomic) IBOutlet UILabel *lblSubtitle;
@property (retain, nonatomic) IBOutlet UILabel *lblQuestion;
@property (retain, nonatomic) IBOutlet UILabelVAlignment *lblInstructions;
@property (retain, nonatomic) IBOutlet MBRoundedRectView *viewRoundedRect;

@property (retain, nonatomic) IBOutlet HonedSlider *slider;
@property (retain, nonatomic) IBOutlet UILabel *lblDays;

@property (retain, nonatomic) NSString *daysTextFormat;

@property (retain, nonatomic) Financials *financials;

@property (retain, nonatomic) PermissionChecker *permissionChecker;

@end

@implementation AccountsPayableViewController

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
    _lblDays.textColor = [skinMan colorForProperty:kSkinSection2FieldLabelFontColor];
    
    _viewRoundedRect.roundedRectBackgroundColor = [skinMan colorForProperty:kSkinSection2FormBackgroundColor];
    
    _lblQuestion.textColor = [skinMan colorForProperty:kSkinSection2FieldLabelFontColor];
    _lblInstructions.textColor = [skinMan colorForProperty:kSkinSection2FieldLabelFontColor];

    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^\\d+\\s+(.+)$" options:0 error:nil];
    self.daysTextFormat = [regex stringByReplacingMatchesInString:_lblDays.text
                                                          options:0
                                                            range:NSMakeRange(0, [_lblDays.text length])
                                                     withTemplate:@"%i $1"];
    
    // load up saved/default value
    self.financials = [stratFileManager_ currentStratFile].financials;
    _slider.value = _financials.accountsPayableTerm.floatValue;
    [_lblDays setText:[NSString stringWithFormat:_daysTextFormat, _financials.accountsPayableTerm.integerValue]];

    // place a transparent button over top of the slider to do our permission check
    if (![_permissionChecker isReadWrite]) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, _slider.frame.size.width, _slider.frame.size.height);
        btn.tag = 888;
        [btn addTarget:_permissionChecker action:@selector(checkReadWrite) forControlEvents:UIControlEventTouchUpInside];
        [_slider addSubview:btn];
    }
    else {
        [[_slider viewWithTag:888] removeFromSuperview];
    }
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [stratFileManager_ saveCurrentStratFile];
}

- (IBAction)sliderChanged:(id)sender {
    NSInteger honedValue = [_slider honedIntegerValue];
    [_lblDays setText:[NSString stringWithFormat:_daysTextFormat, honedValue]];
    _financials.accountsPayableTerm = [NSNumber numberWithInteger:honedValue];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_permissionChecker release];
    [_financials release];
    [_lblTitle release];
    [_lblSubtitle release];
    [_lblQuestion release];
    [_lblInstructions release];
    [_slider release];
    [_lblDays release];
    [_daysTextFormat release];
    [_viewRoundedRect release];
    [super dealloc];
}

- (void)viewDidUnload {
    [self setLblTitle:nil];
    [self setLblSubtitle:nil];
    [self setLblQuestion:nil];
    [self setLblInstructions:nil];
    [self setSlider:nil];
    [self setLblDays:nil];
    [self setDaysTextFormat:nil];
    [self setViewRoundedRect:nil];
    [super viewDidUnload];
}
@end
