//
//  HTMLViewController.m
//  StratPad
//
//  Created by Eric Rogers on July 27, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "HTMLViewController.h"
#import "EventManager.h"
#import "ApplicationSkin.h"
#import "EditionManager.h"
#import "CustomUpgradeViewController.h"
#import "RootViewController.h"

@implementation HTMLViewController

@synthesize webView = webView_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andHTMLFileName:(NSString*)filename
{   
    NSBundle *localBundle = [[LocalizedManager sharedManager]currentBundle];  
    
    NSFileManager *filemanager = [NSFileManager defaultManager];
    if(![filemanager fileExistsAtPath:[localBundle pathForResource:nibNameOrNil ofType:@"nib"]] || nibNameOrNil==nil)
        localBundle = [NSBundle mainBundle];
    self = [super initWithNibName:nibNameOrNil bundle:localBundle];
    if (self) {
        fileName_ = [filename copy];
    }
    return self;
}

- (void)dealloc
{
    self.webView.delegate = nil;
    [webView_ release];    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.webView.backgroundColor = [UIColor clearColor];

    // prevent the webview from bouncing/scrolling.
    disableScrolling(webView_);
    
    [self loadHTML]; 
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.webView.delegate = nil;
    self.webView = nil;
}


#pragma mark - Public

- (NSString*)fileName
{
    return fileName_;
}

#pragma mark - UIWebViewDelegate Methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL *url = [request URL];
    
    NSString *scheme = [url scheme];
    
    if ([scheme isEqualToString:@"onstrategy"]) {

        NSString *pageName = [url host];
        [EventManager fireJumpToOnStrategyPageWithPageName:pageName];
        return NO;
        
    } else if ([scheme isEqualToString:@"onstratpad"]) {
        
        NSString *pageName = [url host];
        [EventManager fireJumpToOnStratPadPageWithPageName:pageName];
        return NO;
        
    }
    else if ([scheme isEqualToString:@"toolkit"]) {
        NSString *pageName = [url host];
        [EventManager fireJumpToToolkitPageWithPageName:pageName];
/*
        // for free, we don't show the full toolkit
        if ([[EditionManager sharedManager] isFeatureEnabled:FeatureToolkit]) {
            NSString *pageName = [url host];
            [EventManager fireJumpToToolkitPageWithPageName:pageName];            
        } else {
            RootViewController *rootViewController = (RootViewController*)[[[UIApplication sharedApplication] keyWindow] rootViewController];
            CustomUpgradeViewController *upgradeVC = [[CustomUpgradeViewController alloc] init];
            [upgradeVC showPopoverInView:rootViewController.view];
            [upgradeVC release];
        }
        return NO;
*/                 
    }
 
    else {
 
        // Ensure that we only open file URL's inside the application.
        if (url.isFileURL) {
            return YES;
            
        } else {        
            [[UIApplication sharedApplication] openURL:url];    
            return NO;
        }
    }
}


#pragma mark - Protected

- (void)loadHTML
{    
    NSArray *components = [fileName_ componentsSeparatedByString:@"."];
    NSString *path = [[[LocalizedManager sharedManager] currentBundle] pathForResource:[components objectAtIndex:0]
                                                                                ofType:[components objectAtIndex:1]];
    if (!path) {
        path = [[NSBundle mainBundle] pathForResource:[components objectAtIndex:0] ofType:[components objectAtIndex:1]];
    }
    NSFileHandle *readHandle = [NSFileHandle fileHandleForReadingAtPath:path];
    
    NSString *htmlString = [[NSString alloc] initWithData: [readHandle readDataToEndOfFile]
                                                 encoding: NSUTF8StringEncoding];
        
    // override applicable font-family, font-size, and color properties that are set by stratpad.css
    // with those specified in the application skin.
    ApplicationSkin *skin = [ApplicationSkin currentSkin];
    NSString *skinStyleFormat = [NSString stringWithFormat:@"\
                                 <style type=\"text/css\">\
                                 html, body {font-family: %@; font-size: %@; color: %@;}\
                                 h1 {font-family: %@; font-size: %@; color: %@}\
                                 h2 {font-family: %@; font-size: %@; color: %@}\
                                 a { color: %@} \
                                 .important { color: %@} \
                                 </style>", 
                                 skin.section1BodyFontName, skin.section1BodyFontSize, skin.section1BodyFontColor,
                                 skin.section1TitleFontName, skin.section1TitleFontSize, skin.section1TitleFontColor,
                                 skin.section1SubtitleFontName, skin.section1SubtitleFontSize, skin.section1SubtitleFontColor,
                                 skin.section1BodyLinkFontColor,
                                 skin.section1BodyImportantFontColor
                                 ];
    
    // append skinning style element right before the end of the head element so we override stratpad.css styles.
    NSString *skinnedHtmlString = [htmlString stringByReplacingOccurrencesOfString:@"</head>" 
                                                                        withString:[NSString stringWithFormat:@"%@</head>", skinStyleFormat]];
    [htmlString release];
    
    NSString *imagePath = [[[LocalizedManager sharedManager] currentBundle] resourcePath];
    NSURL *baseURL = [NSURL fileURLWithPath:imagePath isDirectory:YES];
    TLog(@"baseURL: %@", baseURL);
    
    [webView_ loadHTMLString:skinnedHtmlString baseURL:baseURL];
}

-(BOOL)hasVideo
{
    return [[[LocalizedManager sharedManager] localeIdentifier] hasPrefix:@"en"] && self.chapter.chapterIndex == ChapterIndexWelcome && self.pageNumber == 0;
}

-(NSString*)helpVideoURL
{
    // there's only one reference video for now
    //return @"http://player.vimeo.com/external/70574881.m3u8?p=high,standard,mobile&s=a675740ff9a2f77e437ed0544582b8f5";
    NSString* path = [[NSBundle mainBundle] pathForResource:@"SP iPad Intro - i1.mov" ofType:@"mp4"];
    return path;
}

@end
