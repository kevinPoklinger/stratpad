//
//  RootViewController.h
//  StratPad
//
//  Created by Eric Rogers on July 26, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "SideBarViewController.h"
#import "PageViewController.h"
#import "MenuNavController.h"
#import "SplashView.h"
#import "MKNumberBadgeView/MKNumberBadgeView.h"

@interface RootViewController : UIViewController

// the buttons on the menu bar are public
@property (retain, nonatomic) IBOutlet UIBarButtonItem *settingsItem;
@property(nonatomic, retain) IBOutlet UIBarButtonItem *actionsItem;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *upgradeItem;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *infoItem;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *stratFilesItem;


- (void) setPageTitle:(NSString*)pageTitle;

- (PageViewController*)pageViewController;

- (IBAction)showActionPopover:(id)sender event:(UIEvent*)event;
- (IBAction)showSettingsPopover:(id)sender event:(UIEvent*)event;
- (IBAction)showStratFilesPopover:(id)sender event:(UIEvent*)event;
- (IBAction)showInfoPopover:(id)sender event:(UIEvent*)event;
- (IBAction)showUpgradePopover:(id)sender event:(UIEvent*)event;



-(void)jumpToFinancialsPage:(NSUInteger)index;

// dismiss any and all menus from the top navbar
-(void)dismissAllMenus;

-(BOOL)isSplashScreenShowing;

@end
