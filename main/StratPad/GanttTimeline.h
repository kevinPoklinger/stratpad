//
//  GanttTimeline.h
//  StratPad
//
//  Created by Eric on 11-09-22.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//
//  Represents a timeline in a Gantt Report.

@interface GanttTimeline : NSObject {
    @protected
    Class ganttChartDetailRowClass_;
}

@property (nonatomic,assign) Class ganttChartDetailRowClass;

// abstract - should be overridden by subclasses
- (NSString*)title;  

// returns a date with 24 months added to the given date
- (NSDate*)add24MonthsToDate:(NSDate*)date;

// returns YES by default - override if necessary
- (BOOL)shouldDraw;

@end
