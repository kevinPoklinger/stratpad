//
//  ActivityTest.m
//  StratPad
//
//  Created by Eric on 11-11-08.
//  Copyright (c) 2011 Glassey Strategy. All rights reserved.
//

#import "Theme.h"
#import "StratFile.h"
#import "Objective.h"
#import "Activity.h"
#import "DataManager.h"
#import "NSCalendar+Expanded.h"
#import "NSDate-StratPad.h"
#import "TestSupport.h"
#import <SenTestingKit/SenTestingKit.h>
#import "CoreDataTestCase.h"

@interface ActivityTest : CoreDataTestCase {    
}
@end


@implementation ActivityTest


#pragma mark - durationInMonths Tests

/*
 * Test the durationInMonths method in the situation where
 * an activity has a start date set to March 1, 2011, and an end date set to September 30, 2011. It is 
 * expected that the activity duration will be 7 months.
 */
- (void)testDurationInMonths1
{
    Activity *activity = (Activity*)[DataManager createManagedInstance:NSStringFromClass([Activity class])];
    
    NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:1];
    [comps setMonth:3];
    [comps setYear:2011];
    [comps setHour:0];
    [comps setMinute:0];
    [comps setSecond:0];
    
    NSDate *d1 = [gregorian dateFromComponents:comps];
    activity.startDate = [d1 dateWithZeroedTime];
    
    [comps setDay:30];
    [comps setMonth:9];
    [comps setYear:2011];
    
    NSDate *d2 = [gregorian dateFromComponents:comps];
    activity.endDate = [d2 dateWithZeroedTime];    
    [comps release];
    
    NSUInteger duration = [activity durationInMonths];
    
    STAssertTrue(duration == 7, @"Theme duration should have been 7 months, but was %i", duration);
}

/*
 * Test the durationInMonths method in the situation where
 * an activity has a start date set to March 15, 2011, and an end date set to September 1, 2011. It is 
 * expected that the theme duration will be 7 months.
 */
- (void)testDurationInMonths2
{
    Activity *activity = (Activity*)[DataManager createManagedInstance:NSStringFromClass([Activity class])];
    
    NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:15];
    [comps setMonth:3];
    [comps setYear:2011];
    [comps setHour:0];
    [comps setMinute:0];
    [comps setSecond:0];
    
    activity.startDate = [[gregorian dateFromComponents:comps] dateWithZeroedTime];
    
    [comps setDay:1];
    [comps setMonth:9];
    [comps setYear:2011];
    
    activity.endDate = [[gregorian dateFromComponents:comps] dateWithZeroedTime];    
    [comps release];
    
    NSUInteger duration = [activity durationInMonths];
    
    STAssertTrue(duration == 7, @"Theme duration should have been 7 months, but was %i", duration);
}

/*
 * Test the durationInMonths method in the situation where
 * an activity has a start date set to November 1, 2011, and an end date set to November 1, 2013. It is 
 * expected that the activity duration will be 25 months.
 */
- (void)testDurationInMonths3
{
    Activity *activity = (Activity*)[DataManager createManagedInstance:NSStringFromClass([Activity class])];
    
    NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:1];
    [comps setMonth:11];
    [comps setYear:2011];
    [comps setHour:0];
    [comps setMinute:0];
    [comps setSecond:0];
    
    activity.startDate = [[gregorian dateFromComponents:comps] dateWithZeroedTime];
    
    [comps setDay:1];
    [comps setMonth:11];
    [comps setYear:2013];
    
    activity.endDate = [[gregorian dateFromComponents:comps] dateWithZeroedTime];    
    [comps release];
    
    NSUInteger duration = [activity durationInMonths];
    
    STAssertTrue(duration == 25, @"Theme duration should have been 25 months, but was %i", duration);
}

/*
 * Test the durationInMonths method in the situation where
 * an activity has no start or end date, and its corresponding theme has no start or end date. 
 * It is expected that the activity duration will be that of its theme, which is 61 months.
 */
- (void)testDurationInMonths4
{
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    
    Theme *theme = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];    
    theme.startDate = nil;
    theme.endDate = nil;
    [stratFile addThemesObject:theme];
    
    Objective *objective = (Objective*)[DataManager createManagedInstance:NSStringFromClass([Objective class])];
    [theme addObjectivesObject:objective];
    
    Activity *activity = (Activity*)[DataManager createManagedInstance:NSStringFromClass([Activity class])];    
    activity.startDate = nil;
    activity.endDate = nil;
    [objective addActivitiesObject:activity];
    
    NSUInteger duration = [activity durationInMonths];
    
    STAssertTrue(duration == 61, @"Activity duration should have been 61 months, but was %i", duration);
}


/*
 * Test the durationInMonths method in the situation where
 * an activity has no start or end date, but its theme has a duration of 10 months. 
 * It is expected that the activity duration will be that of its theme.
 */
- (void)testDurationInMonths5
{
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    
    Theme *theme = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    
    NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:1];
    [comps setMonth:1];
    [comps setYear:2011];
    [comps setHour:0];
    [comps setMinute:0];
    [comps setSecond:0];    
    theme.startDate = [[gregorian dateFromComponents:comps] dateWithZeroedTime];  
    
    [comps setMonth:10];
    theme.endDate = [[gregorian dateFromComponents:comps] dateWithZeroedTime];    
    [stratFile addThemesObject:theme];
    
    Objective *objective = (Objective*)[DataManager createManagedInstance:NSStringFromClass([Objective class])];
    [theme addObjectivesObject:objective];
    
    Activity *activity = (Activity*)[DataManager createManagedInstance:NSStringFromClass([Activity class])];    
    activity.startDate = nil;
    activity.endDate = nil;
    [objective addActivitiesObject:activity];
    [comps release];
    
    NSUInteger duration = [activity durationInMonths];
    
    STAssertTrue(duration == 10, @"Activity duration should have been 10 months, but was %i", duration);
}

/*
 * Test the durationInMonths method in the situation where
 * an activity has a start date, 3 months from now, but no end date. It is 
 * expected that the activity will use the theme's normalized end date, which in this case
 * will be 6 months from now, and have a duration of 4 months.
 */
- (void)testDurationInMonths6
{
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    
    NSDate *now = [NSDate dateWithZeroedTime];
    
    Theme *theme = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    theme.startDate = now;
    
    NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setMonth:6];
    
    theme.endDate = [[gregorian dateByAddingComponents:comps toDate:theme.startDate options:0] dateWithZeroedTime];
    [stratFile addThemesObject:theme];
    
    Objective *objective = (Objective*)[DataManager createManagedInstance:NSStringFromClass([Objective class])];
    [theme addObjectivesObject:objective];
    
    Activity *activity = (Activity*)[DataManager createManagedInstance:NSStringFromClass([Activity class])];    
    [comps setMonth:3];
    activity.startDate = [gregorian dateByAddingComponents:comps toDate:now options:0];
    activity.endDate = nil;
    [objective addActivitiesObject:activity];
    [comps release];    
    
    NSUInteger duration = [activity durationInMonths];
    
    STAssertTrue(duration == 4, @"Theme duration should have been 4 months, but was %i", duration);
}

/*
 * Test the durationInMonths method in the situation where
 * an activity has an end date, 3 months from now, but no start date. It is 
 * expected that the activity will use the theme's normalized start date, which in this case
 * will be 1 month from now, and have a duration of 3 months.
 */
- (void)testDurationInMonths7
{
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    
    NSDate *now = [NSDate dateWithZeroedTime];
    
    Theme *theme = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    
    NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setMonth:1];
    theme.startDate = [gregorian dateByAddingComponents:comps toDate:now options:0];
    
    [comps setMonth:6];
    theme.endDate = [[gregorian dateByAddingComponents:comps toDate:theme.startDate options:0] dateWithZeroedTime];
    [stratFile addThemesObject:theme];
    
    Objective *objective = (Objective*)[DataManager createManagedInstance:NSStringFromClass([Objective class])];
    [theme addObjectivesObject:objective];
    
    Activity *activity = (Activity*)[DataManager createManagedInstance:NSStringFromClass([Activity class])];    
    activity.startDate = nil;
    
    [comps setMonth:3];
    activity.endDate = [[gregorian dateByAddingComponents:comps toDate:now options:0] dateWithZeroedTime];
    [objective addActivitiesObject:activity];
    [comps release];    
    
    NSUInteger duration = [activity durationInMonths];
    
    STAssertTrue(duration == 3, @"Theme duration should have been 3 months, but was %i", duration);
}


#pragma mark - numberOfMonthsFromStrategyStart Tests

/*
 * Test the numberOfMonthsFromThemeStart method in the situation where
 * the theme start date is the same as that for the activity.  It is expected
 * that the method will return 0.
 */
- (void)testNumberOfMonthsFromThemeStart1
{
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    Theme *theme = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];    
    theme.startDate = nil;    
    [stratFile addThemesObject:theme];
    
    Objective *objective = (Objective*)[DataManager createManagedInstance:NSStringFromClass([Objective class])];
    [theme addObjectivesObject:objective];
    
    Activity *activity = (Activity*)[DataManager createManagedInstance:NSStringFromClass([Activity class])];    
    activity.startDate = nil;
    [objective addActivitiesObject:activity];

    NSUInteger numberOfMonths = [activity numberOfMonthsFromThemeStart];
    
    STAssertTrue(numberOfMonths == 0, @"Number of months should have been 0, but was %i", numberOfMonths);
}

/*
 * Test the numberOfMonthsFromThemeStart method in the situation where
 * the activity start date is 3 months after the theme start date, which is 3 months after
 * the strategy start.  It is expected that the method will return 3.
 */
- (void)testNumberOfMonthsFromStrategyStart2
{
    NSDate *now = [NSDate dateWithZeroedTime];
    
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    Theme *theme1 = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];    
    theme1.startDate = now;
    [stratFile addThemesObject:theme1];
    
    Theme *theme2 = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];        
    NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setMonth:3];
    
    theme2.startDate = [[gregorian dateByAddingComponents:comps toDate:now options:0] dateWithZeroedTime];    
    [stratFile addThemesObject:theme2];
    
    Objective *objective = (Objective*)[DataManager createManagedInstance:NSStringFromClass([Objective class])];
    [theme2 addObjectivesObject:objective];
    
    Activity *activity = (Activity*)[DataManager createManagedInstance:NSStringFromClass([Activity class])];    
    activity.startDate = [[gregorian dateByAddingComponents:comps toDate:theme2.startDate options:0] dateWithZeroedTime];
    [objective addActivitiesObject:activity];
    [comps release];    

    NSUInteger numberOfMonths = [activity numberOfMonthsFromThemeStart];    
    STAssertTrue(numberOfMonths == 3, @"Number of months should have been 3, but was %i", numberOfMonths);
}

/*
 * Test the numberOfMonthsFromThemeStart method in the situation where
 * the activity start date is 3 months after the theme start date, which is equal to
 * the strategy start (nil).  It is expected that the method will return 3.
 */
- (void)testNumberOfMonthsFromStrategyStart3
{
    NSDate *now = [NSDate dateWithZeroedTime];
    
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    Theme *theme1 = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];    
    theme1.startDate = nil;
    [stratFile addThemesObject:theme1];
    
    NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setMonth:3];
    
    theme1.startDate = [[gregorian dateByAddingComponents:comps toDate:now options:0] dateWithZeroedTime];    
    [stratFile addThemesObject:theme1];
    
    Objective *objective = (Objective*)[DataManager createManagedInstance:NSStringFromClass([Objective class])];
    [theme1 addObjectivesObject:objective];
    
    Activity *activity = (Activity*)[DataManager createManagedInstance:NSStringFromClass([Activity class])];    
    activity.startDate = [[gregorian dateByAddingComponents:comps toDate:theme1.startDate options:0] dateWithZeroedTime];
    [objective addActivitiesObject:activity];
    [comps release];    
    
    NSUInteger numberOfMonths = [activity numberOfMonthsFromThemeStart];    
    STAssertTrue(numberOfMonths == 3, @"Number of months should have been 3, but was %i", numberOfMonths);
}

@end
