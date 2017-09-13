//
//  MBDiamond.h
//  StratPad
//
//  Created by Eric Rogers on 11-12-08.
//  Copyright (c) 2011 Glassey Strategy. All rights reserved.
//
//  A diamond that can be drawn into the current graphics context.

#import "Drawable.h"

@interface MBDiamond : NSObject<Drawable> {
@private
    // rect in which to draw the diamond
    CGRect rect_;
    
    // color of the diamond
    UIColor *color_;
        
}

@property(nonatomic, retain) UIColor *color;
@property(nonatomic, assign) CGRect rect;

- (id)initWithRect:(CGRect)rect;

@end
