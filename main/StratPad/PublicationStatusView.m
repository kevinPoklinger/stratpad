//
//  PublicationStatusView.m
//  StratPad
//
//  Created by Julian Wood on 12-09-27.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "PublicationStatusView.h"
#import "UIColor-Expanded.h"

@implementation PublicationStatusView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.alpha = 0.5f;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat radius = 3.f;

    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, rect.size.width, 0);
    CGPathAddLineToPoint(path, NULL, 0, rect.size.width);
    CGPathAddArcToPoint(path, NULL, CGRectGetMinX(rect), CGRectGetMinY(rect),
                        CGRectGetMaxX(rect), CGRectGetMinY(rect), radius);
    CGPathCloseSubpath(path);
    
    // color and fill
    CGContextSetFillColorWithColor(context, [[UIColor colorWithHexString:@"22A4D5"] CGColor]);
    CGContextAddPath(context, path);
    CGContextFillPath(context);
    CFRelease(path);
    
    [super drawRect:rect];
}

@end
