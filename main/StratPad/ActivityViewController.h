//
//  ActivityViewController.h
//  StratPad
//
//  Created by Eric Rogers on August 18, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "FormViewController.h"
#import "Objective.h"
#import "MBRoundedLabel.h"
#import "ActivityTableViewCell.h"
#import "MBRoundedRectView.h"
#import "ActivityDetailViewController.h"
#import "MBDropDownController.h"
#import "MBLabel.h"
#import "NoRowsTableDataSource.h"
#import "MBFormInstructionsLabel.h"
#import "ActivityTableHeaderView.h"
#import "Theme.h"

@interface ActivityViewController : FormViewController<UITableViewDelegate, UITableViewDataSource, ActivityDetailDelegate, DropDownDelegate> {
 @private        
    UILabel *lblTitle_;
    UILabel *lblSubTitle_;

    MBFormInstructionsLabel *lblInstructions_;
    
    UILabel *lblTheme_;    
    MBDropDownButton *btnTheme_;
    
    UILabel *lblObjective_;
    MBDropDownButton *btnObjective_;    
    
    MBRoundedRectView *roundedRectView_;
    
    UITableView *tblActivities_;
    
    ActivityTableHeaderView *tableHeaderView_;
    
    ActivityTableViewCell *tableCell_;
    
    Theme *theme_;
    Objective *objective_;
    
    // used to store activities for the objective, sorted by order.
    NSMutableArray *activities_;

    MBDropDownController *themeDropDownController_;
    MBDropDownController *objectiveDropDownController_;
    
    ActivityDetailViewController *detailController_;
    
    NoRowsTableDataSource *noRowsTableDataSource_;
    
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
@property(nonatomic, retain) IBOutlet UILabel *lblObjective;
@property(nonatomic, retain) IBOutlet MBDropDownButton *btnObjective;
@property(nonatomic, retain) IBOutlet MBRoundedRectView *roundedRectView;
@property(nonatomic, retain) IBOutlet UITableView *tblActivities;
@property(nonatomic, assign) IBOutlet ActivityTableHeaderView *tableHeaderView;
@property(nonatomic, assign) IBOutlet ActivityTableViewCell *tableCell;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andThemeOrNil:(Theme*)theme andObjectiveOrNil:(Objective*)objective;

- (IBAction)addActivity:(id)sender event:(UIEvent*)event;
- (IBAction)toggleManageMode:(id)sender;

@end
