//
//  GanttDataSource.h
//  StratPad
//
//  Created by Eric Rogers on September 22, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//
//  Stores the starting date of each quarter, and timelines, for the Gantt chart.

#import "GanttTimeline.h"
#import "StratFile.h"
#import "ChartDataSource.h"

extern NSUInteger const ganttNumColumns;

@interface GanttDataSource : ChartDataSource {
@private
    NSArray *columnDates_;
    NSMutableArray *timelines_;
    NSUInteger intervalInMonths_;
}

- (id)initWithStartDate:(NSDate*)startDate forIntervalInMonths:(NSUInteger)intervalInMonths;

@property(nonatomic, readonly) NSArray *columnDates;
@property(nonatomic, readonly) NSMutableArray *timelines;
@property(nonatomic, readonly) NSUInteger intervalInMonths;

@end
