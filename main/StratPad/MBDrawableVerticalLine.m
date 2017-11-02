//
//  MBDrawableVerticalLine.m
//  StratPad
//
//  Created by Eric Rogers on 11-12-09.
//  Copyright (c) 2011 Glassey Strategy. All rights reserved.
//

#import "MBDrawableVerticalLine.h"

@implementation MBDrawableVerticalLine

@synthesize rect = rect_;

- (id)initWithOrigin:(CGPoint)origin height:(CGFloat)height thickness:(CGFloat)thickness andColor:(UIColor*)color
{
    if ((self = [super init])) {            
        origin_ = origin;
        height_ = height;
        thickness_ = thickness;
        color_ = [color retain];

        // round the values passed into the rect so we aren't trying to draw fractions of a pixel
        // which degrades the color and crispness of the line
        rect_ = CGRectMake(roundf(origin_.x), roundf(origin_.y), roundf(thickness_), roundf(height_));
    }
    return self;
}

- (void)changeOrigin:(CGPoint)origin
{
    origin_ = origin;
    
    // round the values passed into the rect so we aren't trying to draw fractions of a pixel
    // which degrades the color and crispness of the line
    rect_ = CGRectMake(roundf(origin_.x), roundf(origin_.y), roundf(thickness_), roundf(height_));
}

#pragma mark - Memory Management

- (void)dealloc
{
    [color_ release];
    [super dealloc];
}


#pragma mark - Drawing

- (void)draw
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    CGContextSetFillColorWithColor(context, [color_ CGColor]);
    CGContextFillRect(context, rect_);
    
    CGContextRestoreGState(context);    
}

@end
