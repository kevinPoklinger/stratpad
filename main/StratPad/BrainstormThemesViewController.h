//
//  BrainstormThemesViewController.h
//  StratPad
//
//  Created by Eric Rogers on August 5, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "FormViewController.h"
#import "ThemeTableViewCell.h"
#import "ThemeOptionsViewController.h"
#import "MBRoundedRectView.h"
#import "NoRowsTableDataSource.h"
#import "BrainstormThemesHeaderView.h"

@interface BrainstormThemesViewController : FormViewController<UITableViewDelegate, UITableViewDataSource, ThemeOptionDelegate> {
@private
    UILabel *lblTitle_;
    UILabel *lblSubTitle_;
    
    UILabel *lblBodyText1_;
    UILabel *lblBodyText2_;    
    
    UITableView *tblThemes_;    
    MBRoundedRectView *roundedRectView_;    
    BrainstormThemesHeaderView *tableHeaderView_;
    
    // outlet to a theme table view cell loaded from a nib resource
	ThemeTableViewCell *tableCell_;
    
    // used to store themes for the StratFile, sorted by order.
    NSMutableArray *sortedThemes_;
    
    ThemeOptionsViewController *detailController_;
    
    NoRowsTableDataSource *noRowsTableDataSource_;

    // flag that is set when the view is disappearing so that
    // we don't perform certain actions such as animations 
    // when disappearing.
    BOOL viewDisappearing_;
    
    UIBarButtonItem *btnItemManage_;
    UIBarButtonItem *btnItemAdd_;
    
    // the table can be expanded by a double-tap
    BOOL expanded_;
    CGFloat expandedBy_;
}


@property (retain, nonatomic) IBOutlet UIToolbar *themeToolBar;
@property(nonatomic, retain) IBOutlet UILabel *lblTitle;
@property(nonatomic, retain) IBOutlet UILabel *lblSubTitle;
@property(nonatomic, retain) IBOutlet UILabel *lblBodyText1;
@property(nonatomic, retain) IBOutlet UILabel *lblBodyText2;
@property(nonatomic, retain) IBOutlet MBRoundedRectView *roundedRectView;
@property(nonatomic, retain) IBOutlet UITableView *tblThemes;
@property(nonatomic, assign) IBOutlet BrainstormThemesHeaderView *tableHeaderView;
@property(nonatomic, assign) IBOutlet ThemeTableViewCell *tableCell;
@property(nonatomic, retain) IBOutlet UIBarButtonItem *btnItemManage;
@property(nonatomic, retain) IBOutlet UIBarButtonItem *btnItemAdd;

- (IBAction)addTheme:(id)sender event:(UIEvent*)event;
- (IBAction)toggleManageMode:(id)sender;
- (IBAction)expandThemesTable:(id)sender event:(UIEvent*)event;

@end
