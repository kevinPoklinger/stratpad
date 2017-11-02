//
//  YammerResultViewController.h
//  StratPad
//
//  Created by Julian Wood on 12-07-12.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YammerResultViewController : UIViewController<UIWebViewDelegate> {
    NSString *author_;
    NSString *thumbURL_;
    NSString *title_;
    NSString *meta_;
    NSString *description_;
    NSString *yammerURL_;
    NSString *errorString_;
}

@property (retain, nonatomic) IBOutlet UIWebView *webView;
@property (retain, nonatomic) IBOutlet UIButton *btnDone;

- (id)initWithResponseString:(NSString*)responseString andError:(NSError**)error;
- (IBAction)done;

@end
