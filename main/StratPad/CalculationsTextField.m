//
//  CalculationsTextField.m
//  StratPad
//
//  Created by Julian Wood on 12-02-02.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "CalculationsTextField.h"
#import "Theme.h"
#import "NSNumber-StratPad.h"
#import "UIColor-Expanded.h"
#import "SkinManager.h"

static CGFloat overlayWidth = 75.f;

@implementation CalculationsTextField

-(void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat radius = 5.f;
        
    // show the corresponding value to the adjustment, iff there is a value
    Theme *theme = (Theme*)self.boundEntity;
    NSString *propertyName = [self.boundProperty substringWithRange:NSMakeRange(0, self.boundProperty.length - @"Adjustment".length)];
    NSNumber *value = [theme valueForKey:propertyName];
        
    if (value != nil && [value doubleValue] != 0) {
        // reserve part of the cell for the value
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, overlayWidth, 0);
        CGPathAddLineToPoint(path, NULL, overlayWidth-15, CGRectGetMaxY(rect));                        
        CGPathAddArcToPoint(path, NULL, CGRectGetMinX(rect), CGRectGetMaxY(rect), 
                            CGRectGetMinX(rect), CGRectGetMinY(rect), radius);
        CGPathAddArcToPoint(path, NULL, CGRectGetMinX(rect), CGRectGetMinY(rect), 
                            CGRectGetMaxX(rect), CGRectGetMinY(rect), radius);
        CGPathCloseSubpath(path);
        
        // color and fill
        CGContextSetFillColorWithColor(context, [[[SkinManager sharedManager] colorForProperty:kSkinSection2TextFieldCalculationColor forMediaType:MediaTypeScreen] CGColor]);
        CGContextAddPath(context, path);
        CGContextFillPath(context);
        CFRelease(path);
        
        // write the value
        CGRect textRect = CGRectMake(rect.origin.x+2, rect.origin.y, rect.size.width, rect.size.height);
        CGContextSetFillColorWithColor(context, [[UIColor colorWithHexString:@"FFFFFF"] CGColor]);
        [[value decimalFormattedNumberWithZeroDisplay:NO] drawInRect:textRect withFont:[UIFont systemFontOfSize:12.f]];
    }
        
}

-(CGRect)editingRectForBounds:(CGRect)bounds
{
    // see if we have a value
    Theme *theme = (Theme*)self.boundEntity;
    NSString *propertyName = [self.boundProperty substringWithRange:NSMakeRange(0, self.boundProperty.length - @"Adjustment".length)];
    NSNumber *value = [theme valueForKey:propertyName];

    CGRect r = [super editingRectForBounds:bounds];
    if (value != nil && [value doubleValue] != 0) {
        // don't let them write in the overlay
        return CGRectMake(r.origin.x+(overlayWidth-15), r.origin.y, r.size.width-(overlayWidth-15), r.size.height);
    } else {
        return r;
    }
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    // see if we have a value
    Theme *theme = (Theme*)self.boundEntity;
    NSString *propertyName = [self.boundProperty substringWithRange:NSMakeRange(0, self.boundProperty.length - @"Adjustment".length)];
    NSNumber *value = [theme valueForKey:propertyName];
    
    CGRect r = [super textRectForBounds:bounds];
    if (value != nil && [value doubleValue] != 0) {
        // don't let them write in the overlay
        return CGRectMake(r.origin.x+(overlayWidth-15), r.origin.y, r.size.width-(overlayWidth-15), r.size.height);
    } else {
        return r;
    }    
}

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender
{    
    // these are things like cut: copy: paste:
    return NO;
}



@end
