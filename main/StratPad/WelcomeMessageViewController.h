//
//  WelcomeMessageViewController.h
//  StratPad
//
//  Created by Julian Wood on 12-05-30.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//
//  Shows a welcome message once, after an application version upgrade only.
//  Version-specific.

#import <UIKit/UIKit.h>

@interface WelcomeMessageViewController : UIViewController<UIPopoverControllerDelegate,UIWebViewDelegate> {
@private
    UIPopoverController *popoverController_;
    CGSize originalViewSize_;
}

@property (retain, nonatomic) IBOutlet UIWebView *webView;

-(void)showWelcomeMessageInView:(UIView*)view;
+(void)markWelcomeAsShown;

@end
