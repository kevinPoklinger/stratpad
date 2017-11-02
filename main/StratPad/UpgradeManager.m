//
//  UpgradeManager.m
//  StratPad
//
//  Created by Julian Wood on 12-01-03.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

// scenarios:
// 1. 1.0 installed, update to 1.1 Premium
//      - if you deleted all the sample files, should we restore them? no
//      - if you changed any of the sample files, should we add back the originals? no
//      - all files in db should be updated with correct permissions and model by lightweight
// 2. 1.1 Premium installed de novo
//      - all 3 sample files are RW
// 3. 1.1 Plus installed de novo
//      - all sample files are changed to Read-only
//      - one empty RW file is added
// 4. 1.1 Plus upgraded to Premium
//      - need to make sure all files become RW in UpgradeVC

#import "UpgradeManager.h"
#import "StratFile.h"
#import "StratFileManager.h"
#import "DataManager.h"
#import "NSDate-StratPad.h"
#import "AppDelegate.h"
#import "PageViewController.h"
#import "RootViewController.h"
#import "EditionManager.h"
#import "RegistrationManager.h"

@implementation UpgradeManager

+(void)upgradeToPlus
{    
    // productId has already been updated in NSUserDefaults
    
    // have to reload the config, just in case we are on Toolkit page
    [[NavigationConfig sharedManager] buildNavigationFromStratFileOrNil:[StratFileManager sharedManager].currentStratFile];

    // reload pages without ads
    AppDelegate* appDelegate = (((AppDelegate*) [UIApplication sharedApplication].delegate));
    PageViewController *pageVC = [(RootViewController*)[appDelegate.window rootViewController] pageViewController];
    [pageVC numberOfPagesChanged];
    [pageVC reloadCurrentPages];
    
    [[RegistrationManager sharedManager] upgradeStratPad:YES isStratBoardUpgraded:NO];
}

+(void)upgradeToPremium
{
    // productId has already been updated in NSUserDefaults

    // have to reload the config, just in case we are on Toolkit page
    [[NavigationConfig sharedManager] buildNavigationFromStratFileOrNil:[StratFileManager sharedManager].currentStratFile];

    // all stratfiles become rw
    NSArray *stratFiles = [DataManager arrayForEntity:NSStringFromClass([StratFile class]) sortDescriptorsOrNil:nil];
    for (StratFile *stratFile in stratFiles) {
        stratFile.permissions = @"0600";
    }
    [DataManager saveManagedInstances];    
    
    // reload pages without ads
    AppDelegate* appDelegate = (((AppDelegate*) [UIApplication sharedApplication].delegate));
    PageViewController *pageVC = [(RootViewController*)[appDelegate.window rootViewController] pageViewController];
    [pageVC numberOfPagesChanged];
    [pageVC reloadCurrentPages];
    
    [[RegistrationManager sharedManager] upgradeStratPad:YES isStratBoardUpgraded:NO];
}

+(void)upgradeToStratBoard
{
    // have to reload the config in order to change the number of pages  
    [[NavigationConfig sharedManager] buildNavigationFromStratFileOrNil:[StratFileManager sharedManager].currentStratFile];
    
    // if we're on StratBoard, need to reload the page
    AppDelegate* appDelegate = (((AppDelegate*) [UIApplication sharedApplication].delegate));
    PageViewController *pageVC = [(RootViewController*)[appDelegate.window rootViewController] pageViewController];
    [pageVC numberOfPagesChanged];
    [pageVC reloadCurrentPages];
    
    [[RegistrationManager sharedManager] upgradeStratPad:NO isStratBoardUpgraded:YES];
}

+(void)upgradeToPlusWithStratBoard
{
    // productId has already been updated in NSUserDefaults
    
    // have to reload the config, just in case we are on Toolkit page
    [[NavigationConfig sharedManager] buildNavigationFromStratFileOrNil:[StratFileManager sharedManager].currentStratFile];
    
    // reload pages without ads, need to reload the StratBoard page
    AppDelegate* appDelegate = (((AppDelegate*) [UIApplication sharedApplication].delegate));
    PageViewController *pageVC = [(RootViewController*)[appDelegate.window rootViewController] pageViewController];
    [pageVC numberOfPagesChanged];
    [pageVC reloadCurrentPages];
    
    // let the server know
    [[RegistrationManager sharedManager] upgradeStratPad:YES isStratBoardUpgraded:YES];

}

#pragma mark -

+(void)addOneReadWriteFile
{
    // add a new read-write file
    StratFile *stratFile = [[StratFileManager sharedManager] createManagedEmptyStratFile];
    stratFile.name = LocalizedString(@"EMPTY_STRATFILE_TITLE", nil);
    stratFile.companyName = LocalizedString(@"EMPTY_STRATFILE_COMPANY", nil);
    stratFile.permissions = @"0600";
        
    [DataManager saveManagedInstances];
}

@end
