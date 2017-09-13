//
//  MBGradientView.m
//  StratPad
//
//  Created by Julian Wood on 11-08-09.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "MBGradientView.h"
#import "UIColor-Expanded.h"
#import <QuartzCore/QuartzCore.h>


@implementation MBGradientView

@synthesize color1 = color1_;
@synthesize color2 = color2_;
@synthesize gradientStartPoint = gradientStartPoint_;
@synthesize gradientEndPoint = gradientEndPoint_;

// programmatically
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}

// IB
- (id)initWithCoder:(NSCoder *)decoder 
{
    self = [super initWithCoder:decoder];
    if (self) {

    }
    return self;
    
}

- (void)drawRect:(CGRect)rect
{
    if (self.color1 == nil) {
        self.color1 = [UIColor blackColor];
    }
    
    if (self.color2 == nil) {
        self.color2 = [UIColor whiteColor];
    }
    
    if (self.gradientStartPoint == nil) {
        self.gradientStartPoint = [NSValue valueWithCGPoint:CGPointZero];
    }
    
    if (self.gradientEndPoint == nil) {
        self.gradientEndPoint = [NSValue valueWithCGPoint:CGPointMake(rect.size.width, rect.size.height)];
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

    // create gradient
    CGColorSpaceRef myColorspace = CGColorSpaceCreateDeviceRGB();        
    CGGradientRef myGradient = CGGradientCreateWithColorComponents (myColorspace, components,
                                                      locations, num_locations);
    
    // draw gradient
    CGContextRef context = UIGraphicsGetCurrentContext();    
    CGContextDrawLinearGradient (context, myGradient, [gradientStartPoint_ CGPointValue], [gradientEndPoint_ CGPointValue], kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    
    CGGradientRelease(myGradient);
}

- (void)dealloc {
    [color1_ release];
    [color2_ release];
    [gradientStartPoint_ release];
    [gradientEndPoint_ release];
    [super dealloc];
}

@end
