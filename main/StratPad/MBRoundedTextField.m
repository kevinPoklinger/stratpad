//
//  MBRoundedTextField.m
//  StratPad
//
//  Created by Eric Rogers on August 12, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "MBRoundedTextField.h"


@implementation MBRoundedTextField

@synthesize roundedRectBackgroundColor = roundedRectBackgroundColor_;

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        roundedRectBackgroundColor_ = [self.backgroundColor retain];
        self.backgroundColor = [UIColor clearColor];        
    }
    return self;
}

- (void)setRoundedRectBackgroundColor:(UIColor *)roundedRectBackgroundColor
{
    [roundedRectBackgroundColor_ release];
    roundedRectBackgroundColor_ = [roundedRectBackgroundColor retain];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{        
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(5, 5)];
    [roundedRectBackgroundColor_ setFill];
    
    [path fill];
    
}

// insets the text when not editing
- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, 10, 0);
}

// insets the text when editing
- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, 10, 0);
}

- (void)dealloc
{
    [roundedRectBackgroundColor_ release];
    [super dealloc];
}

@end
