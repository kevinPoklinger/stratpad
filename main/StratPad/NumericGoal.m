//
//  NumericGoal.m
//  StratPad
//
//  Created by Eric Rogers on September 24, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "NumericGoal.h"

@implementation NumericGoal

@synthesize metric = metric_;
@synthesize date = date_;
@synthesize value = value_;

- (id<Goal>)initWithMetric:(NSString*)metric date:(NSDate*)date andNumericValue:(NSNumber*)value
{
    if ((self = [super init])) {
        metric_ = [metric copy];
        date_ = [date retain];
        value_ = [value retain];
    }
    return self;
}

- (void)dealloc
{
    [date_ release];
    [value_ release];
    [super dealloc];
}

@end
