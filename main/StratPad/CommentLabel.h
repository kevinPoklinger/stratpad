//
//  CommentLabel.h
//  StratPad
//
//  Created by Julian Wood on 12-04-27.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//
//  Draws a multiline label with the supplied text, constrained to the supplied frame.
//  Label will be shrunk to fit around the text.
//  Background is a gradient with rounded edges and a shadow.
//  Call showComment to animate opening.

#import <UIKit/UIKit.h>

typedef enum {
    AnimationDirectionSE,
    AnimationDirectionNE,
    AnimationDirectionNW,
    AnimationDirectionSW
} AnimationDirection;

@interface CommentLabel : UIView {
    CGRect preferredFrame_;
    UIColor *gradientStartColor_;
    UIColor *gradientEndColor_;
    AnimationDirection animationDirection_;
}

@property (nonatomic,copy) NSString *text;
@property (nonatomic,assign) BOOL isShowing;

// we figure out the best rect for showing this comment
@property (nonatomic,assign,readonly) CGSize preferredFrame;

// chartRect is the space available for drawing in, so we can decide if we need to draw left or right side, fat or thin, etc
// commentBoxRect is the comment bubble already showing, that was tapped - used to locate our comment label
// text to show and background colours
- (id)initWithChartRect:(CGRect)chartRect
         commentBoxRect:(CGRect)commentBoxRect
                andText:(NSString*)text 
     gradientStartColor:(UIColor*)gradientStartColor 
       gradientEndColor:(UIColor*)gradientEndColor;
- (void)dismissComment;
- (void)showComment;

@end
