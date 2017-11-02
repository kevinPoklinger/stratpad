//
//  ActivityDetailViewController.h
//  StratPad
//
//  Created by Eric Rogers on August 19, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//
//  This is the detail view in F7

#import "Activity.h"
#import "Objective.h"
#import "StratFile.h"
#import "Frequency.h"
#import "MBRoundedTextField.h"
#import "MBRoundedLabel.h"
#import "MBRoundedTableView.h"
#import "MBAutoSuggestController.h"
#import "MBDateSelectionViewController.h"
#import "ContentViewController.h"
#import "MBCalendarButton.h"
#import "MBRoundedRectView.h"

@protocol ActivityDetailDelegate <NSObject>
- (void)editingCompleteForActivity:(Activity*)activity;
@end


@interface ActivityDetailViewController : ContentViewController<UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, AutoSuggestDelegate, DateSelectionDelegate> {
 @private    
    UIBarButtonItem *titleItem_;
    UIScrollView *fieldsetView_;
    
    UILabel *lblAction_;
    MBRoundedTextField *txtAction_;
    
    UILabel *lblStartDate_;
    MBCalendarButton *btnStartDate_;
    
    UILabel *lblEndDate_;
    MBCalendarButton *btnEndDate_;

    UILabel *lblResponsible_;
    MBAutoSuggestTextField *txtResponsible_;
    
    UILabel *lblUpfrontCost_;
    MBRoundedTextField *txtUpfrontCost_;
    
    UILabel *lblOngoingCost_;
    MBRoundedTextField *txtOngoingCost_;

    UILabel *lblOngoingFrequency_;
    MBRoundedTableView *tblOngoingFrequency_;
    
    NSMutableArray *frequencies_;
            
    MBAutoSuggestController *responsibleController_;
    
    MBDateSelectionViewController *startDateController_;
    MBDateSelectionViewController *endDateController_;

    id<ActivityDetailDelegate> delegate_;
}

@property(nonatomic, retain) IBOutlet UIBarButtonItem *titleItem;
@property(nonatomic, retain) IBOutlet UIScrollView *fieldsetView;
@property(nonatomic, retain) IBOutlet UILabel *lblAction;
@property(nonatomic, retain) IBOutlet MBRoundedTextField *txtAction;
@property(nonatomic, retain) IBOutlet UILabel *lblStartDate;
@property(nonatomic, retain) IBOutlet MBCalendarButton *btnStartDate;
@property(nonatomic, retain) IBOutlet UILabel *lblEndDate;
@property(nonatomic, retain) IBOutlet MBCalendarButton *btnEndDate;
@property(nonatomic, retain) IBOutlet UILabel *lblResponsible;
@property(nonatomic, retain) IBOutlet MBAutoSuggestTextField *txtResponsible;
@property(nonatomic, retain) IBOutlet UILabel *lblUpfrontCost;
@property(nonatomic, retain) IBOutlet MBRoundedTextField *txtUpfrontCost;
@property(nonatomic, retain) IBOutlet UILabel *lblOngoingCost;
@property(nonatomic, retain) IBOutlet MBRoundedTextField *txtOngoingCost;
@property(nonatomic, retain) IBOutlet UILabel *lblOngoingFrequency;
@property(nonatomic, retain) IBOutlet MBRoundedTableView *tblOngoingFrequency;

@property(nonatomic, assign) id<ActivityDetailDelegate> delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andActivity:(Activity*)activity;

- (IBAction)showDatePicker:(id)sender;
- (IBAction)done;

@end
