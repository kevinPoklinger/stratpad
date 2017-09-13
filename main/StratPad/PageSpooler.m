//
//  PageSpooler.m
//  StratPad
//
//  Created by Eric on 11-10-19.
//  Copyright (c) 2011 Glassey Strategy. All rights reserved.
//

#import "PageSpooler.h"
#import "SynthesizeSingleton.h"

@implementation PageSpooler

SYNTHESIZE_SINGLETON_FOR_CLASS(PageSpooler)

- (id)init
{
    if ((self = [super init])) {
        [self resetCumulativePageNumber];
    }
    return self;
}

- (void)resetCumulativePageNumber
{
    cumulativePageNumber_ = 1;
}

- (NSUInteger)cumulativePageNumberForReport
{
    // increment the cumulative page number after it has been returned.
    return cumulativePageNumber_++;    
}

@end
