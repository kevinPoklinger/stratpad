//
//  ContentControllerCache.h
//  StratPad
//
//  Created by Eric Rogers on October 13, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//
//  Used by the PageViewController to cache and manage its ContentViewControllers.

#import "ContentViewController.h"

@interface ContentControllerCache : NSObject {
@private
    // dictionary that stores a view controller instance keyed by
    // the page's global page index.
    NSMutableDictionary *cache_;    
}

// returns the cached controller for the given page index, or nil if no such controller is in the cache.
- (ContentViewController*)controllerForPageIndex:(NSUInteger)pageIndex;

// returns the cached controller that has the given view, or nil if no such controller is in the cache.
- (ContentViewController*)controllerForView:(UIView*)view;

// adds the given controller to the cache with its global page index.
- (void)addController:(ContentViewController*)controller forPageIndex:(NSUInteger)pageIndex;

// removes the controller at the given page index from the cache.
- (void)removeControllerForPageIndex:(NSUInteger)pageIndex;

// essentially prunes the cache.  That is it removes those controllers that do not have
// page indexes matching those in the given array.
- (void)removeControllersNotMatchingPageIndexes:(NSArray*)pageIndexes;

// removes all controllers from the cache.
- (void)flush;

@end
