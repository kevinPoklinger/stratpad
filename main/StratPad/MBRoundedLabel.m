//
//  MBRoundedLabel.m
//  StratPad
//
//  Created by Eric Rogers on August 12, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "MBRoundedLabel.h"

@implementation MBRoundedLabel

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        roundedRectBackgroundColor_ = [self.backgroundColor retain];
        self.backgroundColor = [UIColor clearColor];        
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{        
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(5, 5)];
    [roundedRectBackgroundColor_ setFill];
    
    [path fill];
    
    [super drawRect:rect];    
}

// insets the text within the label
- (void)drawTextInRect:(CGRect)rect 
{
    UIEdgeInsets insets = {0, 10, 0, 10};
    return [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}

- (void)dealloc
{
    [roundedRectBackgroundColor_ release];
    [super dealloc];
}

@end
