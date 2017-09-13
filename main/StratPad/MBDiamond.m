//
//  MBDiamond.m
//  StratPad
//
//  Created by Eric Rogers on 11-12-08.
//  Copyright (c) 2011 Glassey Strategy. All rights reserved.
//

#import "MBDiamond.h"
#import "UIColor-HSVAdditions.h"

@implementation MBDiamond

@synthesize rect = rect_;
@synthesize color = color_;

- (id)initWithRect:(CGRect)rect
{
    if ((self = [super init])) {
        rect_ = rect;
    }
    return self;
}

#pragma mark - Memory Management

- (void)dealloc 
{
    [color_ release];
    [super dealloc];
}

- (void)draw
{
    CGFloat diamondRadius = rect_.size.height;

    // center the diamond in the rect
    CGPoint origin = CGPointMake(rect_.origin.x + diamondRadius/2, 
                                 rect_.origin.y + diamondRadius/2);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    // lighter color for fill, based on the stroke
    struct hsv_color hsv;
	struct rgb_color rgb;
	rgb.r = [color_ red];
	rgb.g = [color_ green];
	rgb.b = [color_ blue];
	hsv = [UIColor HSVfromRGB: rgb];
    UIColor *lighterColor = [UIColor colorWithHue:hsv.hue/360 
                                       saturation:MIN(hsv.sat - 0.25, 1.0) 
                                       brightness:MIN(hsv.val + 0.25, 1.0) 
                                            alpha:1.0];
    
    CGContextSetStrokeColorWithColor(context, [color_ CGColor]);    
    CGContextSetFillColorWithColor(context, [lighterColor CGColor]);    
    CGContextSetLineWidth(context, 1.f);
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathMoveToPoint(path, NULL, origin.x - diamondRadius/2, origin.y);
    CGPathAddLineToPoint(path, NULL, origin.x, origin.y - diamondRadius/2);
    CGPathAddLineToPoint(path, NULL, origin.x + diamondRadius/2, origin.y);
    CGPathAddLineToPoint(path, NULL, origin.x, origin.y + diamondRadius/2);
    CGPathAddLineToPoint(path, NULL, origin.x - diamondRadius/2, origin.y);    
    CGPathCloseSubpath(path);
    
    CGContextAddPath(context, path);
    CGContextFillPath(context);
    
    CGContextAddPath(context, path);
    CGContextStrokePath(context);  
    
    CGPathRelease(path);    
    CGContextRestoreGState(context);
}

@end
