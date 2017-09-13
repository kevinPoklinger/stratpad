//
//  AdManager.h
//  StratPad
//
//  Created by Julian Wood on 12-01-04.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Chapter.h"

@interface AdManager : NSObject
{
    NSMutableArray *ads_;
}

// init
+ (AdManager *)sharedManager;

// setup
- (void)insertAdsIntoPageDictionaries:(NSMutableArray*)pageDicts forChapter:(Chapter*)chapter;
- (NSArray*)adIntervalsForChapter:(Chapter*)chapter;

// public usage
- (NSDictionary*)ad;

@end
