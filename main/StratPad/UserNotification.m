//
//  UserNotification.m
//  StratPad
//
//  Created by Julian Wood on 2013-06-25.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//

#import "UserNotification.h"

@implementation UserNotification

- (void)dealloc
{
    [_color release];
    [_message release];
    [super dealloc];
}

@end
