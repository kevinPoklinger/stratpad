//
//  MBDrawableTextBox.m
//  StratPad
//
//  Created by Eric Rogers on October 6, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "MBDrawableTextBox.h"

@implementation MBDrawableTextBox

@synthesize rect = rect_;

- (id)initWithText:(NSString*)text 
              font:(UIFont*)font 
             color:(UIColor*)color
   backgroundColor:(UIColor*)backgroundColor
           andRect:(CGRect)rect
{
    if ((self = [super init])) {
        backgroundColor_ = [backgroundColor retain];
        rect_ = rect;     
        
        // construct the rect for the label, which is inset from the left by 5px and vertically aligned to the middle of our rect.
        CGSize textSize = [MBDrawableLabel sizeThatFits:rect_.size withText:text andFont:font lineBreakMode:UILineBreakModeTailTruncation];
        CGRect textRect = CGRectMake(rect_.origin.x + 5, rect_.origin.y + (rect_.size.height - textSize.height)/2, textSize.width, textSize.height);
        label_ = [[MBDrawableLabel alloc] initWithText:text font:font color:color lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentLeft andRect:textRect];
    }
    return self;
}

- (void)dealloc
{
    [label_ release];
    [backgroundColor_ release];
    [super dealloc];
}

- (void)draw
{
    CGContextRef context = UIGraphicsGetCurrentContext();    
    
    // draw the box
    CGContextSaveGState(context);
    CGContextAddRect(context, rect_);
    CGContextSetFillColorWithColor(context, [backgroundColor_ CGColor]);
    CGContextFillPath(context);
    CGContextRestoreGState(context);    

    // draw the label
    [label_ draw];
}

@end
