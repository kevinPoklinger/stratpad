//
//  RegisterOrSkipViewController.h
//  StratPad
//
//  Created by Julian Wood on 12-08-22.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//
//  This VC is shown the first time we launch the app, and then it is shown up to 3x more.

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "LMViewController.h"
#import "RegistrationManager.h"

@class MBLoadingView;

@interface RegisterOrSkipViewController : LMViewController<UITextFieldDelegate,UIPopoverControllerDelegate,MFMailComposeViewControllerDelegate,UIWebViewDelegate> {
    @private
    UIPopoverController *popoverController_;
}


@property (nonatomic) MBLoadingView* loadingView;

- (void)showPopoverInView:(UIView*)view;
- (void)dismissPopover;

@end
