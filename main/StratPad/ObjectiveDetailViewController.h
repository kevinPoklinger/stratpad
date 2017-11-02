//
//  ObjectiveDetailViewController.h
//  StratPad
//
//  Created by Eric Rogers on August 17, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "StratFile.h"
#import "Objective.h"
#import "MBAutoSuggestController.h"
#import "MBDateSelectionViewController.h"
#import "ContentViewController.h"
#import "MBRoundedRectView.h"
#import "MBDropDownButton.h"
#import "MBDropDownController.h"
#import "SkinManager.h"

@protocol ObjectiveDetailDelegate <NSObject>
- (void)editingCompleteForObjective:(Objective*)objective;
@end

@interface ObjectiveDetailViewController : ContentViewController<UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, AutoSuggestDelegate, DropDownDelegate> {
@private
    UIBarButtonItem *titleItem_;
    UIScrollView *fieldsetView_;
        
    MBAutoSuggestTextField *txtDescription_;
                
    Objective *objective_;
    
    NSArray *frequencies_;
    NSArray *objectiveTypes_;
    NSMutableArray *metrics_;
    
    MBDropDownController *frequencyDropDownController_;
    MBDropDownController *objectiveTypeDropDownController_;
    
    MBAutoSuggestController *descriptionController_;
    MBAutoSuggestController *metricController_;
        
    id<ObjectiveDetailDelegate> delegate_;
    SkinManager *skinMan_;
}

@property(nonatomic, retain) IBOutlet UIBarButtonItem *titleItem;
@property(nonatomic, retain) IBOutlet UIScrollView *fieldsetView;
@property(nonatomic, retain) IBOutlet MBAutoSuggestTextField *txtDescription;
@property (retain, nonatomic) IBOutlet MBDropDownButton *dropDownFrequency;
@property (retain, nonatomic) IBOutlet MBDropDownButton *dropDownObjective;

// the metrics table
@property (retain, nonatomic) IBOutlet UITableView *tblMetrics;

// buttons in the toolbar
@property (retain, nonatomic) IBOutlet UIBarButtonItem *btnManage;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *btnAddMetric;

// this is behind the metrics table, giving it colour and round edges
@property (retain, nonatomic) IBOutlet MBRoundedRectView *roundedRectView;

// delegate to notify after changes are made to this objective
@property(nonatomic, assign) id<ObjectiveDetailDelegate> delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andObjective:(Objective*)objective;

- (IBAction)done;
- (IBAction)addMetric:(id)sender;
- (IBAction)manageMetrics:(id)sender;

@end