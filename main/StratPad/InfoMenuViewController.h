//
//  InfoMenuViewController.h
//  StratPad
//
//  Created by Julian Wood on 9/12/11.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuNavController.h"
#import "LMViewController.h"

@interface InfoMenuViewController : LMViewController<UIWebViewDelegate> {
    UIWebView *webView_;
}

@property(nonatomic,retain) IBOutlet UIWebView *webView;

@end
