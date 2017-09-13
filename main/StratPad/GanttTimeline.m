//
//  GanttTimeline.m
//  StratPad
//
//  Created by Eric on 11-09-22.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "GanttTimeline.h"
#import "NSCalendar+Expanded.h"


@implementation GanttTimeline

@synthesize ganttChartDetailRowClass = ganttChartDetailRowClass_;

- (NSString*)title
{
    WLog(@"Should be overridden");
    return nil;
}

- (NSDate*)add24MonthsToDate:(NSDate*)date
{
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setMonth:24];
    NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];
    NSDate *newDate = [gregorian dateByAddingComponents:comps toDate:date options:0];
    
    [comps release]; 
    return newDate;
}

- (BOOL)shouldDraw 
{
    return YES;
}

@end
