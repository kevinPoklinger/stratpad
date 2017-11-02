//
//  MBBindableRoundSwitch.m
//  StratPad
//
//  Created by Julian Wood on 11-08-16.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "MBBindableRoundSwitch.h"


@implementation MBBindableRoundSwitch

@synthesize binding = binding_;

-(void)sizeToFit
{
    // figure out width of switch given our text, to a max of 138
    uint maxTextWidth = 100;
    CGRect f = self.frame;
    UIFont *font = [UIFont boldSystemFontOfSize:ceilf(f.size.height * .6)];
    CGSize onSize = [self.onText sizeWithFont:font constrainedToSize:CGSizeMake(maxTextWidth, f.size.height)];
    CGSize offSize = [self.offText sizeWithFont:font constrainedToSize:CGSizeMake(maxTextWidth, f.size.height)];
    
    // right adjusted switch
    uint knobWidth = 30 + 8;
    if (MAX(onSize.width, offSize.width) + knobWidth > f.size.width) {
        CGFloat diff = MAX(onSize.width, offSize.width) + knobWidth - f.size.width;
        self.frame = CGRectMake(f.origin.x-diff, f.origin.y, f.size.width+diff, f.size.height);        
    }

}

@end
