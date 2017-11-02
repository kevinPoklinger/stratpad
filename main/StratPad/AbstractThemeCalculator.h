//
//  AbstractThemeCalculator.h
//  StratPad
//
//  Created by Eric Rogers on August 28, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "Theme.h"


@interface AbstractThemeCalculator : NSObject {
@protected
    BOOL optimistic_;
    NSUInteger themeDurationInMonths_;
}

// stores the one-time values for each month in the theme's lifespan.
@property(nonatomic, retain) NSMutableArray *oneTimeValues;

// stores the monthly values for each month in the theme's lifespan.
@property(nonatomic, retain) NSMutableArray *monthlyValues;

// stores the quarterly values for each month in the theme's lifespan.
@property(nonatomic, retain) NSMutableArray *quarterlyValues;

// stores the annual values for each month in the theme's lifespan.
@property(nonatomic, retain) NSMutableArray *annualValues;

// stores the calculation for each month in the theme's lifespan.
@property(nonatomic, retain) NSMutableArray *monthlyCalculations;


// subclasses must set these properties
@property (nonatomic,retain) NSNumber *oneTimeValue;
@property (nonatomic,retain) NSNumber *monthlyValue;
@property (nonatomic,retain) NSNumber *monthlyAdjustment;
@property (nonatomic,retain) NSNumber *quarterlyValue;
@property (nonatomic,retain) NSNumber *quarterlyAdjustment;
@property (nonatomic,retain) NSNumber *annualValue;
@property (nonatomic,retain) NSNumber *annualAdjustment;

- (id)initWithTheme:(Theme*)theme andIsOptimistic:(BOOL)optimistic;
- (void)calculate;

@end

@interface AbstractThemeCalculator (Testable)

- (void)calculateOneTimeValues;  
- (void)calculateMonthlyValues;  
- (void)calculateQuarterlyValues;
- (void)calculateAnnualValues;   

@end

