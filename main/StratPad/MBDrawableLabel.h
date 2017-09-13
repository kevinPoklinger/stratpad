//
//  MBDrawableLabel.h
//  StratPad
//
//  Created by Eric on 11-09-19.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//
//  This label will wrap and can be stored as a Drawable for later drawing. Draws in the top left corner of rect.

#import "Drawable.h"

@interface MBDrawableLabel : NSObject<Drawable> {
@protected
    NSString *text_;
    UIFont *font_;
    UIColor *color_;
    UILineBreakMode lineBreakMode_;
    UITextAlignment textAlignment_;
    CGRect rect_;
}

@property(nonatomic, retain, readonly) NSString *text;
@property(nonatomic, retain, readonly) UIFont *font;
@property(nonatomic, retain, readonly) UIColor *color;
@property(nonatomic, assign, readonly) UILineBreakMode lineBreakMode;
@property(nonatomic, assign, readonly) UITextAlignment textAlignment;
@property(nonatomic, assign) CGRect rect;
@property(nonatomic, assign) BOOL readyForPrint;

- (id)initWithText:(NSString*)text 
              font:(UIFont*)font 
             color:(UIColor*)color
     lineBreakMode:(UILineBreakMode)lineBreakMode
         alignment:(UITextAlignment)textAlignment
           andRect:(CGRect)rect;

+ (CGSize)sizeThatFits:(CGSize)size withText:(NSString*)text andFont:(UIFont*)font lineBreakMode:(UILineBreakMode)lineBreakMode;

@end
