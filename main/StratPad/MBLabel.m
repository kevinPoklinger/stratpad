//
//  MBLabel.m
//  Powercents
//
//  Created by Julian Wood on 11-05-31.
//  Copyright 2011 EnergyMobile Inc. All rights reserved.
//

#import "MBLabel.h"


@implementation MBLabel

@synthesize insets = insets_;

- (void)drawTextInRect:(CGRect)rect {
    return [super drawTextInRect:UIEdgeInsetsInsetRect(rect, self.insets)];
}

@end
