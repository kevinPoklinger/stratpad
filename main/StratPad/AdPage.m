//
//  AdPage.m
//  StratPad
//
//  Created by Julian Wood on 12-01-04.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "AdPage.h"

@implementation AdPage

- (id)initWithDictionary:(NSDictionary*)dict
{
    self = [super initWithDictionary:dict];
    if (self) {
        self.client = [dict objectForKey:@"Client"];
        self.url = [dict objectForKey:@"URL"];
    }
    return self;
}


-(void)dealloc
{    
    [_client release];
    [_url release];
    [super dealloc];
}


@end
