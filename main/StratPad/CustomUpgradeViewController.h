//
//  CustomUpgradeViewController.h
//  StratPad
//
//  Created by Julian Wood on 12-01-02.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomUpgradeViewController : UIViewController<UIPopoverControllerDelegate> {
    UIPopoverController *popoverController_;
}

- (void)showPopoverInView:(UIView*)view;
- (void)dismissPopover;

@end
