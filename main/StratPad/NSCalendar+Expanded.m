//
//  NSCalendar+Expanded.m
//  StratPad
//
//  Created by Eric Rogers on September 27, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "NSCalendar+Expanded.h"

@implementation NSCalendar (Expanded)

+ (NSCalendar *)cachedGregorianCalendar
{
    static NSCalendar *cachedGregorian;
    if (!cachedGregorian) {
        cachedGregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        [cachedGregorian setTimeZone:[NSTimeZone localTimeZone]];
    }
    return cachedGregorian;
}

+ (NSCalendar *)cachedUTCGregorianCalendar
{
    static NSCalendar *cachedUTCGregorian;
    if (!cachedUTCGregorian) {
        cachedUTCGregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];        
        [cachedUTCGregorian setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    }
    return cachedUTCGregorian;
}
@end
