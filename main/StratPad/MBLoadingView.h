//
//  MBLoadingView.h
//  StratPad
//
//  Created by Julian Wood on 11-12-09.
//  Copyright (c) 2011 Glassey Strategy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MBLoadingView : UIView

@property (nonatomic, assign) UIActivityIndicatorView *progress;

- (void)showInView:(UIView*)view;
- (void)dismiss;

@end
