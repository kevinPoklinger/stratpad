//
//  MBFancyLabel.m
//  StratPad
//
//  Created by Julian Wood on 11-08-25.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "MBFancyLabel.h"


@implementation MBFancyLabel

-(id)initWithTitle:(NSString*)title
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.font = [UIFont systemFontOfSize:24];
        CGSize size = [title sizeWithFont:self.font];
        self.bounds = CGRectMake(0, 0, size.width+90, size.height+90);
        self.textAlignment = UITextAlignmentCenter;
        self.textColor = [UIColor whiteColor];
        self.text = title;
        self.numberOfLines = 1;  
        self.alpha = 1;
        self.opaque = YES;
    }
    return self;
}

-(void)drawRect:(CGRect)rect
{
    // increase bounds a little to account for a rounded rect
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // make room for the shadow and stroke
    CGRect subRect = CGRectInset(rect, 6, 6);
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:subRect
                                               byRoundingCorners:UIRectCornerAllCorners 
                                                     cornerRadii:CGSizeMake(5, 5)];
    CGContextSaveGState(context);
    
    CGContextSetFillColorWithColor(context, [[[UIColor blackColor] colorWithAlphaComponent:0.6] CGColor]);    
    [path fill]; 
    
    CGContextSetShadowWithColor(context, 
                                CGSizeMake(4.f, 4.f), 
                                2.f, 
                                [[[UIColor blackColor] colorWithAlphaComponent:0.5] CGColor]);

    CGContextSetStrokeColorWithColor(context, [[UIColor whiteColor] CGColor]);
    CGContextSetLineWidth(context, 2.f);
    [path stroke];

    CGContextRestoreGState(context);     
    
    [super drawRect:rect];
}

@end
