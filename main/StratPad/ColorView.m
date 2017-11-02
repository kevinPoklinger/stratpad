//
//  ColorView.m
//  StratPad
//
//  Created by Julian Wood on 12-04-02.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "ColorView.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor-Expanded.h"


@implementation ColorView

@synthesize gradientColorStart = gradientColorStart_;
@synthesize gradientColorEnd = gradientColorEnd_;

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    NSAssert(gradientColorStart_ != nil, @"You have to supply a starting color for the gradient");
    NSAssert(gradientColorEnd_ != nil, @"You have to supply an end color for the gradient");
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
        
    // draw a rounded rect background in grey that will appear like a stroke
    CGContextSetFillColorWithColor(context, [[UIColor grayColor] CGColor]);
    UIBezierPath *bgpath = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(5, 5)];
    [bgpath fill];
        
    // make the gradient
    CGFloat colors [] = { 
        gradientColorStart_.red, gradientColorStart_.green, gradientColorStart_.blue, 0.9,
        gradientColorEnd_.red, gradientColorEnd_.green, gradientColorEnd_.blue, 0.9
    };
    
    CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, colors, NULL, 2);
    CGColorSpaceRelease(baseSpace), baseSpace = NULL;
    
    // clip to rounded rect path
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(rect, 1, 1) byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(4, 4)];
    [path addClip];
    
    // draw the gradient in our clipped area
    CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
    
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGGradientRelease(gradient), gradient = NULL; 
    
    CGContextRestoreGState(context);
    
}

@end
