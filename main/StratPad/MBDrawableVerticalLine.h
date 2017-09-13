//
//  MBDrawableVerticalLine.h
//  StratPad
//
//  Created by Eric Rogers on 11-12-09.
//  Copyright (c) 2011 Glassey Strategy. All rights reserved.
//

#import "Drawable.h"

@interface MBDrawableVerticalLine : NSObject<Drawable> {
@private
    CGPoint origin_;
    CGFloat height_;
    CGFloat thickness_;
    UIColor *color_;
    CGRect rect_;
}

@property(nonatomic, assign) CGRect rect;

- (id)initWithOrigin:(CGPoint)origin height:(CGFloat)height thickness:(CGFloat)thickness andColor:(UIColor*)color;

// sets the origin of the vertical line, and updates the rect for the line accordingly.
- (void)changeOrigin:(CGPoint)origin;

@end
