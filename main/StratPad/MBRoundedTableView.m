//
//  MBRoundedTableView.m
//  StratPad
//
//  Created by Eric on 11-08-17.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "MBRoundedTableView.h"
#import <QuartzCore/QuartzCore.h>

@interface HighlightView : UIView 
@end

@implementation HighlightView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(void)drawRect:(CGRect)rect 
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(8, 8)];

    CGContextSetLineWidth(context, 3);
    CGContextSetStrokeColorWithColor(context, [[UIColor blueColor] CGColor]);
    CGContextAddPath(context, [path CGPath]);
    CGContextStrokePath(context);

    [super drawRect:rect];
}

@end

@implementation MBRoundedTableView

- (void)drawRect:(CGRect)rect
{
    self.layer.cornerRadius = 8.0;
    
    [super drawRect:rect];
}

- (BOOL)becomeFirstResponder
{
    HighlightView *highlightView = [[HighlightView alloc] initWithFrame:self.bounds];
    highlightView.alpha = 0;
    [self addSubview:highlightView];
    [highlightView release];
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         highlightView.alpha = 1.0;
                     } completion:^(BOOL finished) {                         
                         [UIView animateWithDuration:0.5
                                          animations:^{
                                              highlightView.alpha = 0;
                                          } completion:^(BOOL finished) {                         
                                              [highlightView removeFromSuperview];
                                          }
                          ];    
                     }
     ];    
    
    return YES;
}

@end
