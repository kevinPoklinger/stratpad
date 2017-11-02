//
//  YammerThread.m
//  StratPad
//
//  Created by Julian Wood on 12-10-05.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "YammerThread.h"

@implementation YammerThread

@synthesize comments, hasMoreComments, totalComments;

- (NSString*)description
{
    return [NSString stringWithFormat: @"[comments: %@, hasMoreComments: %i, totalComments: %i]", comments, hasMoreComments, totalComments];
}

- (void)dealloc
{
    [comments release];
    [super dealloc];
}

@end
