//
//  PageViewController.m
//  StratPad
//
//  Created by Eric Rogers on July 28, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "PageViewController.h"
#import "EventManager.h"
#import <QuartzCore/QuartzCore.h>
#import "DesignedByButton.h"
#import "ApplicationSkin.h"

@interface PageViewController (Private) 

- (void)stratFileLoaded:(NSNotification*)notification;

// a new stratfile is about to load, so cleanup
- (void)stratFileWillLoad:(NSNotification*)notification;

- (NSUInteger)indexOfPreviousPage;
- (NSUInteger)indexOfNextPage;

- (Chapter*)previousChapter;
- (Chapter*)nextChapter;

- (void)chapterChangeHandler:(NSNotification*)notification;
- (void)chapterChanged:(Chapter*)chapter;
- (void)loadChapter:(Chapter*)chapter;

// viewWill/DidAppear viewWill/DidDisappear events
- (void)viewWasPagedIn:(UIView*)view;
- (void)viewWasPagedOut:(UIView*)view;

- (UIView*)viewForPreviousPage;
- (UIView*)viewForCurrentPage;
- (UIView*)viewForNextPage;

- (ContentViewController*)controllerForIndex:(NSUInteger)index;

- (void)removeAllPages;
@end

@implementation PageViewController

@synthesize pagerView = pagerView_;
@synthesize pageControl = pageControl_;
@synthesize pageNumber = pageNumber_;

/*
-(BOOL)automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers {
    // in iOS >= 5, if you add a view which is under control of another VC, that VC will get its own viewWill/DidAppear events, automatically
    // in iOS 4.x, you need to invoke viewWill/DidAppear manually
    // this method impl will suppress the iOS5 behaviour
    // the biggest problem with it is that because of our caching and adding of the nearest neighbours to the scrollview (in CyclicPagerView), viewWill/DidAppear is invoked before the view is actually on screen, when navigating via swipe (but is not a problem when navigating via sidebar touch)
    // see http://stackoverflow.com/questions/7830830/ios-different-addsubview-behavior-between-ios-4-3-and-5-0
    // moral of the story - we are using iOS4 behaviour everywhere, so always invoke viewWill/DidAppear manually
    return NO;
}
*/

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        
        navManager_ = [NavigationConfig sharedManager];
        controllerCache_ = [[ContentControllerCache alloc] init];
        
		// Note: Register here, since we only want to register this view controller once per lifecycle.
        [[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(stratFileWillLoad:)
													 name:kEVENT_STRATFILE_WILL_LOAD
												   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(stratFileLoaded:)
													 name:kEVENT_STRATFILE_LOADED
												   object:nil];

		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(chapterChangeHandler:)
													 name:kEVENT_CHAPTER_WILL_CHANGE
												   object:nil];		
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [pagerView_ release];
    [pageControl_ release];    
    [controllerCache_ release];
    
    [super dealloc];
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    ApplicationSkin *skin = [ApplicationSkin currentSkin];
    [((UIImageView*)self.view) setImage:[UIImage imageNamed:skin.canvasImage]];
    
    DesignedByButton *btnDesignedBy = [[DesignedByButton alloc] initWithFrame:CGRectZero];
    CGSize preferredSize = [btnDesignedBy sizeThatFits:CGSizeZero];
    CGRect b = self.view.bounds;
    CGFloat marginRight = 10;
    btnDesignedBy.frame = CGRectMake(b.origin.x + b.size.width - preferredSize.width - marginRight,
                                     b.origin.y + b.size.height - preferredSize.height,
                                     preferredSize.width, preferredSize.height);
    [btnDesignedBy addTarget:self action:@selector(goGlasseyStrategy:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnDesignedBy];
    [btnDesignedBy release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.pagerView = nil;
    self.pageControl = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}


#pragma mark - Public

- (Page*)currentPage
{
    return [navManager_ pageAtIndex:pageIndex_];
}

- (Chapter*)currentChapter
{
    return [navManager_.chapters objectAtIndex:chapterIndex_];
}

- (void)reloadCurrentPages
{    
    [self removeAllPages];

    // flush the cache since we are reloading all the current pages.
    [controllerCache_ flush];
    
    // draw the current page last, so that the activity viewer disappears at the same time as the view appears
    [pagerView_ insertView:[self viewForNextPage] atIndex:2];
    [pagerView_ insertView:[self viewForPreviousPage] atIndex:0];
    
    UIView *pagedInView = [self viewForCurrentPage];
    [pagerView_ insertView:pagedInView atIndex:1];
    [self viewWasPagedIn:pagedInView];
}

- (void)reloadNextAndPreviousPages
{
    UIView *next = [[pagerView_ subviews] objectAtIndex:2];
    // was used to fire events, but this is not the right time since the view was not visible
    //    [self viewWillBeRemoved:next];
    [next removeFromSuperview];
    
    UIView *previous = [[pagerView_ subviews] objectAtIndex:0]; 
//    [self viewWillBeRemoved:previous];
    [previous removeFromSuperview];

    // remove the next and previous controllers from the cache since 
    // we want to reload them from scratch.
    [controllerCache_ removeControllerForPageIndex:[self indexOfPreviousPage]];
    [controllerCache_ removeControllerForPageIndex:[self indexOfNextPage]];
    
    [pagerView_ insertView:[self viewForPreviousPage] atIndex:0];    
    [pagerView_ insertView:[self viewForNextPage] atIndex:2];        
}

- (void)displayActivityPageAtIndex:(NSUInteger)index
{
    int change = index - pageIndex_;
    pageNumber_ = pageNumber_ + change;        
    self.pageControl.currentPage = pageNumber_;
    
    pageIndex_ = index;
    [self reloadCurrentPages];
}

- (void)loadPage:(Page*)page inChapter:(Chapter*)chapter
{
    chapterIndex_ = [navManager_.chapters indexOfObject:chapter];
    
    // calculate the index of the page relative to all pages.
    pageIndex_ = [navManager_ indexOfPage:page];
    
    self.pageControl.numberOfPages = [chapter.pages count];
    
    // update the page control
    for (uint i = 0; i < chapter.pages.count; i++) {
        if ([chapter.pages objectAtIndex:i] == page) {
            self.pageControl.currentPage = i;                    
        }
    }
    
    pageNumber_ = self.pageControl.currentPage;

    // remove all the pages in the pager view.
    [self removeAllPages];
    
    // remove those controllers in the cache that do not match the next, current, or previous index.
    // we don't want to completely flush the cache since there may be view controllers that are 
    // still applicable to the page and chapter being loaded.
    [controllerCache_ removeControllersNotMatchingPageIndexes:[NSArray arrayWithObjects:
                                                               [NSNumber numberWithInt:[self indexOfPreviousPage]],
                                                               [NSNumber numberWithInt:pageIndex_],
                                                               [NSNumber numberWithInt:[self indexOfNextPage]],                                                               
                                                               nil]];

    
    // insert the current page last, so that the activity viewer disappears at the same time as the view appears
    [pagerView_ insertView:[self viewForNextPage] atIndex:2];
    [pagerView_ insertView:[self viewForPreviousPage] atIndex:0];
    
    UIView *pagedInView = [self viewForCurrentPage];
    [pagerView_ insertView:pagedInView atIndex:1];
    [self viewWasPagedIn:pagedInView];
}

- (void)numberOfPagesChanged
{
    Chapter *chapter = [self currentChapter];
    self.pageControl.numberOfPages = [chapter.pages count];
}

-(void)endEditing
{
    [[self viewForCurrentPage] endEditing:YES];
}

#pragma mark - CyclicPagerViewDelegate 

- (void)pageChanged:(enum ScrollDirection)direction
{    
    // update the page index accordingly
    if (direction == ScrollDirectionRight) {
        pageIndex_ = [self indexOfPreviousPage];
    } else {
        pageIndex_ = [self indexOfNextPage];
    }
    
    // determine if the current page is part of a different chapter or not.
    Chapter *currentChapter = [navManager_.chapters objectAtIndex:chapterIndex_];
    Page *currentPage = [navManager_ pageAtIndex:pageIndex_];    
    
    if ([currentChapter.pages containsObject:currentPage]) {
        if (direction == ScrollDirectionRight) {
            self.pageControl.currentPage = self.pageControl.currentPage - 1;
        } else {
            self.pageControl.currentPage = self.pageControl.currentPage + 1;
        }
        pageNumber_ = self.pageControl.currentPage;
        
    } else {        
        Chapter *chapter;
        if (direction == ScrollDirectionRight) {
            chapter = [self previousChapter];
            [self chapterChanged:chapter];
            self.pageControl.currentPage = self.pageControl.numberOfPages - 1;
            pageNumber_ = self.pageControl.currentPage;
        } else {
            chapter = [self nextChapter];
            [self chapterChanged:chapter];
        }                
        [EventManager fireChapterWillChangeEventWithChapter:chapter fromSource:self];
    }    
    
    // the idea here is depending on which way the user swiped, 
    // we will remove a subview at one end and add one to the other.
    UIView *viewToPageOut;
    UIView *viewToPageIn;
    UIView *viewToRemove;
    UIView *viewToAdd;
    if (direction == ScrollDirectionLeft) {
        viewToRemove = [pagerView_.subviews objectAtIndex:0];
        viewToPageOut = [pagerView_.subviews objectAtIndex:1];
        viewToPageIn = [pagerView_.subviews objectAtIndex:2];
        viewToAdd = [self viewForNextPage];
    } else {
        viewToRemove = [pagerView_.subviews objectAtIndex:2];
        viewToPageOut = [pagerView_.subviews objectAtIndex:1];
        viewToPageIn = [pagerView_.subviews objectAtIndex:0];
        viewToAdd = [self viewForPreviousPage];
    }

    [self viewWasPagedOut:viewToPageOut];
    [self viewWasPagedIn:viewToPageIn];
    //todo: localization: somehow we're getting mixed up here, when we change languages while on page 1
    // if we page forward - get a stratboard chart; if we page back, we get a crash
    
    [viewToRemove removeFromSuperview];
    
    if (direction == ScrollDirectionLeft) {            
        [pagerView_ insertView:viewToAdd atIndex:2];    
    } else {
        [pagerView_ insertView:viewToAdd atIndex:0];    
    }

    // keep our cache tidy by removing those controllers in the cache that do not match the next, current, or previous index.
    [controllerCache_ removeControllersNotMatchingPageIndexes:[NSArray arrayWithObjects:
                                                               [NSNumber numberWithInt:[self indexOfPreviousPage]],
                                                               [NSNumber numberWithInt:pageIndex_],
                                                               [NSNumber numberWithInt:[self indexOfNextPage]],                                                               
                                                               nil]];

    TLog(@"Page index is %i, previous %i, next %i", pageIndex_, [self indexOfPreviousPage], [self indexOfNextPage]);
}


#pragma mark - NSNotification Handlers

- (void)chapterChangeHandler:(NSNotification*)notification
{
    // only handle chapter changed events not generated by ourself.
    if (notification.object != self) {
        [self loadChapter:[notification.userInfo objectForKey:kEVENT_PARAM_CHAPTER]];
    }    
}

- (void)stratFileWillLoad:(NSNotification*)notification
{
    // remove all pages and flush the cache, since we are loading a new StratFile.
    [self removeAllPages];
    [controllerCache_ flush];
}

- (void)stratFileLoaded:(NSNotification*)notification
{ 
    ChapterIndex idx = [[[notification userInfo] objectForKey:kEVENT_PARAM_STRATFILE_CHAPTER_INDEX] intValue];
    
    if (idx != ChapterIndexNone) {
        [self loadChapter:[navManager_.chapters objectAtIndex:idx]];
    } else {
        if (chapterIndex_ > ChapterIndexBrainstormThemes) {
            // we are in a chapter with dynamic pages, so just start from the first
            // page in the chapter.
            pageIndex_ = pageIndex_ - pageNumber_;
            [self loadChapter:[navManager_.chapters objectAtIndex:chapterIndex_]];
        } else {
            // we are in a chapter with a static number of pages, so just reload
            // the current pages.
            [self reloadCurrentPages];
        }
    }
}


#pragma mark - Actions

- (IBAction)pageControlValueChanged:(id)sender
{   
    int change = self.pageControl.currentPage - pageNumber_;
    pageNumber_ = self.pageControl.currentPage;
    pageIndex_ = pageIndex_ + change;
    [self reloadCurrentPages];
}

- (void)goGlasseyStrategy:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.alexglassey.com"]];
}

- (void)setDelaysContentTouches:(BOOL)delaysContentTouches
{
    pagerView_.scrollView.delaysContentTouches = delaysContentTouches;
}

#pragma mark - Private

- (void)chapterChanged:(Chapter*)chapter
{
    chapterIndex_ = [navManager_.chapters indexOfObject:chapter];
    self.pageControl.numberOfPages = [chapter.pages count];
    self.pageControl.currentPage = 0;        
    pageNumber_ = self.pageControl.currentPage;
}

- (void)loadChapter:(Chapter*)chapter
{    
    [self chapterChanged:chapter];
    pageIndex_ = [navManager_ indexOfPage:[chapter.pages objectAtIndex:0]];
    
    TLog(@"Page index is %i, previous %i, next %i", pageIndex_, [self indexOfPreviousPage], [self indexOfNextPage]);

    // remove all the pages in the pager view.
    [self removeAllPages];

    // remove those controllers in the cache that do not match the next, current, or previous index.
    // we don't want to flush the cache since there may be controllers that we can reuse, for example,
    // if we are loading an adjacent chapter.
    [controllerCache_ removeControllersNotMatchingPageIndexes:[NSArray arrayWithObjects:
                                                               [NSNumber numberWithInt:[self indexOfPreviousPage]],
                                                               [NSNumber numberWithInt:pageIndex_],
                                                               [NSNumber numberWithInt:[self indexOfNextPage]],                                                               
                                                               nil]];

    // insert the current page last, so that the activity viewer disappears at the same time as the view appears
    [pagerView_ insertView:[self viewForNextPage] atIndex:2];
    [pagerView_ insertView:[self viewForPreviousPage] atIndex:0];
    
    UIView *pagedInView = [self viewForCurrentPage];
    [pagerView_ insertView:pagedInView atIndex:1];
    [self viewWasPagedIn:pagedInView];
}

- (void)viewWasPagedIn:(UIView*)view
{
    ContentViewController *controller = [controllerCache_ controllerForView:view];    
    [controller viewWillAppear:NO];
    [controller viewDidAppear:NO];    
}

- (void)viewWasPagedOut:(UIView*)view
{
    ContentViewController *controller = [controllerCache_ controllerForView:view];    
    [controller viewWillDisappear:NO]; 
    [controller viewDidDisappear:NO];        
}

- (UIView*)viewForPreviousPage
{    
    ContentViewController *controller = [self controllerForIndex:[self indexOfPreviousPage]];
    return controller.view;
}

- (UIView*)viewForCurrentPage
{    
    ContentViewController *controller = [self controllerForIndex:pageIndex_];
    return controller.view;
}

- (UIView*)viewForNextPage
{
    ContentViewController *controller = [self controllerForIndex:[self indexOfNextPage]];
    return controller.view;
}

- (ContentViewController*)controllerForIndex:(NSUInteger)index
{
    ContentViewController *controller = [controllerCache_ controllerForPageIndex:index];
    
    if (!controller) {
        controller = [navManager_ newContentControllerForPageAtIndex:index];
        [controllerCache_ addController:controller forPageIndex:index];
        [controller release];
    }    
    
    TLog(@"Content Controllers are %@", controllerCache_);
    
    return controller;
}

- (void)removeAllPages
{
    int i = 0;
    for (UIView *subview in [self.pagerView subviews]) {
        ContentViewController *controller = [controllerCache_ controllerForView:subview];    
        [controller viewWillDisappear:NO]; 
        [subview removeFromSuperview];
        [controller viewDidDisappear:NO];        
        i++;
    }    
}

- (NSUInteger)indexOfPreviousPage
{   
    NSInteger result = pageIndex_ - 1;

    if (result < 0) {
        return result + navManager_.totalPages;
    } else {
        return result;
    }
}

- (NSUInteger)indexOfNextPage
{
    NSUInteger result = pageIndex_ + 1;
    
    if (result > (navManager_.totalPages - 1)) {
        return result - navManager_.totalPages;
    } else {
        return result;
    }
}

- (Chapter*)previousChapter
{
    chapterIndex_--;
    
    if (chapterIndex_ < 0) {
        chapterIndex_ = [navManager_.chapters count] - 1;
    }
    return [navManager_.chapters objectAtIndex:chapterIndex_];
}

- (Chapter*)nextChapter
{
    chapterIndex_++;
    
    if (chapterIndex_ > ([navManager_.chapters count] - 1)) {
        chapterIndex_ = 0;
    }
    return [navManager_.chapters objectAtIndex:chapterIndex_];    
}

#pragma mark - Override

- (void)reloadLocalizableResources
{
    // because PageVC is a ContentVC which is an LMVC, do nothing
}

@end
