//
//  GridSupport.h
//  StratPad
//
//  Created by Julian Wood on 12-03-15.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

// there's two issues here
// first is the 0.5 px issue discussed here:
// http://www.raywenderlich.com/2033/core-graphics-101-lines-rectangles-and-gradients
// http://stackoverflow.com/questions/2488115/how-to-set-up-a-user-quartz2d-coordinate-system-with-scaling-that-avoids-fuzzy-d/2488796#2488796

// the second is that when compensating for the half pixel problem, if we're at the 0 edges, 
// we should add 0.5px but if we're at the max edges, we should subtract 0.5px

// it's only an issue for drawing perfect, horizontal or vertical, non-antialiased lines (or rects), such as what we need for grids, on screen (not print)


// useful when anti-aliasing is off and you want a perfect, 1px non-diagonal line
void drawHorizontalLine(CGContextRef context, CGPoint origin, CGFloat width, CGFloat adjustment);
void drawVerticalLine(CGContextRef context, CGPoint origin, CGFloat height, CGFloat adjustment);

// make sure the lines actually intersect! p1 and p2 define first line, p3 and p4 the second
CGPoint lineIntersection(CGPoint p1, CGPoint p2, CGPoint p3, CGPoint p4);