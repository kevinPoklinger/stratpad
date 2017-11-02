//
//  MeetingAgendaViewController.m
//  StratPad
//
//  Created by Julian Wood on 9/15/11.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "MeetingAgendaViewController.h"
#import "MeetingAgendaReport.h"
#import "EventManager.h"
#import "UIColor-Expanded.h"
#import <QuartzCore/QuartzCore.h>

@implementation MeetingAgendaViewController
@synthesize webView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // show the yammer icon if we published something
        [[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(addYammerCommentsButton)
													 name:kEVENT_YAMMER_NEW_PUBLICATION
												   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [webView release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
            
    // get the UIWebView transparent
    webView.backgroundColor = [UIColor clearColor];
    webView.opaque = NO;
    
    NSString *imagePath = [[NSBundle mainBundle] resourcePath];
    imagePath = [imagePath stringByReplacingOccurrencesOfString:@"/" withString:@"//"];
    imagePath = [imagePath stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    NSURL *baseURL = [NSURL URLWithString: [NSString stringWithFormat:@"file:/%@//",imagePath]];
        
    MeetingAgendaReport *meetingAgendaReport = [[MeetingAgendaReport alloc] init];
    [webView loadHTMLString:[meetingAgendaReport html] baseURL:baseURL];
    [meetingAgendaReport release];
    
}

- (void)viewDidUnload
{
    [self setWebView:nil];
    [super viewDidUnload];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self addYammerCommentsButton];
    [super viewDidAppear:animated];
}

#pragma mark - Overrides

- (void)exportToPDF
{    
    MBReportView *reportView = [[MBReportView alloc] init];
    MeetingAgendaReport *meetingAgendaReport = [[MeetingAgendaReport alloc] init];
    reportView.printDelegate = meetingAgendaReport;
    [reportView drawPDFPagesWithOrientation:PageOrientationPortrait];
    [meetingAgendaReport release];
    [reportView release];
}

- (BOOL)isEnabled
{
    return [[[[StratFileManager sharedManager] currentStratFile] themes] count] > 0;
}

- (NSString*)messageWhenDisabled
{
    return LocalizedString(@"MSG_NO_THEMES", nil);
}

#pragma mark - Private

-(void)addYammerCommentsButton
{
    [self addYammerCommentsButtonToView:webView];
}

# pragma mark - Help Video

// @override
-(BOOL)hasVideo
{
    return [[[LocalizedManager sharedManager] localeIdentifier] hasPrefix:@"en"];
}

// @override
-(NSString*)helpVideoURL
{
    //return @"http://player.vimeo.com/external/70704178.m3u8?p=high,standard,mobile&s=83faf6ba89e7e6bf0198813f132de669";
    NSString* path = [[NSBundle mainBundle] pathForResource:@"SP iPad R8" ofType:@"mp4"];
    return path;
}


@end
