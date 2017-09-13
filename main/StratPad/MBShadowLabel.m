//
//  MBShadowLabel.m
//  StratPad
//
//  Created by Julian Wood on 11-08-09.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "MBShadowLabel.h"


@implementation MBShadowLabel

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

- (void)drawRect:(CGRect)rect 
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, 
                                CGSizeMake(3.f, 3.f), 
                                2.f, 
                                [[[UIColor blackColor] colorWithAlphaComponent:0.5] CGColor]);
    CGContextSetFillColorWithColor(context, [self.textColor CGColor]);
    
    UIFont *font = [UIFont systemFontOfSize:self.font.pointSize];
    
    // right aligned
    CGSize size = [self.text sizeWithFont:font];
    CGPoint origin = CGPointMake(rect.size.width - size.width, 0.f);
    
    // draw text
    [self.text drawAtPoint:origin withFont:font];
    
     // stop drawing shadows
    CGContextRestoreGState(context);
}

@end
