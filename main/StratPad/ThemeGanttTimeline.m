//
//  ThemeGanttTimeline.m
//  StratPad
//
//  Created by Eric on 11-09-22.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "ThemeGanttTimeline.h"

@implementation ThemeGanttTimeline

@synthesize title = title_;
@synthesize startDate = startDate_;
@synthesize endDate = endDate_;

- (id)initWithTheme:(Theme *)theme andStrategyStartDate:(NSDate*)strategyStartDate
{
    if ((self = [super init])) {

        ganttChartDetailRowClass_ = NSClassFromString(@"GanttChartThemeRow");
        
        title_ = theme.title;
        
        // if the theme has no start date, then use the strategy start date.
        startDate_ = theme.startDate ? [theme.startDate copy] : [strategyStartDate copy];        

        // if the theme has no end date, then use an end date of 24 months after the
        // strategy start date.
        if (!theme.endDate) {
            endDate_ = [[self add24MonthsToDate:strategyStartDate] retain];            
        } else {
            endDate_ = [theme.endDate copy];
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
