//
//  ChartDataSource.m
//  StratPad
//
//  Created by Julian Wood on 12-02-06.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "ChartDataSource.h"
#import "NSDate-StratPad.h"
#import "NSCalendar+Expanded.h"

@implementation ChartDataSource

+ (NSArray*)calculateColumnStartDatesFromDate:(NSDate*)date withIntervalInMonths:(NSUInteger)intervalInMonths
{
    NSMutableArray *columnDates = [NSMutableArray arrayWithCapacity:9];
    
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setMonth:intervalInMonths];
    NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];
    
    [columnDates addObject:[NSDate dateSetToFirstDayOfMonthForDate:date]];
    for (int i = 0; i < 8; i++) {  
        NSDate *lastDate = [columnDates lastObject];
        NSDate *nextDate = [gregorian dateByAddingComponents:comps toDate:lastDate options:0];
        [columnDates addObject:[NSDate dateSetToFirstDayOfMonthForDate:nextDate]];
    }
    [comps release];
    
    return columnDates;
}

+ (NSUInteger)columnIntervalForStrategyDuration:(NSUInteger)durationInMonths
{
    if (durationInMonths <= 8) {
        return 1;
    }
    else if (durationInMonths <= 24) {
        return 3;
    }
    else if (durationInMonths <= 48) {
        return 6;
    }
    else {
        return 12;
    }    
}


@end
