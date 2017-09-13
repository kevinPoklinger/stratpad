//
//  MBHorizontalLineView.m
//  StratPad
//
//  Created by Eric on 11-08-15.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "MBHorizontalLineView.h"


@implementation MBHorizontalLineView

- (void)drawRect:(CGRect)rect
{   
    // fill in the background and round the edges first.
    [super drawRect:rect];
    
    // draw a single horizontal line at the top of the view.    
    CGContextRef context = UIGraphicsGetCurrentContext();    
    CGContextSetLineWidth(context, 2.0);
    CGContextSetStrokeColorWithColor(context, [[UIColor blackColor] CGColor]);
    CGContextMoveToPoint(context, 0, 1);
    CGContextAddLineToPoint(context, self.frame.size.width, 1);
	CGContextStrokePath(context);
}

@end
