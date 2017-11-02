//
//  SideBarViewController.m
//  StratPad
//
//  Created by Eric Rogers on July 26, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "SideBarViewController.h"
#import "NavigationConfig.h"
#import "EventManager.h"
#import "UIColor-Expanded.h"
#import <QuartzCore/QuartzCore.h>
#import "SideBarButton.h"
#import "SkinManager.h"
#import "YammerCommentManager.h"

@interface SideBarViewController ()
- (void) addChapterLabelsAndButtons:(NSString*)section range:(NSRange)range;
- (void)stratFileLoaded:(NSNotification*)notification;
- (void)showSelectedChapter:(NSUInteger)chapterIndex;
- (NSUInteger)indexForSelectedChapter;
- (SideBarButton*)buttonAtChapterIndex:(NSUInteger)chapterIndex;

@end


@implementation SideBarViewController

@synthesize scrollView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        
		// Note: Register here, since we only want to register this view controller once per lifecycle.
        [[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(stratFileLoaded:)
													 name:kEVENT_STRATFILE_LOADED
												   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(chapterWillChange:)
													 name:kEVENT_CHAPTER_WILL_CHANGE
												   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(reportViewDidDraw:)
													 name:kEVENT_REPORT_VIEW_DID_DRAW
												   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(updateYammerCommentCounts:)
													 name:kEVENT_YAMMER_COMMENTS_UPDATED
												   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(showNewYammerPublication:)
													 name:kEVENT_YAMMER_NEW_PUBLICATION
												   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(showYammerPublications)
													 name:kEVENT_YAMMER_LOGGED_IN
												   object:nil];


    }
    return self;
}


#pragma mark - Memory Management

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [scrollView release];
    [super dealloc];
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    SkinManager *skinMan = [SkinManager sharedManager];
    
    // place the background image in the scrollview
    NSString *sidebarBackgroundImageName = [skinMan stringForProperty:kSkinSidebarBackgroundImage forMediaType:MediaTypeScreen];
    UIImage *imgSidebarBackground = [UIImage imageNamed:sidebarBackgroundImageName];
    UIImageView *imgViewSidebarBackground = [[UIImageView alloc] initWithImage:imgSidebarBackground];
    imgViewSidebarBackground.frame = CGRectMake(0, 0, imgSidebarBackground.size.width, imgSidebarBackground.size.height);
    scrollView.contentSize = CGSizeMake(imgSidebarBackground.size.width, imgSidebarBackground.size.height);
    scrollView.clipsToBounds = NO;
    [scrollView addSubview:imgViewSidebarBackground];
    [imgViewSidebarBackground release];
    
    // labels and buttons
    [self addChapterLabelsAndButtons:@"i" range:NSMakeRange(0, 4)];
    [self addChapterLabelsAndButtons:@"ii" range:NSMakeRange(4, 8)];
    [self addChapterLabelsAndButtons:@"iii" range:NSMakeRange(12, 11)];
    [self addChapterLabelsAndButtons:@"iv" range:NSMakeRange(23, 1)];
    
    loadingChapterIndex_ = -1;
    self.view.clipsToBounds = YES;
}

// so for instance we can add 4 buttons to section i if the range is 0,4
- (void) addChapterLabelsAndButtons:(NSString*)section range:(NSRange)range
{
    CGFloat sectionSpacer = [section isEqualToString:@"i"] ? 0 : [section isEqualToString:@"ii"] ? 10.5 : [section isEqualToString:@"iii"] ? 21.5 : 35;
    CGFloat margintop = 4, spacerY = 4, marginleft = 21, fontSize = 10;
            
    // use the size of the 1x image in our calculations
    CGSize imgSize = CGSizeMake(96.f, 48.f);
    for (int i=range.location; i<range.location+range.length; ++i) {
        // note that this chapter will actually change once the stratfile finishes loading; we check for chapter equality via identity in NavConfig
        Chapter *chapter = [[NavigationConfig sharedManager].chapters objectAtIndex:i];
        
        CGFloat offsetY = margintop + (i*(imgSize.height + spacerY)) + sectionSpacer;
        
        // chapter label
        CGRect f = CGRectMake(0, offsetY + imgSize.height/2 - (fontSize+2)/2, 19, (fontSize+2));
        UILabel *lbl = [[UILabel alloc] initWithFrame:f];
        lbl.backgroundColor = [UIColor clearColor];
        lbl.textAlignment = UITextAlignmentCenter;
        lbl.text = chapter.chapterNumber;
        lbl.font = [UIFont fontWithName:@"Helvetica" size:fontSize];
        lbl.textColor = [UIColor whiteColor];
        [scrollView addSubview:lbl];
        
        // the sidebar button
        CGRect rect = CGRectMake(marginleft, offsetY, imgSize.width, imgSize.height);
        SideBarButton *sideBarButton = [[SideBarButton alloc] initWithFrame:rect
                                                                      title:chapter.title
                                                               chapterNumberLabel:lbl
                                                               chapterIndex:i
                                                                    section:section];
        [sideBarButton addTarget:self
                          action:@selector(selectChapter:) 
                forControlEvents:UIControlEventTouchUpInside];
        [scrollView addSubview:sideBarButton];
        [sideBarButton release];
        [lbl release];        
    }    
}

- (void)viewDidUnload
{
    [self setScrollView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}


// attached to SideBarButton
-(IBAction)selectChapter:(SideBarButton*)sideBarButton
{    
    // update sidebar UI
    [self showSelectedChapter:sideBarButton.chapterIndex];
    
    // restore the cell that was previously loading
    if (loadingChapterIndex_ != -1) {
        Chapter *chapter = [[NavigationConfig sharedManager].chapters objectAtIndex:loadingChapterIndex_];
        if ([chapter isReport]) {            
            // reset btn title and remove activity indicator
            SideBarButton *btn = [self buttonAtChapterIndex:loadingChapterIndex_];
            [btn setTitle:chapter.title forState:UIControlStateNormal];
            [[btn.subviews lastObject] removeFromSuperview];
            
            loadingChapterIndex_ = -1;

        }
        loadingChapterIndex_ = -1;
    }
    
    // add activity (loading) indicator to sidebar button
    // only the MBPDFView sends loadFinished events (kEVENT_REPORT_VIEW_DID_DRAW), so restrict it to reports for now
    Chapter *chapter = [[NavigationConfig sharedManager].chapters objectAtIndex:sideBarButton.chapterIndex];
    if ([chapter isReport]) {
        // store this chapter index so we can turn it off later
        loadingChapterIndex_ = sideBarButton.chapterIndex;
        
        // blank out text so we can see activity indicator
        [sideBarButton setTitle:@"" forState:UIControlStateNormal];
        
        // add an activity indicator to the cell
        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        CGRect f = sideBarButton.frame;
        activityView.frame = CGRectMake(f.size.width/2-activityView.frame.size.width/2, f.size.height/2-activityView.frame.size.height/2, activityView.frame.size.width, activityView.frame.size.height);
        [sideBarButton addSubview:activityView];
        [activityView startAnimating];
        [activityView release];    
    }
    
    // send the ChapterWillChange event (this actually changes the content view)
    // allows us to update the activity indicator first (by using perform...)
    [self performSelector:@selector(changeChapter:) withObject:chapter afterDelay:0.0];    
}


#pragma mark - Support

- (void)changeChapter:(Chapter*)chapter
{
    [EventManager fireChapterWillChangeEventWithChapter:chapter fromSource:self];    
}

- (void)showSelectedChapter:(NSUInteger)chapterIndex
{
    // turn every chapter on or off
    for (UIView *subview in [scrollView subviews]) {
        if ([subview isKindOfClass:[SideBarButton class]]) {
            if ([(SideBarButton*)subview chapterIndex] == chapterIndex) {
                [(SideBarButton*)subview setSelected:YES];
                [scrollView scrollRectToVisible:subview.frame animated:YES];
            } else {
                [(SideBarButton*)subview setSelected:NO];
            }
            
        }
    }        
}

- (NSUInteger)indexForSelectedChapter
{
    uint ct = 0;
    for (UIView *subview in [scrollView subviews]) {
        if ([subview isKindOfClass:[SideBarButton class]]) {
            if ([(SideBarButton*)subview isSelected]) {
                return ct;
            }
            ct++;
        }
    }            
    return -1;
}

- (SideBarButton*)buttonAtChapterIndex:(NSUInteger)chapterIndex
{
    for (UIView *subview in [scrollView subviews]) {
        if ([subview isKindOfClass:[SideBarButton class]] && [(SideBarButton*)subview chapterIndex] == chapterIndex) {
            return (SideBarButton*)subview;
        }
    }          
    ELog(@"Can't find button in sidebar with chapterIndex: %i", chapterIndex);
    return nil;
}

#pragma mark - NSNotification Handlers

- (void)chapterWillChange:(NSNotification*)notification
{
    // only handle chapter changed events not generated by ourself.
    if (notification.object != self) {
        Chapter *chapter = [notification.userInfo objectForKey:kEVENT_PARAM_CHAPTER];
        NSUInteger chapterIndex = [[NavigationConfig sharedManager].chapters indexOfObject:chapter];
        [self showSelectedChapter:chapterIndex];
    } else {
        // turn off the chapter loading
        if (loadingChapterIndex_ != -1) {
            
            // reset btn title and remove activity indicator
            SideBarButton *btn = [self buttonAtChapterIndex:loadingChapterIndex_];
            Chapter *chapter = [[NavigationConfig sharedManager].chapters objectAtIndex:loadingChapterIndex_];
            [btn setTitle:chapter.title forState:UIControlStateNormal];
            [[btn.subviews lastObject] removeFromSuperview];
            
            loadingChapterIndex_ = -1;
        }
    }
}

- (void)reportViewDidDraw:(NSNotification*)notification
{
    // sent by MBPDFView, when finished with drawRect:
    // just want to get rid of the loading view
    if (loadingChapterIndex_ != -1) {
        
        // reset btn title and remove activity indicator
        SideBarButton *btn = [self buttonAtChapterIndex:loadingChapterIndex_];
        Chapter *chapter = [[NavigationConfig sharedManager].chapters objectAtIndex:loadingChapterIndex_];
        [btn setTitle:chapter.title forState:UIControlStateNormal];
        [[btn.subviews lastObject] removeFromSuperview];
        
        loadingChapterIndex_ = -1;
    }
}

- (void)stratFileLoaded:(NSNotification*)notification
{
    ChapterIndex idx = [[[notification userInfo] objectForKey:kEVENT_PARAM_STRATFILE_CHAPTER_INDEX] intValue];
    if (idx != ChapterIndexNone) {
        [self showSelectedChapter:idx];
    }
    // otherwise stay on the same chapter
    
    // refresh all sidebarbuttons with pub status
    [self showYammerPublications];
    
    // update comments
    [[YammerCommentManager sharedManager] updateCommentCounts];    
}

-(void)updateYammerCommentCounts:(NSNotification*)notification
{
    StratFile *stratFile = [[StratFileManager sharedManager] currentStratFile];
    
    // find the correct btn
    SideBarButton *btn;
    for (UIView *subview in [scrollView subviews]) {
        if ([subview isKindOfClass:[SideBarButton class]]) {
            btn = (SideBarButton*)subview;            
            NSUInteger ct = [[YammerCommentManager sharedManager] unreadMessageCountForChapterNumber:btn.chapterNumberLabel.text stratFile:stratFile];
            [btn showBadge:ct];
        }
    }
}

-(void)showNewYammerPublication:(NSNotification*)notification
{
    YammerPublishedReport *yamReport = [notification.userInfo objectForKey:@"yammerReport"];
    
    // check to make sure we haven't changed stratfiles
    StratFile *currentStratFile = [[StratFileManager sharedManager] currentStratFile];
    StratFile *pubStratFile = yamReport.stratFile;
    if (currentStratFile != pubStratFile) {
        return;
    }
    
    // find the correct btn
    SideBarButton *btn;
    for (UIView *subview in [scrollView subviews]) {
        if ([subview isKindOfClass:[SideBarButton class]]) {
            btn = (SideBarButton*)subview;
            if ([btn.chapterNumberLabel.text isEqualToString:yamReport.chapterNumber]) {
                [btn showYammerPublicationStatus: YES];
            }
        }
    }

}

#pragma mark - override

- (void)reloadLocalizableResources
{
    // the title comes from pages.plist, which holds keys to the title in Localizable.strings and is placed in a Chapter at construction time (in [NavigationConfig buildBaseNavigationFromPlist])
    // we need to get those titles to update to new language
    
//    [[NavigationConfig sharedManager] buildBaseNavigationFromPlist];
//    for (UIView *subview in scrollView.subviews) {
//        if ([subview isKindOfClass:[SideBarButton class]]) {
//            SideBarButton *btn = (SideBarButton*)subview;
//            Chapter *chapter = [[NavigationConfig sharedManager].chapters objectAtIndex:btn.chapterIndex];
//            [(SideBarButton*)subview setTitle:chapter.title forState:UIControlStateNormal];
//        }
//    }    
    
}

#pragma mark - Private

-(void)showYammerPublications
{
    StratFile *stratfile = [[StratFileManager sharedManager] currentStratFile];
    for (UIView *subview in [scrollView subviews]) {
        if ([subview isKindOfClass:[SideBarButton class]]) {
            SideBarButton *btn = (SideBarButton*)subview;
            BOOL isPublished = [stratfile isChapterPublishedToYammer:btn.chapterNumberLabel.text];
            [btn showYammerPublicationStatus:isPublished];
        }
    }
}


@end
