//
//  AdManager.m
//  StratPad
//
//  Created by Julian Wood on 12-01-04.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//
//  Check Chapter.m for where we insert ads into a StratFile's pages

#import "AdManager.h"
#import "SynthesizeSingleton.h"
#import "RandomManager.h"
#import "EditionManager.h"

@implementation AdManager

SYNTHESIZE_SINGLETON_FOR_CLASS(AdManager);

- (id)init {
    self = [super init];
    if (self) {
        NSString *configPath = [[NSBundle mainBundle] pathForResource:@"Ads" ofType:@"plist"];
        ads_ = [[NSMutableArray arrayWithContentsOfFile:configPath] retain];
        for (int i=[ads_ count]-1; i>=0; i--) {
            NSDictionary *ad = [ads_ objectAtIndex:i];
            if (![[ad objectForKey:@"enabled"] boolValue]) {
                [ads_ removeObjectAtIndex:i];
            }
        }
    }
    return self;
}

- (void)dealloc
{
    [ads_ release];
    [super dealloc];
}


- (NSDictionary*)ad
{
    int idx = [[RandomManager sharedManager] random:@"Ad" numberOfObjects:[ads_ count]];
    return [ads_ objectAtIndex:idx];
}

- (NSArray*)adIntervalsForChapter:(Chapter*)chapter
{
    if ([chapter.chapterNumber isEqualToString:@"iii"]) {
        return [NSArray arrayWithObjects:
                [NSNumber numberWithInt:4], 
                [NSNumber numberWithInt:4], 
                [NSNumber numberWithInt:4], 
                [NSNumber numberWithInt:4], 
                [NSNumber numberWithInt:4], 
                [NSNumber numberWithInt:4], 
                [NSNumber numberWithInt:4], 
                nil];
        
    } else if ([chapter.chapterNumber isEqualToString:@"iv"]) {
        return [NSArray arrayWithObjects:
                [NSNumber numberWithInt:3], 
                [NSNumber numberWithInt:3], 
                [NSNumber numberWithInt:4], 
                [NSNumber numberWithInt:3], 
                [NSNumber numberWithInt:4], 
                [NSNumber numberWithInt:3], 
                nil];
        
    } else if ([chapter.chapterNumber hasPrefix:@"R"]) {
        // works without mods for R6, R7, R8, R9
        // need to add it to R2, R3,R4,R5 and remove from R6
        // R2, R3, R4, R5 have their own mechanism for determining pages, in -[NavigationConfig populateStrategyMapPagesForStratFileOrNil], for instance
        if ([chapter.chapterNumber isEqualToString:@"R1"] || [chapter.chapterNumber isEqualToString:@"R6"]) {
            // no ads
            return [NSArray array];
        } else {
            // 1 page reports thus get an ad at page 2
            return [NSArray arrayWithObject:[NSNumber numberWithInt:1]];
        }
    } else {
        return [NSArray array];
    }
    
}

- (void)insertAdsIntoPageDictionaries:(NSMutableArray*)pageDicts forChapter:(Chapter*)chapter
{
    if ([[EditionManager sharedManager] isFeatureEnabled:FeatureAds]) {
        uint idx = 0;
        for (NSNumber *adInterval in [self adIntervalsForChapter:chapter]) {
            NSDictionary *ad = [[AdManager sharedManager] ad];
            idx += [adInterval unsignedIntValue]; 
            [pageDicts insertObject:ad atIndex:idx++]; 
        }
    }
}



@end
