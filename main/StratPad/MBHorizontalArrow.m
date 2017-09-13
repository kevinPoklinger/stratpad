//
//  MBHorizontalArrow.m
//  StratPad
//
//  Created by Eric Rogers on 11-12-08.
//  Copyright (c) 2011 Glassey Strategy. All rights reserved.
//

#import "MBHorizontalArrow.h"
#import "MBDrawableHorizontalLine.h"

@interface MBHorizontalArrow (Private)
- (void)drawHorizontalLine;
- (void)drawArrowHead;
@end

@implementation MBHorizontalArrow

@synthesize color = color_;
@synthesize rect = rect_;

- (id)initWithRect:(CGRect)rect arrowHeadSize:(CGSize)arrowHeadSize andLineWidth:(CGFloat)lineWidth
{
    if ((self = [super init])) {
        rect_ = rect;
        lineWidth_ = lineWidth;
        arrowHeadSize_ = arrowHeadSize;
    }
    return self;
}

#pragma mark - Memory Management

- (void)dealloc 
{
    [color_ release];
    [super dealloc];
}

#pragma mark - Drawable

- (void)draw
{
    arrowHeadStrokeWidth_ = 1.f;
    [self drawHorizontalLine];
    [self drawArrowHead];
}

- (void)drawHorizontalLine
{
    // center the arrow vertically in its rect.
    CGPoint horizontalLineOrigin = CGPointMake(rect_.origin.x, rect_.origin.y + (rect_.size.height - lineWidth_)/2);
    CGFloat horizontalLineWidth = rect_.size.width - arrowHeadSize_.width + arrowHeadStrokeWidth_;
    MBDrawableHorizontalLine *horizontalLine = [[MBDrawableHorizontalLine alloc] initWithOrigin:horizontalLineOrigin 
                                                                                          width:horizontalLineWidth 
                                                                                      thickness:lineWidth_ 
                                                                                       andColor:color_];
    [horizontalLine draw];
    [horizontalLine release];    
}

- (void)drawArrowHead
{
    CGFloat arrowHeadWidth = arrowHeadSize_.width - arrowHeadStrokeWidth_;
    CGFloat arrowHeadHeight = arrowHeadSize_.height;
    
    // origin of the arrow head is the top-left of it
    CGPoint origin = CGPointMake(rect_.origin.x + rect_.size.width - arrowHeadWidth,
                                 rect_.origin.y + (rect_.size.height - arrowHeadHeight)/2);
        
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    CGContextSetStrokeColorWithColor(context, [color_ CGColor]);    
    CGContextSetFillColorWithColor(context, [color_ CGColor]);    
    CGContextSetLineWidth(context, arrowHeadStrokeWidth_);
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathMoveToPoint(path, NULL, origin.x, origin.y);
    CGPathAddLineToPoint(path, NULL, origin.x + arrowHeadWidth, origin.y + arrowHeadHeight/2);
    CGPathAddLineToPoint(path, NULL, origin.x, origin.y + arrowHeadHeight);
    CGPathAddLineToPoint(path, NULL, origin.x, origin.y);
    CGPathCloseSubpath(path);
    
    CGContextAddPath(context, path);
    CGContextFillPath(context);
    
    CGContextAddPath(context, path);
    CGContextStrokePath(context);  
    
    CGPathRelease(path);        
    
    CGContextRestoreGState(context);    
}

@end
