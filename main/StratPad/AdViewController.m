//
//  AdViewController.m
//  StratPad
//
//  Created by Julian Wood on 12-01-04.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//
//  Show the ad (registers an impression)
//  Clicking the ad will register a click through and open in Mobile Safari (otherwise we have to do forward/back nav or some reloading thing)

//  Check Chapter.m for where we insert ads into a StratFile's pages
//  Then it jsut uses the regular html page vc mechanism


#import "AdViewController.h"
#import "RootViewController.h"
#import "AdPage.h"
#import "Tracking.h"
#import "CustomUpgradeViewController.h"

@interface AdViewController (Private)
- (AdPage*)adPage;
@end

@implementation AdViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    AdPage *adPage = [self adPage];
    
    // allows us to click anywhere on the page to invoke the URL
    [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.addEventListener('click', function(){document.location='%@';},false);", adPage.url]];
    
    [Tracking logEvent:kTrackingEventAdImpression withParameters:[NSDictionary dictionaryWithObject:adPage.client forKey:@"client"]];
}

#pragma mark - UIWebViewDelegate Methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *scheme = request.URL.scheme;
    
    if ([scheme hasPrefix:@"http"]) {
        // track ad click thru
        AdPage *adPage = [self adPage];
        [Tracking logEvent:kTrackingEventAdClick withParameters:[NSDictionary dictionaryWithObject:adPage.client forKey:@"client"]];
        
    } else if ([scheme isEqualToString:@"upgrade"]) {
        // track upgrade event
        AdPage *adPage = [self adPage];
        [Tracking logEvent:kTrackingEventAdClick withParameters:[NSDictionary dictionaryWithObject:adPage.client forKey:@"client"]];
        
        // show custom upgrade screen
        RootViewController *rootViewController = (RootViewController*)[[[[UIApplication sharedApplication] delegate] window] rootViewController];
        CustomUpgradeViewController *upgradeVC = [[CustomUpgradeViewController alloc] init];
        [upgradeVC showPopoverInView:rootViewController.view];
        [upgradeVC release];

        return NO;
    }
    // else probably the file scheme used to load the actual ad page itself
    
    // the js handler will take care of sending us to the designated http URL, through the super impl here
    return [super webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
}

- (AdPage*)adPage
{
    RootViewController *rootViewController = (RootViewController*)[[[UIApplication sharedApplication] keyWindow] rootViewController];
    
    return (AdPage*)rootViewController.pageViewController.currentPage;
}

@end
