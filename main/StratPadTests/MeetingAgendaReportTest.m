//
//  MeetingAgendaReportTest.m
//  StratPad
//
//  Created by Julian Wood on 9/19/11.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "Theme.h"
#import "Activity.h"
#import "DataManager.h"
#import "MeetingAgendaReport.h"
#import "StratFile.h"
#import "StratFileManager.h"
#import "Meeting.h"
#import "NSDate-StratPad.h"
#import "MeetingAgendaReport.h"
#import "Meeting.h"
#import "AgendaItem.h"
#import "ThemeAgendaItem.h"

double const day = 24*60*60;
double const week = 7*24*60*60;
double const year = 365*24*60*60;

@interface MeetingAgendaReportTest : SenTestCase {    
}
@end

@interface MeetingAgendaReportTest (Private)
- (BOOL)dayMonthYearEqualForDate1:(NSDate*)date1 andDate2:(NSDate*)date2;
- (StratFile*)createStratFile;
@end

@implementation MeetingAgendaReportTest

- (void) setUp
{
    // pretend we're running the tests in England (UTC), since that's how we are generating dates, though i don't think leap years are being handled correctly
    [NSTimeZone resetSystemTimeZone];
    [NSTimeZone setDefaultTimeZone:[NSTimeZone utcTimeZone]];
    [super setUp];
}

- (void) tearDown
{
    [NSTimeZone resetSystemTimeZone];
    [NSTimeZone setDefaultTimeZone:[NSTimeZone systemTimeZone]];
    [super tearDown];
}

- (void)testStartDate {
    
    StratFile *stratFile = [self createStratFile];
    
    NSDate *startDate = [MeetingAgendaReport strategyStartDate];
    NSDate *expectedDate = [NSDate dateWithTimeIntervalSince1970:10*year + 3*week];
    STAssertEqualObjects(expectedDate, startDate, @"Oops");
    
    // nil start dates are equal to now 
    Theme *theme5 = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    theme5.title = @"Test Theme 5";
    [stratFile addThemesObject:theme5];
    
    // even though nil start date is ordered first, we should see the 1980 date
    startDate = [MeetingAgendaReport strategyStartDate];
    STAssertEqualObjects(expectedDate, startDate, @"Oops");    
    
}

- (void)testEndDate {
    
    StratFile *stratFile = [self createStratFile];
    
    NSDate *endDate = [MeetingAgendaReport strategyEndDate];
    NSDate *expectedDate = [NSDate dateWithTimeIntervalSince1970:22*year + 4*week];
    STAssertEqualObjects(expectedDate, endDate, @"Oops");
    
    // with a nil end date, we make it equal to the strategy end date, which looks at all other theme end dates, and then theme start dates
    Theme *theme5 = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    theme5.title = @"Test Theme 5";
    [stratFile addThemesObject:theme5];
    
    endDate = [MeetingAgendaReport strategyEndDate];
    expectedDate = [NSDate dateFromISO8601:@"19920124T00:00:00+0000"]; 
    STAssertTrue([self dayMonthYearEqualForDate1:endDate andDate2:expectedDate], @"Earliest date should have been 1992, but was %@", endDate);    

}

- (void) testPeriodicMeetings
{
    // weekly - if something starts on Wednesday, want to meet about it on the preceeding Monday, even if before the stratFile startDate; solves a bunch of edge cases
    NSMutableArray *meetings = [[NSMutableArray array] retain];
    NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:38*year + 6*week]; // 2008-02-03 Sunday
    NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:38*year + 10*week];  // 2008-03-02 Sunday
        
    [Meeting addWeeklyMeetings:startDate endDate:endDate meetings:meetings];
    STAssertEquals([meetings count], (uint)5, @"Oops");

    // ensure dates are not the same
    NSDate *date0 = [[meetings objectAtIndex:0] startDate];
    NSDate *date1 = [[meetings objectAtIndex:1] startDate];
    STAssertTrue([date0 compare:date1] == NSOrderedAscending, @"Oops, date0 should be earlier than date1");
    STAssertTrue([self dayMonthYearEqualForDate1:date0 andDate2:[NSDate dateFromISO8601:@"20080128T00:00:00+0000"]], @"Oops - make sure you are testing in English in the Canada locale (region).");
    
    // monthly - same idea as weekly
    [meetings removeAllObjects];
    startDate = [NSDate dateWithTimeIntervalSince1970:38*year + 6*week]; // 2008-02-03 Feb Mar,Apr,May,Jun
    endDate = [NSDate dateWithTimeIntervalSince1970:38*year + 30*week];  // 2008-07-20 July
    
    [Meeting addMonthlyMeetings:startDate endDate:endDate meetings:meetings];
    STAssertEquals([meetings count], (uint)6, @"Oops");
    
    // quarterly
    [meetings removeAllObjects];
    startDate = [NSDate dateWithTimeIntervalSince1970:38*year + 6*week]; // 2008-02-03 Apr,Jul
    endDate = [NSDate dateWithTimeIntervalSince1970:38*year + 30*week];  // 2008-07-20 
    
    [Meeting addQuarterlyMeetings:startDate endDate:endDate meetings:meetings];
    STAssertEquals([meetings count], (uint)1, @"Oops");

    // yearly - 1y ~10mo
    [meetings removeAllObjects];
    startDate = [NSDate dateWithTimeIntervalSince1970:38*year + 6*week]; // 2008-02-03 Apr,Jul
    endDate = [NSDate dateWithTimeIntervalSince1970:38*year + 2*year];  // 2008-07-20 
    
    [Meeting addYearlyMeetings:startDate endDate:endDate meetings:meetings];
    STAssertEquals([meetings count], (uint)1, @"Oops");
    
    // yearly - 2y 1d; we don't have a meeting until say September of 2009, if the startdate was sept 5, 2008
    [meetings removeAllObjects];
    startDate = [NSDate dateWithTimeIntervalSince1970:38*year];                 // Dec 22, 2007
    endDate = [NSDate dateWithTimeIntervalSince1970:38*year + 2*year + 1*day];  // Dec 22, 2009
    
    DLog(@"start: %@", [startDate longFormattedDateForLocalTimeZone]);
    DLog(@"end: %@", [endDate longFormattedDateForLocalTimeZone]);
    
    [Meeting addYearlyMeetings:startDate endDate:endDate meetings:meetings];
    STAssertEquals([meetings count], (uint)2, @"Oops");
    
}

- (void) testHeadings
{
    // normally, when scheduling meetings, the startDate gets normalized to some other value (first day of week, etc)
    // so here, dates don't get adjusted
    
    // a Monday
    NSDate *startDate = [NSDate dateFromISO8601:@"20080204"]; // Mon, Feb 4, 2008 UTC - all weekly meetings will start on Monday
//    NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:38*year + 6*week + 1*day]; // Mon, Feb 4, 2008 UTC - all weekly meetings will start on Monday
    Meeting *meeting = [[Meeting alloc] initWithType:MeetingTypeWeekly startDate:startDate];
    
    NSAttributedString *heading = [meeting newHeadingWithFontName:@"Helvetica" boldFontName:@"Helvetica-Bold" fontSize:12.f andFontColor:[UIColor blackColor]];
    STAssertEqualObjects([heading string], @"During the week of February 4, 2008, have a weekly meeting to:", @"Oops - sure you're running it in English, in a Canadian locale?");
    [meeting release];
    [heading release];

    
    // A Wednesday, just for the heck of it
    startDate = [NSDate dateWithTimeIntervalSince1970:38*year + 6*week + 3*day]; // Wed, Feb 6, 2008 UTC
    meeting = [[Meeting alloc] initWithType:MeetingTypeWeekly startDate:startDate];
    
    heading = [meeting newHeadingWithFontName:@"Helvetica" boldFontName:@"Helvetica-Bold" fontSize:12.f andFontColor:[UIColor blackColor]];
    STAssertEqualObjects([heading string], @"During the week of February 4, 2008, have a weekly meeting to:", @"Oops - sure you're running it in English, in a Canadian locale?");
    [meeting release];
    [heading release];
    
    // monthly
    startDate = [NSDate dateWithTimeIntervalSince1970:38*year + 6*week + 3*day]; // Wed, Feb 6, 2008 UTC
    meeting = [[Meeting alloc] initWithType:MeetingTypeMonthly startDate:startDate];
    
    heading = [meeting newHeadingWithFontName:@"Helvetica" boldFontName:@"Helvetica-Bold" fontSize:12.f andFontColor:[UIColor blackColor]];
    STAssertEqualObjects([heading string], @"As soon as you can in February 2008, have a monthly meeting to:", @"Oops - sure you're running it in English, in a Canadian locale?");
    [meeting release];
    [heading release];

    // quarterly
    startDate = [NSDate dateWithTimeIntervalSince1970:38*year + 6*week + 3*day]; // Wed, Feb 6, 2008 UTC
    meeting = [[Meeting alloc] initWithType:MeetingTypeQuarterly
                                  startDate:startDate];
    
    heading = [meeting newHeadingWithFontName:@"Helvetica" boldFontName:@"Helvetica-Bold" fontSize:12.f andFontColor:[UIColor blackColor]];
    STAssertEqualObjects([heading string], @"As soon as you can in February 2008, have a quarterly meeting to:", @"Oops - sure you're running it in English, in a Canadian locale?");
    [meeting release];
    [heading release];
    
    // yearly
    startDate = [NSDate dateWithTimeIntervalSince1970:38*year + 6*week + 3*day]; // Wed, Feb 6, 2008 UTC
    meeting = [[Meeting alloc] initWithType:MeetingTypeAnnually
                                  startDate:startDate];
    
    heading = [meeting newHeadingWithFontName:@"Helvetica" boldFontName:@"Helvetica-Bold" fontSize:12.f andFontColor:[UIColor blackColor]];
    STAssertEqualObjects([heading string], @"As soon as you can in February 2008, have an annual meeting to:", @"Oops - sure you're running it in English, in a Canadian locale?");
    [meeting release];
    [heading release];
}

- (void)testBlockStorage
{
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          ^(double p) { return (p + 2); }, @"addTwo",
                          ^(double p) { return (p * 3); }, @"mulThree",
                          ^(double p) { return sqrt(p); }, @"root",
                          nil];
	
    double x = 2.5;
    for (id key in dict) {
        double (^func)(double) = [dict objectForKey:key];
        DLog(@"%@: %f", key, func(x));
    }
}

- (void)testDateComparisons
{
    NSDate *d1 = [NSDate dateTimeFromISO8601:@"20111201T23:32:50-0700"];
    NSDate *d2 = [NSDate dateTimeFromISO8601:@"20101201T23:32:50-0700"];
    STAssertTrue([d1 isAfterDay:d2], @"Oops");
    
    NSDate *d3 = [NSDate dateTimeFromISO8601:@"20111201T23:32:50-0700"];
    STAssertFalse([d3 isAfterDay:d1], @"Oops");
    STAssertFalse([d3 isBeforeDay:d1], @"Oops");
    
    NSDate *d4 = [NSDate dateTimeFromISO8601:@"20111201T18:32:50-0700"];
    STAssertFalse([d4 isAfterDay:d1], @"Oops");
    STAssertFalse([d4 isBeforeDay:d1], @"Oops");
    
    NSDate *d5 = [NSDate dateTimeFromISO8601:@"20111202T18:32:50-0700"];
    STAssertTrue([d5 isAfterDay:d4], @"Oops");
    STAssertFalse([d5 isBeforeDay:d4], @"Oops");
    
    NSDate *d6 = [NSDate dateTimeFromISO8601:@"20111201T00:00:00+0000"];
    NSDate *d7 = [NSDate dateTimeFromISO8601:@"20111202T00:00:00+0000"];
    STAssertTrue([d6 isBeforeDay:d7], @"Oops");
    STAssertFalse([d6 isAfterDay:d7], @"Oops");
    
    STAssertFalse([d7 isBeforeDay:d6], @"Oops");
    STAssertTrue([d7 isAfterDay:d6], @"Oops");
    
    // note that we override isAfter, etc for MeetinAgendaReport - only compare days
    NSDate *d8 = [NSDate dateTimeFromISO8601:@"20111201T23:36:50-0700"];
    NSDate *d9 = [NSDate dateTimeFromISO8601:@"20111201T23:34:50-0700"];
    STAssertTrue([d8 compare:d9] == NSOrderedDescending, @"Oops");
    STAssertTrue([d8 isAfter:d9], @"Oops");
    STAssertFalse([d8 isAfterDay:d9], @"Oops");

}

- (void)testR8_1
{
    // this is the 2012_2013 Expansion Strategy where we have themes showing up in the wrong meeting
    // STRATPAD-261
    NSString *path = [[NSBundle bundleForClass:[MeetingAgendaReportTest class]] 
                          pathForResource:@"R8.1" ofType:@"xml"];
        
    // we're ignoring the returned stratfile, but this places the stratfile into the db
    StratFile *stratFile = [[StratFileManager sharedManager] stratFileFromXmlAtPath:path];

    STAssertEqualObjects(stratFile.name, @"2012/2013 Expansion Strategy", @"Oops");
    
    [[StratFileManager sharedManager] loadStratFile:stratFile withChapterIndex:0];    
    STAssertEqualObjects([StratFileManager sharedManager].currentStratFile.name, @"2012/2013 Expansion Strategy", @"Oops");
    
    MeetingAgendaReport *report = [[MeetingAgendaReport alloc] init];

    STAssertEquals([report.meetings count], (uint)138, @"Oops");
    
    Meeting *firstMeeting = [report.meetings objectAtIndex:0];
    STAssertEquals([firstMeeting.agendaItems count], (uint)3, @"Oops");
    
    // want to verify that 'Expand sales and marketing activities' theme is in Jun 25, 2012 weekly meeting
    BOOL found = NO;
    for (Meeting *meeting in report.meetings) {
        if ([meeting.startDate compareDayMonthAndYearTo:[NSDate dateFromISO8601:@"20120625"]] == NSOrderedSame) {
            
            STAssertEquals([meeting.agendaItems count], (uint)3, @"Oops");
            
            for (AgendaItem *agendaItem in meeting.agendaItems) {
                if (agendaItem.agendaItemType == AgendaItemThemeStart) {
                    NSString *title = [(ThemeAgendaItem*)agendaItem theme].title;
                    found = [title isEqualToString:@"Expand sales and marketing activities"];
                }
            }
        }
    }
    STAssertTrue(found, @"Oops");
    
    [report release];    
}

#pragma mark - private

- (BOOL)dayMonthYearEqualForDate1:(NSDate*)date1 andDate2:(NSDate*)date2
{
    unsigned int unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];    
    NSDateComponents *comps = [gregorian components:unitFlags fromDate:date1  toDate:date2  options:0];
    [gregorian release];
    
    return [comps year] == 0 && [comps month] == 0 && [comps day] == 0;
}

- (StratFile*)createStratFile
{
    StratFile *stratFile = [[StratFileManager sharedManager] createManagedEmptyStratFile];
    [[StratFileManager sharedManager] loadStratFile:stratFile withChapterIndex:0];
    
    Theme *theme1 = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    theme1.title = @"Test Theme 1";
    theme1.startDate = [NSDate dateWithTimeIntervalSince1970:10*year + 3*week]; // Jan 20, 1980
    theme1.endDate = [NSDate dateWithTimeIntervalSince1970:11*year + 3*week]; // Jan 20, 1981
    [stratFile addThemesObject:theme1];
    
    Theme *theme2 = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    theme2.title = @"Test Theme 2";
    theme2.startDate = [NSDate dateWithTimeIntervalSince1970:14*year + 2*week]; // Jan 13, 1984
    theme2.endDate = [NSDate dateWithTimeIntervalSince1970:15*year + 2*week]; // Jan 13, 1985
    [stratFile addThemesObject:theme2];
    
    Theme *theme3 = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    theme3.title = @"Test Theme 3";
    theme3.startDate = [NSDate dateWithTimeIntervalSince1970:20*year + 3*week]; // Jan 20, 1990
    theme3.endDate = [NSDate dateWithTimeIntervalSince1970:21*year + 3*week]; // Jan 20, 1991
    [stratFile addThemesObject:theme3];
    
    Theme *theme4 = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    theme4.title = @"Test Theme 4";
    theme4.startDate = [NSDate dateWithTimeIntervalSince1970:21*year + 4*week]; // Jan 27, 1991
    theme4.endDate = [NSDate dateWithTimeIntervalSince1970:22*year + 4*week]; // Jan 27, 1992
    [stratFile addThemesObject:theme4];
    
    return stratFile;
}

@end
