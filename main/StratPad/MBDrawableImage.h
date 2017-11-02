//
//  MBDrawableImage.h
//  StratPad
//
//  Created by Eric Rogers on October 13, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//
//  Draws a given image into a Core Graphics context, scaled to fit
//  the rect.

#import "Drawable.h"

@interface MBDrawableImage : NSObject<Drawable> {
@private
    CGRect rect_;
    UIImage *image_;    
}

- (id)initWithImage:(UIImage*)image andRect:(CGRect)rect;

@end
