//
//  CommentLabel.m
//  StratPad
//
//  Created by Julian Wood on 12-04-27.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "CommentLabel.h"
#import "UIColor-Expanded.h"
#import <QuartzCore/QuartzCore.h>

// the insets between the text and the label bounds
#define padding 5.f

@implementation CommentLabel

@synthesize text=text_;
@synthesize isShowing;
@synthesize preferredFrame;

- (id)init
{
    self = [super init];
    if (self) {
        NSAssert(text_ != nil, @"You must provide text.");
    }
    return self;
}

- (id)initWithChartRect:(CGRect)chartRect
         commentBoxRect:(CGRect)commentBoxRect
                andText:(NSString*)text 
     gradientStartColor:(UIColor*)gradientStartColor 
       gradientEndColor:(UIColor*)gradientEndColor
{
    self = [super init];
    if (self) {
        text_ = text;
        gradientStartColor_ = [gradientStartColor retain];
        gradientEndColor_ = [gradientEndColor retain];
        isShowing = NO;
                
        [self calculateCommentLabelCoords:commentBoxRect chartRect:chartRect];

        // rounded rect with shadow
        self.backgroundColor = [UIColor clearColor];
        self.layer.masksToBounds = NO;
        self.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.layer.shadowOffset = CGSizeMake(0,-1);
        self.layer.shadowRadius = 2;
        self.layer.shadowOpacity = 0.7;
        
        // use showComment
        self.hidden = YES;
        
        UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissComment)];
        [self addGestureRecognizer:gestureRecognizer];
        [gestureRecognizer release];
    }
    return self;
}

- (void)showComment
{    
    self.hidden = NO;
    
    // drawrect has already drawn at proper size, so set the frame as a startpoint for an animation
    // want to get the animation to appear to come from near commentBox
    switch (animationDirection_) {
            
        case AnimationDirectionNE:
            self.frame = CGRectMake(preferredFrame_.origin.x, 
                                    preferredFrame_.origin.y+preferredFrame_.size.height,
                                    0, 0);
            break;
            
        case AnimationDirectionNW:
            self.frame = CGRectMake(preferredFrame_.origin.x+preferredFrame_.size.width, 
                                    preferredFrame_.origin.y+preferredFrame_.size.height, 
                                    0, 0);
            break;
            
        case AnimationDirectionSW:
            self.frame = CGRectMake(preferredFrame_.origin.x+preferredFrame_.size.width, 
                                    preferredFrame_.origin.y, 
                                    0, 0);
            break;
            
        default: // AnimationDirectionSE
            self.frame = CGRectMake(preferredFrame_.origin.x, 
                                    preferredFrame_.origin.y, 
                                    0, 0);            
            break;
    }

    [UIView animateWithDuration:0.3
                     animations:^{
                         self.frame = preferredFrame_;
                         isShowing = YES;
                     }
     ];
}

- (void)dismissComment
{
    CGRect targetFrame;
    switch (animationDirection_) {
        case AnimationDirectionNE:
            targetFrame = CGRectMake(self.frame.origin.x, 
                                     self.frame.origin.y+self.frame.size.height, 
                                     0, 0);
            break;
            
        case AnimationDirectionNW:
            targetFrame = CGRectMake(self.frame.origin.x+self.frame.size.width, 
                                     self.frame.origin.y+self.frame.size.height, 
                                     0, 0);
            break;
            
        case AnimationDirectionSW:
            targetFrame = CGRectMake(self.frame.origin.x+self.frame.size.width, 
                                     self.frame.origin.y, 
                                     0, 0);
            break;
            
        default: // AnimationDirectionSE
            targetFrame = CGRectMake(self.frame.origin.x, 
                                     self.frame.origin.y, 
                                     0, 0);
            break;
    }    

    [UIView animateWithDuration:0.3
                     animations:^{
                         self.frame = targetFrame;
                     } 
                     completion:^(BOOL finished) {
                         [self removeFromSuperview];
                         isShowing = NO;
                     }
     ];
}

#pragma mark - Private

- (void)dealloc
{
    [gradientStartColor_ release];
    [gradientEndColor_ release];
    [super dealloc];
}

- (void)drawRect:(CGRect)rect
{
    // we'll constrain to rect.size and maintain the rect.origin
    // if we need less than 1 line then allow it to shrink
    // otherwise expand height as necessary
    // draw a rounded rect with a gradient background and a drop shadow
    // animate in via fade
    // auto-fade out after 5s
    // also allow a touch to cancel it immediately, either in or outside the label
        
    CGRect boxRect = CGRectMake(rect.origin.x, rect.origin.y, preferredFrame_.size.width, preferredFrame_.size.height);
    CGRect textRect = CGRectInset(boxRect, padding, padding);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // make the gradient
    CGFloat colors [] = { 
        gradientStartColor_.red, gradientStartColor_.green, gradientStartColor_.blue, 0.9,
        gradientEndColor_.red, gradientEndColor_.green, gradientEndColor_.blue, 0.9
    };
    
    CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, colors, NULL, 2);
    CGColorSpaceRelease(baseSpace), baseSpace = NULL;
    
    // in order to reset the paths
    CGContextSaveGState(context);
    
    // shadow for the text
    UIColor *shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    CGContextSetShadowWithColor(context, CGSizeMake(0, -1.f), 1.f, [shadowColor CGColor]);    

    
    // rounded rect
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:boxRect 
                                               byRoundingCorners:UIRectCornerAllCorners
                                                     cornerRadii:CGSizeMake(3, 3)];
        
    // clip to rounded rect
    CGContextAddPath(context, path.CGPath);
    CGContextClip(context);
    
    // draw the gradient in our clipped area
    CGPoint startPoint = CGPointMake(CGRectGetMidX(boxRect), CGRectGetMinY(boxRect));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(boxRect), CGRectGetMaxY(boxRect));
    
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGGradientRelease(gradient);
    
    // draw the text    
    CGContextSetFillColorWithColor(context, [[UIColor colorWithHexString:@"FFFFFF"] CGColor]);
    [text_ drawInRect:textRect 
              withFont:[UIFont systemFontOfSize:14]
         lineBreakMode:UILineBreakModeWordWrap
             alignment:UITextAlignmentCenter];
    
    // restore
    CGContextRestoreGState(context);    
}

-(void)calculateCommentLabelCoords:(CGRect)commentBoxRect chartRect:(CGRect)chartRect
{
    // calculate optimal size
    CGSize preferredTextBoxSize = [text_ sizeWithFont:[UIFont systemFontOfSize:14]
                                    constrainedToSize:CGSizeMake(100, 300)
                                        lineBreakMode:UILineBreakModeWordWrap];
    
    CGSize actualTextBoxSize = [text_ sizeWithFont:[UIFont systemFontOfSize:14]
                                 constrainedToSize:CGSizeMake(100, 999)
                                     lineBreakMode:UILineBreakModeWordWrap];
    
    if (actualTextBoxSize.height > preferredTextBoxSize.height) {
        // we must have truncated, so alleviate a little
        preferredTextBoxSize = [text_ sizeWithFont:[UIFont systemFontOfSize:14]
                                 constrainedToSize:CGSizeMake(200, 400)
                                     lineBreakMode:UILineBreakModeWordWrap];        
    }
    
    // start with SE and work ccw
    CGRect boxRect;
    CGPoint commentLabelOrigin;
    BOOL isPlaced = NO;
    AnimationDirection dir = AnimationDirectionSE;
    while (!isPlaced) {
        switch (dir) {
            case AnimationDirectionNE:
                // needs to be oriented such that bottom-left corner of commentLabel aligns with bottom right corner of commentBox
                commentLabelOrigin = CGPointMake(commentBoxRect.origin.x+commentBoxRect.size.width+2, 
                                                 commentBoxRect.origin.y+commentBoxRect.size.height-preferredTextBoxSize.height-padding*2);
                animationDirection_ = AnimationDirectionNE;
                break;
                
            case AnimationDirectionNW:
                // needs to be oriented such that bottom-right corner of commentLabel aligns with bottom left corner of commentBox
                commentLabelOrigin = CGPointMake(commentBoxRect.origin.x-2-preferredTextBoxSize.width-padding*2, 
                                                 commentBoxRect.origin.y+commentBoxRect.size.height-preferredTextBoxSize.height-padding*2);
                animationDirection_ = AnimationDirectionNW;                
                break;
                
            case AnimationDirectionSW:
                // needs to be oriented such that top-right corner of commentLabel aligns with top left corner of commentBox
                commentLabelOrigin = CGPointMake(commentBoxRect.origin.x-2-preferredTextBoxSize.width-padding*2, 
                                                 commentBoxRect.origin.y);                
                animationDirection_ = AnimationDirectionSW;
                break;
                
            default: // AnimationDirectionSE
                // top right corner of commentBox -> extends to SE
                commentLabelOrigin = CGPointMake(commentBoxRect.origin.x+commentBoxRect.size.width+2, commentBoxRect.origin.y);
                animationDirection_ = AnimationDirectionSE;
                break;
                
        }
        
        // rect for the commentLabel
        boxRect = CGRectMake(commentLabelOrigin.x, commentLabelOrigin.y, 
                             preferredTextBoxSize.width+padding*2, preferredTextBoxSize.height+padding*2);                
        
        if (CGRectContainsRect(chartRect, boxRect)) {
            // we're good to go - store it for drawRect and showComment
            self.frame = boxRect;
            preferredFrame_ = boxRect;
            isPlaced = YES;
        }
        
        dir++;
    }
}


@end
