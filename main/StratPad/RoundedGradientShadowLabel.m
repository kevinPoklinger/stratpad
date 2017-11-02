//
//  RoundedGradientShadowLabel.m
//  StratPad
//
//  Created by Julian Wood on 11-08-09.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "RoundedGradientShadowLabel.h"
#import "UIColor-Expanded.h"


@implementation RoundedGradientShadowLabel

@synthesize color1 = color1_;
@synthesize color2 = color2_;
@synthesize gradientStartPoint = gradientStartPoint_;
@synthesize gradientEndPoint = gradientEndPoint_;

// programmatically
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

// IB
- (id)initWithCoder:(NSCoder *)decoder 
{
    self = [super initWithCoder:decoder];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
    
}

- (void)dealloc 
{
    [color1_ release];
    [color2_ release];
    [gradientStartPoint_ release];
    [gradientEndPoint_ release];
    [super dealloc];
}

- (void)drawRect:(CGRect)rect 
{    
    // initialize colors
    if (self.color1 == nil) {
        self.color1 = [UIColor blackColor];
    }
    
    if (self.color2 == nil) {
        self.color2 = [UIColor whiteColor];
    }
    
    if (self.gradientStartPoint == nil) {
        self.gradientStartPoint = [NSValue valueWithCGPoint:CGPointMake(CGRectGetMidX(rect), 0)];
    }
    
    if (self.gradientEndPoint == nil) {
        self.gradientEndPoint = [NSValue valueWithCGPoint:CGPointMake(CGRectGetMidX(rect), rect.size.height)];
    }
    
    // will use 2 gradient colours
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    
    // get color components for 2 gradient colours
    CGFloat components[8];    
    NSArray *comp1 = [color1_ arrayFromRGBAComponents];
    NSArray *comp2 = [color2_ arrayFromRGBAComponents];
    for (uint i=0; i<4; ++i) {
        components[i] = [[comp1 objectAtIndex:i] floatValue];
        components[i+4] = [[comp2 objectAtIndex:i] floatValue];
    }

    // start drawing
    CGContextRef context = UIGraphicsGetCurrentContext();        
    CGContextSaveGState(context);    
    
    // set up the shadow
    CGContextSetShadowWithColor(context, 
                                CGSizeMake(3.f, 3.f), 
                                2.f, 
                                [[[UIColor blackColor] colorWithAlphaComponent:0.5] CGColor]);

    CGRect subRect = CGRectInset(rect, 3.f, 3.f);
    UIBezierPath *gradientPath = [UIBezierPath bezierPathWithRoundedRect:subRect byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(3, 3)];            
    
    // draw rect for the purpose of getting the shadow down
    CGContextSetFillColorWithColor(context, [[UIColor grayColor] CGColor]);
    [gradientPath fill];
    
    // turn off shadow
    CGContextSetShadowWithColor(context, CGSizeMake(0, 0), 0, NULL);
    
    // set up the gradient rounded rect
    CGColorSpaceRef myColorspace = CGColorSpaceCreateDeviceRGB();        
    CGGradientRef myGradient = CGGradientCreateWithColorComponents (myColorspace, components, locations, num_locations);

    // ensure we are only drawing the gradient within the gradient path.
    [gradientPath addClip];    

    // draw gradient
    CGContextDrawLinearGradient (context, myGradient, [gradientStartPoint_ CGPointValue], [gradientEndPoint_ CGPointValue], kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);    
    CGGradientRelease(myGradient);

    CGContextRestoreGState(context); 

    // draw text
    [super drawRect:CGRectInset(subRect, 2, 2)];
}

@end
