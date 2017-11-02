//
//  DefineObjectivesViewController.h
//  StratPad
//
//  Created by Eric Rogers on August 16, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "FormViewController.h"
#import "MBRoundedRectView.h"
#import "MBRoundedTableViewCell.h"
#import "DefineObjectivesHeaderView.h"
#import "DefineObjectivesTableViewCell.h"
#import "AddObjectiveTableViewCell.h"
#import "ObjectiveDetailViewController.h"
#import "MBLabel.h"
#import "MBDropDownController.h"
#import "MBRoundedRectView.h"
#import "MBFormInstructionsLabel.h"
#import "ObjectiveHeaderTableViewCell.h"

@interface DefineObjectivesViewController : FormViewController<UITableViewDataSource, UITableViewDelegate, ObjectiveDetailDelegate, DropDownDelegate> {
 @private    
    UILabel *lblTitle_;
    UILabel *lblSubTitle_;
    
    MBFormInstructionsLabel *lblInstructions_;
    
    UILabel *lblTheme_;
    MBDropDownButton *btnTheme_;
    MBDropDownController *themeDropDownController_;
    
    UITableView *tblObjectives_;
    
    Theme *theme_;
    
    NSArray *objectiveTypes_;
    NSMutableArray *objectiveGroups_;
    
    MBRoundedRectView *roundedRectView_;
    
    ObjectiveHeaderTableViewCell *headingTableCell_;
    
    DefineObjectivesTableViewCell *tableCell_;
    
    AddObjectiveTableViewCell *addObjectiveTableCell_;
    
    DefineObjectivesHeaderView *headerView_;
        
    ObjectiveDetailViewController *detailController_;
    
    // flag that is set when the view is disappearing so that
    // we don't perform certain actions such as animations 
    // when disappearing.
    BOOL viewDisappearing_;
    
    UIBarButtonItem *btnItemManage_;
    UIBarButtonItem *btnItemAdd_;
}


@property (retain, nonatomic) IBOutlet UIToolbar *toolbar;

@property(nonatomic, retain) IBOutlet UIBarButtonItem *btnItemManage;
@property(nonatomic, retain) IBOutlet UIBarButtonItem *btnItemAdd;

@property(nonatomic, retain) IBOutlet UILabel *lblTitle;
@property(nonatomic, retain) IBOutlet UILabel *lblSubTitle;

@property(nonatomic, retain) IBOutlet MBFormInstructionsLabel *lblInstructions;

@property(nonatomic, retain) IBOutlet UILabel *lblTheme;
@property(nonatomic, retain) IBOutlet MBDropDownButton *btnTheme;

@property(nonatomic, retain) IBOutlet UITableView *tblObjectives;

@property(nonatomic, retain) IBOutlet MBRoundedRectView *roundedRectView;

@property(nonatomic, assign) IBOutlet ObjectiveHeaderTableViewCell *headingTableCell;
@property(nonatomic, assign) IBOutlet AddObjectiveTableViewCell *addObjectiveTableCell;
@property(nonatomic, assign) IBOutlet DefineObjectivesTableViewCell *tableCell;

@property(nonatomic, assign) IBOutlet DefineObjectivesHeaderView *headerView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andThemeOrNil:(Theme*)theme;


@end
