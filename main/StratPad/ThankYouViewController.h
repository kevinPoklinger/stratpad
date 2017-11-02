//
//  ThankYouViewController.h
//  StratPad
//
//  Created by Julian Wood on 2012-10-17.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//
//  Shown when the user successfully validates their registration, from a link in an email.

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "LMViewController.h"

@interface ThankYouViewController : LMViewController<MFMailComposeViewControllerDelegate, UIWebViewDelegate>

@end
