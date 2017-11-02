//
//  NSCalendar+Expanded.h
//  StratPad
//
//  Created by Eric Rogers on September 27, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//
//  Provides the ability to access a cached calendar instance which is 
//  faster than creating one each time we need to perform a calendrical 
//  calculation.  For more information see:
//  http://www.mikeabdullah.net/NSCalendar_currentCalendar.html


@interface NSCalendar (Expanded)

// returns a calendar set to the current time zone.
+ (NSCalendar *)cachedGregorianCalendar;

// returns a calendar set to UTC
// @deprecated use the calendar for the current time zone
+ (NSCalendar *)cachedUTCGregorianCalendar;

@end
