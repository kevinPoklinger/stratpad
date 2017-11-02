//
//  AllowingUsToProgressRow.m
//  StratPad
//
//  Created by Eric Rogers on 11-12-09.
//  Copyright (c) 2011 Glassey Strategy. All rights reserved.
//

#import "AllowingUsToProgressRow.h"

@implementation AllowingUsToProgressRow

@synthesize backgroundColor;
@synthesize fontColor;

- (id)initWithRect:(CGRect)rect
{
    if ((self = [super init])) {
        rect_ = rect; 
        startingXForValueColumns_ = rect_.origin.x + 0.3f * rect_.size.width;        
        endingXForValueColumns_ = rect_.origin.x + rect_.size.width;
    }
    return self;
}

#pragma mark - Memory Management

- (void)dealloc 
{
    [backgroundColor release];
    [fontColor release];
    [super dealloc];
}

#pragma mark - Drawable

- (CGRect)rect
{
    return rect_;
}

- (void)setRect:(CGRect)rect
{
    rect_ = rect;
}

- (void)draw
{
    WLog(@"This method should be overridden!");
}

- (CGRect)rectForColumn:(NSUInteger)column
{    
    if (column == 0) { 
        return CGRectMake(rect_.origin.x, rect_.origin.y, startingXForValueColumns_ - rect_.origin.x, rowHeight_);                
    } else {
        uint x = startingXForValueColumns_ + (column - 1) * valueColumnWidth_;
        return CGRectMake(x, rect_.origin.y, valueColumnWidth_, rowHeight_);        
    }
}

@end
