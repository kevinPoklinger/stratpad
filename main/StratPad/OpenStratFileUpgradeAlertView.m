//
//  OpenStratFileUpgradeAlertView.m
//  StratPad
//
//  Created by Julian Wood on 12-01-12.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "OpenStratFileUpgradeAlertView.h"
#import "RootViewController.h"
#import "CustomUpgradeViewController.h"
#import "AppDelegate.h"

@implementation OpenStratFileUpgradeAlertView

- (void)show
{
    [self retain];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:LocalizedString(@"UPGRADE_REQUIRED_TITLE", nil)
                                                        message:LocalizedString(@"UPGRADE_REQUIRED_MESSAGE", nil)
                                                       delegate:self
                                              cancelButtonTitle:LocalizedString(@"CANCEL", nil)
                                              otherButtonTitles:LocalizedString(@"OK", nil), nil];
    [alertView show];
    [alertView release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        // ok - invoke custom upgrade vc
        RootViewController *rootViewController = (RootViewController*)[[[[UIApplication sharedApplication] delegate] window] rootViewController];
        CustomUpgradeViewController *upgradeVC = [[CustomUpgradeViewController alloc] init];
        [upgradeVC showPopoverInView:rootViewController.view];
        [upgradeVC release];
    }
    [self release];
}



@end
