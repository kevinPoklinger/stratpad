//
//  MBRoundedButton.m
//  StratPad
//
//  Created by Eric Rogers on August 22, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "MBRoundedButton.h"

@implementation MBRoundedButton

@synthesize roundedRectBackgroundColor = roundedRectBackgroundColor_;

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // store whatever color was set in IB
        self.roundedRectBackgroundColor = self.backgroundColor;
        
        // change it to clear, so that we can draw a rounded rect
        self.backgroundColor = [UIColor clearColor];        
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{        
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(5, 5)];
    [roundedRectBackgroundColor_ setFill];
    
    [path fill];
    
}
- (void)dealloc
{
    [roundedRectBackgroundColor_ release];
    [super dealloc];
}

@end
