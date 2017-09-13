//
//  GanttDataSource.m
//  StratPad
//
//  Created by Eric on 11-09-22.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "GanttDataSource.h"
#import "NSDate-StratPad.h"

NSUInteger const ganttNumColumns = 8;

@implementation GanttDataSource

@synthesize columnDates = columnDates_;
@synthesize timelines = timelines_;
@synthesize intervalInMonths = intervalInMonths_;

- (id)initWithStartDate:(NSDate*)startDate forIntervalInMonths:(NSUInteger)intervalInMonths
{
    if ((self = [super init])) {      
        intervalInMonths_ = intervalInMonths;
        columnDates_ = [[ChartDataSource calculateColumnStartDatesFromDate:startDate withIntervalInMonths:intervalInMonths] retain];
        timelines_ = [[NSMutableArray array] retain];
    }
    return self;
}

- (void)dealloc
{
    [columnDates_ release];
    [timelines_ release];
    
    [super dealloc];
}

@end
