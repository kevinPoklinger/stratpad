//
//  ChartDataSource.h
//  StratPad
//
//  Created by Julian Wood on 12-02-06.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChartDataSource : NSObject

// returns an array containing the starting UTC dates of each interval beginning
// in the month of the given date, for 8 intervals.
+(NSArray*)calculateColumnStartDatesFromDate:(NSDate*)date withIntervalInMonths:(NSUInteger)intervalInMonths;

// what used to be quarters, now we calculate a time period that best fits 8 columns
+ (NSUInteger)columnIntervalForStrategyDuration:(NSUInteger)durationInMonths;

@end
