//
//  ActivityCalculator.m
//  StratPad
//
//  Created by Eric on 11-11-08.
//  Copyright (c) 2011 Glassey Strategy. All rights reserved.
//

#import "ActivityCalculator.h"
#import "Frequency.h"

@implementation ActivityCalculator

@synthesize activity = activity_;
@synthesize upFrontValues = upFrontValues_;
@synthesize onGoingValues = onGoingValues_;
@synthesize monthlyCalculations = monthlyCalculations_;

- (id)initWithActivity:(Activity*)activity andIsOptimistic:(BOOL)optimistic
{
    if ((self = [super init])) {
        activity_ = activity;
        optimistic_ = optimistic;                
        activityDurationInMonths_ = [activity_ durationInMonths];
        
        upFrontValues_ = [[NSMutableArray arrayWithCapacity:activityDurationInMonths_] retain];
        onGoingValues_ = [[NSMutableArray arrayWithCapacity:activityDurationInMonths_] retain];
        
        monthlyCalculations_ = [[NSMutableArray arrayWithCapacity:activityDurationInMonths_] retain];
        
        [self calculate];        
    }
    return self;
}


#pragma mark - Memory Management

- (void)dealloc
{
    [upFrontValues_ release];
    [onGoingValues_ release];
    
    [monthlyCalculations_ release];
    
    [super dealloc];
}

- (NSString*)description
{
    return [NSString stringWithFormat:
            @"Up Front: %@, On Going: %@, TOTAL: %@",
            upFrontValues_, onGoingValues_, monthlyCalculations_];
}

- (void)calculate
{ 
    [self calculateUpFrontValues];
    
    // calculate the ongoing values for the activity depending on its ongoing frequency.

    if ([activity_.ongoingFrequency categoryRaw] == FrequencyCategoryMonthly) {
        [self calculateMonthlyOnGoingValues];        
        
    } else if ([activity_.ongoingFrequency categoryRaw] == FrequencyCategoryQuarterly) {
        [self calculateQuarterlyOnGoingValues];
        
    } else if ([activity_.ongoingFrequency categoryRaw] == FrequencyCategoryAnnually) {
        [self calculateAnnualOnGoingValues];    
        
    } else {
        
        // just zero out the ongoing values if we are in an unexpected situation.
        for (int i = 0; i < activityDurationInMonths_; i++) {
            [onGoingValues_ addObject:[NSNumber numberWithDouble:0]];
        }
        
        ELog(@"Unsupported ongoing frequency type: %@", activity_.ongoingFrequency);
    }
    
    // sum the up-front, and ongoing value for each month
    double sum;    
    for (uint i = 0; i < activityDurationInMonths_; i++) {
        sum = 0;        
        sum += [[self.upFrontValues objectAtIndex:i] doubleValue];
        sum += [[self.onGoingValues objectAtIndex:i] doubleValue];
        
        [monthlyCalculations_ addObject:[NSNumber numberWithDouble:sum]];
    }    
}

- (void)calculateUpFrontValues
{
    for (uint i = 0; i < activityDurationInMonths_; i++) {
        if (i == 0) {
            [upFrontValues_ addObject:[NSNumber numberWithDouble:[activity_.upfrontCost doubleValue]]];
        } else {
            [upFrontValues_ addObject:[NSNumber numberWithDouble:0]];
        }        
    }    
}

- (void)calculateMonthlyOnGoingValues
{
    for (uint i = 0; i < activityDurationInMonths_; i++) {
        [onGoingValues_ addObject:[NSNumber numberWithDouble:[activity_.ongoingCost doubleValue]]];
    }    
}

- (void)calculateQuarterlyOnGoingValues
{
    if (optimistic_) {
        
        // when optimistic, quarterly values are included in the starting month of each quarter over the
        // duration of the activity.  e.g., months 0, 3, 6, ...
        for (uint i = 0; i < activityDurationInMonths_; i++) {
            
            if (i % 3 == 0) {            
                [onGoingValues_ addObject:[NSNumber numberWithDouble:[activity_.ongoingCost doubleValue]]];
            } else {
                [onGoingValues_ addObject:[NSNumber numberWithDouble:0]];
            }
        }    
        
    } else {
        
        // when pessimistic, quarterly values are included in the last month of each quarter over the
        // duration of the theme.  e.g., months 2, 5, 8, ...
        //
        // Don't include the quarterly value if the last month of the theme occurs in the first month of a quarter.
        // However, we include it if it is in the second month of a quarter.
        for (uint i = 0; i < activityDurationInMonths_; i++) {
            
            if ((i + 1) % 3 == 0) {            
                [onGoingValues_ addObject:[NSNumber numberWithDouble:[activity_.ongoingCost doubleValue]]];
            } else {
                
                // include the quarterly value if we are in the last month of the theme, which also happens to be the 
                // second month in the quarter.
                if (i == (activityDurationInMonths_ - 1) && ((i + 1) % 3) == 2) {
                    [onGoingValues_ addObject:[NSNumber numberWithDouble:[activity_.ongoingCost doubleValue]]];
                } else {                
                    [onGoingValues_ addObject:[NSNumber numberWithDouble:0]];
                }
            }
        }    
        
    }
}

- (void)calculateAnnualOnGoingValues
{
    if (optimistic_) {
        
        // when optimistic, annual values are included in the starting month of each year over the
        // duration of the theme.  e.g., months 0, 12, 24 ...
        for (uint i = 0; i < activityDurationInMonths_; i++) {
            
            if (i % 12 == 0) {            
                [onGoingValues_ addObject:[NSNumber numberWithDouble:[activity_.ongoingCost doubleValue]]];
            } else {
                [onGoingValues_ addObject:[NSNumber numberWithDouble:0]];
            }
        }    
        
    } else {
        
        // when pessimistic, annual values are included in the last month of each year. e.g., months 12, 24, ...
        // they are also included in the last month of the theme.
        for (uint i = 0; i < activityDurationInMonths_; i++) {
            
            if (i >= 11 && (i + 1) % 12 == 0) {            
                [onGoingValues_ addObject:[NSNumber numberWithDouble:[activity_.ongoingCost doubleValue]]];
            } else {
                
                // include the annual value if we are in the last month of the theme
                if (i == (activityDurationInMonths_ - 1)) {
                    [onGoingValues_ addObject:[NSNumber numberWithDouble:[activity_.ongoingCost doubleValue]]];
                } else {                
                    [onGoingValues_ addObject:[NSNumber numberWithDouble:0]];
                }
            }
        }            
    }    
}

@end
