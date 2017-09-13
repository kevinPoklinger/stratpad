//
//  ChartReportHeader.m
//  StratPad
//
//  Created by Julian Wood on 12-05-11.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "ChartReportHeader.h"
#import "UIColor-Expanded.h"

@implementation ChartReportHeader

- (id)initWithText:(NSString*)text 
              font:(UIFont*)font 
             color:(UIColor*)color
     lineBreakMode:(UILineBreakMode)lineBreakMode
         alignment:(UITextAlignment)textAlignment
           andRect:(CGRect)rect
{
    if ((self = [super initWithText:text font:font color:color lineBreakMode:lineBreakMode alignment:textAlignment andRect:rect])) {
        boundingLinePoints_ = [[NSMutableArray alloc] init];
        [boundingLinePoints_ addObject:[NSValue valueWithCGPoint:rect.origin]];
    }
    return self;
}

- (void)sizeToFit
{
    // noop - we keep the original rect
}

- (void)draw
{
    CGContextRef context = UIGraphicsGetCurrentContext();    
    CGContextSaveGState(context);
    
    // background for text    
    CGRect headingRect = CGRectMake(rect_.origin.x, rect_.origin.y, rect_.size.width, 17.f);
    CGContextAddRect(context, headingRect);
    CGContextClip(context);
    
    // make the gradient
    UIColor *colorStart = [UIColor colorWithHexString:boundingLineColor];
    UIColor *colorEnd = [UIColor whiteColor];
    
    CGFloat colors [] = { 
        colorStart.red, colorStart.green, colorStart.blue, 0.9,
        colorEnd.red, colorEnd.green, colorEnd.blue, 0.9
    };
    
    CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, colors, NULL, 2);
    CGColorSpaceRelease(baseSpace), baseSpace = NULL;
    
    // draw the gradient in our clipped area
    CGPoint startPoint = CGPointMake(CGRectGetMinX(headingRect), CGRectGetMidY(headingRect));
    CGPoint endPoint = CGPointMake(CGRectGetMaxX(headingRect), CGRectGetMidY(headingRect));
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGGradientRelease(gradient);

    CGContextRestoreGState(context);
    CGContextSaveGState(context);
    
    
    // instead of drawing a line down the side, set up a path, and add to it as we draw comments in the same column, then render the path
    // then later, when rendering comments, do the same thing, but outside of the report header
        
    // the difference between the current origin and the first point in boundingLinePoints_ is the offset
    CGPoint oldOrigin = [[boundingLinePoints_ objectAtIndex:0] CGPointValue]; // should be {0,0}
    [boundingLinePoints_ removeObjectAtIndex:0];    
    CGFloat offsetX = rect_.origin.x - oldOrigin.x;
    CGFloat offsetY = rect_.origin.y - oldOrigin.y;

    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, rect_.origin.x, rect_.origin.y);
    
    for (NSValue *val in boundingLinePoints_) {
        CGPoint p = CGPointOffset(val.CGPointValue, offsetX, offsetY);
        CGPathAddLineToPoint(path, NULL, p.x, p.y);
    }
    
    CGContextSetLineWidth(context, 1.f);
    CGContextSetStrokeColorWithColor(context, [colorStart CGColor]);
    CGContextAddPath(context, path);
    CGContextStrokePath(context);
    CGPathRelease(path);
    
    
    // the text    
    CGRect textRect = CGRectMake(rect_.origin.x+5, rect_.origin.y+2, rect_.size.width-5, rect_.size.height);
    CGContextSetFillColorWithColor(context, [color_ CGColor]);
    [text_ drawInRect:textRect withFont:font_ lineBreakMode:lineBreakMode_ alignment:textAlignment_];

    CGContextRestoreGState(context);        
}

- (void)addPointToBoundingLinePoints:(CGPoint)point
{
    [boundingLinePoints_ addObject:[NSValue valueWithCGPoint:point]];
}

- (void)dealloc
{
    [boundingLinePoints_ release];
    [super dealloc];
}

- (NSString*)description
{    
    return [NSString stringWithFormat:
            @"[rect: %@, text: %@, readyForPrint: %@]", 
            NSStringFromCGRect(self.rect), self.text, [NSNumber numberWithBool:[self readyForPrint]]
            ];
}



@end
