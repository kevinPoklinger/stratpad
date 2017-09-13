//
//  BooleanTableViewCell.m
//  StratPad
//
//  Created by Julian Wood on 11-08-16.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "BooleanTableViewCell.h"


@implementation BooleanTableViewCell

@synthesize lblName = lblName_;
@synthesize switchOption = switchOption_;

- (void)dealloc
{
    [lblName_ release];
    [switchOption_ release];
    
    [super dealloc];
}

@end
