//
//  ReachTheseGoalsDataSource.h
//  StratPad
//
//  Created by Eric Rogers on September 23, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//
//  Stores the date of each quarter, and goals, for the Reach These Goals chart.

#import "StratFile.h"
#import "Goal.h"
#import "ChartDataSource.h"

@interface ReachTheseGoalsDataSource : ChartDataSource {
@private
    // stores dates corresponding to the beginning of each quarter for a total of 24 months.
    NSArray *columnDates_;

    // keyed by goal metrics, contains arrays of matching goals.
    NSMutableDictionary *goals_; 
    
    NSUInteger intervalInMonths_;
}

@property(nonatomic, readonly) NSArray *columnDates;
@property(nonatomic, readonly) NSMutableDictionary *goals;
@property(nonatomic, readonly) NSUInteger intervalInMonths;


- (id)initWithStartDate:(NSDate*)startDate forIntervalInMonths:(NSUInteger)intervalInMonths;

- (void)addGoal:(id<Goal>)goal;

// provides the names of the goals (metrics) ordered alphabetically.
- (NSArray*)goalHeadings;

// returns the goals for the specified goal heading that occur on, or after the column date corresponding to the 
// given index, but before the column date, correpsonding to the subsequent index.
- (NSArray*)goalsForHeading:(NSString*)heading fromColumnDateAtIndex:(NSUInteger)index;

@end
