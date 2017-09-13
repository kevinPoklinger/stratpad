//
//  ThemeDetailViewController.h
//  StratPad
//
//  Created by Eric Rogers on August 9, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//
//  This is a detail view for F4.

#import "Theme.h"
#import "StratFile.h"
#import "ContentViewController.h"
#import "MBRoundedRectView.h"
#import "MBRoundedTextField.h"

@protocol ThemeOptionDelegate <NSObject>
- (void)editingCompleteForTheme:(Theme*)theme;
@end

@interface ThemeOptionsViewController : ContentViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate> {
 @private
    MBRoundedRectView *roundedRectView_;
    
    UIBarButtonItem *titleItem_;
    
    UILabel *lblTitle_;
    UILabel *lblOptions_;
    
    MBRoundedTextField *txtTitle_;
    UITableView *tblOptions_;    
         
    Theme *theme_;
    
    id<ThemeOptionDelegate> delegate_;
    
}

@property(nonatomic, retain) IBOutlet MBRoundedRectView *roundedRectView;
@property(nonatomic, retain) IBOutlet UIBarButtonItem *titleItem;
@property(nonatomic, retain) IBOutlet UILabel *lblTitle;
@property(nonatomic, retain) IBOutlet UILabel *lblOptions;
@property(nonatomic, retain) IBOutlet MBRoundedTextField *txtTitle;
@property(nonatomic, retain) IBOutlet UITableView *tblOptions;

@property(nonatomic, assign) id<ThemeOptionDelegate> delegate;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andTheme:(Theme*)theme;

- (IBAction)done;

@end
