//
//  RegistrationViewController.h
//  StratPad
//
//  Created by Julian Wood on 12-08-22.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//
//  This VC is shown from the Settings menu as a thank you.
//  It's also shown as a form for registering.

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "LMViewController.h"

@interface RegistrationViewController : LMViewController<UITextFieldDelegate,MFMailComposeViewControllerDelegate> {
    CGSize viewInfoSize_;
}

@end
