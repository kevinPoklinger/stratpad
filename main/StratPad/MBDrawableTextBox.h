//
//  MBDrawableTextBox.h
//  StratPad
//
//  Created by Eric Rogers on October 6, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//
//  Draws a coloured box with a single line of text inset 
//  from the left, and aligned vertically in the middle of the box.

#import "Drawable.h"
#import "MBDrawableLabel.h"


@interface MBDrawableTextBox : NSObject<Drawable> {
@private
    MBDrawableLabel *label_;
    UIColor *backgroundColor_;
    CGRect rect_;
}

@property(nonatomic, assign) CGRect rect;

- (id)initWithText:(NSString*)text 
              font:(UIFont*)font 
             color:(UIColor*)color
   backgroundColor:(UIColor*)backgroundColor
           andRect:(CGRect)rect;

@end
