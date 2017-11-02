//
//  MBTextField.m
//  StratPad
//
//  Created by Eric Rogers on August 15, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "MBTextField.h"
#import "StratFileManager.h"

@implementation MBTextField

@synthesize label = label_;

- (void)setBindingWithEntity:(id)entity andProperty:(NSString*)property
{
    self.boundEntity = entity;
    self.boundProperty = property;
}

- (void)dealloc
{
    [label_ release];
    [_boundEntity release];
    [_boundProperty release];
    [super dealloc];
}

@end
