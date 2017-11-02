//
//  AssetsViewController.m
//  StratPad
//
//  Created by Julian Wood on 2013-04-22.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//

#import "AssetsViewController.h"
#import "MBRoundedRectView.h"
#import "SkinManager.h"
#import "StratFileManager.h"
#import "Asset.h"
#import "Financials.h"
#import "AssetCell.h"
#import "DataManager.h"
#import "PermissionChecker.h"
#import "UserNotificationDisplayManager.h"
#import "UIColor-Expanded.h"

@interface AssetsViewController ()

@property (retain, nonatomic) IBOutlet UILabel *lblTitle;
@property (retain, nonatomic) IBOutlet UILabel *lblSubtitle;
@property (retain, nonatomic) IBOutlet MBRoundedRectView *viewRoundedRect;
@property (retain, nonatomic) IBOutlet UILabel *lblInstructions;
@property (retain, nonatomic) IBOutlet UITableView *tblAssets;
@property (retain, nonatomic) IBOutlet UIButton *btnAddNewAsset;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *btnManageAssets;

@property (retain, nonatomic) NSOrderedSet *assets;

@property (retain, nonatomic) PermissionChecker *permissionChecker;

@end

@implementation AssetsViewController

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
    
    _tblAssets.backgroundColor = [UIColor clearColor];
    _tblAssets.opaque = NO;
    _tblAssets.backgroundView = nil;
    _tblAssets.clipsToBounds = YES;
    
    SkinManager *skinMan = [SkinManager sharedManager];
    
    _viewRoundedRect.roundedRectBackgroundColor = [skinMan colorForProperty:kSkinSection2FormBackgroundColor];
    
    _lblTitle.font = [skinMan fontWithName:kSkinSection2TitleFontName andSize:kSkinSection2TitleFontSize];
    _lblTitle.textColor = [skinMan colorForProperty:kSkinSection2TitleFontColor];
    
    _lblSubtitle.font = [skinMan fontWithName:kSkinSection2SubtitleFontName andSize:kSkinSection2SubtitleFontSize];
    _lblSubtitle.textColor = [skinMan colorForProperty:kSkinSection2SubtitleFontColor];
    
    _lblInstructions.textColor = [skinMan colorForProperty:kSkinSection2FieldLabelFontColor];
    
    self.assets = [stratFileManager_ currentStratFile].financials.assets;
    
    _btnAddNewAsset.hidden = _assets.count != 0;
    
    // grab the tableHeaderView out of the nib
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"AssetCell" owner:self options:nil];
    //NSArray *topLevelObjects = [[[LocalizedManager sharedManager] currentBundle] loadNibNamed:@"AssetCell" owner:self options:nil];
    UIView *headerView = [topLevelObjects objectAtIndex:1];

    // skin the detail table header colours
    for (UILabel *lbl in headerView.subviews) {
        lbl.textColor = [skinMan colorForProperty:kSkinSection2FieldLabelFontColor];
    }

    _tblAssets.tableHeaderView = headerView;
    
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
    
    // update transient flag on assets and redraw
    for (Asset *asset in _assets) {
        asset.isNew = NO;
    }
    [_tblAssets reloadData];
    
    [[UserNotificationDisplayManager sharedManager] dismiss];
    
    [stratFileManager_ saveCurrentStratFile];
    
}

- (void)dealloc {
    [_permissionChecker release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_assets release];
    [_lblTitle release];
    [_lblSubtitle release];
    [_viewRoundedRect release];
    [_lblInstructions release];
    [_tblAssets release];
    [_btnAddNewAsset release];
    [_btnManageAssets release];
    [_toolbar release];
    [super dealloc];
}

- (IBAction)addAsset:(id)sender {
    if ([_permissionChecker checkReadWrite]) {
        Asset *asset = (Asset*)[DataManager createManagedInstance:NSStringFromClass([Asset class])];
        asset.isNew = YES;
        Financials *financials = [stratFileManager_ currentStratFile].financials;
        [financials insertObject:asset inAssetsAtIndex:0];
        [_tblAssets insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]]
                          withRowAnimation:UITableViewRowAnimationRight];
        
        [stratFileManager_ saveCurrentStratFile];
        
        _btnAddNewAsset.hidden = YES;        
    }
}

- (IBAction)manage:(id)sender
{
    if ([_permissionChecker checkReadWrite]) {
        UIBarButtonItem *button = (UIBarButtonItem*)sender;
        
        if (self.tblAssets.editing) {
            // switch off editing mode.
            [button setTitle:LocalizedString(@"MANAGE", nil)];
            [self.tblAssets setEditing:NO animated:YES];
        } else {
            [button setTitle:LocalizedString(@"DONE", nil)];
            [self.tblAssets setEditing:YES animated:YES];
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
        Asset *asset = [_assets objectAtIndex:row];
        Financials *financials = [stratFileManager_ currentStratFile].financials;
        [financials removeAssetsObject:asset];
        
        [_tblAssets deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [stratFileManager_ saveCurrentStratFile];
        
        if (!_assets.count) {
            _btnAddNewAsset.hidden = NO;
            
            // switch off editing mode.
            [_btnManageAssets setTitle:LocalizedString(@"MANAGE", nil)];
            [self.tblAssets setEditing:NO animated:YES];
        }
        
        [self check];
        
    }
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _assets.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AssetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AssetCell"];
    if (cell == nil) {
        // Load the nib and assign an owner
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"AssetCell" owner:self options:nil];
        //NSArray *topLevelObjects = [[[LocalizedManager sharedManager] currentBundle] loadNibNamed:@"AssetCell" owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.validator = self;
    
    Asset *asset = [_assets objectAtIndex:indexPath.row];
    [cell loadValues:asset];

    return cell;
}

#pragma mark - Notifications

- (void)didShowKeyboard:(NSNotification*)notification
{
    // remember we actually have 3 VC's loaded, and in this case, they are each listening for the keyboard
    
    NSIndexPath *indexPath = nil;
    for (int i=0, ct=[_assets count]; i<ct; ++i) {
        indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        AssetCell *cell = (AssetCell*)[_tblAssets cellForRowAtIndexPath:indexPath];
        if ([cell.txtName isEditing] || [cell.txtValue isEditing] || [cell.txtSalvageValue isEditing]) {
            break;
        }
    }
    
    if (!indexPath) {
        // if we show the keyboard when we have no rows, but are on the next view
        return;
    }
    
    CGRect activeRect = [_tblAssets rectForRowAtIndexPath:indexPath];
    CGRect tblRect = _tblAssets.bounds;
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    // Adjust the bottom content inset of your scroll view by the keyboard height (rotated 90 because we're landscape)
    // distance from bottom of tbl to bottom of root view
    CGFloat deltaYFromBottomEdge = 74.f;
    CGFloat h = keyboardSize.height - deltaYFromBottomEdge;
    
    // check if the remaining visible tbl rect contains our row
    CGRect visibleTblRect = CGRectMake(tblRect.origin.x, tblRect.origin.y, tblRect.size.width, tblRect.size.height-h);
    if (!CGRectContainsPoint(visibleTblRect, activeRect.origin) ) {
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, h, 0.0);
        _tblAssets.contentInset = contentInsets;
        _tblAssets.scrollIndicatorInsets = contentInsets;
        [_tblAssets scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
}

- (void)didHideKeyboard:(NSNotification*)notification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    _tblAssets.contentInset = contentInsets;
    _tblAssets.scrollIndicatorInsets = contentInsets;
}

#pragma mark - Validation

-(void)check
{
    // if any assets are invalid, show a nice message
    for (Asset *asset in _assets) {
        if (!asset.isValid) {
            NSString *formatString = LocalizedString(@"LoanEquityAssetValidationWarning", nil);
            NSString *msg = [NSString stringWithFormat:formatString, LocalizedString(@"Assets", nil)];
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
