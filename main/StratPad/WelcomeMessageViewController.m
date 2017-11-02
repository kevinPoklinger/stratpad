//
//  WelcomeMessageViewController.m
//  StratPad
//
//  Created by Julian Wood on 12-05-30.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "WelcomeMessageViewController.h"
#import "EditionManager.h"
#import "NSUserDefaults+StratPad.h"

@interface WelcomeMessageViewController ()

@end

@implementation WelcomeMessageViewController
@synthesize webView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    disableScrolling(self.webView);
    originalViewSize_ = self.view.bounds.size;
    webView.delegate = self;
    
    [self loadHTML];
}

- (void)viewDidUnload
{
    [self setWebView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)dealloc {
    [self dismissPopover];
    [webView release];
    [super dealloc];
}

#pragma mark - Public

-(void)showWelcomeMessageInView:(UIView*)view
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *versionNumber = [[EditionManager sharedManager] versionNumber];
    BOOL hasShownWelcome = [userDefaults boolForKey:[NSString stringWithFormat:keyHasShownWelcomeFormat, versionNumber]];
        
    if (!hasShownWelcome) {
        [self performSelector:@selector(showPopoverInView:) withObject:view afterDelay:1.f];
    }
}

+(void)markWelcomeAsShown
{
    // update userdefaults
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *versionNumber = [[EditionManager sharedManager] versionNumber];    
    [userDefaults setBool:YES forKey:[NSString stringWithFormat:keyHasShownWelcomeFormat, versionNumber]];
    [userDefaults synchronize];
}

#pragma mark - UIPopoverControllerDelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    [WelcomeMessageViewController markWelcomeAsShown];
}


#pragma mark - Private

- (void)loadHTML
{    
    NSString *versionNumber = [[[EditionManager sharedManager] versionNumber] stringByReplacingOccurrencesOfString:@"." withString:@"_"];
    NSString *filename = [NSString stringWithFormat:@"welcome-%@", versionNumber];
    NSString *path = [[[LocalizedManager sharedManager] currentBundle] pathForResource:filename ofType:@"html"];
    if (path) {
        NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
        [webView loadRequest:[NSURLRequest requestWithURL:url]];
        [url release];        
    } else {
        WLog(@"No welcome message for: %@", filename);
        [WelcomeMessageViewController markWelcomeAsShown];
    }
}

- (void)showPopoverInView:(UIView*)view
{		    
    if (popoverController_) {
        [popoverController_ release]; popoverController_ = nil;		
    }
    
    popoverController_ = [[UIPopoverController alloc] initWithContentViewController:self];
    popoverController_.delegate = self;
    popoverController_.popoverContentSize = originalViewSize_;
    [popoverController_ presentPopoverFromRect:view.bounds
                                        inView:view
                      permittedArrowDirections:0 // no arrows
                                      animated:YES];	
}


- (void)dismissPopover
{
    [popoverController_ dismissPopoverAnimated:YES];
	[popoverController_ release];
	popoverController_ = nil;
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([[request.URL scheme] hasPrefix:@"file"]) {
        return YES;
    } else {
        [[UIApplication sharedApplication] openURL:request.URL];
        return NO;
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    ELog(@"err: %@", error);
}





@end
