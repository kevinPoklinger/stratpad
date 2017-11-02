//
//  Objective.m
//  StratPad
//
//  Created by Eric Rogers on October 17, 2011.
//  Copyright (c) 2011 Glassey Strategy. All rights reserved.
//

#import "Objective.h"
#import "Activity.h"
#import "Frequency.h"
#import "Metric.h"
#import "ObjectiveType.h"
#import "Theme.h"
#import "DataManager.h"
#import "NSDate-StratPad.h"
#import "NumericGoal.h"
#import "TextGoal.h"

@implementation Objective

@dynamic order;
@dynamic summary;
@dynamic reviewFrequency;
@dynamic theme;
@dynamic objectiveType;
@dynamic activities;
@dynamic metrics;

#pragma mark - Convenience

- (NSMutableArray*)activitiesSortedByOrder
{
    NSSortDescriptor *orderSort = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    NSArray *sortDescriptorArray = [NSArray arrayWithObjects: orderSort, nil];
    [orderSort release];
    
    NSSet *unsortedActivities = self.activities;    
    NSMutableArray *sortedActivities = [NSMutableArray arrayWithArray:[unsortedActivities sortedArrayUsingDescriptors:sortDescriptorArray]];    
    return sortedActivities;
}

- (NSMutableArray*)activitiesSortedByDate
{
    // would like to see starts go in order
    // then ends (ie shorter bars first)
    // if no start, then use the end
    // if neither, use the order (ie that you see on F7)
        
    NSArray *sortDescriptorArray = [NSArray arrayWithObjects:
                                    [NSSortDescriptor sortDescriptorWithKey:@"startDate" ascending:YES],
                                    [NSSortDescriptor sortDescriptorWithKey:@"endDate" ascending:YES],
                                    [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES],
                                    nil];
    
    NSSet *unsortedActivities = self.activities;    
    NSMutableArray *sortedActivities = [NSMutableArray arrayWithArray:[unsortedActivities sortedArrayUsingDescriptors:sortDescriptorArray]];
    return sortedActivities;
}

- (NSDate*)earliestDate
{
    NSDate *date = [NSDate distantFuture];
    for (Metric *metric in self.metrics) {
        if ([metric.targetDate compare:date] == NSOrderedAscending) {
            date = metric.targetDate;
        }
    }
    
    for (Activity *activity in self.activities) {
        if (activity.startDate && [activity.startDate compare:date] == NSOrderedAscending) {
            date = activity.startDate;
        } 
        else if (activity.endDate && [activity.endDate compare:date] == NSOrderedAscending) {
            date = activity.endDate;
        }
    }
    return [date isEqual:[NSDate distantFuture]] ? nil : date;
}

- (NSDate*)latestDate
{
    NSDate *date = [NSDate distantPast];
    for (Metric *metric in self.metrics) {
        if ([metric.targetDate isAfter:date]) {
            date = metric.targetDate;
        }
    }
    
    for (Activity *activity in self.activities) {
        if (activity.endDate && [activity.endDate isAfter:date]) {
            date = activity.endDate;
        } 
        else if (activity.startDate && [activity.startDate isAfter:date]) {
            date = activity.startDate;
        }
    }
    return [date isEqual:[NSDate distantPast]] ? nil : date;
}


@end
