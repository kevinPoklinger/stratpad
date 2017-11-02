//
//  SinglePageReportBuilder.m
//  StratPad
//
//  Created by Eric Rogers on October 6, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "SinglePageReportBuilder.h"


@implementation SinglePageReportBuilder

@synthesize mediaType = mediaType_;

- (id)initWithPageRect:(CGRect)rect
{
    if ((self = [super init])) {
        pageRect_ = rect;
        drawables_ = [[NSMutableArray array] retain];
    }
    return self;
}

- (void)dealloc
{
    [drawables_ release];
    [super dealloc];
}

- (void)addDrawable:(id<Drawable>)drawable
{
    [drawables_ addObject:drawable];
}

- (NSArray*)build
{
    return [NSArray arrayWithObject:drawables_];
}

@end
