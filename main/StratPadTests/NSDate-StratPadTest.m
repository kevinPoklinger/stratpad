//
//  NSDate-StratPadTest.m
//  StratPad
//
//  Created by Julian Wood on 2/20/12.
//  Copyright 2012 Glassey Strategy. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "TestSupport.h"
#import "CoreDataTestCase.h"
#import "NSDate-StratPad.h"
#import "NSCalendar+Expanded.h"

@interface NSDate_StratPadTest : CoreDataTestCase 
@end


@implementation NSDate_StratPadTest

- (void) setUp
{
    [NSTimeZone resetSystemTimeZone];
    [NSTimeZone setDefaultTimeZone:[NSTimeZone systemTimeZone]];

    TLog(@"system tz for test: %@", [NSTimeZone systemTimeZone]);
    TLog(@"default tz for test: %@", [NSTimeZone defaultTimeZone]);
    TLog(@"local tz for test: %@", [NSTimeZone localTimeZone]);
    
    [super setUp];
}

- (void) tearDown
{
    [NSTimeZone resetSystemTimeZone];
    [NSTimeZone setDefaultTimeZone:[NSTimeZone systemTimeZone]];
    [super tearDown];
}


- (void)testISO8601DateOnly 
{
    // full format: yyyyMMdd'T'HH:mm:ssZ
    // the thing to remember is we ignore (throw away) time and tz info

    // this is 1:31 am local time, or 8:31 am UTC
    NSString *dateString = @"20120216T01:31:10-0700";
    NSDate *date = [NSDate dateFromISO8601:dateString];    
    NSString *dateOutput1 = [date localFormattedDate];

    // now we should be looking at 20120216 in local time
    // ie for MST it is 2012-02-16 at midnight (00:00)
    // for UTC, we are looking at 20120-02-16 07:00
    // designed to be run in MST    
    STAssertEqualObjects(dateOutput1, @"02-16-2012", @"Oops");
    STAssertEqualObjects([date localFormattedDateTime], @"02-16-2012 00:00", @"Oops");
    STAssertEqualObjects([date utcFormattedDateTime], @"02-16-2012 07:00", @"Oops");

    // 18:31 UTC
    dateString = @"20120216T11:31:10-0700";
    date = [NSDate dateFromISO8601:dateString];    
    NSString *dateOutput2 = [date localFormattedDate];

    // this is the next day in UTC, but we want to keep showing the current day
    dateString = @"20120216T21:31:10-0700";
    date = [NSDate dateFromISO8601:dateString];    
    NSString *dateOutput3 = [date localFormattedDate];
    
    STAssertEqualObjects(dateOutput1, dateOutput2, @"Oops");
    STAssertEqualObjects(dateOutput1, dateOutput3, @"Oops");

    // they should all be Feb 16, 2012 00:00 in local time
    NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:16];
    [comps setMonth:2];
    [comps setYear:2012];
    [comps setHour:0];
    [comps setMinute:0];
    [comps setSecond:0];
    NSDate *theDate = [gregorian dateFromComponents:comps];
    NSString *dateOutput4 = [theDate localFormattedDate];

    STAssertEqualObjects(dateOutput1, dateOutput4, @"Oops: dateOutput1: %@", dateOutput1);
}

- (void)testISO8601DateTime
{
    // full format: yyyyMMdd'T'HH:mm:ssZ

    // this is 1:31 am local time (MST), or 8:31 am UTC
    NSString *dateString = @"20120216T01:31:10-0700";
    NSDate *date = [NSDate dateTimeFromISO8601:dateString];    
    NSString *dateOutput = [date utcFormattedDateTime];    
    STAssertEqualObjects(dateOutput, @"02-16-2012 08:31", @"Oops");

    dateString = @"20120216T01:31:10-0400";
    date = [NSDate dateTimeFromISO8601:dateString];    
    dateOutput = [date utcFormattedDateTime];
    STAssertEqualObjects(dateOutput, @"02-16-2012 05:31", @"Oops");

    // now look at toString method
    // designed to be run in MST
    NSString *isoString = [date stringForISO8601DateTime];
    STAssertEqualObjects(isoString, @"20120215T22:31:10-0700", @"Oops");
    
}

- (void)testDateWithZeroedTime
{
    NSString *dateString = @"20120216T01:31:10-0700";
    NSDate *date = [NSDate dateTimeFromISO8601:dateString];  
    
    // check the validity of our date
    STAssertEquals([date timeIntervalSinceReferenceDate], (NSTimeInterval)351073870, @"Oops");
    STAssertEqualObjects([date utcFormattedDateTime], @"02-16-2012 08:31", @"Oops");

    // now zero it
    NSDate *zDate = [date dateWithZeroedTime];
    STAssertEqualObjects([zDate localFormattedDateTime], @"02-16-2012 00:00", @"Oops");
    
    // try a bunch of other times throughout the day
    dateString = @"20120216T01:31:10-0700";
    date = [NSDate dateTimeFromISO8601:dateString];   
    zDate = [date dateWithZeroedTime];
    STAssertEqualObjects([zDate localFormattedDateTime], @"02-16-2012 00:00", @"Oops");

    dateString = @"20120216T09:31:10-0700";
    date = [NSDate dateTimeFromISO8601:dateString];   
    zDate = [date dateWithZeroedTime];
    STAssertEqualObjects([zDate localFormattedDateTime], @"02-16-2012 00:00", @"Oops");

    dateString = @"20120216T15:31:10-0700";
    date = [NSDate dateTimeFromISO8601:dateString];   
    zDate = [date dateWithZeroedTime];
    STAssertEqualObjects([zDate localFormattedDateTime], @"02-16-2012 00:00", @"Oops");

    dateString = @"20120216T23:31:10-0700";
    date = [NSDate dateTimeFromISO8601:dateString];   
    zDate = [date dateWithZeroedTime];
    STAssertEqualObjects([zDate localFormattedDateTime], @"02-16-2012 00:00", @"Oops");
    
    
    // try another tz
    [NSTimeZone setDefaultTimeZone:[NSTimeZone timeZoneWithName:@"Europe/Paris"]];
    dateString = @"20120216T01:31:10+0100";
    date = [NSDate dateTimeFromISO8601:dateString];
    zDate = [date dateWithZeroedTime];
    STAssertEqualObjects([zDate localFormattedDateTime], @"02-16-2012 00:00", @"Oops");
    STAssertEqualObjects([zDate utcFormattedDateTime], @"02-15-2012 23:00", @"Oops");

    dateString = @"20120216T23:31:10+0100";
    date = [NSDate dateTimeFromISO8601:dateString];
    zDate = [date dateWithZeroedTime];
    STAssertEqualObjects([zDate localFormattedDateTime], @"02-16-2012 00:00", @"Oops");

}

-(void)testDatePickerStrategy 
{    
    // so say we are in PST and we choose a date in the date picker, which is set to local time
    NSString *dateString = @"20120216T21:31:10-0800";
    NSDate *date = [NSDate dateFromISO8601:dateString];    

    // we store this in our stratfile
    NSString *dateStringForStratfile = [date stringForISO8601Date];
    STAssertEqualObjects(dateStringForStratfile, @"20120216", @"Oops");
    
    // now we open this file in Calgary - better show the same date
    // note that the default timezone defaults to system tz, which is the local tz
    [NSTimeZone setDefaultTimeZone:[NSTimeZone timeZoneWithName:@"America/Edmonton"]];
    NSDate *dateInCalgary = [NSDate dateFromISO8601:dateStringForStratfile];
    NSString *dateStringInCalgary = [dateInCalgary localFormattedDate];
    
    // in France - same date
    [NSTimeZone setDefaultTimeZone:[NSTimeZone timeZoneWithName:@"Europe/Paris"]];
    NSDate *dateInFrance = [NSDate dateFromISO8601:dateStringForStratfile];
    NSString *dateStringInFrance = [dateInFrance localFormattedDate];

    STAssertEqualObjects(dateStringInCalgary, dateStringInFrance, @"Oops");

    [NSTimeZone setDefaultTimeZone:[NSTimeZone timeZoneWithName:@"America/Edmonton"]];

    // startDate from 'Get to Market!.xml', theme 'Complete DocLock Development'
    dateString = @"20120101T00:00:00+0000";
    date = [NSDate dateFromISO8601:dateString];    
    DLog(@"date: %@", date);
    DLog(@"date: %@", [date utcFormattedDateTime]);
    DLog(@"date: %@", [date localFormattedDateTime]);
    
}

-(void)testDateSetToFirstDayOfMonthOfInterval
{
    // so if we're given Mar 7, and interval 2, then we return mar 1
    // Apr 8 and 2 -> mar 1
    // Apr 8 and 3 -> apr 1
    // Apr 8 and 6 -> jan 1
    // feb 4 and 2 -> jan 1
    // that way we'll always land on january at some point

    NSString *dateString = @"20120307T00:00:00+0000";
    NSDate *date = [NSDate dateFromISO8601:dateString];
    NSDate *firstIntervalDate = [NSDate dateSetToFirstDayOfMonthOfInterval:2 forDate:date];
    STAssertTrue([firstIntervalDate compareIgnoringTime:[NSDate dateFromISO8601:@"20120301"]] == NSOrderedSame, @"Oops");
    
    dateString = @"20120201T06:00:00+0000";
    date = [NSDate dateFromISO8601:dateString];
    firstIntervalDate = [NSDate dateSetToFirstDayOfMonthOfInterval:1 forDate:date];
    STAssertTrue([firstIntervalDate compareIgnoringTime:[NSDate dateFromISO8601:@"20120201"]] == NSOrderedSame, @"Oops");

    dateString = @"20120408T00:00:00+0000";
    date = [NSDate dateFromISO8601:dateString];
    firstIntervalDate = [NSDate dateSetToFirstDayOfMonthOfInterval:2 forDate:date];
    STAssertTrue([firstIntervalDate compareIgnoringTime:[NSDate dateFromISO8601:@"20120301"]] == NSOrderedSame, @"Oops");

    dateString = @"20120408T00:00:00+0000";
    date = [NSDate dateFromISO8601:dateString];
    firstIntervalDate = [NSDate dateSetToFirstDayOfMonthOfInterval:3 forDate:date];
    STAssertTrue([firstIntervalDate compareIgnoringTime:[NSDate dateFromISO8601:@"20120401"]] == NSOrderedSame, @"Oops");

    dateString = @"20120408T00:00:00+0000";
    date = [NSDate dateFromISO8601:dateString];
    firstIntervalDate = [NSDate dateSetToFirstDayOfMonthOfInterval:6 forDate:date];
    STAssertTrue([firstIntervalDate compareIgnoringTime:[NSDate dateFromISO8601:@"20120101"]] == NSOrderedSame, @"Oops");

    dateString = @"20120224T00:00:00+0000";
    date = [NSDate dateFromISO8601:dateString];
    firstIntervalDate = [NSDate dateSetToFirstDayOfMonthOfInterval:6 forDate:date];
    STAssertTrue([firstIntervalDate compareIgnoringTime:[NSDate dateFromISO8601:@"20120101"]] == NSOrderedSame, @"Oops");

    dateString = @"20120708T00:00:00+0000";
    date = [NSDate dateFromISO8601:dateString];
    firstIntervalDate = [NSDate dateSetToFirstDayOfMonthOfInterval:3 forDate:date];
    STAssertTrue([firstIntervalDate compareIgnoringTime:[NSDate dateFromISO8601:@"20120701"]] == NSOrderedSame, @"Oops");

    dateString = @"20120502T00:00:00+0000";
    date = [NSDate dateFromISO8601:dateString];
    firstIntervalDate = [NSDate dateSetToFirstDayOfMonthOfInterval:1 forDate:date];
    STAssertTrue([firstIntervalDate compareIgnoringTime:[NSDate dateFromISO8601:@"20120501"]] == NSOrderedSame, @"Oops");

    dateString = @"20121001T06:00:00+0000";
    date = [NSDate dateFromISO8601:dateString];
    firstIntervalDate = [NSDate dateSetToFirstDayOfMonthOfInterval:1 forDate:date];
    STAssertTrue([firstIntervalDate compareIgnoringTime:[NSDate dateFromISO8601:@"20121001"]] == NSOrderedSame, @"Oops");

}

- (void)testDateComparisons
{
    NSDate *d8 = [NSDate dateTimeFromISO8601:@"20111201T23:36:50-0700"];
    NSDate *d9 = [NSDate dateTimeFromISO8601:@"20111201T23:34:50-0700"];
    STAssertTrue([d8 compare:d9] == NSOrderedDescending, @"Oops");
    STAssertTrue([d8 isAfter:d9], @"Oops");
}


@end