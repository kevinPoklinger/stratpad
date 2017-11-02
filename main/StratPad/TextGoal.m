//
//  TextGoal.m
//  StratPad
//
//  Created by Eric Rogers on September 24, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "TextGoal.h"

@implementation TextGoal

@synthesize metric = metric_;
@synthesize date = date_;
@synthesize value = value_;

- (id<Goal>)initWithMetric:(NSString*)metric date:(NSDate*)date andValue:(NSString*)value
{
    if ((self = [super init])) {
        metric_ = [metric copy];
        date_ = [date retain];
        value_ = [value copy];
    }
    return self;
}

- (void)dealloc
{
    [date_ release];
    [super dealloc];
}

@end
