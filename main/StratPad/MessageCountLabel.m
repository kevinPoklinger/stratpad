//
//  MessageCountLabel.m
//  StratPad
//
//  Created by Julian Wood on 12-09-26.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "MessageCountLabel.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor-Expanded.h"

@implementation MessageCountLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (CGSize)preferredSize
{
    CGSize textSize = [self.text sizeWithFont:self.font constrainedToSize:self.bounds.size];
    return CGSizeMake(textSize.width + 6, self.bounds.size.height);
}

- (void)drawRect:(CGRect)rect
{
    UIColor *color1 = [UIColor colorWithHexString:@"22A4D5"];
    UIColor *color2 = [UIColor colorWithHexString:@"1EA0D4"];
    NSValue *gradientStartPoint = [NSValue valueWithCGPoint:CGPointMake(CGRectGetMidX(rect), 0)];
    NSValue *gradientEndPoint = [NSValue valueWithCGPoint:CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect))];
    
    // will use 2 gradient colours
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    
    // get color components for 2 gradient colours
    CGFloat components[8];
    NSArray *comp1 = [color1 arrayFromRGBAComponents];
    NSArray *comp2 = [color2 arrayFromRGBAComponents];
    for (uint i=0; i<4; ++i) {
        components[i] = [[comp1 objectAtIndex:i] floatValue];
        components[i+4] = [[comp2 objectAtIndex:i] floatValue];
    }
    
    // start drawing
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    UIBezierPath *gradientPath = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(3, 3)];
        
    // set up the gradient rounded rect
    CGColorSpaceRef myColorspace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef myGradient = CGGradientCreateWithColorComponents (myColorspace, components, locations, num_locations);
    
    // ensure we are only drawing the gradient within the gradient path.
    [gradientPath addClip];
    
    // draw gradient
    CGContextDrawLinearGradient (context, myGradient, [gradientStartPoint CGPointValue], [gradientEndPoint CGPointValue], kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    CGGradientRelease(myGradient);
    
    CGContextRestoreGState(context);
    
    // draw text
    [super drawRect:CGRectInset(rect, 2, 2)];

}

@end
