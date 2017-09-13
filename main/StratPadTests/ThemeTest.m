//
//  ThemeTest.m
//  StratPad
//
//  Created by Eric on 11-11-06.
//  Copyright (c) 2011 Glassey Strategy. All rights reserved.
//

#import "Theme.h"
#import "StratFile.h"
#import "DataManager.h"
#import "NSCalendar+Expanded.h"
#import "NSDate-StratPad.h"
#import "TestSupport.h"
#import <SenTestingKit/SenTestingKit.h>
#import "AppDelegate.h"
#import "CoreDataTestCase.h"

@interface ThemeTest : CoreDataTestCase {    
}
@end


@implementation ThemeTest


#pragma mark - durationInMonths Tests

/*
 * Test the durationInMonths method in the situation where
 * a theme has a start date set to March 1, 2011, and an end date set to September 30, 2011. It is 
 * expected that the theme duration will be 7 months.
 */
- (void)testDurationInMonths1
{
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    
    Theme *theme = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    
    NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:1];
    [comps setMonth:3];
    [comps setYear:2011];
    [comps setHour:0];
    [comps setMinute:0];
    [comps setSecond:0];
    
    theme.startDate = [[gregorian dateFromComponents:comps] dateWithZeroedTime];
    
    [comps setDay:30];
    [comps setMonth:9];
    [comps setYear:2011];

    theme.endDate = [[gregorian dateFromComponents:comps] dateWithZeroedTime];    
    [comps release];
    
    [stratFile addThemesObject:theme];
    
    NSUInteger duration = [theme durationInMonths];
    
    STAssertTrue(duration == 7, @"Theme duration should have been 7 months, but was %i", duration);
}

/*
 * Test the durationInMonths method in the situation where
 * a theme has a start date set to March 15, 2011, and an end date set to September 1, 2011. It is 
 * expected that the theme duration will be 7 months.
 */
- (void)testDurationInMonths2
{
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    
    Theme *theme = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    
    NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:15];
    [comps setMonth:3];
    [comps setYear:2011];
    [comps setHour:0];
    [comps setMinute:0];
    [comps setSecond:0];
    
    theme.startDate = [[gregorian dateFromComponents:comps] dateWithZeroedTime];
    
    [comps setDay:1];
    [comps setMonth:9];
    [comps setYear:2011];
    
    theme.endDate = [[gregorian dateFromComponents:comps] dateWithZeroedTime];    
    [comps release];
    
    [stratFile addThemesObject:theme];
    
    NSUInteger duration = [theme durationInMonths];
    
    STAssertTrue(duration == 7, @"Theme duration should have been 7 months, but was %i", duration);
}

/*
 * Test the durationInMonths method in the situation where
 * a theme has a start date set to November 1, 2011, and an end date set to November 1, 2013. It is 
 * expected that the theme duration will be 25 months.
 */
- (void)testDurationInMonths3
{
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    
    Theme *theme = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    
    NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:1];
    [comps setMonth:11];
    [comps setYear:2011];
    [comps setHour:0];
    [comps setMinute:0];
    [comps setSecond:0];
    
    theme.startDate = [[gregorian dateFromComponents:comps] dateWithZeroedTime];
    
    [comps setDay:1];
    [comps setMonth:11];
    [comps setYear:2013];
    
    theme.endDate = [[gregorian dateFromComponents:comps] dateWithZeroedTime];    
    [comps release];
    
    [stratFile addThemesObject:theme];
    
    NSUInteger duration = [theme durationInMonths];
    
    STAssertTrue(duration == 25, @"Theme duration should have been 25 months, but was %i", duration);
}

/*
 * Test the durationInMonths method in the situation where
 * a theme has no start or end date. It is expected that the theme
 * duration will be 60 months.
 */
- (void)testDurationInMonths4
{
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    
    Theme *theme = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    theme.startDate = nil;
    theme.endDate = nil;
    [stratFile addThemesObject:theme];

    // creating the dates like this doesn't take into account the leap year, and is thus off by 1 day, which means we're off by 1 month
    NSUInteger duration = [theme durationInMonths] - 1;

    STAssertTrue(duration == 60, @"Theme duration should have been 60 months, but was %i", duration);
}

/*
 * Test the durationInMonths method in the situation where
 * a theme has a start date, 3 months from now, but no end date. It is 
 * expected that the theme duration will be 60 months.
 */
- (void)testDurationInMonths5
{
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    
    Theme *theme = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];

    NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setMonth:3];
        
    theme.startDate = [[gregorian dateByAddingComponents:comps toDate:[NSDate dateWithZeroedTime] options:0] dateWithZeroedTime];
    theme.endDate = nil;
    [stratFile addThemesObject:theme];
    
    // creating the dates like this doesn't take into account the leap year, and is thus off by 1 day, which means we're off by 1 month
    NSUInteger duration = [theme durationInMonths] - 1;
    
    STAssertTrue(duration == 60, @"Theme duration should have been 60 months, but was %i", duration);
}

/*
 * Test the durationInMonths method in the situation where
 * a theme has no start date, and an end date 9 months from now. It is 
 * expected that the theme duration will be 10 months.
 */
- (void)testDurationInMonths6
{
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    
    Theme *theme = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    
    NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setMonth:9];
    
    theme.startDate = nil;
    theme.endDate = [[gregorian dateByAddingComponents:comps toDate:[NSDate dateWithZeroedTime] options:0] dateWithZeroedTime];
    [stratFile addThemesObject:theme];
    
    NSUInteger duration = [theme durationInMonths];
    
    STAssertTrue(duration == 10, @"Theme duration should have been 10 months, but was %i", duration);
}

/*
 * Test the durationInMonths method in the leap year situation where
 * a theme starts Jan 1, 2012 and ends Feb 29, 2012.
 * It is expected that the theme duration will be 2 months.
 */
- (void)testDurationInMonths7
{
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    
    Theme *theme = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
        
    theme.startDate = [NSDate dateFromISO8601:@"20120101"];
    theme.endDate = [NSDate dateFromISO8601:@"20120229"];
    [stratFile addThemesObject:theme];
    DLog(@"theme: %@", theme);
    
    NSUInteger duration = [theme durationInMonths];
    
    STAssertTrue(duration == 2, @"Theme duration should have been 2 months, but was %i", duration);
}


#pragma mark - numberOfMonthsFromStrategyStart Tests

/*
 * Test the numberOfMonthsFromStrategyStart method in the situation where
 * the strategy start date is the same as that for the theme.  It is expected
 * that the method will return 0.
 */
- (void)testNumberOfMonthsFromStrategyStart1
{
    StratFile *stratFile = [TestSupport createEmptyStratFile];    
    Theme *theme = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];    
    theme.startDate = nil;    
    [stratFile addThemesObject:theme];
    
    NSUInteger numberOfMonths = [theme numberOfMonthsFromStrategyStart];
    
    STAssertTrue(numberOfMonths == 0, @"Number of months should have been 0, but was %i", numberOfMonths);
}

/*
 * Test the numberOfMonthsFromStrategyStart method in the situation where
 * the theme start date is 3 months after the strategy start date.  It is expected
 * that the method will return 3.
 */
- (void)testNumberOfMonthsFromStrategyStart2
{
    StratFile *stratFile = [TestSupport createEmptyStratFile];    
    Theme *theme1 = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];    
    theme1.startDate = [[NSDate dateWithZeroedTime] dateWithZeroedTime];
    [stratFile addThemesObject:theme1];
    
    Theme *theme2 = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];        
    NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setMonth:3];

    theme2.startDate = [[gregorian dateByAddingComponents:comps toDate:[NSDate dateWithZeroedTime] options:0] dateWithZeroedTime];    
    [stratFile addThemesObject:theme2];
    
    NSUInteger numberOfMonths = [theme1 numberOfMonthsFromStrategyStart];    
    STAssertTrue(numberOfMonths == 0, @"Number of months should have been 0, but was %i", numberOfMonths);
    
    numberOfMonths = [theme2 numberOfMonthsFromStrategyStart];    
    STAssertTrue(numberOfMonths == 3, @"Number of months should have been 3, but was %i", numberOfMonths);
}

- (void)testModel
{
    StratFile *stratFile = [TestSupport createEmptyStratFile];    
    Theme *theme1 = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];    
    theme1.startDate = [[NSDate dateWithZeroedTime] dateWithZeroedTime];
    [stratFile addThemesObject:theme1];
    
    // flush out db errors
    NSManagedObjectContext *managedObjectContext = [(AppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
	NSError *error;
	if (![managedObjectContext save:&error]) {
		NSArray* detailedErrors = [[error userInfo] objectForKey:NSDetailedErrorsKey];
		if(detailedErrors != nil && [detailedErrors count] > 0) {
			for(NSError* detailedError in detailedErrors) {
				ELog(@"  DetailedError: %@", [detailedError userInfo]);
			}
		}
        STFail(@"Failed to save to data store: %@", [error localizedDescription]);
    }


}

@end
