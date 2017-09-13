//
//  NavigationConfig.h
//  StratPad
//
//  Created by Eric Rogers on July 27, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//
//  Manages the navigation model for the application based off of
//  the combination of Pages.plist and a StratFile.
//
//  When adding a new report, with a dynamic number of pages:
//  -[newContentControllerForPageAtIndex:]
//      - this allows you to specify the chapter builder, next
//      - if nothing specified, just constructs the specified vc (from pages.plist) with a single page
//      - the index represents the page index in the context of all the pages in a strafile
//  -[buildNavigationFromStratFileOrNil:]
//      - this allows you to determine how many pages there are
//      - we will typically issue a populate... message, which either checks with the VC for numberOfPages, or figures it out itself
//      - it's the number of pages we add to a chapter in populate... which ultimately determines how many pages there are
//  - NB. if the numPages changes based on form values, you need to recalculate the number of pages
//      - to do this we, issue an NSNotification using the EventManager, and typically listen for it in the RootViewController


#import "Page.h"
#import "Chapter.h"
#import "StratFile.h"
#import "Objective.h"

@class ContentViewController;


@interface NavigationConfig : NSObject {
 @private
    NSMutableArray *chapters_;
    
    NSUInteger totalPages_;
}

// note that chapters change every time a stratfile is loaded
@property (nonatomic, readonly) NSArray *chapters;

// note that the total number of pages changes every time a stratfile is loaded
@property (nonatomic, readonly) NSUInteger totalPages;

+ (NavigationConfig*)sharedManager;

// returns the index of the given page relative to the entire navigation.
// Returns -1 if the page is not found.
- (NSInteger)indexOfPage:(Page*)page;

// returns the page at the given index, relative to the entire navigation.
- (Page*)pageAtIndex:(NSUInteger)pageIndex;

// returns the chapter at the given global page index
- (Chapter*)chapterAtIndex:(NSUInteger)pageIndex;

// returns the page number within its chapter at the given global page index
- (NSUInteger)pageNumberAtIndex:(NSUInteger)pageIndex;

// chapter info for the given chapter index
- (Chapter*)chapterAtChapterIndex:(ChapterIndex)chapterIndex;

// rebuilds the navigation for the application from the given StratFile, or the 
// default navigation if nil.
- (void)buildNavigationFromStratFileOrNil:(StratFile*)stratFile;

// this builds or rebuilds the navigation from Pages.plist, used predominantly by the sidebar
- (void)buildBaseNavigationFromPlist;

// creates and initializes the content controller for the page at the given index, relative 
// to the entire navigation.
- (ContentViewController*)newContentControllerForPageAtIndex:(NSUInteger)index;

// returns the global index of the first page in the chapter at the given index.
- (NSUInteger)startingPageIndexForChapterAtIndex:(ChapterIndex)chapterIndex;

// determines the index of the page corresponding to the given theme within the theme details chapter.
- (NSUInteger)themeDetailsPageIndexForTheme:(Theme*)theme;

// determines the index of the page corresponding to the given theme within the define objectives chapter.
- (NSUInteger)defineObjectivesPageIndexForTheme:(Theme*)theme;

// determines the index of the page corresponding to the given theme within the activity chapter.
- (NSUInteger)activityPageIndexForTheme:(Theme*)theme;

// determines the index of the page corresponding to the given objective within the activity chapter.
- (NSUInteger)activityPageIndexForObjective:(Objective*)objective;

// returns an initialized content view controller for the given page.  That is a content view
// controller that has already had viewWillAppear and viewDidAppear called so it loads its state.
// designed to be called externally, by the printing subsystem
- (ContentViewController*)newViewControllerForPage:(Page*)page;

@end
