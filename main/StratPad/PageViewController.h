//
//  PageViewController.h
//  StratPad
//
//  Created by Eric Rogers on July 28, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "Chapter.h"
#import "ContentViewController.h"
#import "NavigationConfig.h"
#import "CyclicPagerView.h"
#import "StratFile.h"
#import "ContentControllerCache.h"
#import "LMViewController.h"

@interface PageViewController : LMViewController<CyclicPagerViewDelegate> {
@private
    CyclicPagerView *pagerView_;
    UIPageControl *pageControl_;
    
    NavigationConfig *navManager_;
    
    // 0-based index relative to the start of the stratfile
    NSInteger chapterIndex_;

    // 0-based index relative to the start of the stratfile
    NSInteger pageIndex_;
        
    // 0-based index relative to the start of the chapter
    NSInteger pageNumber_; 
    
    ContentControllerCache *controllerCache_;
}

@property(nonatomic, retain) IBOutlet CyclicPagerView *pagerView;
@property(nonatomic, retain) IBOutlet UIPageControl *pageControl;

@property(nonatomic, readonly) Page *currentPage;
@property(nonatomic, readonly) Chapter *currentChapter;

@property(nonatomic,readonly) NSInteger pageNumber;

- (void)reloadCurrentPages;
- (void)reloadNextAndPreviousPages;

- (void)displayActivityPageAtIndex:(NSUInteger)index;
- (void)loadPage:(Page*)page inChapter:(Chapter*)chapter;

- (IBAction)pageControlValueChanged:(id)sender;
- (void)numberOfPagesChanged;

// dismisses the keyboard
-(void)endEditing;

// NO (the default) if you want controls in the main page scrolling content area to respond instantly
- (void)setDelaysContentTouches:(BOOL)delaysContentTouches;

@end
