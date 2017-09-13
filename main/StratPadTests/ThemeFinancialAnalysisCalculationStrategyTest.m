//
//  ThemeFinancialAnalysisCalculationStrategyTest.m
//  StratPad
//
//  Created by Eric on 11-11-06.
//  Copyright (c) 2011 Glassey Strategy. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "ThemeFinancialAnalysisCalculationStrategy.h"
#import "DataManager.h"
#import "StratFile.h"
#import "Theme.h"
#import "Objective.h"
#import "Activity.h"
#import "Frequency.h"
#import "NSDate-StratPad.h"
#import "NSCalendar+Expanded.h"
#import "TestSupport.h"

@interface ThemeFinancialAnalysisCalculationStrategyTest : SenTestCase {    
}
@end


@implementation ThemeFinancialAnalysisCalculationStrategyTest


#pragma mark - changeInRevenueForMonthNumber Tests

/*
 * Test the changeInRevenueForMonthNumber method with a theme that starts on the same date as the strategy.
 * It is expected that the theme will begin contributing from the first month in the strategy.
 */
- (void)testChangeInRevenueForMonthNumber1
{    
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    Theme *theme1 = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    theme1.startDate = [NSDate dateWithZeroedTime];
    theme1.revenueMonthly = [NSNumber numberWithDouble:10];    
    [stratFile addThemesObject:theme1];
    
    ThemeFinancialAnalysisCalculationStrategy *strategy = [[ThemeFinancialAnalysisCalculationStrategy alloc] initWithTheme:theme1 isOptimistic:YES isRelativeToStrategyStart:YES];
    
    double result = 0;    
    for (uint i = 0; i < [strategy calculationDurationInMonths]; i++) {        
        result = [[strategy changeInRevenueForMonthNumber:i] doubleValue];        
        STAssertTrue(result == 10, @"Result should have been 10, but was %f", result);        
    }
    
    [strategy release];
}

/*
 * Test the changeInRevenueForMonthNumber method with a theme that starts in a month 5 months from the 
 * beginning of the strategy.  It is expected that the theme will begin contributing from month 5 in the strategy.
 */
- (void)testChangeInRevenueForMonthNumber2
{    
    StratFile *stratFile = [TestSupport createEmptyStratFile];

    Theme *theme1 = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    theme1.startDate = [NSDate dateWithZeroedTime];
    [stratFile addThemesObject:theme1];

    Theme *theme2 = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];

    NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setMonth:5];    
    theme2.startDate = [[gregorian dateByAddingComponents:comps toDate:[NSDate dateWithZeroedTime] options:0] dateWithZeroedTime];
    [comps release];
    
    theme2.revenueMonthly = [NSNumber numberWithDouble:10];    
    [stratFile addThemesObject:theme2];

    ThemeFinancialAnalysisCalculationStrategy *strategy = [[ThemeFinancialAnalysisCalculationStrategy alloc] initWithTheme:theme2 isOptimistic:YES isRelativeToStrategyStart:YES];
    
    double result = 0;    
    for (uint i = 0; i < [strategy calculationDurationInMonths]; i++) {        
        result = [[strategy changeInRevenueForMonthNumber:i] doubleValue];        
        
        if (i >= 5) {
            STAssertTrue(result == 10, @"Result should have been 10, but was %f for %i", result, i);        
        } else {
            STAssertTrue(result == 0, @"Result should have been 0, but was %f", result);        
        }
    }
    
    [strategy release];
}

/*
 * Test the changeInRevenueForMonthNumber method with a theme that starts in a month 5 months from the 
 * beginning of the strategy, and is two months in length.  It is expected that the theme will begin contributing 
 * from months 5 to 7 in the strategy.
 */
- (void)testChangeInRevenueForMonthNumber3
{    
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    
    Theme *theme1 = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    theme1.startDate = [NSDate dateWithZeroedTime];
    [stratFile addThemesObject:theme1];
    
    Theme *theme2 = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    
    NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setMonth:5];    
    theme2.startDate = [[gregorian dateByAddingComponents:comps toDate:[NSDate dateWithZeroedTime] options:0] dateWithZeroedTime];

    [comps setMonth:7];    
    theme2.endDate = [[gregorian dateByAddingComponents:comps toDate:[NSDate dateWithZeroedTime] options:0] dateWithZeroedTime];
    [comps release];
    
    theme2.revenueMonthly = [NSNumber numberWithDouble:10];    
    [stratFile addThemesObject:theme2];
    
    ThemeFinancialAnalysisCalculationStrategy *strategy = [[ThemeFinancialAnalysisCalculationStrategy alloc] initWithTheme:theme2 isOptimistic:YES isRelativeToStrategyStart:YES];
    
    double result = 0;    
    for (uint i = 0; i < [strategy calculationDurationInMonths]; i++) {        
        result = [[strategy changeInRevenueForMonthNumber:i] doubleValue];        
        
        if (i >= 5 && i <= 7) {
            STAssertTrue(result == 10, @"Result should have been 10, but was %f for %i", result, i);        
        } else {
            STAssertTrue(result == 0, @"Result should have been 0, but was %f", result);        
        }
    }
    
    [strategy release];
}


#pragma mark - firstYearChangeInRevenue Tests

/*
 * Test the firstYearChangeInRevenue method with a theme that is 6 months in duration, and the
 * calculation is not relative to the strategy start date.  It is expected that the first year 
 * change in revenue will be the sum of the all revenue calculations for the theme.
 */
- (void)testFirstYearChangeInRevenue1
{    
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    Theme *theme1 = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    theme1.startDate = [NSDate dateWithZeroedTime];
    
    NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setMonth:5];    
    theme1.endDate = [[gregorian dateByAddingComponents:comps toDate:[NSDate dateWithZeroedTime] options:0] dateWithZeroedTime];
    [comps release];

    theme1.revenueMonthly = [NSNumber numberWithDouble:10];    
    [stratFile addThemesObject:theme1];
    
    ThemeFinancialAnalysisCalculationStrategy *strategy = [[ThemeFinancialAnalysisCalculationStrategy alloc] initWithTheme:theme1 isOptimistic:YES isRelativeToStrategyStart:NO];
    
    double result = [[strategy changeInRevenueForYear:0] doubleValue];
    STAssertTrue(result == 60, @"Result should have been 60, but was %f", result);        
    
    [strategy release];
}

/*
 * Test the firstYearChangeInRevenue method with a theme that begins 8 months after the strategy start, and the
 * calculation is relative to the strategy start date.  It is expected that the first year 
 * change in revenue will be the sum of the first 6 months of the revenue calculations for the theme.
 */
- (void)testFirstYearChangeInRevenue2
{    
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    Theme *theme1 = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    theme1.startDate = [NSDate dateWithZeroedTime];
    [stratFile addThemesObject:theme1];
    
    Theme *theme2 = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    
    NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setMonth:8];    
    theme2.startDate = [[gregorian dateByAddingComponents:comps toDate:[NSDate dateWithZeroedTime] options:0] dateWithZeroedTime];
    [comps release];
    
    theme2.revenueMonthly = [NSNumber numberWithDouble:10];    
    [stratFile addThemesObject:theme2];
    
    ThemeFinancialAnalysisCalculationStrategy *strategy = [[ThemeFinancialAnalysisCalculationStrategy alloc] initWithTheme:theme2 isOptimistic:YES isRelativeToStrategyStart:YES];
    
    double result = [[strategy changeInRevenueForYear:0] doubleValue];
    STAssertTrue(result == 40, @"Result should have been 40, but was %f", result);        
    
    [strategy release];
}


#pragma mark - subsYearsChangeInRevenue Tests

/*
 * Test the subsYearsChangeInRevenue method with a theme that is 6 months in duration, and the
 * calculation is not relative to the strategy start date.  It is expected that the subs years
 * change in revenue will be 0.
 */
- (void)testSubsYearsChangeInRevenue1
{    
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    Theme *theme1 = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    theme1.startDate = [NSDate dateWithZeroedTime];
    
    NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setMonth:5];    
    theme1.endDate = [[gregorian dateByAddingComponents:comps toDate:[NSDate dateWithZeroedTime] options:0] dateWithZeroedTime];
    [comps release];
    
    theme1.revenueMonthly = [NSNumber numberWithDouble:10];    
    [stratFile addThemesObject:theme1];
    
    ThemeFinancialAnalysisCalculationStrategy *strategy = [[ThemeFinancialAnalysisCalculationStrategy alloc] initWithTheme:theme1 isOptimistic:YES isRelativeToStrategyStart:NO];
    
    double result = [[strategy changeInRevenueForYearsAfter:0] doubleValue];
    STAssertTrue(result == 0, @"Result should have been 0, but was %f", result);        
    
    [strategy release];
}

/*
 * Test the subsYearsChangeInRevenue method with a theme that begins 8 months after the strategy start, and the
 * calculation is relative to the strategy start date.  It is expected that the subs years 
 * change in revenue will be the sum of months 12 to 60 of the revenue calculations for the theme.
 */
- (void)testSubsYearsChangeInRevenue2
{    
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    Theme *theme1 = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    theme1.startDate = [NSDate dateWithZeroedTime];
    [stratFile addThemesObject:theme1];
    
    Theme *theme2 = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    
    NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setMonth:8];    
    theme2.startDate = [[gregorian dateByAddingComponents:comps toDate:[NSDate dateWithZeroedTime] options:0] dateWithZeroedTime];
    [comps release];
    
    theme2.revenueMonthly = [NSNumber numberWithDouble:10];    
    [stratFile addThemesObject:theme2];
    
    ThemeFinancialAnalysisCalculationStrategy *strategy = [[ThemeFinancialAnalysisCalculationStrategy alloc] initWithTheme:theme2 isOptimistic:YES isRelativeToStrategyStart:YES];
    
    double result = [[strategy changeInRevenueForYearsAfter:0] doubleValue];
    STAssertTrue(result == 480, @"Result should have been 480, but was %f", result);        
    
    [strategy release];
}


#pragma mark - changeInCOGSForMonthNumber Tests

/*
 * Test the changeInCOGSForMonthNumber method with a theme that starts on the same date as the strategy.
 * It is expected that the theme will begin contributing from the first month in the strategy.
 */
- (void)testChangeInCOGSForMonthNumber1
{    
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    Theme *theme1 = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    theme1.startDate = [NSDate dateWithZeroedTime];
    theme1.cogsMonthly = [NSNumber numberWithDouble:10];    
    [stratFile addThemesObject:theme1];
    
    ThemeFinancialAnalysisCalculationStrategy *strategy = [[ThemeFinancialAnalysisCalculationStrategy alloc] initWithTheme:theme1 isOptimistic:YES isRelativeToStrategyStart:YES];
    
    double result = 0;    
    for (uint i = 0; i < [strategy calculationDurationInMonths]; i++) {
        result = [[strategy changeInCOGSForMonthNumber:i] doubleValue];        
        STAssertTrue(result == 10, @"Result should have been 10, but was %f", result);        
    }
    
    [strategy release];
}

/*
 * Test the changeInCOGSForMonthNumber method with a theme that starts in a month 5 months from the 
 * beginning of the strategy.  It is expected that the theme will begin contributing from month 5 in the strategy.
 */
- (void)testChangeInCOGSForMonthNumber2
{    
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    
    Theme *theme1 = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    theme1.startDate = [NSDate dateWithZeroedTime];
    [stratFile addThemesObject:theme1];
    
    Theme *theme2 = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    
    NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setMonth:5];    
    theme2.startDate = [[gregorian dateByAddingComponents:comps toDate:[NSDate dateWithZeroedTime] options:0] dateWithZeroedTime];
    [comps release];
    
    theme2.cogsMonthly = [NSNumber numberWithDouble:10];    
    [stratFile addThemesObject:theme2];
    
    ThemeFinancialAnalysisCalculationStrategy *strategy = [[ThemeFinancialAnalysisCalculationStrategy alloc] initWithTheme:theme2 isOptimistic:YES isRelativeToStrategyStart:YES];
    
    double result = 0;    
    for (uint i = 0; i < [strategy calculationDurationInMonths]; i++) {        
        result = [[strategy changeInCOGSForMonthNumber:i] doubleValue];        
        
        if (i >= 5) {
            STAssertTrue(result == 10, @"Result should have been 10, but was %f for %i", result, i);        
        } else {
            STAssertTrue(result == 0, @"Result should have been 0, but was %f", result);        
        }
    }
    
    [strategy release];
}

/*
 * Test the changeInCOGSForMonthNumber method with a theme that starts in a month 5 months from the 
 * beginning of the strategy, and is two months in length.  It is expected that the theme will begin contributing 
 * from months 5 to 7 in the strategy.
 */
- (void)testChangeInCOGSForMonthNumber3
{    
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    
    Theme *theme1 = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    theme1.startDate = [NSDate dateWithZeroedTime];
    [stratFile addThemesObject:theme1];
    
    Theme *theme2 = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    
    NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setMonth:5];    
    theme2.startDate = [[gregorian dateByAddingComponents:comps toDate:[NSDate dateWithZeroedTime] options:0] dateWithZeroedTime];
    
    [comps setMonth:7];    
    theme2.endDate = [[gregorian dateByAddingComponents:comps toDate:[NSDate dateWithZeroedTime] options:0] dateWithZeroedTime];
    [comps release];
    
    theme2.cogsMonthly = [NSNumber numberWithDouble:10];    
    [stratFile addThemesObject:theme2];
    
    ThemeFinancialAnalysisCalculationStrategy *strategy = [[ThemeFinancialAnalysisCalculationStrategy alloc] initWithTheme:theme2 isOptimistic:YES isRelativeToStrategyStart:YES];
    
    double result = 0;    
    for (uint i = 0; i < [strategy calculationDurationInMonths]; i++) {        
        result = [[strategy changeInCOGSForMonthNumber:i] doubleValue];        
        
        if (i >= 5 && i <= 7) {
            STAssertTrue(result == 10, @"Result should have been 10, but was %f for %i", result, i);        
        } else {
            STAssertTrue(result == 0, @"Result should have been 0, but was %f", result);        
        }
    }
    
    [strategy release];
}


#pragma mark - firstYearChangeInCOGS Tests

/*
 * Test the firstYearChangeInCOGS method with a theme that is 6 months in duration, and the
 * calculation is not relative to the strategy start date.  It is expected that the first year 
 * change in COGS will be the sum of the all COGS calculations for the theme.
 */
- (void)testFirstYearChangeInCOGS1
{    
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    Theme *theme1 = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    theme1.startDate = [NSDate dateWithZeroedTime];
    
    NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setMonth:5];    
    theme1.endDate = [[gregorian dateByAddingComponents:comps toDate:[NSDate dateWithZeroedTime] options:0] dateWithZeroedTime];
    [comps release];
    
    theme1.cogsMonthly = [NSNumber numberWithDouble:10];    
    [stratFile addThemesObject:theme1];
    
    ThemeFinancialAnalysisCalculationStrategy *strategy = [[ThemeFinancialAnalysisCalculationStrategy alloc] initWithTheme:theme1 isOptimistic:YES isRelativeToStrategyStart:NO];
    
    double result = [[strategy changeInCOGSForYear:0] doubleValue];
    STAssertTrue(result == 60, @"Result should have been 60, but was %f", result);        
    
    [strategy release];
}

/*
 * Test the firstYearChangeInCOGS method with a theme that begins 8 months after the strategy start, and the
 * calculation is relative to the strategy start date.  It is expected that the first year 
 * change in COGS will be the sum of the first 6 months of the COGS calculations for the theme.
 */
- (void)testFirstYearChangeInCOGS2
{    
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    Theme *theme1 = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    theme1.startDate = [NSDate dateWithZeroedTime];
    [stratFile addThemesObject:theme1];
    
    Theme *theme2 = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    
    NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setMonth:8];    
    theme2.startDate = [[gregorian dateByAddingComponents:comps toDate:[NSDate dateWithZeroedTime] options:0] dateWithZeroedTime];
    [comps release];
    
    theme2.cogsMonthly = [NSNumber numberWithDouble:10];    
    [stratFile addThemesObject:theme2];
    
    ThemeFinancialAnalysisCalculationStrategy *strategy = [[ThemeFinancialAnalysisCalculationStrategy alloc] initWithTheme:theme2 isOptimistic:YES isRelativeToStrategyStart:YES];
    
    double result = [[strategy changeInCOGSForYear:0] doubleValue];
    STAssertTrue(result == 40, @"Result should have been 40, but was %f", result);        
    
    [strategy release];
}


#pragma mark - subsYearsChangeInCOGS Tests

/*
 * Test the subsYearsChangeInCOGS method with a theme that is 6 months in duration, and the
 * calculation is not relative to the strategy start date.  It is expected that the subs years
 * change in cogs will be 0.
 */
- (void)testSubsYearsChangeInCOGS1
{    
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    Theme *theme1 = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    theme1.startDate = [NSDate dateWithZeroedTime];
    
    NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setMonth:5];    
    theme1.endDate = [[gregorian dateByAddingComponents:comps toDate:[NSDate dateWithZeroedTime] options:0] dateWithZeroedTime];
    [comps release];
    
    theme1.cogsMonthly = [NSNumber numberWithDouble:10];    
    [stratFile addThemesObject:theme1];
    
    ThemeFinancialAnalysisCalculationStrategy *strategy = [[ThemeFinancialAnalysisCalculationStrategy alloc] initWithTheme:theme1 isOptimistic:YES isRelativeToStrategyStart:NO];
    
    double result = [[strategy changeInCOGSForYearsAfter:0] doubleValue];
    STAssertTrue(result == 0, @"Result should have been 0, but was %f", result);        
    
    [strategy release];
}

/*
 * Test the subsYearsChangeInCOGS method with a theme that begins 8 months after the strategy start, and the
 * calculation is relative to the strategy start date.  It is expected that the subs years 
 * change in cogs will be the sum of months 12 to 60 of the cogs calculations for the theme.
 */
- (void)testSubsYearsChangeInCOGS2
{    
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    Theme *theme1 = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    theme1.startDate = [NSDate dateWithZeroedTime];
    [stratFile addThemesObject:theme1];
    
    Theme *theme2 = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    
    NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setMonth:8];    
    theme2.startDate = [[gregorian dateByAddingComponents:comps toDate:[NSDate dateWithZeroedTime] options:0] dateWithZeroedTime];
    [comps release];
    
    theme2.cogsMonthly = [NSNumber numberWithDouble:10];    
    [stratFile addThemesObject:theme2];
    
    ThemeFinancialAnalysisCalculationStrategy *strategy = [[ThemeFinancialAnalysisCalculationStrategy alloc] initWithTheme:theme2 isOptimistic:YES isRelativeToStrategyStart:YES];
    
    double result = [[strategy changeInCOGSForYearsAfter:0] doubleValue];
    STAssertTrue(result == 480, @"Result should have been 480, but was %f", result);        
    
    [strategy release];
}


#pragma mark - changeInExpensesForMonthNumber Tests

/*
 * Test the changeInExpensesForMonthNumber method with a theme that starts on the same date as the strategy.
 * It is expected that the theme will begin contributing from the first month in the strategy.
 */
- (void)testChangeInExpensesForMonthNumber1
{    
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    Theme *theme1 = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    theme1.startDate = [NSDate dateWithZeroedTime];
    theme1.researchAndDevelopmentMonthly = [NSNumber numberWithDouble:10];    
    [stratFile addThemesObject:theme1];
    
    ThemeFinancialAnalysisCalculationStrategy *strategy = [[ThemeFinancialAnalysisCalculationStrategy alloc] initWithTheme:theme1 isOptimistic:YES isRelativeToStrategyStart:YES];
    
    double result = 0;    
    for (uint i = 0; i < [strategy calculationDurationInMonths]; i++) {        
        result = [[strategy changeInRadForMonthNumber:i] doubleValue];        
        STAssertTrue(result == 10, @"Result should have been 10, but was %f", result);        
    }
    
    [strategy release];
}

/*
 * Test the changeInExpensesForMonthNumber method with a theme that starts in a month 5 months from the 
 * beginning of the strategy.  It is expected that the theme will begin contributing from month 5 in the strategy.
 */
- (void)testChangeInExpensesForMonthNumber2
{    
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    
    Theme *theme1 = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    theme1.startDate = [NSDate dateWithZeroedTime];
    [stratFile addThemesObject:theme1];
    
    Theme *theme2 = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    
    NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setMonth:5];    
    theme2.startDate = [[gregorian dateByAddingComponents:comps toDate:[NSDate dateWithZeroedTime] options:0] dateWithZeroedTime];
    [comps release];
    
    theme2.researchAndDevelopmentMonthly = [NSNumber numberWithDouble:10];    
    [stratFile addThemesObject:theme2];
    
    ThemeFinancialAnalysisCalculationStrategy *strategy = [[ThemeFinancialAnalysisCalculationStrategy alloc] initWithTheme:theme2 isOptimistic:YES isRelativeToStrategyStart:YES];
    
    double result = 0;    
    for (uint i = 0; i < [strategy calculationDurationInMonths]; i++) {        
        result = [[strategy changeInRadForMonthNumber:i] doubleValue];        
        
        if (i >= 5) {
            STAssertTrue(result == 10, @"Result should have been 10, but was %f for %i", result, i);        
        } else {
            STAssertTrue(result == 0, @"Result should have been 0, but was %f", result);        
        }
    }
    
    [strategy release];
}

/*
 * Test the changeInExpensesForMonthNumber method with a theme that starts in a month 5 months from the 
 * beginning of the strategy, and is two months in length.  It is expected that the theme will begin contributing 
 * from months 5 to 7 in the strategy.
 */
- (void)testChangeInExpensesForMonthNumber3
{    
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    
    Theme *theme1 = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    theme1.startDate = [NSDate dateWithZeroedTime];
    [stratFile addThemesObject:theme1];
    
    Theme *theme2 = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    
    NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setMonth:5];    
    theme2.startDate = [[gregorian dateByAddingComponents:comps toDate:[NSDate dateWithZeroedTime] options:0] dateWithZeroedTime];
    
    [comps setMonth:7];    
    theme2.endDate = [[gregorian dateByAddingComponents:comps toDate:[NSDate dateWithZeroedTime] options:0] dateWithZeroedTime];
    [comps release];
    
    theme2.researchAndDevelopmentMonthly = [NSNumber numberWithDouble:10];    
    [stratFile addThemesObject:theme2];
    
    ThemeFinancialAnalysisCalculationStrategy *strategy = [[ThemeFinancialAnalysisCalculationStrategy alloc] initWithTheme:theme2 isOptimistic:YES isRelativeToStrategyStart:YES];
    
    double result = 0;    
    for (uint i = 0; i < [strategy calculationDurationInMonths]; i++) {        
        result = [[strategy changeInRadForMonthNumber:i] doubleValue];        
        
        if (i >= 5 && i <= 7) {
            STAssertTrue(result == 10, @"Result should have been 10, but was %f for %i", result, i);        
        } else {
            STAssertTrue(result == 0, @"Result should have been 0, but was %f", result);        
        }
    }
    
    [strategy release];
}


#pragma mark - firstYearChangeInExpenses Tests

/*
 * Test the firstYearChangeInExpenses method with a theme that is 6 months in duration, and the
 * calculation is not relative to the strategy start date.  It is expected that the first year 
 * change in expenses will be the sum of the all expense calculations for the theme.
 */
- (void)testFirstYearChangeInExpenses1
{    
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    Theme *theme1 = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    theme1.startDate = [NSDate dateWithZeroedTime];
    
    NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setMonth:5];    
    theme1.endDate = [[gregorian dateByAddingComponents:comps toDate:[NSDate dateWithZeroedTime] options:0] dateWithZeroedTime];
    [comps release];
    
    theme1.researchAndDevelopmentMonthly = [NSNumber numberWithDouble:10];    
    [stratFile addThemesObject:theme1];
    
    ThemeFinancialAnalysisCalculationStrategy *strategy = [[ThemeFinancialAnalysisCalculationStrategy alloc] initWithTheme:theme1 isOptimistic:YES isRelativeToStrategyStart:NO];
    
    double result = [[strategy changeInRadForYear:0] doubleValue];
    STAssertTrue(result == 60, @"Result should have been 60, but was %f", result);        
    
    [strategy release];
}

/*
 * Test the firstYearChangeInExpenses method with a theme that begins 8 months after the strategy start, and the
 * calculation is relative to the strategy start date.  It is expected that the first year 
 * change in expenses will be the sum of the first 6 months of the expense calculations for the theme.
 */
- (void)testFirstYearChangeInExpenses2
{    
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    Theme *theme1 = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    theme1.startDate = [NSDate dateWithZeroedTime];
    [stratFile addThemesObject:theme1];
    
    Theme *theme2 = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    
    NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setMonth:8];    
    theme2.startDate = [[gregorian dateByAddingComponents:comps toDate:[NSDate dateWithZeroedTime] options:0] dateWithZeroedTime];
    [comps release];
    
    theme2.researchAndDevelopmentMonthly = [NSNumber numberWithDouble:10];    
    [stratFile addThemesObject:theme2];
    
    ThemeFinancialAnalysisCalculationStrategy *strategy = [[ThemeFinancialAnalysisCalculationStrategy alloc] initWithTheme:theme2 isOptimistic:YES isRelativeToStrategyStart:YES];
    
    double result = [[strategy changeInRadForYear:0] doubleValue];
    STAssertTrue(result == 40, @"Result should have been 40, but was %f", result);        
    
    [strategy release];
}


#pragma mark - subsYearsChangeInExpenses Tests

/*
 * Test the subsYearsChangeInExpenses method with a theme that is 6 months in duration, and the
 * calculation is not relative to the strategy start date.  It is expected that the subs years
 * change in expenses will be 0.
 */
- (void)testSubsYearsChangeInExpenses1
{    
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    Theme *theme1 = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    theme1.startDate = [NSDate dateWithZeroedTime];
    
    NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setMonth:5];    
    theme1.endDate = [[gregorian dateByAddingComponents:comps toDate:[NSDate dateWithZeroedTime] options:0] dateWithZeroedTime];
    [comps release];
    
    theme1.researchAndDevelopmentMonthly = [NSNumber numberWithDouble:10];    
    [stratFile addThemesObject:theme1];
    
    ThemeFinancialAnalysisCalculationStrategy *strategy = [[ThemeFinancialAnalysisCalculationStrategy alloc] initWithTheme:theme1 isOptimistic:YES isRelativeToStrategyStart:NO];
    
    double result = [[strategy changeInRadForYearsAfter:0] doubleValue];
    STAssertTrue(result == 0, @"Result should have been 0, but was %f", result);        
    
    [strategy release];
}

/*
 * Test the subsYearsChangeInExpenses method with a theme that begins 8 months after the strategy start, and the
 * calculation is relative to the strategy start date.  It is expected that the subs years 
 * change in expenses will be the sum of months 12 to 60 of the expense calculations for the theme.
 */
- (void)testSubsYearsChangeInExpenses2
{    
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    Theme *theme1 = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    theme1.startDate = [NSDate dateWithZeroedTime];
    [stratFile addThemesObject:theme1];
    
    Theme *theme2 = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    
    NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setMonth:8];    
    theme2.startDate = [[gregorian dateByAddingComponents:comps toDate:[NSDate dateWithZeroedTime] options:0] dateWithZeroedTime];
    [comps release];
    
    theme2.researchAndDevelopmentMonthly = [NSNumber numberWithDouble:10];    
    [stratFile addThemesObject:theme2];
    
    ThemeFinancialAnalysisCalculationStrategy *strategy = [[ThemeFinancialAnalysisCalculationStrategy alloc] initWithTheme:theme2 isOptimistic:YES isRelativeToStrategyStart:YES];
    
    double result = [[strategy changeInRadForYearsAfter:0] doubleValue];
    STAssertTrue(result == 480, @"Result should have been 480, but was %f", result);        
    
    [strategy release];
}


#pragma mark - changeInCostsForMonthNumber Tests

/*
 * Test the changeInCostsForMonthNumber method with a theme that starts on the same date as the strategy.
 * It is expected that the theme will begin contributing from the first month in the strategy.
 */
- (void)testChangeInCostsForMonthNumber1
{    
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    Theme *theme1 = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    theme1.startDate = [NSDate dateWithZeroedTime];
    theme1.generalAndAdminMonthly = [NSNumber numberWithDouble:10];    
    [stratFile addThemesObject:theme1];
    
    ThemeFinancialAnalysisCalculationStrategy *strategy = [[ThemeFinancialAnalysisCalculationStrategy alloc] initWithTheme:theme1 isOptimistic:YES isRelativeToStrategyStart:YES];
    
    double result = 0;    
    for (uint i = 0; i < [strategy calculationDurationInMonths]; i++) {        
        result = [[strategy changeInGaaForMonthNumber:i] doubleValue];        
        STAssertTrue(result == 10, @"Result should have been 10, but was %f", result);        
    }
    
    [strategy release];
}

/*
 * Test the changeInCostsForMonthNumber method with a theme that starts in a month 5 months from the 
 * beginning of the strategy.  It is expected that the theme will begin contributing from month 5 in the strategy.
 */
- (void)testChangeInCostsForMonthNumber2
{    
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    
    Theme *theme1 = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    theme1.startDate = [NSDate dateWithZeroedTime];
    [stratFile addThemesObject:theme1];
    
    Theme *theme2 = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    
    NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setMonth:5];    
    theme2.startDate = [[gregorian dateByAddingComponents:comps toDate:[NSDate dateWithZeroedTime] options:0] dateWithZeroedTime];
    [comps release];
    
    theme2.generalAndAdminMonthly = [NSNumber numberWithDouble:10];    
    [stratFile addThemesObject:theme2];
    
    ThemeFinancialAnalysisCalculationStrategy *strategy = [[ThemeFinancialAnalysisCalculationStrategy alloc] initWithTheme:theme2 isOptimistic:YES isRelativeToStrategyStart:YES];
    
    double result = 0;    
    for (uint i = 0; i < [strategy calculationDurationInMonths]; i++) {        
        result = [[strategy changeInGaaForMonthNumber:i] doubleValue];        
        
        if (i >= 5) {
            STAssertTrue(result == 10, @"Result should have been 10, but was %f for %i", result, i);        
        } else {
            STAssertTrue(result == 0, @"Result should have been 0, but was %f", result);        
        }
    }
    
    [strategy release];
}

/*
 * Test the changeInCostsForMonthNumber method with a theme that starts in a month 5 months from the 
 * beginning of the strategy, and is two months in length.  It is expected that the theme will begin contributing 
 * from months 5 to 7 in the strategy.
 */
- (void)testChangeInCostsForMonthNumber3
{    
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    
    Theme *theme1 = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    theme1.startDate = [NSDate dateWithZeroedTime];
    [stratFile addThemesObject:theme1];
    
    Theme *theme2 = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    
    NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setMonth:5];    
    theme2.startDate = [[gregorian dateByAddingComponents:comps toDate:[NSDate dateWithZeroedTime] options:0] dateWithZeroedTime];
    
    [comps setMonth:7];    
    theme2.endDate = [[gregorian dateByAddingComponents:comps toDate:[NSDate dateWithZeroedTime] options:0] dateWithZeroedTime];
    [comps release];
    
    theme2.generalAndAdminMonthly = [NSNumber numberWithDouble:10];    
    [stratFile addThemesObject:theme2];
    
    ThemeFinancialAnalysisCalculationStrategy *strategy = [[ThemeFinancialAnalysisCalculationStrategy alloc] initWithTheme:theme2 isOptimistic:YES isRelativeToStrategyStart:YES];
    
    double result = 0;    
    for (uint i = 0; i < [strategy calculationDurationInMonths]; i++) {        
        result = [[strategy changeInGaaForMonthNumber:i] doubleValue];        
        
        if (i >= 5 && i <= 7) {
            STAssertTrue(result == 10, @"Result should have been 10, but was %f for %i", result, i);        
        } else {
            STAssertTrue(result == 0, @"Result should have been 0, but was %f", result);        
        }
    }
    
    [strategy release];
}

/*
 * Test the changeInCostsForMonthNumber method with a theme that starts on the same date as the strategy.
 * The theme has an activity that begins on the same day as the theme.
 * It is expected that the activity will begin contributing from the first month in the strategy.
 */
- (void)testChangeInCostsForMonthNumber4
{    
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    Theme *theme1 = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    theme1.startDate = [NSDate dateWithZeroedTime];
    [stratFile addThemesObject:theme1];
    
    Objective *objective = (Objective*)[DataManager createManagedInstance:NSStringFromClass([Objective class])];
    [theme1 addObjectivesObject:objective];
    
    Activity *activity = (Activity*)[DataManager createManagedInstance:NSStringFromClass([Activity class])];
    activity.startDate = [NSDate dateWithZeroedTime];
    activity.upfrontCost = [NSNumber numberWithDouble:100];
    activity.ongoingCost = [NSNumber numberWithDouble:20];
    activity.ongoingFrequency = [Frequency frequencyForCategory:FrequencyCategoryMonthly];
    [objective addActivitiesObject:activity];
    
    ThemeFinancialAnalysisCalculationStrategy *strategy = [[ThemeFinancialAnalysisCalculationStrategy alloc] initWithTheme:theme1 isOptimistic:YES isRelativeToStrategyStart:YES];
    
    double result = 0;    
    for (uint i = 0; i < [strategy calculationDurationInMonths]; i++) {        
        
        result = [[strategy changeInGaaForMonthNumber:i] doubleValue];        
        
        if (i == 0) {
            STAssertTrue(result == 120, @"Result should have been 120, but was %f", result);        
        } else {
            STAssertTrue(result == 20, @"Result should have been 20, but was %f", result);            
        }
    }
    
    [strategy release];
}

/*
 * Test the changeInCostsForMonthNumber method with a theme that starts in a month 5 months from the 
 * beginning of the strategy.  The theme has an activity that begins 2 months into the theme.
 * It is expected that the activity will begin contributing from month 7 in the strategy.
 */
- (void)testChangeInCostsForMonthNumber5
{   
    NSDate *now = [NSDate dateWithZeroedTime];
    
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    Theme *theme1 = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    theme1.startDate = now;
    [stratFile addThemesObject:theme1];
    
    Theme *theme2 = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    
    NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setMonth:5];    
    theme2.startDate = [[gregorian dateByAddingComponents:comps toDate:now options:0] dateWithZeroedTime];
    [stratFile addThemesObject:theme2];
    
    Objective *objective = (Objective*)[DataManager createManagedInstance:NSStringFromClass([Objective class])];
    [theme2 addObjectivesObject:objective];
    
    Activity *activity = (Activity*)[DataManager createManagedInstance:NSStringFromClass([Activity class])];
    [comps setMonth:2];
    activity.startDate = [gregorian dateByAddingComponents:comps toDate:theme2.startDate options:0];
    activity.upfrontCost = [NSNumber numberWithDouble:100];
    activity.ongoingCost = [NSNumber numberWithDouble:20];
    activity.ongoingFrequency = [Frequency frequencyForCategory:FrequencyCategoryMonthly];
    [objective addActivitiesObject:activity];
    [comps release];
    
    ThemeFinancialAnalysisCalculationStrategy *strategy = [[ThemeFinancialAnalysisCalculationStrategy alloc] initWithTheme:theme2 isOptimistic:YES isRelativeToStrategyStart:YES];
    
    double result = 0;    
    for (uint i = 0; i < [strategy calculationDurationInMonths]; i++) {        
        
        result = [[strategy changeInGaaForMonthNumber:i] doubleValue];        
        
        if (i == 7) {
            STAssertTrue(result == 120, @"Result should have been 120, but was %f", result);
            
        } else if (i > 7) {
            STAssertTrue(result == 20, @"Result should have been 20, but was %f", result);
            
        } else {
            STAssertTrue(result == 0, @"Result should have been 0, but was %f", result);            
        }
    }
    
    [strategy release];
}

/*
 * Test the changeInCostsForMonthNumber method with a theme that starts in a month 5 months from the 
 * beginning of the strategy, and is two months in length.  It has an activity that begins and ends
 * at the same time.It is expected that the activity will begin contributing from months 5 to 7 in the strategy.
 */
- (void)testChangeInCostsForMonthNumber6
{    
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    
    Theme *theme1 = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    theme1.startDate = [NSDate dateWithZeroedTime];
    [stratFile addThemesObject:theme1];
    
    Theme *theme2 = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    
    NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setMonth:5];    
    theme2.startDate = [[gregorian dateByAddingComponents:comps toDate:[NSDate dateWithZeroedTime] options:0] dateWithZeroedTime];
    
    [comps setMonth:7];    
    theme2.endDate = [[gregorian dateByAddingComponents:comps toDate:[NSDate dateWithZeroedTime] options:0] dateWithZeroedTime];
    [stratFile addThemesObject:theme2];
    
    Objective *objective = (Objective*)[DataManager createManagedInstance:NSStringFromClass([Objective class])];
    [theme2 addObjectivesObject:objective];
    
    Activity *activity = (Activity*)[DataManager createManagedInstance:NSStringFromClass([Activity class])];
    [comps setMonth:2];
    activity.ongoingCost = [NSNumber numberWithDouble:20];
    activity.ongoingFrequency = [Frequency frequencyForCategory:FrequencyCategoryMonthly];
    [objective addActivitiesObject:activity];
    [comps release];
    
    ThemeFinancialAnalysisCalculationStrategy *strategy = [[ThemeFinancialAnalysisCalculationStrategy alloc] initWithTheme:theme2 isOptimistic:YES isRelativeToStrategyStart:YES];
    
    double result = 0;    
    for (uint i = 0; i < [strategy calculationDurationInMonths]; i++) {        
        result = [[strategy changeInGaaForMonthNumber:i] doubleValue];        
                
        if (i >= 5 && i <= 7) {
            STAssertTrue(result == 20, @"Result should have been 20, but was %f for %i", result, i);        
        } else {
            STAssertTrue(result == 0, @"Result should have been 0, but was %f", result);        
        }
    }
    
    [strategy release];
}


#pragma mark - firstYearChangeInCosts Tests

/*
 * Test the firstYearChangeInCosts method with a theme that is 6 months in duration, and the
 * calculation is not relative to the strategy start date.  It is expected that the first year 
 * change in costs will be the sum of the all cost calculations for the theme.
 */
- (void)testFirstYearChangeInCosts1
{    
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    Theme *theme1 = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    theme1.startDate = [NSDate dateWithZeroedTime];
    
    NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setMonth:5];    
    theme1.endDate = [[gregorian dateByAddingComponents:comps toDate:[NSDate dateWithZeroedTime] options:0] dateWithZeroedTime];
    [comps release];
    
    theme1.generalAndAdminMonthly = [NSNumber numberWithDouble:10];    
    [stratFile addThemesObject:theme1];
    
    ThemeFinancialAnalysisCalculationStrategy *strategy = [[ThemeFinancialAnalysisCalculationStrategy alloc] initWithTheme:theme1 isOptimistic:YES isRelativeToStrategyStart:NO];
    
    double result = [[strategy changeInGaaForYear:0] doubleValue];
    STAssertTrue(result == 60, @"Result should have been 60, but was %f", result);        
    
    [strategy release];
}

/*
 * Test the firstYearChangeInCosts method with a theme that begins 8 months after the strategy start, and the
 * calculation is relative to the strategy start date.  It is expected that the first year 
 * change in costs will be the sum of the first 6 months of the cost calculations for the theme.
 */
- (void)testFirstYearChangeInCosts2
{    
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    Theme *theme1 = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    theme1.startDate = [NSDate dateWithZeroedTime];
    [stratFile addThemesObject:theme1];
    
    Theme *theme2 = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    
    NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setMonth:8];    
    theme2.startDate = [[gregorian dateByAddingComponents:comps toDate:[NSDate dateWithZeroedTime] options:0] dateWithZeroedTime];
    [comps release];
    
    theme2.generalAndAdminMonthly = [NSNumber numberWithDouble:10];    
    [stratFile addThemesObject:theme2];
    
    ThemeFinancialAnalysisCalculationStrategy *strategy = [[ThemeFinancialAnalysisCalculationStrategy alloc] initWithTheme:theme2 isOptimistic:YES isRelativeToStrategyStart:YES];
    
    double result = [[strategy changeInGaaForYear:0] doubleValue];
    STAssertTrue(result == 40, @"Result should have been 40, but was %f", result);        
    
    [strategy release];
}


#pragma mark - subsYearsChangeInExpenses Tests

/*
 * Test the subsYearsChangeInCosts method with a theme that is 6 months in duration, and the
 * calculation is not relative to the strategy start date.  It is expected that the subs years
 * change in costs will be 0.
 */
- (void)testSubsYearsChangeInCosts1
{    
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    Theme *theme1 = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    theme1.startDate = [NSDate dateWithZeroedTime];
    
    NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setMonth:5];    
    theme1.endDate = [[gregorian dateByAddingComponents:comps toDate:[NSDate dateWithZeroedTime] options:0] dateWithZeroedTime];
    [comps release];
    
    theme1.generalAndAdminMonthly = [NSNumber numberWithDouble:10];    
    [stratFile addThemesObject:theme1];
    
    ThemeFinancialAnalysisCalculationStrategy *strategy = [[ThemeFinancialAnalysisCalculationStrategy alloc] initWithTheme:theme1 isOptimistic:YES isRelativeToStrategyStart:NO];
    
    double result = [[strategy changeInGaaForYearsAfter:0] doubleValue];
    STAssertTrue(result == 0, @"Result should have been 0, but was %f", result);        
    
    [strategy release];
}

/*
 * Test the subsYearsChangeInCosts method with a theme that begins 8 months after the strategy start, and the
 * calculation is relative to the strategy start date.  It is expected that the subs years 
 * change in costs will be the sum of months 12 to 60 of the cost calculations for the theme.
 */
- (void)testSubsYearsChangeInCosts2
{    
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    Theme *theme1 = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    theme1.startDate = [NSDate dateWithZeroedTime];
    [stratFile addThemesObject:theme1];
    
    Theme *theme2 = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    
    NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setMonth:8];    
    theme2.startDate = [[gregorian dateByAddingComponents:comps toDate:[NSDate dateWithZeroedTime] options:0] dateWithZeroedTime];
    [comps release];
    
    theme2.generalAndAdminMonthly = [NSNumber numberWithDouble:10];    
    [stratFile addThemesObject:theme2];
    
    ThemeFinancialAnalysisCalculationStrategy *strategy = [[ThemeFinancialAnalysisCalculationStrategy alloc] initWithTheme:theme2 isOptimistic:YES isRelativeToStrategyStart:YES];
    
    double result = [[strategy changeInGaaForYearsAfter:0] doubleValue];
    STAssertTrue(result == 480, @"Result should have been 480, but was %f", result);        
    
    [strategy release];
}

@end
