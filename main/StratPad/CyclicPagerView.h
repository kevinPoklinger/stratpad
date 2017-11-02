//
//  CyclicPagerView.h
//  StratPad
//
//  Created by Eric Rogers on August 4, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

enum ScrollDirection {
    ScrollDirectionRight,
    ScrollDirectionLeft
};

@protocol CyclicPagerViewDelegate <NSObject>
- (void)pageChanged:(enum ScrollDirection)direction;
@end

@interface CyclicPagerView : UIView<UIScrollViewDelegate> {
@private
    NSUInteger pageCount_;
    
    float lastContentOffset_;
    
    id<CyclicPagerViewDelegate> delegate_;
}

@property(nonatomic, readonly) NSUInteger pageCount;
@property(nonatomic, assign) IBOutlet id<CyclicPagerViewDelegate> delegate;
@property(nonatomic, retain) UIScrollView *scrollView;



// returns all the subviews for this view.
- (NSArray*)subviews;

// inserts the view at the given index and repositions the scroll view so that
// the view at index 1 is displayed.
- (void)insertView:(UIView*)view atIndex:(NSUInteger)index;

@end
