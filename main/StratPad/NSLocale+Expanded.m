//
//  NSLocale+Expanded.m
//  StratPad
//
//  Created by Julian Wood on 12-08-15.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "NSLocale+Expanded.h"

@implementation NSLocale (Expanded)

- (NSString *)displayNameForKeyExpanded:(id)key value:(id)value
{
    // check our list first
    if ([key isEqualToString:NSLocaleCountryCode]) {
        if ([value isEqualToString:@"es-MX"]) {
            return @"México"; // show it's own localization, regardless of user-chosen localization
        }
    }
    
    return [self displayNameForKey:key value:value];
}

@end
