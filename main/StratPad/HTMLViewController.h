//
//  HTMLViewController.h
//  StratPad
//
//  Created by Eric Rogers on July 27, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//
//  The baseURL is always the directory, with a trailing slash, containing the html file.
//  All html files are localized, and thus in a .lproj folder.
//  Some images are localized, and thus in the same folder.
//  Non-localized images are in the parent folder.
//  Non-localized css is in the parent folder.

#import "ContentViewController.h"

@interface HTMLViewController : ContentViewController<UIWebViewDelegate> {
 @private
    NSString *fileName_;    
    UIWebView *webView_;
}

@property (nonatomic, retain) IBOutlet UIWebView *webView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andHTMLFileName:(NSString*)filename;

- (NSString*)fileName;

@end

@interface HTMLViewController (Protected)
- (void)loadHTML;
@end

