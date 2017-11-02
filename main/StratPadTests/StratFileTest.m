//
//  StratFileTest.m
//  StratPad
//
//  Created by Eric Rogers on August 31, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "StratFile.h"
#import "Theme.h"
#import "DataManager.h"
#import "TestSupport.h"
#import "CoreDataTestCase.h"
#import "NSDate-StratPad.h"
#import "StratFileManager.h"

@interface StratFileTest : CoreDataTestCase {    
}
@end

@interface StratFileTest (Private)
- (BOOL)dayMonthYearEqualForDate1:(NSDate*)date1 andDate2:(NSDate*)date2;
@end

@implementation StratFileTest


#pragma mark - themesSortedByOrder Tests

- (void)testDescription
{
    NSString *path = [[NSBundle bundleForClass:[StratFileTest class]] 
                      pathForResource:@"export1" ofType:@"xml"];    
    StratFile *stratFile = [[StratFileManager sharedManager] stratFileFromXmlAtPath:path];

    @try {
        DLog(@"stratfile: %@", stratFile); 
    }
    @catch (NSException *exception) {
        STFail(@"Couldn't log stratfile at path: %@", path);
    }
    
    path = [[NSBundle bundleForClass:[StratFileTest class]] 
                      pathForResource:@"export2" ofType:@"xml"];    
    stratFile = [[StratFileManager sharedManager] stratFileFromXmlAtPath:path];
    
    @try {
        DLog(@"stratfile: %@", stratFile);        
    }
    @catch (NSException *exception) {
        STFail(@"Couldn't log stratfile at path: %@", path);
    }

    path = [[NSBundle bundleForClass:[StratFileTest class]] 
                      pathForResource:@"export3" ofType:@"xml"];    
    stratFile = [[StratFileManager sharedManager] stratFileFromXmlAtPath:path];
    
    @try {
        DLog(@"stratfile: %@", stratFile);        
    }
    @catch (NSException *exception) {
        STFail(@"Couldn't log stratfile at path: %@", path);
    }

}

- (void)testThemesSortedByOrder
{
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    NSArray *sortedThemes = [stratFile themesSortedByOrder];    
    STAssertTrue(sortedThemes.count == 0, @"Should not have received any themes, but got %i", sortedThemes.count);
        
    Theme *theme1 = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    theme1.order = [NSNumber numberWithInt:0];
    [stratFile addThemesObject:theme1];
    sortedThemes = [stratFile themesSortedByOrder];    
    STAssertTrue(sortedThemes.count == 1, @"Should have received 1 theme, but got %i", sortedThemes.count);
    STAssertEqualObjects(theme1, [sortedThemes objectAtIndex:0], @"First theme should have been theme1, but was %@", [sortedThemes objectAtIndex:0]);
    
    Theme *theme2 = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    theme2.order = [NSNumber numberWithInt:1];
    [stratFile addThemesObject:theme2];
    sortedThemes = [stratFile themesSortedByOrder];    
    STAssertTrue(sortedThemes.count == 2, @"Should have received 2 theme, but got %i", sortedThemes.count);
    STAssertEqualObjects(theme1, [sortedThemes objectAtIndex:0], @"First theme should have been theme1, but was %@", [sortedThemes objectAtIndex:0]);
    STAssertEqualObjects(theme2, [sortedThemes objectAtIndex:1], @"First theme should have been theme2, but was %@", [sortedThemes objectAtIndex:1]);
}


#pragma mark - themesSortedByStartDate Tests

- (void)testThemesSortedByStartDate
{
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    NSArray *sortedThemes = [stratFile themesSortedByStartDate];    
    STAssertTrue(sortedThemes.count == 0, @"Should not have received any themes, but got %i", sortedThemes.count);
    
    Theme *theme1 = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    [stratFile addThemesObject:theme1];
    sortedThemes = [stratFile themesSortedByStartDate];    
    STAssertTrue(sortedThemes.count == 1, @"Should have received 1 theme, but got %i", sortedThemes.count);
    STAssertEqualObjects(theme1, [sortedThemes objectAtIndex:0], @"First theme should have been theme1, but was %@", [sortedThemes objectAtIndex:0]);
    
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];    
    [comps setMonth:1];
    NSDate *aMonthFromNow = [gregorian dateByAddingComponents:comps toDate:[NSDate date] options:0];
    [comps release];
    [gregorian release];

    Theme *theme2 = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    theme2.startDate = aMonthFromNow;
    [stratFile addThemesObject:theme2];
    sortedThemes = [stratFile themesSortedByStartDate];    
    STAssertTrue(sortedThemes.count == 2, @"Should have received 2 themes, but got %i", sortedThemes.count);
    STAssertEqualObjects(theme1, [sortedThemes objectAtIndex:0], @"First theme should have been theme1, but was %@", [sortedThemes objectAtIndex:0]);
    STAssertEqualObjects(theme2, [sortedThemes objectAtIndex:1], @"First theme should have been theme2, but was %@", [sortedThemes objectAtIndex:1]);
    
    Theme *theme3 = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    theme3.startDate = [NSDate date];
    [stratFile addThemesObject:theme3];
    sortedThemes = [stratFile themesSortedByStartDate];    
    STAssertTrue(sortedThemes.count == 3, @"Should have received 3 themes, but got %i", sortedThemes.count);
    STAssertEqualObjects(theme1, [sortedThemes objectAtIndex:0], @"First theme should have been theme1, but was %@", [sortedThemes objectAtIndex:0]);
    STAssertEqualObjects(theme3, [sortedThemes objectAtIndex:1], @"Second theme should have been theme3, but was %@", [sortedThemes objectAtIndex:1]);
    STAssertEqualObjects(theme2, [sortedThemes objectAtIndex:2], @"Third theme should have been theme2, but was %@", [sortedThemes objectAtIndex:2]);
}


#pragma mark - dateOfEarliestThemeOrToday Tests

- (void)testDateOfEarliestThemeOrTodayWithNoThemes
{
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    NSDate *date = [stratFile dateOfEarliestThemeOrToday];
    STAssertTrue([date compareIgnoringTime:[NSDate date]] == NSOrderedSame, @"Earliest date should have been %@, but was %@", [NSDate date], date);
}

- (void)testDateOfEarliestThemeOrTodayWithOneThemeWithNoStartDate
{
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    
    Theme *theme1 = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    [stratFile addThemesObject:theme1];

    NSDate *date = [stratFile dateOfEarliestThemeOrToday];    
    STAssertTrue([self dayMonthYearEqualForDate1:date andDate2:[NSDate date]], @"Earliest date should have been today, but was %@", date);    
}

- (void)testDateOfEarliestThemeOrTodayWithOneThemeWithAStartDate
{
    StratFile *stratFile = [TestSupport createEmptyStratFile];

    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];    
    [comps setMonth:1];
    
    NSDate *aMonthFromNow = [gregorian dateByAddingComponents:comps toDate:[NSDate date] options:0];
    [comps release];

    Theme *theme1 = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    theme1.startDate = aMonthFromNow;
    [stratFile addThemesObject:theme1];
    
    NSDate *date = [stratFile dateOfEarliestThemeOrToday];    
    STAssertTrue([date isEqualToDate:aMonthFromNow], @"Earliest date should have been a month from now, but was %@", date);    
}

- (void)testDateOfEarliestThemeOrTodayWithMultipleThemesWithOneHavingNoStartDate
{
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];    
    [comps setMonth:1];
    
    NSDate *aMonthFromNow = [gregorian dateByAddingComponents:comps toDate:[NSDate date] options:0];
    [comps release];
    
    Theme *theme1 = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    theme1.startDate = aMonthFromNow;
    [stratFile addThemesObject:theme1];
    
    Theme *theme2 = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    theme2.startDate = [NSDate date];
    [stratFile addThemesObject:theme2];
    
    NSDate *date = [stratFile dateOfEarliestThemeOrToday];    
    STAssertTrue([self dayMonthYearEqualForDate1:date andDate2:[NSDate date]], @"Earliest date should have been today, but was %@", date);    
}

- (void)testDateOfEarliestThemeOrTodayWithMultipleThemesWithAllHavingStartDates
{
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];    
    [comps setMonth:1];
    
    NSDate *aMonthFromNow = [gregorian dateByAddingComponents:comps toDate:[NSDate date] options:0];

    [comps setMonth:0];
    [comps setYear:1];
    NSDate *aYearFromNow = [gregorian dateByAddingComponents:comps toDate:[NSDate date] options:0];    
    [comps release];
    
    Theme *theme1 = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    theme1.startDate = aYearFromNow;
    [stratFile addThemesObject:theme1];
    
    Theme *theme2 = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    theme2.startDate = aMonthFromNow;
    [stratFile addThemesObject:theme2];
    
    NSDate *date = [stratFile dateOfEarliestThemeOrToday];    
    STAssertTrue([self dayMonthYearEqualForDate1:date andDate2:aMonthFromNow], @"Earliest date should have been a month from now, but was %@", date);    
}

- (void)testPermissions
{
    StratFile *stratFile = [TestSupport createEmptyStratFile];

    // just verify that permissions are set
    STAssertEqualObjects(stratFile.permissions, @"0600", @"Oops");
    STAssertEquals([stratFile.permissions intValue], (int)600, @"Oops");
    
    // check read capabilities for 0600
    STAssertTrue([stratFile isReadable:UserTypeOwner], @"Oops");
    STAssertFalse([stratFile isReadable:UserTypeGroup], @"Oops");    
    STAssertFalse([stratFile isReadable:UserTypeOther], @"Oops");    
    
    // check write capabilities for 0600
    STAssertTrue([stratFile isWritable:UserTypeOwner], @"Oops");
    STAssertFalse([stratFile isWritable:UserTypeGroup], @"Oops");    
    STAssertFalse([stratFile isWritable:UserTypeOther], @"Oops");    
    
    // check 0400 read
    stratFile.permissions = @"0400";
    STAssertTrue([stratFile isReadable:UserTypeOwner], @"Oops");
    STAssertFalse([stratFile isReadable:UserTypeGroup], @"Oops");    
    STAssertFalse([stratFile isReadable:UserTypeOther], @"Oops");    

    // check 0400 write
    STAssertFalse([stratFile isWritable:UserTypeOwner], @"Oops");
    STAssertFalse([stratFile isWritable:UserTypeGroup], @"Oops");    
    STAssertFalse([stratFile isWritable:UserTypeOther], @"Oops");    
}

- (void)testStrategyDuration 
{
    StratFile *stratFile = [TestSupport createEmptyStratFile];
        
    Theme *theme1 = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    theme1.startDate = [TestSupport dateFromString:@"2012-10-01"];
    [stratFile addThemesObject:theme1];
        
    // no end date
    uint years = [stratFile strategyDurationInYears];
    STAssertEquals(years, (uint)5, @"Oops");
    
    uint months = [stratFile strategyDurationInMonths];
    STAssertEquals(months, (uint)5*12, @"Oops");
    

    // end date 16 mos after startdate
    theme1.endDate = [TestSupport dateFromString:@"2014-02-01"];
    years = [stratFile strategyDurationInYears];
    STAssertEquals(years, (uint)2, @"Oops");

    months = [stratFile strategyDurationInMonths];
    STAssertEquals(months, (uint)16, @"Oops");
    
    
    // 9 months
    theme1.startDate = [TestSupport dateFromString:@"2012-01-01"];
    theme1.endDate = [TestSupport dateFromString:@"2012-09-30"];
    years = [stratFile strategyDurationInYears];
    STAssertEquals(years, (uint)1, @"Oops");

    months = [stratFile strategyDurationInMonths];
    STAssertEquals(months, (uint)9, @"Oops");

}

@end


@implementation StratFileTest (Private)


- (BOOL)dayMonthYearEqualForDate1:(NSDate*)date1 andDate2:(NSDate*)date2
{
    unsigned int unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];    
    NSDateComponents *comps = [gregorian components:unitFlags fromDate:date1  toDate:date2  options:0];
    [gregorian release];
    
    return [comps year] == 0 && [comps month] == 0 && [comps day] == 0;
}

@end
