//
//  Activity.m
//  StratPad
//
//  Created by Eric on 11-08-18.
//  Copyright (c) 2011 Glassey Strategy. All rights reserved.
//

#import "Activity.h"
#import "Frequency.h"
#import "Objective.h"
#import "Theme.h"
#import "NSCalendar+Expanded.h"
#import "NSDate-StratPad.h"


@implementation Activity
@dynamic action;
@dynamic responsible;
@dynamic endDate;
@dynamic startDate;
@dynamic upfrontCost;
@dynamic ongoingCost;
@dynamic order;
@dynamic ongoingFrequency;
@dynamic objective;  //inverse

- (NSDate*)normalizedStartDate
{
    if (self.startDate) {
        return self.startDate;
    } else {
        return [self.objective.theme normalizedStartDate];
    }
}

- (NSDate*)normalizedEndDate
{
    if (self.endDate) {
        return self.endDate;
    } else {
        return [self.objective.theme normalizedEndDate];
    }
}

- (NSUInteger)durationInMonths
{
    if (!durationInMonths_) {
        unsigned comparisonFlags = NSMonthCalendarUnit;
        NSCalendar *calendar = [NSCalendar cachedGregorianCalendar];    
        
        NSDate *normalizedStartDate = [NSDate dateSetToFirstDayOfMonthForDate:[self normalizedStartDate]];    
        NSDate *normalizedEndDate = [NSDate dateSetToFirstDayOfNextMonthForDate:[self normalizedEndDate]];
        
        NSDateComponents *comps = [calendar components:comparisonFlags 
                                              fromDate:normalizedStartDate
                                                toDate:normalizedEndDate
                                               options:0];     
        durationInMonths_ = [[NSNumber numberWithUnsignedInt:[comps month]] retain];
    }
    return durationInMonths_.unsignedIntValue;
}

- (NSUInteger)numberOfMonthsFromThemeStart
{
    if (!numberOfMonthsFromThemeStart_) {
        unsigned comparisonFlags = NSMonthCalendarUnit;
        NSCalendar *calendar = [NSCalendar cachedGregorianCalendar];    
        
        NSDate *normalizedThemeStartDate = [NSDate dateSetToFirstDayOfMonthForDate:[self.objective.theme normalizedStartDate]];    
        NSDate *normalizedActivityStartDate = [NSDate dateSetToFirstDayOfMonthForDate:[self normalizedStartDate]];
        
        NSDateComponents *comps = [calendar components:comparisonFlags 
                                              fromDate:normalizedThemeStartDate
                                                toDate:normalizedActivityStartDate
                                               options:0];
        numberOfMonthsFromThemeStart_ = [[NSNumber numberWithUnsignedInt:[comps month]] retain];
    }    
    return numberOfMonthsFromThemeStart_.unsignedIntValue;            
}

- (void)dealloc
{
    [numberOfMonthsFromThemeStart_ release];
    [durationInMonths_ release];
    [super dealloc];
}

@end
