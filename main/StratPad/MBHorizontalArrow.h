//
//  MBHorizontalArrow.h
//  StratPad
//
//  Created by Eric Rogers on 11-12-08.
//  Copyright (c) 2011 Glassey Strategy. All rights reserved.
//
//  A horizonal arrow, pointing to the right, that can be drawn into the current graphics context.

#import "Drawable.h"

@interface MBHorizontalArrow : NSObject<Drawable> {
@private
    // color of the arrow
    UIColor *color_;
    
    // rect in which to draw the arrow
    CGRect rect_;
    
    // the width of the horizontal line for the arrow
    CGFloat lineWidth_;
    
    // stroke width of the arrowhead
    CGFloat arrowHeadStrokeWidth_;
    
    // the size of the arrow head
    CGSize arrowHeadSize_;
}

@property(nonatomic, retain) UIColor *color;
@property(nonatomic, assign) CGRect rect;

- (id)initWithRect:(CGRect)rect arrowHeadSize:(CGSize)arrowHeadSize andLineWidth:(CGFloat)lineWidth;

@end
