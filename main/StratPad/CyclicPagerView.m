//
//  CyclicPagerView.m
//  StratPad
//
//  Created by Eric Rogers on August 4, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "CyclicPagerView.h"
#import <QuartzCore/QuartzCore.h>

@interface CyclicPagerView (Private)
- (void)positionView:(UIView*)view atIndex:(NSUInteger)index;
- (void)scrollToMiddlePage;
- (void)removeShadowsFromPageViews;
- (void)addShadowsToPageViews;
- (void)addShadowToPageView:(UIView*)pageView;
@end


@implementation CyclicPagerView

@synthesize pageCount = pageCount_;
@synthesize delegate = delegate_;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        
        pageCount_ = 3;
        
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
        
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        self.scrollView = scrollView;
        [scrollView release];
        
        _scrollView.delegate = self;
        _scrollView.pagingEnabled = YES;
        _scrollView.opaque = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width * pageCount_, _scrollView.frame.size.height);
        _scrollView.delaysContentTouches = NO;
        [self addSubview:_scrollView];
    }
    return self;
}


#pragma mark - Memory Management

- (void)dealloc
{
    [_scrollView release];
    
    [super dealloc];
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    // if warranted ever, this is the appropriate place for viewWillAppear
    // remove the shadows from all pages so that moving them is buttery smooth.
    [self removeShadowsFromPageViews];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView 
{    
    // add the shadows to the pages once they have stopped moving.
    [self addShadowsToPageViews];
    
    NSUInteger scrollDistance = abs(_scrollView.contentOffset.x - lastContentOffset_);

	// don't bother doing anything unless we have scrolled far enough to 
    // trigger a page change
	if (scrollDistance < _scrollView.frame.size.width) {        
		return;	
	} 
    
    // determine the direction that the user scrolled
    enum ScrollDirection direction; 
    if (lastContentOffset_ > scrollView.contentOffset.x) {
        direction = ScrollDirectionRight;        
    } else {
        direction = ScrollDirectionLeft;
    }    
       
    // inform the delegate that a page change occurred
    [self.delegate pageChanged:direction];
}


#pragma mark - Public

- (void)insertView:(UIView*)view atIndex:(NSUInteger)index
{    
    [_scrollView insertSubview:view atIndex:index];    
    
    // reposition all the subviews so they are in the correct position, and scroll to the middle subview.
    NSUInteger i = 0;
    for (UIView *subview in _scrollView.subviews) {
        [self positionView:subview atIndex:i];
        i++;
    }
    
    [self scrollToMiddlePage];
    
    // ensure we add the shadow on insertion, since not doing so will prevent shadows from appearing
    // when we first load the app, or switch chapters.  i.e., scrollViewWillBeginDragging is not
    // called in these two situations.
    [self addShadowToPageView:view];
}

- (NSArray*)subviews
{
    return _scrollView.subviews;
}


#pragma mark - Private

- (void)positionView:(UIView*)view atIndex:(NSUInteger)index
{
    // scroll view is inset 3px, add a left inset to provide a total of 13px between the page and the side bar.
    // the page width determines the right margin, which should be 13px in width as well.    
    NSUInteger leftInset = 10; 
    view.frame = CGRectMake(_scrollView.frame.size.width * index + leftInset, 0, view.frame.size.width, view.frame.size.height);
}

- (void)scrollToMiddlePage
{
    [_scrollView scrollRectToVisible:CGRectMake(_scrollView.frame.size.width, 0, _scrollView.frame.size.width, _scrollView.frame.size.height) animated:NO   
     ];    
    lastContentOffset_ = _scrollView.contentOffset.x;
}

- (void)removeShadowsFromPageViews
{
    for (UIView *view in _scrollView.subviews) {
        view.layer.shadowColor = nil;
        view.layer.shadowOffset = CGSizeZero;
        view.layer.shadowOpacity = 0;
    }    
}

- (void)addShadowsToPageViews
{
    for (UIView *view in _scrollView.subviews) {
        [self addShadowToPageView:view];
    }
}

- (void)addShadowToPageView:(UIView*)view
{    
    view.layer.shadowOffset = CGSizeMake(3, 3);
    view.layer.shadowColor = [[UIColor blackColor] CGColor];
    view.layer.shadowOpacity = 0.8; 
}

@end
