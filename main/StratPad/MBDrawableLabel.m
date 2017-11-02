//
//  MBDrawableLabel.m
//  StratPad
//
//  Created by Eric on 11-09-19.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "MBDrawableLabel.h"

@implementation MBDrawableLabel

@synthesize text = text_;
@synthesize font = font_;
@synthesize color = color_;
@synthesize lineBreakMode = lineBreakMode_;
@synthesize textAlignment = textAlignment_;
@synthesize rect = rect_;
@synthesize readyForPrint;

- (id)initWithText:(NSString*)text 
              font:(UIFont*)font 
             color:(UIColor*)color
     lineBreakMode:(UILineBreakMode)lineBreakMode
         alignment:(UITextAlignment)textAlignment
           andRect:(CGRect)rect
{
    if ((self = [super init])) {
        text_ = [text copy];
        font_ = [font retain];
        color_ = [color retain];
        lineBreakMode_ = lineBreakMode;
        textAlignment_ = textAlignment;
        rect_ = rect;
    }
    return self;
}

- (void)dealloc
{
    [text_ release];
    [font_ release];
    [color_ release];
    [super dealloc];
}

+ (CGSize)sizeThatFits:(CGSize)size withText:(NSString*)text andFont:(UIFont*)font lineBreakMode:(UILineBreakMode)lineBreakMode
{
    return [text sizeWithFont:font constrainedToSize:size lineBreakMode:lineBreakMode];
}

- (void)sizeToFit
{
    CGSize constrainedToSize = lineBreakMode_ == UILineBreakModeWordWrap ? CGSizeMake(rect_.size.width, 9999) : rect_.size;
    CGSize sizeThatFits = [text_ sizeWithFont:font_ constrainedToSize:constrainedToSize lineBreakMode:lineBreakMode_];   
    rect_ = CGRectMake(rect_.origin.x, rect_.origin.y, sizeThatFits.width, sizeThatFits.height);
}

- (void)draw
{
    CGContextRef context = UIGraphicsGetCurrentContext();    
    CGContextSaveGState(context);
    
    CGContextSetFillColorWithColor(context, [color_ CGColor]);
    [text_ drawInRect:rect_ withFont:font_ lineBreakMode:lineBreakMode_ alignment:textAlignment_];

    // debug
//    CGContextStrokeRect(context, rect_);
    
    CGContextRestoreGState(context);    
}

-(NSString*)description
{
    return [NSString stringWithFormat:
            @"[text: %@, rect: %@]", 
            self.text, NSStringFromCGRect(rect_)
            ];
}

@end
