//
//  MBLoadingView.m
//  StratPad
//
//  Created by Julian Wood on 11-12-09.
//  Copyright (c) 2011 Glassey Strategy. All rights reserved.
//

#import "MBLoadingView.h"

@implementation MBLoadingView

- (id)initWithFrame:(CGRect)frame
{
    CGRect updateFrame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
    self = [super initWithFrame:updateFrame];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        self.tag = 92545;
        
        _progress = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _progress.center = self.center;
        [self addSubview:_progress];
        [_progress startAnimating];
        [_progress release];
    }
    return self;
}

- (void)showInView:(UIView*)view
{
    if ([view viewWithTag:92545]) {
        return;
    }
    self.alpha = 0;
    [view addSubview:self];
    [view bringSubviewToFront:self];
    [UIView animateWithDuration:0.2
                     animations:^{
                         self.alpha = 1;
                     } completion:nil
     ];    
}

- (void)dismiss
{
    [UIView animateWithDuration:0.2
                     animations:^{
                         self.alpha = 0;
                     } completion:^(BOOL finished){
                         if (finished) {
                             [self removeFromSuperview];
                         }
                     }
     ];    
}

@end
