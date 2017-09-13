//
//  GridSupport.m
//  StratPad
//
//  Created by Julian Wood on 12-03-15.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "GridSupport.h"

void drawHorizontalLine(CGContextRef context, CGPoint origin, CGFloat width, CGFloat adjustment)
{
    CGContextMoveToPoint(context, origin.x, origin.y+adjustment);
    CGContextAddLineToPoint(context, origin.x+width, origin.y+adjustment);            
}

void drawVerticalLine(CGContextRef context, CGPoint origin, CGFloat height, CGFloat adjustment)
{
    CGContextMoveToPoint(context, origin.x+adjustment, origin.y);
    CGContextAddLineToPoint(context, origin.x+adjustment, origin.y+height);            
}

CGPoint lineIntersection(CGPoint p1, CGPoint p2, CGPoint p3, CGPoint p4)
{
    CGFloat x12 = p1.x - p2.x;
    CGFloat x34 = p3.x - p4.x;
    CGFloat y12 = p1.y - p2.y;
    CGFloat y34 = p3.y - p4.y;
    
    CGFloat c = x12 * y34 - y12 * x34;
    
    if (fabs(c) < 0.01)
    {
        // No intersection
        WLog(@"No intersection. Returning 0,0.")
        return CGPointZero;
    }
    else
    {
        // Intersection
        CGFloat a = p1.x * p2.y - p1.y * p2.x;
        CGFloat b = p3.x * p4.y - p3.y * p4.x;
        
        CGFloat x = (a * x34 - b * x12) / c;
        CGFloat y = (a * y34 - b * y12) / c;
        
        return CGPointMake(x, y);
    }
}
