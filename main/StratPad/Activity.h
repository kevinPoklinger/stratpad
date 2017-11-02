//
//  Activity.h
//  StratPad
//
//  Created by Eric on 11-08-18.
//  Copyright (c) 2011 Glassey Strategy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Frequency, Objective, Responsible;

@interface Activity : NSManagedObject {
@private
    NSNumber *durationInMonths_;
    NSNumber *numberOfMonthsFromThemeStart_;
}
@property (nonatomic, retain) NSString * action;
@property (nonatomic, retain) NSDate * endDate;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSNumber * upfrontCost;
@property (nonatomic, retain) NSNumber * ongoingCost;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) Frequency * ongoingFrequency;
@property (nonatomic, retain) Objective * objective;
@property (nonatomic, retain) Responsible * responsible;

// - if an activity has no start date, assume the start date of the theme.
- (NSDate*)normalizedStartDate;

// - if an activity has no end date, assume the end date of the theme.
- (NSDate*)normalizedEndDate;

// returns the duration in months for the activity.
- (NSUInteger)durationInMonths;

// returns the number of months from the theme's normalized start date 
// to the activity start date.
- (NSUInteger)numberOfMonthsFromThemeStart;

@end
