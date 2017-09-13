//
//  RoundedRectView.m
//  MBExperimental
//
//  Created by Julian Wood on 11-07-30.
//  Copyright 2011 Mobilesce Inc. All rights reserved.
//

#import "MBRoundedRectView.h"
#import <QuartzCore/QuartzCore.h>

@implementation MBRoundedRectView

@synthesize roundedRectBackgroundColor = roundedRectBackgroundColor_;

// programmatically
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        roundedRectBackgroundColor_ = [self.backgroundColor retain];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

// IB
- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        roundedRectBackgroundColor_ = [self.backgroundColor retain];
        self.backgroundColor = [UIColor clearColor];        
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{        
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(5, 5)];
    [roundedRectBackgroundColor_ setFill];
    
    [path fill];
    
}
- (void)dealloc
{
    [roundedRectBackgroundColor_ release];
    [super dealloc];
}

@end
