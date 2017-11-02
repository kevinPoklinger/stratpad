//
//  ActivityCalculator.h
//  StratPad
//
//  Created by Eric on 11-11-08.
//  Copyright (c) 2011 Glassey Strategy. All rights reserved.
//

#import "Activity.h"

@interface ActivityCalculator : NSObject {
@private    
    Activity *activity_;

    BOOL optimistic_;

    NSUInteger activityDurationInMonths_;

    NSMutableArray *upFrontValues_;
    
    NSMutableArray *onGoingValues_;

    NSMutableArray *monthlyCalculations_;        
}

@property(nonatomic, readonly) Activity *activity;

// stores the up-front values for each month in the activity's lifespan.
@property(nonatomic, retain) NSArray *upFrontValues;

// stores the ongoing values for each month in the activity's lifespan.
@property(nonatomic, retain) NSArray *onGoingValues;

// stores the calculation for each month in the activity's lifespan.
@property(nonatomic, retain) NSArray *monthlyCalculations;

- (id)initWithActivity:(Activity*)activity andIsOptimistic:(BOOL)optimistic;

- (void)calculate;

@end


@interface ActivityCalculator (Testable)

- (void)calculateUpFrontValues;
- (void)calculateMonthlyOnGoingValues;
- (void)calculateQuarterlyOnGoingValues;
- (void)calculateAnnualOnGoingValues;

@end
