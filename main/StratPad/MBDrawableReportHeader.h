//
//  MBDrawableReportHeader.h
//  StratPad
//
//  Created by Eric Rogers on October 13, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//
//  Provides a basic report header template that can be drawn into the 
//  current Core Graphics context.  By itself, the template will render
//  a white report title overtop of a horizontal rectangular gradient.
//  The gradient begins at position 0,0 in the rect.  All text is inset
//  from the left by textInsetLeft.  
//
//  Clients can add additional lines of text to the header using a 
//  font and colour of their choice.  A line can be added to one of two 
//  sections in the header, a title section, or description section.
//  The title section begins immediately below the report title and gradient.
//  The description section begins 5px below the end of the title section.
//
//  This is for print headers.


#import "Drawable.h"

@interface MBDrawableReportHeader : NSObject<Drawable> {
@private    
    CGRect rect_;

    CGFloat textInsetLeft_;
    
    NSMutableArray *drawables_;    
        
    NSString *reportTitle_;
    
    NSMutableArray *titleItems_;
    NSMutableArray *descriptionItems_;
    
}

- (id)initWithRect:(CGRect)rect textInsetLeft:(CGFloat)textInsetLeft andReportTitle:(NSString*)reportTitle;

// amount to inset the text in the header from the left by, releative to the rect for the header.
@property(nonatomic, assign) CGFloat textInsetLeft;

// text that appears on top of the gradient in the header
@property(nonatomic, copy) NSString *reportTitle;

// appears to be designed for print only
- (void)addTitleItemWithText:(NSString*)text font:(UIFont*)font andColor:(UIColor*)color;

- (void)addDescriptionItemWithText:(NSString*)text font:(UIFont*)font andColor:(UIColor*)color;

@end
