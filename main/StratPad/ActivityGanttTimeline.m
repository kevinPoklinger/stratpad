//
//  ActivityGanttTimeline.m
//  StratPad
//
//  Created by Eric on 11-09-22.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "ActivityGanttTimeline.h"

@implementation ActivityGanttTimeline

@synthesize title = title_;
@synthesize startDate = startDate_;
@synthesize endDate = endDate_;

- (id)initWithActivity:(Activity *)activity andStrategyStartDate:(NSDate*)strategyStartDate
{
    if ((self = [super init])) {
        
        ganttChartDetailRowClass_ = NSClassFromString(@"GanttChartActivityRow");
        
        title_ = activity.action;
        
        startDate_ = [activity.startDate copy];
        
        // if the activity has a start date, but no end date, then use an end date 
        // of 24 months after the strategy start date.
        if (activity.startDate && !activity.endDate) {
            endDate_ = [[self add24MonthsToDate:strategyStartDate] retain];            
        } else {
            endDate_ = [activity.endDate copy];
        }        
    }
    return self;    
}

- (void)dealloc
{
    [startDate_ release];
    [endDate_ release];
    [super dealloc];
}

@end
