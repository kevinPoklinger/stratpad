//
//  MBTestDrawable.m
//  StratPad
//
//  Created by Julian Wood on 12-05-13.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "MBTestDrawable.h"

@implementation MBTestDrawable

@synthesize rect = rect_;

- (id)initWithRect:(CGRect)rect
{
    if ((self = [super init])) {
        rect_ = rect;
    }
    return self;
}

- (void)draw
{
    
}

@end
