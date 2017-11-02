//
//  ColorChooserCell.m
//  StratPad
//
//  Created by Julian Wood on 12-04-13.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "ColorChooserCell.h"

@implementation ColorChooserCell
@synthesize colorView;
@synthesize lblTitle;

- (void)dealloc {
    [colorView release];
    [lblTitle release];
    [super dealloc];
}
@end
