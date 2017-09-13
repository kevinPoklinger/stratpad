//
//  ThemeRevenueCalculatorTest.m
//  StratPad
//
//  Created by Eric Rogers on August 26, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "ThemeRevenueCalculator.h"
#import "DataManager.h"
#import "StratFile.h"
#import "Theme.h"
#import "NSDate-StratPad.h"
#import "NSCalendar+Expanded.h"
#import "TestSupport.h"

@interface ThemeRevenueCalculatorTest : SenTestCase {    
}
@end


@implementation ThemeRevenueCalculatorTest

#pragma mark - One Time Calculation Tests

/*
 * Test the calculateOneTimeValues method with an optimistic setting.  It is expected that 
 * only the first month of the theme will contain the one time revenue value.
 */
- (void)testCalculateOneTimeValues1
{    
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    Theme *theme = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    theme.revenueOneTime = [NSNumber numberWithDouble:200];
    [stratFile addThemesObject:theme];
    
    ThemeRevenueCalculator *calculator = [[ThemeRevenueCalculator alloc] initWithTheme:theme andIsOptimistic:YES];        

    double result = 0;    
    for (uint i = 0; i < [calculator.oneTimeValues count]; i++) {

        result = [[calculator.oneTimeValues objectAtIndex:i] doubleValue];
        
        if (i == 0) {
            STAssertTrue(result == 200, @"Result should have been 200, but was %d", result);            
        } else {
            STAssertTrue(result == 0, @"Result should have been 0, but was %d", result);        
        }
    }
    
    [calculator release];
}

/*
 * Test the calculateOneTimeValues method with a pessimistic setting.  It is expected that 
 * only the first month of the theme will contain the one time revenue value.
 */
- (void)testCalculateOneTimeValues2
{    
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    Theme *theme = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    theme.revenueOneTime = [NSNumber numberWithDouble:200];
    [stratFile addThemesObject:theme];
    
    ThemeRevenueCalculator *calculator = [[ThemeRevenueCalculator alloc] initWithTheme:theme andIsOptimistic:NO];        
    
    double result = 0;    
    for (uint i = 0; i < [calculator.oneTimeValues count]; i++) {
        
        result = [[calculator.oneTimeValues objectAtIndex:i] doubleValue];
        
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
 * Test the calculateMonthlyValues method with an optimistic setting.  It is expected that 
 * every month of the theme will contain the monthly revenue value.
 */
- (void)testCalculateMonthlyValues1
{    
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    Theme *theme = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    theme.revenueMonthly = [NSNumber numberWithDouble:2000];
    [stratFile addThemesObject:theme];
    
    ThemeRevenueCalculator *calculator = [[ThemeRevenueCalculator alloc] initWithTheme:theme andIsOptimistic:YES];        
    
    double result = 0;    
    for (uint i = 0; i < [calculator.monthlyValues count]; i++) {
        
        result = [[calculator.monthlyValues objectAtIndex:i] doubleValue];
        STAssertTrue(result == 2000, @"Result should have been 2000, but was %d", result);            
    }
    
    [calculator release];
}

/*
 * Test the calculateMonthlyValues method with a pessimistic setting.  It is expected that 
 * every month of the theme will contain the monthly revenue value.
 */
- (void)testCalculateMonthlyValues2
{    
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    Theme *theme = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    theme.revenueMonthly = [NSNumber numberWithDouble:2000];
    [stratFile addThemesObject:theme];
    
    ThemeRevenueCalculator *calculator = [[ThemeRevenueCalculator alloc] initWithTheme:theme andIsOptimistic:NO];        
    
    double result = 0;    
    for (uint i = 0; i < [calculator.monthlyValues count]; i++) {
        
        result = [[calculator.monthlyValues objectAtIndex:i] doubleValue];
        STAssertTrue(result == 2000, @"Result should have been 2000, but was %d", result);            
    }
    
    [calculator release];
}


#pragma mark - Quarterly Calculation Tests

/*
 * Test the calculateQuarterlyValues method with an optimistic setting.  It is expected that 
 * the quarter revenue value will occur in months 0, 3, 6, ... (i.e., the first month of each quarter)
 */
- (void)testCalculateQuarterlyValues1
{    
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    Theme *theme = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    theme.revenueQuarterly = [NSNumber numberWithDouble:20000];
    [stratFile addThemesObject:theme];
    
    ThemeRevenueCalculator *calculator = [[ThemeRevenueCalculator alloc] initWithTheme:theme andIsOptimistic:YES];        
    
    double result = 0;    
    for (uint i = 0; i < [calculator.quarterlyValues count]; i++) {
        
        result = [[calculator.quarterlyValues objectAtIndex:i] doubleValue];
        
        if (i % 3 == 0) {        
            STAssertTrue(result == 20000, @"Result should have been 20000, but was %d", result);            
        } else {
            STAssertTrue(result == 0, @"Result should have been 0, but was %d", result);            
        }
    }
    
    [calculator release];
}

/*
 * Test the calculateQuarterlyValues method with a pessimistic setting and a theme that is exactly 6 months in duration.  It 
 * is expected that the quarter revenue value will occur in months 2 and 5 (i.e., the last month of each quarter)
 */
- (void)testCalculateQuarterlyValues2
{    
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    Theme *theme = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    
    NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setMonth:5];    
    theme.endDate = [[gregorian dateByAddingComponents:comps toDate:[NSDate dateWithZeroedTime] options:0] dateWithZeroedTime];
    
    theme.revenueQuarterly = [NSNumber numberWithDouble:20000];
    [stratFile addThemesObject:theme];
    
    ThemeRevenueCalculator *calculator = [[ThemeRevenueCalculator alloc] initWithTheme:theme andIsOptimistic:NO];        
    
    double result = 0;    
    for (uint i = 0; i < [calculator.quarterlyValues count]; i++) {
        
        result = [[calculator.quarterlyValues objectAtIndex:i] doubleValue];
        
        if (i == 2 || i == 5) {        
            STAssertTrue(result == 20000, @"Result should have been 20000, but was %d", result);            
        } else {
            STAssertTrue(result == 0, @"Result should have been 0, but was %d", result);            
        }
    }
    
    [calculator release];
}

/*
 * Test the calculateQuarterlyValues method with a pessimistic setting and a theme that is 7 months in duration.  It 
 * is expected that the quarter revenue value will occur in months 2 and 5 (i.e., the last month of each quarter)
 */
- (void)testCalculateQuarterlyValues3
{    
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    Theme *theme = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    
    NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setMonth:6];    
    theme.endDate = [[gregorian dateByAddingComponents:comps toDate:[NSDate dateWithZeroedTime] options:0] dateWithZeroedTime];
    
    theme.revenueQuarterly = [NSNumber numberWithDouble:20000];
    [stratFile addThemesObject:theme];
    
    ThemeRevenueCalculator *calculator = [[ThemeRevenueCalculator alloc] initWithTheme:theme andIsOptimistic:NO];        
    
    double result = 0;    
    for (uint i = 0; i < [calculator.quarterlyValues count]; i++) {
        
        result = [[calculator.quarterlyValues objectAtIndex:i] doubleValue];
        
        if (i == 2 || i == 5) {        
            STAssertTrue(result == 20000, @"Result should have been 20000, but was %d", result);            
        } else {
            STAssertTrue(result == 0, @"Result should have been 0, but was %d", result);            
        }
    }
    
    [calculator release];
}

/*
 * Test the calculateQuarterlyValues method with a pessimistic setting and a theme that is 8 months in duration.  It 
 * is expected that the quarter revenue value will occur in months 2, 5, and 7 (i.e., the last month of each of the first two quarters, 
   and the second month in the last quarter).
 */
- (void)testCalculateQuarterlyValues4
{    
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    Theme *theme = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    
    NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setMonth:7];    
    theme.endDate = [[gregorian dateByAddingComponents:comps toDate:[NSDate dateWithZeroedTime] options:0] dateWithZeroedTime];
    
    theme.revenueQuarterly = [NSNumber numberWithDouble:20000];
    [stratFile addThemesObject:theme];
    
    ThemeRevenueCalculator *calculator = [[ThemeRevenueCalculator alloc] initWithTheme:theme andIsOptimistic:NO];        
    
    double result = 0;    
    for (uint i = 0; i < [calculator.quarterlyValues count]; i++) {
        
        result = [[calculator.quarterlyValues objectAtIndex:i] doubleValue];
        
        if (i == 2 || i == 5 || i == 7) {        
            STAssertTrue(result == 20000, @"Result should have been 20000, but was %d", result);            
        } else {
            STAssertTrue(result == 0, @"Result should have been 0, but was %d", result);            
        }
    }
    
    [calculator release];
}


#pragma mark - Annual Calculation Tests

/*
 * Test the calculateAnnualValues method with an optimistic setting.
 * It is expected that the annual revenue value will occur in months 0, 12, ... (i.e., the first month of each year)
 */
- (void)testCalculateAnnualValues1
{    
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    Theme *theme = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    theme.revenueAnnually = [NSNumber numberWithDouble:200000];
    [stratFile addThemesObject:theme];
    
    ThemeRevenueCalculator *calculator = [[ThemeRevenueCalculator alloc] initWithTheme:theme andIsOptimistic:YES];        
    
    double result = 0;    
    for (uint i = 0; i < [calculator.annualValues count]; i++) {
        
        result = [[calculator.annualValues objectAtIndex:i] doubleValue];
        
        if (i % 12 == 0) {        
            STAssertTrue(result == 200000, @"Result should have been 200000, but was %d", result);            
        } else {
            STAssertTrue(result == 0, @"Result should have been 0, but was %d", result);            
        }
    }
    
    [calculator release];
}

/*
 * Test the calculateAnnualValues method with a pessimistic setting and a theme that is longer than a year in duration.  It 
 * is expected that the annual revenue value will occur the first month of each year, and in the last month of the theme.
 */
- (void)testCalculateAnnualValues2
{    
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    Theme *theme = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    
    NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setMonth:16];    
    theme.endDate = [[gregorian dateByAddingComponents:comps toDate:[NSDate dateWithZeroedTime] options:0] dateWithZeroedTime];
    
    theme.revenueAnnually = [NSNumber numberWithDouble:200000];
    [stratFile addThemesObject:theme];
    
    ThemeRevenueCalculator *calculator = [[ThemeRevenueCalculator alloc] initWithTheme:theme andIsOptimistic:NO];        
    
    double result = 0;    
    for (uint i = 0; i < [calculator.annualValues count]; i++) {
        
        result = [[calculator.annualValues objectAtIndex:i] doubleValue];
        
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
- (void)testCalculateAnnualValues3
{    
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    Theme *theme = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    
    NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setMonth:9];    
    theme.endDate = [[gregorian dateByAddingComponents:comps toDate:[NSDate dateWithZeroedTime] options:0] dateWithZeroedTime];
    
    theme.revenueAnnually = [NSNumber numberWithDouble:200000];
    [stratFile addThemesObject:theme];
    
    ThemeRevenueCalculator *calculator = [[ThemeRevenueCalculator alloc] initWithTheme:theme andIsOptimistic:NO];        
    
    double result = 0;    
    for (uint i = 0; i < [calculator.annualValues count]; i++) {
        
        result = [[calculator.annualValues objectAtIndex:i] doubleValue];
        
        if (i == 9) {        
            STAssertTrue(result == 200000, @"Result should have been 200000, but was %d", result);            
        } else {
            STAssertTrue(result == 0, @"Result should have been 0, but was %d", result);            
        }
    }
    
    [calculator release];
}

@end
