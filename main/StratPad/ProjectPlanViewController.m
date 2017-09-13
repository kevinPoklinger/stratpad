//
//  ProjectPlanViewController.m
//  StratPad
//
//  Created by Julian Wood on 9/13/11.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "ProjectPlanViewController.h"
#import "ProjectPlanReport.h"
#import "StratFileManager.h"
#import "UIColor-Expanded.h"
#import "EventManager.h"

@implementation ProjectPlanViewController

@synthesize scrollView = scrollView_;
@synthesize pdfView = pdfView_;


#pragma mark - Memory Management

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
    [pdfView_ release];
    [scrollView_ release];
    
    [super dealloc];
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    ProjectPlanReport *screenDelegate = [[ProjectPlanReport alloc] init];
    pdfView_.screenDelegate = screenDelegate;
    [screenDelegate release];
    
    ProjectPlanReport *printDelegate = [[ProjectPlanReport alloc] init];    
    pdfView_.printDelegate = printDelegate;
    [printDelegate release];
    
    // adjust the height of the pdfView to adjust for the required height of the on-screen content.
    CGFloat viewHeight = [screenDelegate heightToDisplayContentForBounds:self.pdfView.bounds];
    self.pdfView.frame = CGRectMake(self.pdfView.frame.origin.x, self.pdfView.frame.origin.y, self.pdfView.frame.size.width, viewHeight);                
    
    // set the size of the content for the scroll view based on the size of the Gantt chart it contains.
    self.scrollView.contentSize = CGSizeMake(self.pdfView.frame.size.width, self.pdfView.frame.size.height);
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    [pdfView_ release], pdfView_ = nil;
    [scrollView_ release], scrollView_ = nil;
}

-(void)viewDidAppear:(BOOL)animated
{
    [self addYammerCommentsButton];
    [super viewDidAppear:animated];
}


#pragma mark - Public

// an override
- (void)exportToPDF
{    
    [pdfView_ drawPDFPagesWithOrientation:PageOrientationPortrait];
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
    [self addYammerCommentsButtonToView:pdfView_];
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
    //return @"http://player.vimeo.com/external/70704179.m3u8?p=high,standard,mobile&s=7e31ef9b7b5fcbcdbf371a9cc3866f74";
    NSString* path = [[NSBundle mainBundle] pathForResource:@"SP iPad R7" ofType:@"mp4"];
    return path;
}


@end
