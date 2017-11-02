//
//  MBDrawableImage.m
//  StratPad
//
//  Created by Eric Rogers on October 13, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "MBDrawableImage.h"


@implementation MBDrawableImage

- (id)initWithImage:(UIImage*)image andRect:(CGRect)rect
{
    if ((self = [super init])) {
        rect_ = rect;
        image_ = [image retain];
    }
    return self;
}

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
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    [image_ drawInRect:rect_];
    
    CGContextRestoreGState(context);    
}

- (void)dealloc
{
    [image_ release];
    [super dealloc];
}

@end
