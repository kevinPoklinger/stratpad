//
//  MBFormInstructionsLabel.m
//  StratPad
//
//  Created by Julian Wood on 11-10-03.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "MBFormInstructionsLabel.h"
#import "UIColor-Expanded.h"
#import "ApplicationSkin.h"

@implementation MBFormInstructionsLabel

@synthesize strokeColor = strokeColor_;

// programmatically
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.insets = UIEdgeInsetsMake(2, 10, 2, 10);
    }
    return self;
}

// IB
- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.insets = UIEdgeInsetsMake(2, 10, 2, 10);
    }
    return self;
}

- (void)dealloc
{
    [strokeColor_ release];
    [super dealloc];
}

-(void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
        
    CGContextSetStrokeColorWithColor(context, [self.strokeColor CGColor]);
    CGContextSetLineWidth(context, 3);
    CGContextStrokeRect(context, rect);    
    
    [super drawRect:rect];
}


@end
