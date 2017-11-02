//
//  PointerBox.m
//  StratPad
//
//  Created by Julian Wood on 11-08-31.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "PointerBox.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>

@implementation PointerBox

@synthesize text=text_;
@synthesize frame=frame_;
@synthesize color=color_;
@synthesize targetFrames=targetFrames_;

// params for arrow shape
CGFloat const arrowAngle = degreesToRadians(20);
CGFloat const magnitude = 6.f;

-(id)initWithText:(NSString *)text frame:(CGRect)frame color:(UIColor *)color targetFrames:(NSMutableSet *)targetFrames;
{
    self = [super init];
    if (self) {
        text_ = text;
        frame_ = frame;
        color_ = color;
        targetFrames_ = targetFrames;
    }
    return self;
}

-(void)drawArrow:(CGContextRef)context
{
    CGContextSaveGState(context);
    
    CGPoint tail = CGPointMake(CGRectGetMidX(frame_), CGRectGetMinY(frame_));
    
    for (NSValue *val in targetFrames_) {
        
        CGRect targetFrame = [val CGRectValue];
        
        // virtual target is nearer center of target frame, to space lines out
        // as we get farther away from target, space them out a bit more
        CGFloat dY = CGRectGetMidY(frame_) - CGRectGetMidY(targetFrame);
        CGFloat virtualDy = dY/75 * 6;    
        CGPoint targetPoint = CGPointMake(CGRectGetMidX(targetFrame), CGRectGetMaxY(targetFrame)-virtualDy);
        
        // what angle are we at? we are always pointing up
        CGFloat b = tail.y-targetPoint.y;
        CGFloat a = targetPoint.x-tail.x;
        CGFloat c = sqrtf(a*a + b*b);
        CGFloat theta = asinf(b/c);
        if (a > 0) {
            theta = M_PI - theta;
        }
        
        // to make the arrows show up half-decently, we need to place them below the box a little bit, depending on angle
        CGFloat thetaTo90 = fabsf(M_PI_2-theta);
        CGFloat yAdjust = radiansToDegrees(thetaTo90)/30;
        
        // compute target point from target frame
        // it is the point at which the line intersects the target frame, on its way to the virtual point of the target frame
        CGFloat tb = virtualDy;
        CGFloat tc = tb/sinf(theta);
        CGFloat ta = tc * cosf(theta);
        CGFloat x = targetPoint.x + ta;
        CGFloat y = targetPoint.y + tb;  
        targetPoint = CGPointMake(x, y + yAdjust);
        
        // set up context for drawing lines
        CGContextSetStrokeColorWithColor(context, [[UIColor colorWithHexString:@"818181"] CGColor]);
        CGContextSetLineWidth(context, 1.f);
        
        // draw line
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, tail.x, tail.y);
        CGPathAddLineToPoint(path, NULL, targetPoint.x, targetPoint.y);
        
        // left side of arrow
        CGFloat gamma = M_PI - 2*arrowAngle - (theta-arrowAngle);    
        CGPathAddLineToPoint(path, NULL, targetPoint.x-magnitude*cosf(gamma), targetPoint.y+magnitude*sinf(gamma));
        
        // right side of arrow
        CGPathMoveToPoint(path, NULL, targetPoint.x, targetPoint.y);
        CGFloat alpha = theta - arrowAngle;
        CGPathAddLineToPoint(path, NULL, targetPoint.x+magnitude*cosf(alpha), targetPoint.y+magnitude*sinf(alpha));
        
        // render
        CGContextAddPath(context, path);
        CGContextStrokePath(context);
        CGPathRelease(path);

        
    }

    CGContextRestoreGState(context);
}

- (void)draw:(CGContextRef)context
{
    WLog(@"Override!!");
}


@end
