//
//  SettingsMenuViewController.h
//  StratPad
//
//  Created by Julian Wood on 11-08-11.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "MenuNavController.h"
#import "BooleanTableViewCell.h"
#import "Settings.h"
#import "TextFieldTableViewCell.h"
#import "LogoCell.h"
#import "LMViewController.h"

@interface SettingsMenuViewController : LMViewController <UITableViewDelegate, UITableViewDataSource, TableBasedMenu, LogoEditor,
    // these are both for the UIImagePickerController
    UINavigationControllerDelegate, UIImagePickerControllerDelegate> 
{
@private
    UITableView *tableView_;
    NSMutableArray *menuItems_;
    
    Settings *settings_;
    
    UIPopoverController *popoverForImagePicker_;
    
    // part of a hack to make sure the popovers resize correctly
    BOOL firstTimeShow_;
}

// TableBasedMenu contract
@property (nonatomic,retain) UITableView *tableView;

// let our delegate reset this flag
-(void)resetFirstTimeShowFlag;

// if we invoke the UIImagePickerController, then tap settings/actions/etc again, it shows up on top of UIImagePickerController, so use this method to dismiss it
-(void)dismissImagePicker;

@end
