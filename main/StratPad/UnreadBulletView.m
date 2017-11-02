//
//  UnreadBulletView.m
//  StratPad
//
//  Created by Julian Wood on 12-10-01.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "UnreadBulletView.h"
#import "UIColor-Expanded.h"

@implementation UnreadBulletView

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
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddEllipseInRect(path, NULL, rect);
    
    // color and fill
    CGContextSetFillColorWithColor(context, [[UIColor colorWithHexString:@"3f74c0"] CGColor]);
    CGContextAddPath(context, path);
    CGContextFillPath(context);
    CFRelease(path);
    
    [super drawRect:rect];
}

@end
