//
//  EquityInvestmentsViewController.m
//  StratPad
//
//  Created by Julian Wood on 2013-04-23.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//

#import "EquityInvestmentsViewController.h"
#import "SkinManager.h"
#import "MBRoundedRectView.h"
#import "StratFileManager.h"
#import "Financials.h"
#import "Equity.h"
#import "DataManager.h"
#import "RootViewController.h"
#import "CustomUpgradeViewController.h"
#import "EquityCell.h"
#import "PermissionChecker.h"
#import "UserNotificationDisplayManager.h"
#import "UIColor-Expanded.h"

@interface EquityInvestmentsViewController ()
@property (retain, nonatomic) IBOutlet UILabel *lblTitle;
@property (retain, nonatomic) IBOutlet UILabel *lblSubtitle;
@property (retain, nonatomic) IBOutlet UILabel *lblInstructions;
@property (retain, nonatomic) IBOutlet MBRoundedRectView *viewRoundedRect;
@property (retain, nonatomic) IBOutlet UITableView *tblEquities;
@property (retain, nonatomic) IBOutlet UIButton *btnAddNewEquity;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *btnManageEquities;

@property (retain, nonatomic) NSOrderedSet *equities;

@property (retain, nonatomic) PermissionChecker *permissionChecker;

@end

@implementation EquityInvestmentsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didShowKeyboard:)
                                                     name:UIKeyboardDidShowNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didHideKeyboard:)
                                                     name:UIKeyboardDidHideNotification
                                                   object:nil];
        
        PermissionChecker *checker = [[PermissionChecker alloc] initWithStratFile:[stratFileManager_ currentStratFile]];
        self.permissionChecker = checker;
        [checker release];

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _tblEquities.backgroundColor = [UIColor clearColor];
    _tblEquities.opaque = NO;
    _tblEquities.backgroundView = nil;
    _tblEquities.clipsToBounds = YES;
    
    SkinManager *skinMan = [SkinManager sharedManager];
    
    _viewRoundedRect.roundedRectBackgroundColor = [skinMan colorForProperty:kSkinSection2FormBackgroundColor];
    
    _lblTitle.font = [skinMan fontWithName:kSkinSection2TitleFontName andSize:kSkinSection2TitleFontSize];
    _lblTitle.textColor = [skinMan colorForProperty:kSkinSection2TitleFontColor];
    
    _lblSubtitle.font = [skinMan fontWithName:kSkinSection2SubtitleFontName andSize:kSkinSection2SubtitleFontSize];
    _lblSubtitle.textColor = [skinMan colorForProperty:kSkinSection2SubtitleFontColor];
    
    _lblInstructions.textColor = [skinMan colorForProperty:kSkinSection2FieldLabelFontColor];
    
    self.equities = [stratFileManager_ currentStratFile].financials.equities;
    
    _btnAddNewEquity.hidden = _equities.count != 0;
    
    // grab the tableHeaderView out of the nib
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"EquityCell" owner:self options:nil];
    //NSArray *topLevelObjects = [[[LocalizedManager sharedManager] currentBundle] loadNibNamed:@"EquityCell" owner:self options:nil];
    UIView *headerView = [topLevelObjects objectAtIndex:1];
    
    // skin the detail table header colours
    for (UILabel *lbl in headerView.subviews) {
        lbl.textColor = [skinMan colorForProperty:kSkinSection2FieldLabelFontColor];
    }
    
    _tblEquities.tableHeaderView = headerView;
    
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_toolbar setNeedsLayout];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self check];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    // update transient flag on loans and redraw
    for (Equity *equity in _equities) {
        equity.isNew = NO;
    }
    [_tblEquities reloadData];
    
    [[UserNotificationDisplayManager sharedManager] dismiss];
    
    [stratFileManager_ saveCurrentStratFile];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_permissionChecker release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_equities release];
    [_lblTitle release];
    [_lblSubtitle release];
    [_lblInstructions release];
    [_viewRoundedRect release];
    [_tblEquities release];
    [_btnAddNewEquity release];
    [_btnManageEquities release];
    [_toolbar release];
    [super dealloc];
}

- (IBAction)addEquity:(id)sender {
    if ([_permissionChecker checkReadWrite]) {        
        Equity *equity = (Equity*)[DataManager createManagedInstance:NSStringFromClass([Equity class])];
        equity.isNew = YES;
        Financials *financials = [stratFileManager_ currentStratFile].financials;
        [financials insertObject:equity inEquitiesAtIndex:0];
        [_tblEquities insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]]
                            withRowAnimation:UITableViewRowAnimationRight];
        
        [stratFileManager_ saveCurrentStratFile];
        
        _btnAddNewEquity.hidden = YES;
    }
}

- (IBAction)manage:(id)sender
{
    if ([_permissionChecker checkReadWrite]) {
        UIBarButtonItem *button = (UIBarButtonItem*)sender;
        
        if (_tblEquities.editing) {
            // switch off editing mode.
            [button setTitle:LocalizedString(@"MANAGE", nil)];
            [_tblEquities setEditing:NO animated:YES];
        } else {
            [button setTitle:LocalizedString(@"DONE", nil)];
            [_tblEquities setEditing:YES animated:YES];
        }
    }
}


#pragma mark - UITableViewDelegate

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSUInteger row = [indexPath row];
        Equity *equity = [_equities objectAtIndex:row];
        Financials *financials = [stratFileManager_ currentStratFile].financials;
        [financials removeEquitiesObject:equity];
        
        [_tblEquities deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [stratFileManager_ saveCurrentStratFile];
        
        if (!_equities.count) {
            _btnAddNewEquity.hidden = NO;
            
            // switch off editing mode.
            [_btnManageEquities setTitle:LocalizedString(@"MANAGE", nil)];
            [self.tblEquities setEditing:NO animated:YES];
        }
        
        [self check];
        
    }
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _equities.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EquityCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EquityCell"];
    if (cell == nil) {
        // Load the nib and assign an owner
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"EquityCell" owner:self options:nil];
        //NSArray *topLevelObjects = [[[LocalizedManager sharedManager] currentBundle] loadNibNamed:@"EquityCell" owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.validator = self;
    
    Equity *equity = [_equities objectAtIndex:indexPath.row];

    [cell loadValues:equity];
    
    return cell;
}


#pragma mark - Notifications

- (void)didShowKeyboard:(NSNotification*)notification
{
    // remember we actually have 3 VC's loaded, and in this case, they are each listening for the keyboard
    
    NSIndexPath *indexPath = nil;
    for (int i=0, ct=[_equities count]; i<ct; ++i) {
        indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        EquityCell *cell = (EquityCell*)[_tblEquities cellForRowAtIndexPath:indexPath];
        if ([cell.txtName isEditing] || [cell.txtValue isEditing] ) {
            break;
        }
    }
    
    if (!indexPath) {
        // if we show the keyboard when we have no rows, but are on the next view
        return;
    }
    
    CGRect activeRect = [_tblEquities rectForRowAtIndexPath:indexPath];
    CGRect tblRect = _tblEquities.bounds;
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    // Adjust the bottom content inset of your scroll view by the keyboard height (rotated 90 because we're landscape)
    // distance from bottom of tbl to bottom of root view
    CGFloat deltaYFromBottomEdge = 74.f;
    CGFloat h = keyboardSize.height - deltaYFromBottomEdge;
    
    // check if the remaining visible tbl rect contains our row
    CGRect visibleTblRect = CGRectMake(tblRect.origin.x, tblRect.origin.y, tblRect.size.width, tblRect.size.height-h);
    if (!CGRectContainsPoint(visibleTblRect, activeRect.origin) ) {
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, h, 0.0);
        _tblEquities.contentInset = contentInsets;
        _tblEquities.scrollIndicatorInsets = contentInsets;
        [_tblEquities scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
}

- (void)didHideKeyboard:(NSNotification*)notification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    _tblEquities.contentInset = contentInsets;
    _tblEquities.scrollIndicatorInsets = contentInsets;
}



#pragma mark - Validation

-(void)check
{
    // if any loans are invalid, show a nice message
    for (Equity *equity in _equities) {
        if (!equity.isValid) {
            NSString *formatString = LocalizedString(@"LoanEquityAssetValidationWarning", nil);
            NSString *msg = [NSString stringWithFormat:formatString, LocalizedString(@"Equities", nil)];
            [[UserNotificationDisplayManager sharedManager] showMessageAfterDelay:0
                                                                            color:[[UIColor colorWithHexString:@"800000"] colorWithAlphaComponent:0.8]
                                                                      autoDismiss:YES
                                                                          message:msg];
            
            return;
        }
    }
    [[UserNotificationDisplayManager sharedManager] dismiss];
}

@end
