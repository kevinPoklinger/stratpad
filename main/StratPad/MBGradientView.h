//
//  MBGradientView.h
//  StratPad
//
//  Created by Julian Wood on 11-08-09.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//
//  Draws an axial gradient of the 2 specified colors from start to end. The gradient fills in the rest
//  of the rect with solid colours at the ends of the gradient.

#import <UIKit/UIKit.h>


@interface MBGradientView : UIView {
    UIColor *color1_;
    UIColor *color2_;
    
    NSValue *gradientStartPoint_;
    NSValue *gradientEndPoint_;
}

@property (nonatomic, retain) UIColor *color1;
@property (nonatomic, retain) UIColor *color2;

@property (nonatomic, retain) NSValue *gradientStartPoint;
@property (nonatomic, retain) NSValue *gradientEndPoint;

@end
