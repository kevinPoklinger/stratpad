//
//  AbstractThemeCalculator.m
//  StratPad
//
//  Created by Eric Rogers on August 28, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "AbstractThemeCalculator.h"

@implementation AbstractThemeCalculator

- (id)initWithTheme:(Theme*)theme andIsOptimistic:(BOOL)optimistic
{
    if ((self = [super init])) {
        optimistic_ = optimistic;                
        themeDurationInMonths_ = [theme durationInMonths];

        NSUInteger initialCapacity = MIN(20*12, themeDurationInMonths_);
        self.oneTimeValues = [NSMutableArray arrayWithCapacity:initialCapacity];
        self.monthlyValues = [NSMutableArray arrayWithCapacity:initialCapacity];
        self.quarterlyValues = [NSMutableArray arrayWithCapacity:initialCapacity];
        self.annualValues = [NSMutableArray arrayWithCapacity:initialCapacity];
        
        self.monthlyCalculations = [NSMutableArray arrayWithCapacity:initialCapacity];
    }
    return self;
}


#pragma mark - Memory Management

- (void)dealloc
{    
    [_oneTimeValue release];
    [_monthlyValue release];
    [_monthlyAdjustment release];
    [_quarterlyValue release];
    [_quarterlyAdjustment release];
    [_annualValue release];
    [_annualAdjustment release];
    
    [_oneTimeValues release];
    [_monthlyValues release];
    [_quarterlyValues release];
    [_annualValues release];
    
    [_monthlyCalculations release];
     
    [super dealloc];
}

- (NSString*)description
{
    return [NSString stringWithFormat:
            @"One Time: %@, Monthly: %@, Quarterly: %@, Annual: %@, TOTAL: %@",
            _oneTimeValues, _monthlyValues, _quarterlyValues, _annualValues, _monthlyCalculations];
}

- (void)calculate
{ 
    [self calculateOneTimeValues];
    [self calculateMonthlyValues];
    [self calculateQuarterlyValues];
    [self calculateAnnualValues];    
    
    // sum the one-time, monthly, quarterly, and annual value for each month
    double sum;    
    for (uint i = 0; i < themeDurationInMonths_; i++) {
        sum = 0;        
        sum += [[self.oneTimeValues objectAtIndex:i] doubleValue];
        sum += [[self.monthlyValues objectAtIndex:i] doubleValue];
        sum += [[self.quarterlyValues objectAtIndex:i] doubleValue];
        sum += [[self.annualValues objectAtIndex:i] doubleValue];

        [_monthlyCalculations addObject:[NSNumber numberWithDouble:sum]];
    }    
}

// one day we might want to change our calculations to use NSDecimalNumber and/or change doubles in Core Data to decimal
-(NSDecimalNumber*)adjust:(NSNumber*)base adjustment:(NSDecimalNumber*)adjustment
{
    // we have a situation where our base numbers are doubles (eg Theme.cogsAnnually), 
    //  but we are only ever using the int portion    
    NSDecimalNumber *decimalBase = [NSDecimalNumber decimalNumberWithMantissa:[base intValue]
                                                                     exponent:1
                                                                   isNegative:[base intValue] < 0];
    NSDecimalNumber *oneHundred = [NSDecimalNumber decimalNumberWithMantissa:100
                                                                    exponent:1
                                                                  isNegative:NO];
    NSDecimalNumber *percentage = [adjustment decimalNumberByDividingBy:oneHundred];
    NSDecimalNumber *adjustBy = [decimalBase decimalNumberByMultiplyingBy:percentage];
    return [decimalBase decimalNumberByAdding:adjustBy];
}

#pragma mark - Calculations

- (void)calculateOneTimeValues
{
    // no adjustments here
    for (uint i = 0; i < themeDurationInMonths_; i++) {
        if (i == 0) {
            // nils become 0's
            [_oneTimeValues addObject:[NSNumber numberWithDouble:_oneTimeValue.doubleValue]];
        } else {
            [_oneTimeValues addObject:[NSNumber numberWithDouble:0]];
        }
    }
}

- (void)calculateMonthlyValues
{
    // for each month, we have to compound the values
    double basicMonthly = [_monthlyValue doubleValue];
    for (uint i = 0; i < themeDurationInMonths_; i++) {
        [_monthlyValues addObject:[NSNumber numberWithDouble:basicMonthly]];
        basicMonthly = basicMonthly + (basicMonthly * [_monthlyAdjustment doubleValue]/100);
    }
}

- (void)calculateQuarterlyValues
{
    double basicQuarterly = [_quarterlyValue doubleValue];
    if (optimistic_) {
        
        // when optimistic, quarterly values are included in the starting month of each quarter over the
        // duration of the theme.  e.g., months 0, 3, 6, ...
        for (uint i = 0; i < themeDurationInMonths_; i++) {
            
            if (i % 3 == 0) {
                [_quarterlyValues addObject:[NSNumber numberWithDouble:basicQuarterly]];
                basicQuarterly = basicQuarterly + (basicQuarterly * [_quarterlyAdjustment doubleValue]/100);
            } else {
                [_quarterlyValues addObject:[NSNumber numberWithDouble:0]];
            }
        }
        
    } else {
        
        // when pessimistic, quarterly values are included in the last month of each quarter over the
        // duration of the theme.  e.g., months 2, 5, 8, ...
        //
        // Don't include the quarterly value if the last month of the theme occurs in the first month of a quarter.
        // However, we include it if it is in the second month of a quarter.
        for (uint i = 0; i < themeDurationInMonths_; i++) {
            
            if ((i + 1) % 3 == 0) {
                [_quarterlyValues addObject:[NSNumber numberWithDouble:basicQuarterly]];
                basicQuarterly = basicQuarterly + (basicQuarterly * [_quarterlyAdjustment doubleValue]/100);
            } else {
                
                // include the quarterly value if we are in the last month of the theme, which also happens to be the
                // second month in the quarter.
                if (i == (themeDurationInMonths_ - 1) && ((i + 1) % 3) == 2) {
                    [_quarterlyValues addObject:[NSNumber numberWithDouble:basicQuarterly]];
                    basicQuarterly = basicQuarterly + (basicQuarterly * [_quarterlyAdjustment doubleValue]/100);
                } else {
                    [_quarterlyValues addObject:[NSNumber numberWithDouble:0]];
                }
            }
        }
        
    }
}

- (void)calculateAnnualValues
{
    double basicAnnual = [_annualValue doubleValue];
    if (optimistic_) {
        
        // when optimistic, annual values are included in the starting month of each year over the
        // duration of the theme.  e.g., months 0, 12, 24 ...
        for (uint i = 0; i < themeDurationInMonths_; i++) {
            
            if (i % 12 == 0) {
                [_annualValues addObject:[NSNumber numberWithDouble:basicAnnual]];
                basicAnnual = basicAnnual + (basicAnnual * [_annualAdjustment doubleValue]/100);
            } else {
                [_annualValues addObject:[NSNumber numberWithDouble:0]];
            }
        }
        
    } else {
        
        // when pessimistic, annual values are included in the last month of each year. e.g., months 0, 12, 24, ...
        // they are also included in the last month of the theme.
        for (uint i = 0; i < themeDurationInMonths_; i++) {
            
            if (i >= 11 && (i + 1) % 12 == 0) {
                [_annualValues addObject:[NSNumber numberWithDouble:basicAnnual]];
                basicAnnual = basicAnnual + (basicAnnual * [_annualAdjustment doubleValue]/100);
            } else {
                
                // include the annual value if we are in the last month of the theme
                if (i == (themeDurationInMonths_ - 1)) {
                    [_annualValues addObject:[NSNumber numberWithDouble:basicAnnual]];
                    basicAnnual = basicAnnual + (basicAnnual * [_annualAdjustment doubleValue]/100);
                } else {
                    [_annualValues addObject:[NSNumber numberWithDouble:0]];
                }
            }
        }
        
    }
}

@end
