//
//  Page.m
//  StratPad
//
//  Created by Eric on 11-07-28.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "Page.h"


@implementation Page

- (id)initWithDictionary:(NSDictionary*)dict
{
    self = [super init];
    if (self) {
        self.viewControllerClass = [dict objectForKey:@"ViewController"];
    }
    return self;
}

- (void)dealloc
{
    [_viewControllerClass release];
    [super dealloc];
}

@end
