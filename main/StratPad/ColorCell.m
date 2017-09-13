//
//  ColorCell.m
//  StratPad
//
//  Created by Julian Wood on 12-04-02.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "ColorCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation ColorCell
@synthesize lblColor;
@synthesize colorView;
@synthesize lblColorScheme;

- (void)dealloc {
    [lblColor release];
    [colorView release];
    [lblColorScheme release];
    [super dealloc];
}

@end
