//
//  YammerTopic.m
//  StratPad
//
//  Created by Julian Wood on 12-07-11.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "YammerTopic.h"

@implementation YammerTopic

@synthesize topicId = topicId_, topicName = topicName_;

- (id)initWithTopicId:(NSUInteger)topicId topicName:(NSString*)topicName
{
    self = [super init];
    if (self) {
        topicId_ = topicId;
        topicName_ = [topicName retain];
    }
    return self;
}

- (void)dealloc
{
    [topicName_ release];
    [super dealloc];
}

- (NSString*)description
{    
    return [NSString stringWithFormat: @"[topicId: %i, topicName:%@]", self.topicId, self.topicName];
}

@end
