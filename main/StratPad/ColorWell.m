//
//  ColorWell.m
//  StratPad
//
//  Created by Julian Wood on 12-05-17.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "ColorWell.h"
#import "UIColor-Expanded.h"

@implementation ColorWell

@synthesize rect = rect_;
@synthesize color = color_;
@synthesize readyForPrint;

- (id)initWithRect:(CGRect)rect color:(UIColor*)color
{
    self = [super init];
    if (self) {
        rect_ = rect;
        color_ = [color retain];
    }
    return self;
}

- (void)dealloc
{
    [color_ release];
    [super dealloc];
}

- (void)sizeToFit
{
    // no-op
}

- (void)draw
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    // draw a rounded rect background in grey that will appear like a stroke
    CGContextSetFillColorWithColor(context, [[UIColor colorWithHexString:@"4c4c4c"] CGColor]);
    UIBezierPath *bgpath = [UIBezierPath bezierPathWithRoundedRect:rect_ byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(3, 3)];
    [bgpath fill];
    
    // solid fill
    CGContextSetFillColorWithColor(context, [color_ CGColor]);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(rect_, 1, 1) 
                                               byRoundingCorners:UIRectCornerAllCorners 
                                                     cornerRadii:CGSizeMake(2, 2)];
    [path fill];
    
    CGContextRestoreGState(context);

}

@end
