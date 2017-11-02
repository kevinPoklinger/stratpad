//
//  EmployeeDeductionsViewController.m
//  StratPad
//
//  Created by Julian Wood on 2013-04-23.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//

#import "EmployeeDeductionsViewController.h"
#import "SkinManager.h"
#import "MBRoundedRectView.h"
#import "EmployeeDeductions.h"
#import "StratFileManager.h"
#import "Financials.h"
#import "UIView+ObjectTagAdditions.h"
#import "COGSValidator.h"
#import "HonedSlider.h"
#import "PermissionChecker.h"

@interface EmployeeDeductionsViewController ()
@property (retain, nonatomic) IBOutlet UILabel *lblTitle;
@property (retain, nonatomic) IBOutlet UILabel *lblSubtitle;
@property (retain, nonatomic) IBOutlet MBRoundedRectView *viewRoundedRect;
@property (retain, nonatomic) IBOutlet UITableView *tblDueDate;

@property (retain, nonatomic) IBOutlet HonedSlider *sliderCOGS;
@property (retain, nonatomic) IBOutlet HonedSlider *sliderGA;
@property (retain, nonatomic) IBOutlet HonedSlider *sliderRD;
@property (retain, nonatomic) IBOutlet HonedSlider *sliderSM;
@property (retain, nonatomic) IBOutlet HonedSlider *sliderEmployee;
@property (retain, nonatomic) IBOutlet HonedSlider *sliderEmployer;

@property (retain, nonatomic) EmployeeDeductions *deductions;

@property (retain, nonatomic) COGSValidator *cogsValidator;

@property (retain, nonatomic) PermissionChecker *permissionChecker;

@end

@implementation EmployeeDeductionsViewController

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
    
    _tblDueDate.backgroundColor = [UIColor clearColor];
    _tblDueDate.opaque = NO;
    _tblDueDate.backgroundView = nil;
    _tblDueDate.clipsToBounds = YES;
    
    // because we are making the background transparent, and because we have a grouped table, and because we have padding around the cells, compensate by adjusting the frame
    CGRect f = _tblDueDate.frame;
    _tblDueDate.frame = CGRectMake(f.origin.x-10, f.origin.y-10, f.size.width+20, f.size.height+20);


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
    
    self.deductions = [stratFileManager_ currentStratFile].financials.employeeDeductions;
    
    // bind to core data properties
    _sliderCOGS.objectTag = @"percentCogsAreWages";
    _sliderGA.objectTag = @"percentGandAAreWages";
    _sliderRD.objectTag = @"percentRandDAreWages";
    _sliderSM.objectTag = @"percentSandMAreWages";
    _sliderEmployee.objectTag = @"employeeContributionPercentage";
    _sliderEmployer.objectTag = @"employerContributionPercentage";
    
    // initial value - set default in core data
    _sliderCOGS.value = _deductions.percentCogsAreWages.floatValue;
    _sliderGA.value = _deductions.percentGandAAreWages.floatValue;
    _sliderRD.value = _deductions.percentRandDAreWages.floatValue;
    _sliderSM.value = _deductions.percentSandMAreWages.floatValue;
    _sliderEmployee.value = _deductions.employeeContributionPercentage.floatValue;
    _sliderEmployer.value = _deductions.employerContributionPercentage.floatValue;
    
    // update corresponding label
    NSString *percentFormat = LocalizedString(@"PERCENT_MESSAGE_FORMAT", nil);
    [(UILabel*)[self.view viewWithTag:_sliderCOGS.tag+1] setText:[NSString stringWithFormat:percentFormat, _deductions.percentCogsAreWages]];
    [(UILabel*)[self.view viewWithTag:_sliderGA.tag+1] setText:[NSString stringWithFormat:percentFormat, _deductions.percentGandAAreWages]];
    [(UILabel*)[self.view viewWithTag:_sliderRD.tag+1] setText:[NSString stringWithFormat:percentFormat, _deductions.percentRandDAreWages]];
    [(UILabel*)[self.view viewWithTag:_sliderSM.tag+1] setText:[NSString stringWithFormat:percentFormat, _deductions.percentSandMAreWages]];
    [(UILabel*)[self.view viewWithTag:_sliderEmployee.tag+1] setText:[NSString stringWithFormat:percentFormat, _deductions.employeeContributionPercentage]];
    [(UILabel*)[self.view viewWithTag:_sliderEmployer.tag+1] setText:[NSString stringWithFormat:percentFormat, _deductions.employerContributionPercentage]];
    
    COGSValidator *validator = [[COGSValidator alloc] initWithSlider:_sliderCOGS];
    self.cogsValidator = validator;
    [validator release];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_permissionChecker release];
    [_cogsValidator release];
    [_deductions release];
    [_lblTitle release];
    [_lblSubtitle release];
    [_viewRoundedRect release];
    [_tblDueDate release];
    [_sliderCOGS release];
    [_sliderGA release];
    [_sliderRD release];
    [_sliderSM release];
    [_sliderEmployee release];
    [_sliderEmployer release];
    [super dealloc];
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

- (IBAction)sliderChanged:(HonedSlider*)slider
{
    // for COGS, we want to restrict to 100-percentCogsIsInventory
    // we can automatically change percentCogsIsInventory, we can restrict COGS, or we can allow and leave a warning
    NSNumber *invPercentage = [stratFileManager_ currentStratFile].financials.percentCogsIsInventory;
    
    NSNumber *val = [NSNumber numberWithInt:[slider honedIntegerValue]];    
    [_deductions setValue:val forKey:slider.objectTag];
    
    if (slider == _sliderCOGS) {
        [_cogsValidator validateCOGS:invPercentage wagePercentage:val];
    }
    
    UILabel *lbl = (UILabel*)[self.view viewWithTag:slider.tag+1];
    NSString *percentFormat = LocalizedString(@"PERCENT_MESSAGE_FORMAT", nil);
    lbl.text = [NSString stringWithFormat:percentFormat, val];
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_permissionChecker checkReadWrite]) {
        _deductions.dueDate = [NSNumber numberWithInteger:indexPath.row];
        
        // reset the old selected cell as well as check the new cell
        [_tblDueDate reloadData];        
    }
}



#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"DueDateCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DueDateCell"] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        SkinManager *skinMan = [SkinManager sharedManager];
        cell.textLabel.textColor = [skinMan colorForProperty:kSkinSection2TableCellFontColor];
        cell.backgroundColor = [skinMan colorForProperty:kSkinSection2TableCellBackgroundColor forMediaType:MediaTypeScreen];

    }
    
    if (_deductions.dueDate != nil && _deductions.dueDate.integerValue == indexPath.row) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    NSString *key = [NSString stringWithFormat:@"RemittanceDueDate_%d", indexPath.row];
    cell.textLabel.text = LocalizedString(key, nil);
    
    return cell;    
}

@end
