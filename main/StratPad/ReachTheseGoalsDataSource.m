//
//  ReachTheseGoalsDataSource.m
//  StratPad
//
//  Created by Eric Rogers on September 23, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "ReachTheseGoalsDataSource.h"
#import "Theme.h"
#import "Objective.h"
#import "Goal.h"
#import "NSString-Expanded.h"
#import "NSDate-StratPad.h"
#import "TextGoal.h"


@implementation ReachTheseGoalsDataSource

@synthesize columnDates = columnDates_;
@synthesize goals = goals_;
@synthesize intervalInMonths = intervalInMonths_;

- (id)initWithStartDate:(NSDate*)startDate forIntervalInMonths:(NSUInteger)intervalInMonths;
{
    if ((self = [super init])) {
        intervalInMonths_ = intervalInMonths;
        columnDates_ = [[ChartDataSource calculateColumnStartDatesFromDate:startDate withIntervalInMonths:intervalInMonths] retain];
        goals_ = [[NSMutableDictionary dictionary] retain];        
    }
    return self;
}

- (void)dealloc
{
    [columnDates_ release];
    [goals_ release];
    [super dealloc];
}

- (void)addGoal:(id<Goal>)goal
{
    NSString *key = goal.metric;    
    
    // append the text for a text goal to the metric and use it as the key, as long as 
    // there is actually a value for the text goal.
    if ([goal isKindOfClass:[TextGoal class]]) {
        TextGoal *textGoal = (TextGoal*)goal;
        if (textGoal.value && ![textGoal.value isBlank]) {
            key = [key stringByAppendingFormat:@" %@", ((TextGoal*)goal).value];
        }
    }
    
    NSMutableArray *goalsForMetric = [goals_ objectForKey:key];
    
    if (!goalsForMetric) {
        goalsForMetric = [NSMutableArray array];
        [goals_ setObject:goalsForMetric forKey:key];
    }
    
    [goalsForMetric addObject:goal];
}

- (NSArray*)goalHeadings
{
    NSArray *sortedHeadings = [[goals_ allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2];
    }];    
    return sortedHeadings;    
}

- (NSArray*)goalsForHeading:(NSString*)heading fromColumnDateAtIndex:(NSUInteger)index
{    
    NSArray *goals = [goals_ objectForKey:heading];
    NSDate *startDate = [columnDates_ objectAtIndex:index];
    NSDate *endDate = [columnDates_ objectAtIndex:index + 1];
    
    NSMutableArray *matchingGoals = [NSMutableArray array];
    
    for (id<Goal> goal in goals) {
        if ([goal.date compareDayMonthAndYearTo:startDate] != NSOrderedAscending
            && [goal.date compareDayMonthAndYearTo:endDate] == NSOrderedAscending) {
            [matchingGoals addObject:goal];
        }
    }

    return matchingGoals;
}

@end
