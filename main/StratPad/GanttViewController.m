//
//  GanttViewController.m
//  StratPad
//
//  Created by Eric Rogers on August 31, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "GanttViewController.h"
#import "NSDate-StratPad.h"
#import "GanttDataSource.h"
#import "GanttReport.h"
#import "StratFile.h"
#import "UIColor-Expanded.h"
#import "EventManager.h"

@interface GanttViewController (Private)
- (GanttDataSource*)createGanttDataSourceForStratFile:(StratFile*)stratFile;
@end

@implementation GanttViewController

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
    [scrollView_ release];
    [pdfView_ release];
    
    [super dealloc];
}


#pragma mark - View Lifecycle

- (void)viewDidLoad
{    
    StratFile *stratFile = [stratFileManager_ currentStratFile];
    
    GanttReport *screenDelegate = [[GanttReport alloc] initWithStratFile:stratFile];    
    pdfView_.screenDelegate = screenDelegate;
    [screenDelegate release];
    
    GanttReport *printDelegate = [[GanttReport alloc] initWithStratFile:stratFile];
    pdfView_.printDelegate = printDelegate;
    [printDelegate release];

    // adjust the height of the pdfView to adjust for the required height of the on-screen content.
    CGFloat viewHeight = [screenDelegate heightToDisplayContentForBounds:self.pdfView.bounds];
    self.pdfView.frame = CGRectMake(self.pdfView.frame.origin.x, self.pdfView.frame.origin.y, self.pdfView.frame.size.width, viewHeight);                

    // set the size of the content for the scroll view based on the size of the Gantt chart it contains.
    self.scrollView.contentSize = CGSizeMake(self.pdfView.frame.size.width, self.pdfView.frame.size.height);
    
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.scrollView = nil;
    self.pdfView = nil;
}

-(void)viewDidAppear:(BOOL)animated
{
    [self addYammerCommentsButton];
    [super viewDidAppear:animated];
}

# pragma mark - ContentViewController overrides

- (void)exportToPDF
{    
    [pdfView_ drawPDFPagesWithOrientation:PageOrientationLandscape];
}

- (BOOL)isEnabled
{
    return stratFileManager_.currentStratFile.themes.count > 0;
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
    //return @"http://player.vimeo.com/external/70704180.m3u8?p=high,standard,mobile&s=77182a7822ea1b48253ebaa5ff51c754";
    NSString* path = [[NSBundle mainBundle] pathForResource:@"SP iPad R6" ofType:@"mp4"];
    return path;
}


@end
