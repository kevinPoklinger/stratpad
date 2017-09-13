//
//  LinkedFieldOrganizer.m
//  StratPad
//
//  Created by Julian Wood on 2013-05-29.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//

#import "LinkedFieldOrganizer.h"

@implementation LinkedFieldOrganizer

- (void)dealloc
{
    [_linkedFields release];
    [super dealloc];
}

-(void)resignRespondersExcept:(UIResponder*)responder
{
    for (UIResponder *r in _linkedFields) {
        if (r != responder) {
            [r resignFirstResponder];
        }
    }    
}

@end
