//
//  RoundedGradientShadowLabel.h
//  StratPad
//
//  Created by Julian Wood on 11-08-09.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//
//  Draws a label as normal on top of a rounded rect, with a gradient background and a drop shadow. Make 
//  sure your label's bounds are 3px greater than they would normally be, to leave room for drawing the shadow.


@interface RoundedGradientShadowLabel : UILabel {
@private
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
