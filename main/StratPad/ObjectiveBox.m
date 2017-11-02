//
//  ObjectiveBox.m
//  StratPad
//
//  Created by Julian Wood on 11-09-01.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "ObjectiveBox.h"


@implementation ObjectiveBox

@synthesize objective=objective_;

-(id)initWithObjective:(Objective *)objective frame:(CGRect)frame fontName:(NSString*)fontName fontSize:(CGFloat)fontSize fontColor:(UIColor*)fontColor color:(UIColor *)color targetFrames:(NSMutableSet *)targetFrames
{
    self = [super initWithText:objective.summary frame:frame color:color targetFrames:targetFrames];
    if (self) {
        objective_ = objective;
        fontName_ = fontName;
        fontSize_ = fontSize;
        fontColor_ = [fontColor retain];
    }
    return self;
}

- (void)dealloc
{
    [fontColor_ release];
    [super dealloc];
}

- (void)draw:(CGContextRef)context
{
    // themes are row 1
    CGContextSetFillColorWithColor(context, [self.color CGColor]);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.frame byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
    CGContextAddPath(context, [path CGPath]);
    CGContextFillPath(context); 
    
    CGRect insetRect = CGRectInset(self.frame, 3, 3);
    
    UIFont *font = [UIFont fontWithName:fontName_ size:fontSize_];
    CGSize size = [self.objective.summary sizeWithFont:font constrainedToSize:insetRect.size lineBreakMode:UILineBreakModeTailTruncation];
    
    CGContextSetFillColorWithColor(context, [fontColor_ CGColor]);
    [self.objective.summary drawInRect:CGRectMake(insetRect.origin.x, insetRect.origin.y + (insetRect.size.height-size.height)/2, insetRect.size.width, insetRect.size.height)
             withFont:font
        lineBreakMode:UILineBreakModeTailTruncation 
            alignment:UITextAlignmentCenter];
}

@end
