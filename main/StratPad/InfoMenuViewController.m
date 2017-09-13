//
//  InfoMenuViewController.m
//  StratPad
//
//  Created by Julian Wood on 9/12/11.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "InfoMenuViewController.h"
#import "EditionManager.h"
#import "NSUserDefaults+StratPad.h"
#import "UAKeychainUtils+StratPad.h"

@interface InfoMenuViewController (Private)
- (void)updateVersionAndProductName;
@end

@implementation InfoMenuViewController

@synthesize webView = webView_;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [webView_ release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // if keyboard comes up, enable scrolling
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(willShowKeyboard:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(willHideKeyboard:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
        
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = [NSString stringWithFormat:LocalizedString(@"MENU_INFO_TITLE", nil), [[EditionManager sharedManager] productDisplayName]];

    [self reloadLocalizableResources];
}

- (void)loadHTML
{
    NSString *path = [[[LocalizedManager sharedManager] currentBundle] pathForResource:@"Info" ofType:@"html"];
    NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    [url release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [webView_ release], webView_ = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    // make sure the productName gets updated, since we might have this view cached after an IAP
    [self updateVersionAndProductName];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    DLog(@"request: %@", request.URL);
    
    if ([[request.URL scheme] hasPrefix:@"file"]) {
        return YES;
    } else {
        [[UIApplication sharedApplication] openURL:request.URL];
        return NO;
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self updateVersionAndProductName];
}

- (void)updateVersionAndProductName
{
    NSDictionary *plistData = [[NSBundle mainBundle] infoDictionary];
    NSString *version = [plistData objectForKey:@"CFBundleShortVersionString"];
    NSString *build = [plistData objectForKey:@"CFBundleVersion"];
    
    NSString *versionString = [NSString stringWithFormat:@"Version %@, Build %@.", version, build];
    NSString *productName = [[EditionManager sharedManager] productDisplayName];
    NSString *appStoreURL = [[EditionManager sharedManager] appStoreURL];
    
    [webView_ stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementById('versionString').innerHTML='%@'", versionString]];
    [webView_ stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementById('productName').innerHTML='%@'", productName]];    
    [webView_ stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementById('appStoreURL').href='%@'", appStoreURL]];
    
    BOOL isVerified = [[UAKeychainUtils valueForKey:keyChainVerified] boolValue];
    if (isVerified) {
        [webView_ stringByEvaluatingJavaScriptFromString:@"document.getElementById('pleaseRegister').style.display='none'"];
    } else {
        [webView_ stringByEvaluatingJavaScriptFromString:@"document.getElementById('forums').style.display='none'"];
    }
}

#pragma mark Notifications

- (void)willShowKeyboard:(NSNotification*)notification
{
    [[[self.webView subviews] lastObject] setScrollEnabled:YES];
}

- (void)willHideKeyboard:(NSNotification*)notification
{
    // non-english content tends to be larger
    if ([[[LocalizedManager sharedManager] localeIdentifier] isEqualToString:@"en"]) {
        disableScrolling(self.webView);
    }
}

#pragma mark - Override

-(void)reloadLocalizableResources
{
    // call to super not necessary
    [self loadHTML];
    
    // non-english content tends to be larger
    if ([[[LocalizedManager sharedManager] localeIdentifier] isEqualToString:@"en"]) {
        disableScrolling(self.webView);
    } else {
        [[[self.webView subviews] lastObject] setScrollEnabled:YES];
        [[[self.webView subviews] lastObject] flashScrollIndicators];
    }
}

@end
