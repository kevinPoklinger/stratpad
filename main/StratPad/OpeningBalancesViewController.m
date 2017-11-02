//
//  OpeningBalancesViewController.m
//  StratPad
//
//  Created by Julian Wood on 2013-04-26.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//

#import "OpeningBalancesViewController.h"
#import "UILabelVAlignment.h"
#import "MBRoundedRectView.h"
#import "SkinManager.h"
#import "Financials.h"
#import "OpeningBalances.h"


@interface OpeningBalancesViewController ()
@property (retain, nonatomic) IBOutlet UILabel *lblTitle;
@property (retain, nonatomic) IBOutlet UILabel *lblSubtitle;
@property (retain, nonatomic) IBOutlet UILabel *lblInstructions;
@property (retain, nonatomic) IBOutlet UILabelVAlignment *lblDetails;
@property (retain, nonatomic) IBOutlet UITableView *tblBalances;

@property (retain, nonatomic) OpeningBalances *openingBalances;

@property (retain, nonatomic) NSArray *properties;

@end

@implementation OpeningBalancesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.properties = [NSArray arrayWithObjects:
                           @"cash",
                           @"accountsReceivable",
                           @"inventory",
                           @"prepaidExpenses",
                           @"longTermAssets",
                           @"otherAssets",
                           @"accountsPayable",
                           @"employeeDeductionsPayable",
                           @"salesTaxPayable",
                           @"incomeTaxesPayable",
                           @"shortTermLoan",
                           @"currentPortionofLTD",
                           @"longTermLoan",
                           @"prepaidPurchases",
                           @"otherLiabilities",
                           @"loansFromShareholders",
                           @"capitalStock",
                           @"retainedEarnings",
                           nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didShowKeyboard:)
                                                     name:UIKeyboardDidShowNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didHideKeyboard:)
                                                     name:UIKeyboardDidHideNotification
                                                   object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    SkinManager *skinMan = [SkinManager sharedManager];
    
    // rounded rect background
    MBRoundedRectView *backgroundView = [[MBRoundedRectView alloc] initWithFrame:_tblBalances.frame];
    backgroundView.roundedRectBackgroundColor = [skinMan colorForProperty:kSkinSection2FormBackgroundColor];
    _tblBalances.backgroundView = backgroundView;
    [backgroundView release];
        
    _lblTitle.font = [skinMan fontWithName:kSkinSection2TitleFontName andSize:kSkinSection2TitleFontSize];
    _lblTitle.textColor = [skinMan colorForProperty:kSkinSection2TitleFontColor];
    
    _lblSubtitle.font = [skinMan fontWithName:kSkinSection2SubtitleFontName andSize:kSkinSection2SubtitleFontSize];
    _lblSubtitle.textColor = [skinMan colorForProperty:kSkinSection2SubtitleFontColor];
    
    _lblInstructions.textColor = [skinMan colorForProperty:kSkinSection2FieldLabelFontColor];
    _lblDetails.textColor = [skinMan colorForProperty:kSkinSection2FieldLabelFontColor];
    
    self.openingBalances = [stratFileManager_ currentStratFile].financials.openingBalances;
    
    // grab the tableHeaderView out of the nib
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"OpeningBalanceCell" owner:self options:nil];
    UIView *headerView = [topLevelObjects objectAtIndex:1];
    
    // skin the detail table header colours
    for (UILabel *lbl in headerView.subviews) {
        lbl.textColor = [skinMan colorForProperty:kSkinSection2FieldLabelFontColor];
    }
    
    _tblBalances.tableHeaderView = headerView;
    
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [stratFileManager_ saveCurrentStratFile];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [_properties release];
    [_openingBalances release];
    
    [_lblTitle release];
    [_lblSubtitle release];
    [_lblInstructions release];
    [_lblDetails release];
    [_tblBalances release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setLblTitle:nil];
    [self setLblSubtitle:nil];
    [self setLblInstructions:nil];
    [self setLblDetails:nil];
    [self setTblBalances:nil];
    [super viewDidUnload];
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _properties.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"OpeningBalanceCell";
    OpeningBalanceCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        // Load the nib and assign an owner
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    NSInteger row = indexPath.row;
    NSString *key = [NSString stringWithFormat:@"OpeningBalance_%d", row];
    cell.lblName.text = LocalizedString(key, nil);
    cell.txtValue.property = [_properties objectAtIndex:row];
    cell.openingBalances = _openingBalances;
    cell.row = row;
    cell.delegate = self;
    // todo: calculations
    cell.lblCalculated.text = @"-";
    cell.lblDifference.text = @"-";
    [cell reloadData];
    
    // last row can have the done key
    if (row == _properties.count-1) {
        cell.txtValue.returnKeyType = UIReturnKeyDone;
    }
    
    return cell;
}

#pragma mark RowScrollerDelegate

-(void)scrollToRow:(NSInteger)row
{
    // because the next field is actually the next row
    [_tblBalances scrollToRowAtIndexPath:
     [NSIndexPath indexPathForRow:row inSection:0]
                        atScrollPosition:UITableViewScrollPositionMiddle
                                animated:YES];
}

-(UIResponder*)nextField:(NSInteger)lastRow
{
    NSInteger row = lastRow + 1;
    if (row == _properties.count) {
        row = 0;
    }
    OpeningBalanceCell *cell = (OpeningBalanceCell*)[_tblBalances cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
    return cell.txtValue;
}


#pragma mark - Notifications

- (void)didShowKeyboard:(NSNotification*)notification
{
    // remember we actually have 3 VC's loaded, and in this case, they are each listening for the keyboard
    
    NSIndexPath *indexPath = nil;
    for (int i=0, ct=[_properties count]; i<ct; ++i) {
        indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        OpeningBalanceCell *cell = (OpeningBalanceCell*)[_tblBalances cellForRowAtIndexPath:indexPath];
        if ([cell.txtValue isEditing] ) {
            break;
        }
    }
    
    if (!indexPath) {
        // if we show the keyboard when we have no rows, but are on the next view
        return;
    }
    
    CGRect activeRect = [_tblBalances rectForRowAtIndexPath:indexPath];
    CGRect tblRect = _tblBalances.bounds;
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    // Adjust the bottom content inset of your scroll view by the keyboard height (rotated 90 because we're landscape)
    // distance from bottom of tbl to bottom of root view
    CGFloat deltaYFromBottomEdge = 64.f;
    CGFloat h = keyboardSize.height - deltaYFromBottomEdge;

    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, h, 0.0);
    _tblBalances.contentInset = contentInsets;
    _tblBalances.scrollIndicatorInsets = contentInsets;

    // check if the remaining visible tbl rect contains our row
    CGRect visibleTblRect = CGRectMake(tblRect.origin.x, tblRect.origin.y, tblRect.size.width, tblRect.size.height-h);
    if (!CGRectContainsPoint(visibleTblRect, activeRect.origin) ) {
        [_tblBalances scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
}

- (void)didHideKeyboard:(NSNotification*)notification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    _tblBalances.contentInset = contentInsets;
    _tblBalances.scrollIndicatorInsets = contentInsets;
}



@end
