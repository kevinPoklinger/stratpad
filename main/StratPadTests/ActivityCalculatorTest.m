//
//  ActivityCalculatorTest.m
//  StratPad
//
//  Created by Eric on 11-11-09.
//  Copyright (c) 2011 Glassey Strategy. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "ActivityCalculator.h"
#import "Frequency.h"
#import "DataManager.h"
#import "Activity.h"
#import "NSDate-StratPad.h"
#import "NSCalendar+Expanded.h"


@interface ActivityCalculatorTest : SenTestCase
@end

@implementation ActivityCalculatorTest

#pragma mark - Up Front Calculation Tests

/*
 * Test the calculateUpFrontValues method with an optimistic setting.  It is expected that 
 * only the first month of the monthly calculations will contain the up front value.
 */
- (void)testCalculateUpFrontValues1
{    
    Activity *activity = (Activity*)[DataManager createManagedInstance:NSStringFromClass([Activity class])];
    activity.upfrontCost = [NSNumber numberWithDouble:200];
    
    ActivityCalculator *calculator = [[ActivityCalculator alloc] initWithActivity:activity andIsOptimistic:YES];        
    
    double result = 0;    
    for (uint i = 0; i < [calculator.upFrontValues count]; i++) {
        
        result = [[calculator.upFrontValues objectAtIndex:i] doubleValue];
        
        if (i == 0) {
            STAssertTrue(result == 200, @"Result should have been 200, but was %d", result);            
        } else {
            STAssertTrue(result == 0, @"Result should have been 0, but was %d", result);        
        }
    }
    
    [calculator release];
}

/*
 * Test the calculateUpFrontValues method with a pessimistic setting.  It is expected that 
 * only the first month of the monthly calculations will contain the up front value.
 */
- (void)testCalculateUpFrontValues2
{    
    Activity *activity = (Activity*)[DataManager createManagedInstance:NSStringFromClass([Activity class])];
    activity.upfrontCost = [NSNumber numberWithDouble:200];
    
    ActivityCalculator *calculator = [[ActivityCalculator alloc] initWithActivity:activity andIsOptimistic:NO];        
    
    double result = 0;    
    for (uint i = 0; i < [calculator.upFrontValues count]; i++) {
        
        result = [[calculator.upFrontValues objectAtIndex:i] doubleValue];
        
        if (i == 0) {
            STAssertTrue(result == 200, @"Result should have been 200, but was %d", result);            
        } else {
            STAssertTrue(result == 0, @"Result should have been 0, but was %d", result);        
        }
    }
    
    [calculator release];
}


#pragma mark - Monthly Calculation Tests

/*
 * Test the calculateMonthlyOnGoingValues method with an optimistic setting.  It is expected that 
 * every month of the activity will contain the ongoing cost value.
 */
- (void)testCalculateMonthlyOnGoingValues1
{    
    Activity *activity = (Activity*)[DataManager createManagedInstance:NSStringFromClass([Activity class])];
    activity.ongoingFrequency = [Frequency frequencyForCategory:FrequencyCategoryMonthly];
    activity.ongoingCost = [NSNumber numberWithDouble:20];
    
    ActivityCalculator *calculator = [[ActivityCalculator alloc] initWithActivity:activity andIsOptimistic:YES];        
    
    double result = 0;    
    for (uint i = 0; i < [calculator.onGoingValues count]; i++) {        
        result = [[calculator.onGoingValues objectAtIndex:i] doubleValue];
        STAssertTrue(result == 20, @"Result should have been 20, but was %d", result);            
    }
    
    [calculator release];
}

/*
 * Test the calculateMonthlyOnGoingValues method with a pessimistic setting.  It is expected that 
 * every month of the theme will contain the monthly revenue value.
 */
- (void)testCalculateMonthlyOnGoingValues2
{    
    Activity *activity = (Activity*)[DataManager createManagedInstance:NSStringFromClass([Activity class])];
    activity.ongoingFrequency = [Frequency frequencyForCategory:FrequencyCategoryMonthly];
    activity.ongoingCost = [NSNumber numberWithDouble:20];
    
    ActivityCalculator *calculator = [[ActivityCalculator alloc] initWithActivity:activity andIsOptimistic:NO];        
    
    double result = 0;    
    for (uint i = 0; i < [calculator.onGoingValues count]; i++) {        
        result = [[calculator.onGoingValues objectAtIndex:i] doubleValue];
        STAssertTrue(result == 20, @"Result should have been 20, but was %d", result);            
    }
    
    [calculator release];
}


#pragma mark - Quarterly Calculation Tests

/*
 * Test the calculateQuarterlyOnGoingValues method with an optimistic setting.  It is expected that 
 * the quarter ongoing value will occur in months 0, 3, 6, ... (i.e., the first month of each quarter)
 */
- (void)testCalculateQuarterlyOnGoingValues1
{    
    Activity *activity = (Activity*)[DataManager createManagedInstance:NSStringFromClass([Activity class])];
    activity.ongoingFrequency = [Frequency frequencyForCategory:FrequencyCategoryQuarterly];
    activity.ongoingCost = [NSNumber numberWithDouble:2000];
    
    ActivityCalculator *calculator = [[ActivityCalculator alloc] initWithActivity:activity andIsOptimistic:YES];        
    
    double result = 0;    
    for (uint i = 0; i < [calculator.onGoingValues count]; i++) {
        
        result = [[calculator.onGoingValues objectAtIndex:i] doubleValue];
        
        if (i % 3 == 0) {        
            STAssertTrue(result == 2000, @"Result should have been 2000, but was %d", result);            
        } else {
            STAssertTrue(result == 0, @"Result should have been 0, but was %d", result);            
        }
    }
    
    [calculator release];
}

/*
 * Test the calculateQuarterlyOnGoingValues method with a pessimistic setting and an activity that is exactly 6 months in duration.  It 
 * is expected that the quarter ongoing value will occur in months 2 and 5 (i.e., the last month of each quarter)
 */
- (void)testCalculateQuarterlyOnGoingValues2
{    
    Activity *activity = (Activity*)[DataManager createManagedInstance:NSStringFromClass([Activity class])];
    activity.ongoingFrequency = [Frequency frequencyForCategory:FrequencyCategoryQuarterly];
    activity.ongoingCost = [NSNumber numberWithDouble:2000];
    activity.startDate = [NSDate dateWithZeroedTime];
        
    NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setMonth:5];    
    activity.endDate = [[gregorian dateByAddingComponents:comps toDate:activity.startDate options:0] dateWithZeroedTime];
    
    ActivityCalculator *calculator = [[ActivityCalculator alloc] initWithActivity:activity andIsOptimistic:NO];        
        
    double result = 0;    
    for (uint i = 0; i < [calculator.onGoingValues count]; i++) {
        
        result = [[calculator.onGoingValues objectAtIndex:i] doubleValue];
        
        if (i == 2 || i == 5) {        
            STAssertTrue(result == 2000, @"Result should have been 2000, but was %d", result);            
        } else {
            STAssertTrue(result == 0, @"Result should have been 0, but was %d", result);            
        }
    }
    
    [calculator release];
}

/*
 * Test the calculateQuarterlyOnGoingValues method with a pessimistic setting and an activity that is 7 months in duration.  It 
 * is expected that the quarter ongoing value will occur in months 2 and 5 (i.e., the last month of each quarter)
 */
- (void)testCalculateQuarterlyValues3
{    
    Activity *activity = (Activity*)[DataManager createManagedInstance:NSStringFromClass([Activity class])];
    activity.ongoingFrequency = [Frequency frequencyForCategory:FrequencyCategoryQuarterly];
    activity.ongoingCost = [NSNumber numberWithDouble:2000];
    activity.startDate = [NSDate dateWithZeroedTime];
    
    NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setMonth:6];    
    activity.endDate = [[gregorian dateByAddingComponents:comps toDate:activity.startDate options:0] dateWithZeroedTime];
    
    ActivityCalculator *calculator = [[ActivityCalculator alloc] initWithActivity:activity andIsOptimistic:NO];        
    
    double result = 0;    
    for (uint i = 0; i < [calculator.onGoingValues count]; i++) {
        
        result = [[calculator.onGoingValues objectAtIndex:i] doubleValue];
        
        if (i == 2 || i == 5) {        
            STAssertTrue(result == 2000, @"Result should have been 2000, but was %d", result);            
        } else {
            STAssertTrue(result == 0, @"Result should have been 0, but was %d", result);            
        }
    }
    
    [calculator release];
}

/*
 * Test the calculateQuarterlyOnGoingValues method with a pessimistic setting and an activity that is 8 months in duration.  It 
 * is expected that the quarter ongoing value will occur in months 2, 5, and 7 (i.e., the last month of each of the first two quarters, 
 * and the second month in the last quarter).
 */
- (void)testCalculateQuarterlyOnGoingValues4
{    
    Activity *activity = (Activity*)[DataManager createManagedInstance:NSStringFromClass([Activity class])];
    activity.ongoingFrequency = [Frequency frequencyForCategory:FrequencyCategoryQuarterly];
    activity.ongoingCost = [NSNumber numberWithDouble:2000];
    activity.startDate = [NSDate dateWithZeroedTime];
    
    NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setMonth:7];    
    activity.endDate = [[gregorian dateByAddingComponents:comps toDate:[NSDate dateWithZeroedTime] options:0] dateWithZeroedTime];
    
    ActivityCalculator *calculator = [[ActivityCalculator alloc] initWithActivity:activity andIsOptimistic:NO];        
    
    double result = 0;    
    for (uint i = 0; i < [calculator.onGoingValues count]; i++) {
        
        result = [[calculator.onGoingValues objectAtIndex:i] doubleValue];
        
        if (i == 2 || i == 5 || i == 7) {        
            STAssertTrue(result == 2000, @"Result should have been 2000, but was %d", result);            
        } else {
            STAssertTrue(result == 0, @"Result should have been 0, but was %d", result);            
        }
    }
    
    [calculator release];
}


#pragma mark - Annual Calculation Tests

/*
 * Test the calculateAnnualOnGoingValues method with an optimistic setting.
 * It is expected that the annual ongoing value will occur in months 0, 12, ... (i.e., the first month of each year)
 */
- (void)testCalculateAnnualValues1
{    
    Activity *activity = (Activity*)[DataManager createManagedInstance:NSStringFromClass([Activity class])];
    activity.ongoingFrequency = [Frequency frequencyForCategory:FrequencyCategoryAnnually];
    activity.ongoingCost = [NSNumber numberWithDouble:200000];
    
    ActivityCalculator *calculator = [[ActivityCalculator alloc] initWithActivity:activity andIsOptimistic:YES];        
    
    double result = 0;    
    for (uint i = 0; i < [calculator.onGoingValues count]; i++) {
        
        result = [[calculator.onGoingValues objectAtIndex:i] doubleValue];
        
        if (i % 12 == 0) {        
            STAssertTrue(result == 200000, @"Result should have been 200000, but was %d", result);            
        } else {
            STAssertTrue(result == 0, @"Result should have been 0, but was %d", result);            
        }
    }
    
    [calculator release];
}

/*
 * Test the calculateAnnualOnGoingValues method with a pessimistic setting and an activity that is longer than a year in duration.  It 
 * is expected that the annual ongoing value will occur the first month of each year, and in the last month of the activity.
 */
- (void)testCalculateAnnualOnGoingValues2
{    
    Activity *activity = (Activity*)[DataManager createManagedInstance:NSStringFromClass([Activity class])];
    activity.ongoingFrequency = [Frequency frequencyForCategory:FrequencyCategoryAnnually];
    activity.ongoingCost = [NSNumber numberWithDouble:200000];
    activity.startDate = [NSDate dateWithZeroedTime];
    
    NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setMonth:16];    
    activity.endDate = [[gregorian dateByAddingComponents:comps toDate:activity.startDate options:0] dateWithZeroedTime];
            
    ActivityCalculator *calculator = [[ActivityCalculator alloc] initWithActivity:activity andIsOptimistic:NO];        
    
    double result = 0;    
    for (uint i = 0; i < [calculator.onGoingValues count]; i++) {
        
        result = [[calculator.onGoingValues objectAtIndex:i] doubleValue];
        
        if (i == 11 || i == 16) {        
            STAssertTrue(result == 200000, @"Result should have been 200000, but was %d", result);            
        } else {
            STAssertTrue(result == 0, @"Result should have been 0, but was %d", result);            
        }
    }
    
    [calculator release];
}

/*
 * Test the calculateAnnualValues method with a pessimistic setting and a theme that is less than a year in duration.  It 
 * is expected that the annual revenue value will occur the last month of the theme.
 */
- (void)testCalculateAnnualOnGoingValues3
{    
    Activity *activity = (Activity*)[DataManager createManagedInstance:NSStringFromClass([Activity class])];
    activity.ongoingFrequency = [Frequency frequencyForCategory:FrequencyCategoryAnnually];
    activity.ongoingCost = [NSNumber numberWithDouble:200000];
    activity.startDate = [NSDate dateWithZeroedTime];
    
    NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setMonth:9];    
    activity.endDate = [[gregorian dateByAddingComponents:comps toDate:activity.startDate options:0] dateWithZeroedTime];
    
    ActivityCalculator *calculator = [[ActivityCalculator alloc] initWithActivity:activity andIsOptimistic:NO];        
    
    double result = 0;    
    for (uint i = 0; i < [calculator.onGoingValues count]; i++) {
        
        result = [[calculator.onGoingValues objectAtIndex:i] doubleValue];
        
        if (i == 9) {        
            STAssertTrue(result == 200000, @"Result should have been 200000, but was %d", result);            
        } else {
            STAssertTrue(result == 0, @"Result should have been 0, but was %d", result);            
        }
    }
    
    [calculator release];
}

@end
