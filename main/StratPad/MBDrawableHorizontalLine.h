//
//  MBDrawableHorizontalLine.h
//  StratPad
//
//  Created by Eric Rogers on October 4, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//
//  Draws a horizontal line with a specific width, colour, and thickness
//  from a specific origin.

#import "Drawable.h"

@interface MBDrawableHorizontalLine : NSObject<Drawable> {
@private
    CGPoint origin_;
    CGFloat width_;
    CGFloat thickness_;
    UIColor *color_;
    CGRect rect_;
}

@property(nonatomic, assign) CGRect rect;

- (id)initWithOrigin:(CGPoint)origin width:(CGFloat)width thickness:(CGFloat)thickness andColor:(UIColor*)color;

// sets the origin of the horizontal line, and updates the rect for the line accordingly.
- (void)changeOrigin:(CGPoint)origin;

@end
