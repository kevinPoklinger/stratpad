//
//  ThemeDetailTextField.m
//  StratPad
//
//  Created by Julian Wood on 12-02-01.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "ThemeDetailTextField.h"
#import "UIColor-Expanded.h"
#import "SkinManager.h"

@implementation ThemeDetailTextField

@synthesize hasAdjustment = hasAdjustment_;

-(void)setHasAdjustment:(BOOL)hasAdjustment
{
    hasAdjustment_ = hasAdjustment;
    [self setNeedsDisplay];
}

-(void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    // add a little indicator if this field has an adjustment
    if (hasAdjustment_) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGFloat radius = 5.f;

        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, 15, 0);
        CGPathAddLineToPoint(path, NULL, 0, 15);                        
        CGPathAddArcToPoint(path, NULL, CGRectGetMinX(rect), CGRectGetMinY(rect), 
                            CGRectGetMaxX(rect), CGRectGetMinY(rect), radius);
        CGPathCloseSubpath(path);
        
        // color and fill
        CGContextSetFillColorWithColor(context, [[[SkinManager sharedManager] colorForProperty:kSkinSection2TextFieldCalculationColor forMediaType:MediaTypeScreen] CGColor]);
        CGContextAddPath(context, path);
        CGContextFillPath(context); 
        CFRelease(path);
    }
}

@end
