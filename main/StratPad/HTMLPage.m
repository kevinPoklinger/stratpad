//
//  HTMLPage.m
//  StratPad
//
//  Created by Eric on 11-07-28.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "HTMLPage.h"

@implementation HTMLPage

- (id)initWithDictionary:(NSDictionary*)dict
{
    self = [super initWithDictionary:dict];
    if (self) {
        self.filename = [dict objectForKey:@"Filename"];
    }
    return self;
}

- (void)dealloc
{
    [_filename release];
    [super dealloc];
}

@end
