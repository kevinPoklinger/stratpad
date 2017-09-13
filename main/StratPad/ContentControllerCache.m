//
//  ContentControllerCache.m
//  StratPad
//
//  Created by Eric Rogers on October 13, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "ContentControllerCache.h"

@implementation ContentControllerCache

- (id)init
{
    if ((self = [super init])) {
        cache_ = [[NSMutableDictionary dictionaryWithCapacity:3] retain];
    }
    return self;
}

- (void)dealloc
{
    [cache_ release];
    [super dealloc];
}

- (NSString*)description
{
    return [cache_ description];
}

- (ContentViewController*)controllerForPageIndex:(NSUInteger)pageIndex
{
    ContentViewController *controller = [cache_ objectForKey:[NSNumber numberWithInt:pageIndex]];

    if (controller) {
        TLog(@"Cache hit returning controller: %@ for pageIndex: %i", controller, pageIndex);
    } else {
        TLog(@"Cache miss for pageIndex: %i", pageIndex);   
    }
    
    return controller;
}

- (ContentViewController*)controllerForView:(UIView*)view
{
    for (ContentViewController *controller in [cache_ allValues]) {
        if (controller.view == view) {
            return controller;
        }
    }
    return nil;
}

- (void)addController:(ContentViewController*)controller forPageIndex:(NSUInteger)pageIndex
{
    [cache_ setObject:controller forKey:[NSNumber numberWithInt:pageIndex]];
}

- (void)removeControllerForPageIndex:(NSUInteger)pageIndex
{
    [cache_ removeObjectForKey:[NSNumber numberWithInt:pageIndex]];
}

- (void)removeControllersNotMatchingPageIndexes:(NSArray*)pageIndexes
{
     for (NSNumber *key in [cache_ allKeys]) { 
        if (![pageIndexes containsObject:key]) {
            [cache_ removeObjectForKey:key];
        }
    }
}

- (void)flush
{
    [cache_ removeAllObjects];
}

@end
