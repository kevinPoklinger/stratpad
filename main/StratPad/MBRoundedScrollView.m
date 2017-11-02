//
//  MBRoundedScrollView.m
//  StratPad
//
//  Created by Eric Rogers on August 12, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "MBRoundedScrollView.h"
#import <QuartzCore/QuartzCore.h>

@implementation MBRoundedScrollView

@synthesize roundedRectBackgroundColor=roundedRectBackgroundColor_;

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.roundedRectBackgroundColor = self.backgroundColor;
        self.backgroundColor = [UIColor clearColor];     
        
        self.contentSize = CGSizeMake(self.bounds.size.width, self.bounds.size.height);
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{   
    CGContextRef context = UIGraphicsGetCurrentContext();    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(5, 5)];
    CGContextSetFillColorWithColor(context, [self.roundedRectBackgroundColor CGColor]);    
    [path fill];    
}

@end
