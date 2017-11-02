//
//  LoansViewController.m
//  StratPad
//
//  Created by Julian Wood on 2013-04-16.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//

#import "LoansViewController.h"
#import "MBRoundedRectView.h"
#import "SkinManager.h"
#import "LoanCell.h"
#import "NoRowsTableDataSource.h"
#import "DataManager.h"
#import "Financials.h"
#import "Loan.h"
#import "PermissionChecker.h"
#import "UserNotificationDisplayManager.h"
#import "UIColor-Expanded.h"

@interface LoansViewController ()

@property (retain, nonatomic) IBOutlet UILabel *lblTitle;
@property (retain, nonatomic) IBOutlet UILabel *lblSubtitle;
@property (retain, nonatomic) IBOutlet MBRoundedRectView *viewRoundedRect;
@property (retain, nonatomic) IBOutlet UILabel *lblInstructions;
@property (retain, nonatomic) IBOutlet UITableView *tblLoans;
@property (retain, nonatomic) IBOutlet UIButton *btnAddNewLoan;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *btnManageLoans;

@property (retain, nonatomic) NSOrderedSet *loans;

@property (retain, nonatomic) PermissionChecker *permissionChecker;

@end

@implementation LoansViewController

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
    
    _tblLoans.backgroundColor = [UIColor clearColor];
    _tblLoans.opaque = NO;
    _tblLoans.backgroundView = nil;
    _tblLoans.clipsToBounds = YES;
    
    SkinManager *skinMan = [SkinManager sharedManager];
    
    _viewRoundedRect.roundedRectBackgroundColor = [skinMan colorForProperty:kSkinSection2FormBackgroundColor];
    
    _lblTitle.font = [skinMan fontWithName:kSkinSection2TitleFontName andSize:kSkinSection2TitleFontSize];
    _lblTitle.textColor = [skinMan colorForProperty:kSkinSection2TitleFontColor];
    
    _lblSubtitle.font = [skinMan fontWithName:kSkinSection2SubtitleFontName andSize:kSkinSection2SubtitleFontSize];
    _lblSubtitle.textColor = [skinMan colorForProperty:kSkinSection2SubtitleFontColor];
    
    _lblInstructions.textColor = [skinMan colorForProperty:kSkinSection2FieldLabelFontColor];
    
    self.loans = [stratFileManager_ currentStratFile].financials.loans;
    
    _btnAddNewLoan.hidden = _loans.count != 0;
        
    // grab the tableHeaderView out of the nib
    
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"LoanCell" owner:self options:nil];
    //NSArray *topLevelObjects = [[[LocalizedManager sharedManager] currentBundle] loadNibNamed:@"LoanCell" owner:self options:nil];
    UIView *headerView = [topLevelObjects objectAtIndex:1];
    
    // skin the detail table header colours
    for (UILabel *lbl in headerView.subviews) {
        lbl.textColor = [skinMan colorForProperty:kSkinSection2FieldLabelFontColor];
    }
    
    _tblLoans.tableHeaderView = headerView;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // if any loans are invalid, show a nice message
    [self check];
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_toolbar setNeedsLayout];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    // update transient flag on loans and redraw
    for (Loan *loan in _loans) {
        loan.isNew = NO;
    }
    [_tblLoans reloadData];
    
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
    [_loans release];
    [_lblTitle release];
    [_lblSubtitle release];
    [_viewRoundedRect release];
    [_lblInstructions release];
    [_tblLoans release];
    [_btnAddNewLoan release];
    [_btnManageLoans release];
    [_toolbar release];
    [super dealloc];
}

#pragma mark - Actions

- (IBAction)addLoan:(id)sender {
    if ([_permissionChecker checkReadWrite]) {
        Loan *loan = (Loan*)[DataManager createManagedInstance:NSStringFromClass([Loan class])];
        loan.isNew = YES;
        Financials *financials = [stratFileManager_ currentStratFile].financials;
        [financials insertObject:loan inLoansAtIndex:0];
        [_tblLoans insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
        
        [stratFileManager_ saveCurrentStratFile];
        
        _btnAddNewLoan.hidden = YES;
    }
}

- (IBAction)manage:(id)sender
{
    if ([_permissionChecker checkReadWrite]) {
        UIBarButtonItem *button = (UIBarButtonItem*)sender;
        
        if (self.tblLoans.editing) {
            // switch off editing mode.
            [button setTitle:LocalizedString(@"MANAGE", nil)];
            [self.tblLoans setEditing:NO animated:YES];
        } else {
            [button setTitle:LocalizedString(@"DONE", nil)];
            [self.tblLoans setEditing:YES animated:YES];
        }
        
    }
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSUInteger row = [indexPath row];
        Loan *loan = [_loans objectAtIndex:row];
        Financials *financials = [stratFileManager_ currentStratFile].financials;
        [financials removeLoansObject:loan];

        [_tblLoans deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [stratFileManager_ saveCurrentStratFile];
        
        if (!_loans.count) {
            _btnAddNewLoan.hidden = NO;
            
            // switch off editing mode.
            [_btnManageLoans setTitle:LocalizedString(@"MANAGE", nil)];
            [self.tblLoans setEditing:NO animated:YES];
        }
        
        [self check];
        
    }
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _loans.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LoanCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LoanCell"];
    if (cell == nil) {
        // Load the nib and assign an owner
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"LoanCell" owner:self options:nil];
        //NSArray *topLevelObjects = [[[LocalizedManager sharedManager] currentBundle] loadNibNamed:@"LoanCell" owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.validator = self;
    
    Loan *loan = [_loans objectAtIndex:indexPath.row];
    [cell loadValues:loan];
        
    return cell;
}

#pragma mark - Notifications

- (void)didShowKeyboard:(NSNotification*)notification
{
    NSIndexPath *indexPath = nil;
    for (int i=0, ct=[_loans count]; i<ct; ++i) {
        indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        LoanCell *cell = (LoanCell*)[_tblLoans cellForRowAtIndexPath:indexPath];
        if ([cell.txtName isEditing] || [cell.txtAmount isEditing]) {
            break;
        }
    }

    if (!indexPath) {
        // if we show the keyboard when we have no rows, but are on the next view
        return;
    }
    
    CGRect activeRect = [_tblLoans rectForRowAtIndexPath:indexPath];
    CGRect tblRect = _tblLoans.bounds;
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    // Adjust the bottom content inset of your scroll view by the keyboard height (rotated 90 because we're landscape)
    // distance from bottom of tbl to bottom of root view
    CGFloat deltaYFromBottomEdge = 74.f;
    //CGFloat h = keyboardSize.width - deltaYFromBottomEdge;
    CGFloat h = keyboardSize.height - deltaYFromBottomEdge;
    
    // check if the remaining visible tbl rect contains our row
    CGRect visibleTblRect = CGRectMake(tblRect.origin.x, tblRect.origin.y, tblRect.size.width, tblRect.size.height-h);
    if (!CGRectContainsPoint(visibleTblRect, activeRect.origin) ) {
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, h, 0.0);
        _tblLoans.contentInset = contentInsets;
        _tblLoans.scrollIndicatorInsets = contentInsets;        
        [_tblLoans scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }    
}

- (void)didHideKeyboard:(NSNotification*)notification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    _tblLoans.contentInset = contentInsets;
    _tblLoans.scrollIndicatorInsets = contentInsets;
}

#pragma mark - Validation

-(void)check
{
    for (Loan *loan in _loans) {
        if (!loan.isValid) {
            NSString *formatString = LocalizedString(@"LoanEquityAssetValidationWarning", nil);
            NSString *msg = [NSString stringWithFormat:formatString, LocalizedString(@"Loans", nil)];
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
