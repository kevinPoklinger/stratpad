//
//  Meeting.m
//  StratPad
//
//  Created by Julian Wood on 9/19/11.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "Meeting.h"
#import "NSDate-StratPad.h"
#import "AbstractReportDelegate.h"
#import "AgendaItem.h"
#import "NSString-Expanded.h"
#import "NSCalendar+Expanded.h"
#import "ReportPrintFonts.h"

#define strong(s) [NSString stringWithFormat:@"<strong>%@</strong>", s] 

@interface NSDate (Meeting)
- (NSString*)formattedDateForPeriodHeading;
@end

@implementation NSDate (Meeting)

- (NSString*)formattedDateForPeriodHeading
{
    // locale independent
    // used in R8
    static NSDateFormatter* sDatePeriodFormatter = nil;
    
    if (!sDatePeriodFormatter) {
        sDatePeriodFormatter = [[NSDateFormatter alloc] init];
        [sDatePeriodFormatter setDateFormat:@"MMMM yyyy"];
        [sDatePeriodFormatter setTimeZone:[NSTimeZone localTimeZone]];
    }
    
    return [sDatePeriodFormatter stringFromDate:self];
}



@end

@interface Meeting (Private)
+(void)addPeriodicMeetings:(NSDate*)startDate endDate:(NSDate*)endDate meetings:(NSMutableArray*)meetings meetingType:(MeetingType)meetingType;

+(NSAttributedString*)newHeadingForPeriod:(NSDate*)aDate formatKey:(NSString*)formatKey frequencyKey:(NSString*)frequencyKey withFontName:(NSString*)fontName boldFontName:(NSString*)boldFontName fontSize:(CGFloat)fontSize andFontColor:(UIColor*)fontColor;
+(NSAttributedString*)newHeadingForWeekIncludingDate:(NSDate*)aDate withFontName:(NSString*)fontName boldFontName:(NSString*)boldFontName fontSize:(CGFloat)fontSize andFontColor:(UIColor*)fontColor;

+(NSDate*)dateForFirstWeeklyMeeting:(NSDate*)startDate;
+(NSDate*)dateForFirstMonthlyMeeting:(NSDate*)startDate;
+(NSDate*)dateForFirstQuarterlyMeeting:(NSDate*)startDate;
+(NSDate*)dateForFirstAnnualMeeting:(NSDate*)startDate;

+(NSDate*)mondayOfWeekForDate:(NSDate*)aDate;

+(NSAttributedString*)newAttributedStringWithBoldWords:(NSString*)string boldWords:(NSArray*)boldWords withFontName:(NSString*)fontName boldFontName:(NSString*)boldFontName fontSize:(CGFloat)fontSize andFontColor:(UIColor*)fontColor;
@end

@implementation Meeting

@synthesize meetingType = meetingType_;
@synthesize startDate = startDate_;
@synthesize agendaItems = agendaItems_;

-(void)dealloc
{
    [agendaItems_ release];
    [startDate_ release];
    [super dealloc];
}


#pragma mark - Public


-(id)initWithType:(MeetingType)meetingType startDate:(NSDate*)startDate
{
    self = [super init];
    if (self) {
        meetingType_ = meetingType;
        startDate_ = [startDate retain];
        agendaItems_ = [[NSMutableSet set] retain];
    }
    return self;
}

-(BOOL)matchesFrequency:(Frequency*)frequency
{
    switch (meetingType_) {
        case MeetingTypeWeekly:
            return [frequency.category unsignedIntValue] == FrequencyCategoryWeekly;
            
        case MeetingTypeMonthly:
            return [frequency.category unsignedIntValue] == FrequencyCategoryMonthly;
            
        case MeetingTypeQuarterly:
            return [frequency.category unsignedIntValue] == FrequencyCategoryQuarterly;
            
        case MeetingTypeAnnually:
            return [frequency.category unsignedIntValue] == FrequencyCategoryAnnually;
            
        default:
            WLog(@"Invalid meetingType: %i", meetingType_);
            return NO;
    }
}

-(NSString*)frequencyString
{
    switch (meetingType_) {
        case MeetingTypeWeekly:
            return [[[Frequency frequencyForCategory:FrequencyCategoryWeekly] nameForCurrentLocale] lowercaseString];
            
        case MeetingTypeMonthly:
            return [[[Frequency frequencyForCategory:FrequencyCategoryMonthly] nameForCurrentLocale] lowercaseString];
            
        case MeetingTypeQuarterly:
            return [[[Frequency frequencyForCategory:FrequencyCategoryQuarterly] nameForCurrentLocale] lowercaseString];
            
        case MeetingTypeAnnually:
            return [LocalizedString(@"FREQUENCY_NAME_ANNUAL", nil) lowercaseString];
            
        default:
            WLog(@"Invalid meetingType: %i", meetingType_);
            @throw [NSException exceptionWithName:@"Illegal meetingType_" reason:@"Illegal MeetingType" userInfo:nil];
    }

}

-(NSString*)responsiblePhrase
{
    NSMutableArray *responsibles = [NSMutableArray arrayWithCapacity:[agendaItems_ count]];
    for (AgendaItem *agendaItem in agendaItems_) {
        NSString *responsible = [agendaItem responsible];
        if (responsible && ![responsible isBlank] && ![responsibles containsObject:responsible]) {
            [responsibles addObject:responsible];
        }
    }
    
    switch ([responsibles count]) {
        case 0:
            return nil;
        case 2:
            [responsibles sortUsingSelector:@selector(caseInsensitiveCompare:)];
            NSString *s = [responsibles componentsJoinedByString:[NSString stringWithFormat:@" %@ ", LocalizedString(@"MAR_AND", nil)]];
            return s;
            
        default:
            [responsibles sortUsingSelector:@selector(caseInsensitiveCompare:)];
            return [responsibles componentsJoinedByString:@", "];
    }
        
}

-(NSAttributedString*)newHeadingWithFontName:(NSString*)fontName boldFontName:(NSString*)boldFontName fontSize:(CGFloat)fontSize andFontColor:(UIColor*)fontColor
{
    switch (meetingType_) {
        case MeetingTypeWeekly:
            return [Meeting newHeadingForWeekIncludingDate:startDate_ withFontName:fontName boldFontName:boldFontName fontSize:fontSize andFontColor:fontColor];
            
        case MeetingTypeMonthly:
            return [Meeting newHeadingForPeriod:startDate_ formatKey:@"MAR_PERIODIC_MEETING" frequencyKey:@"FREQUENCY_3" withFontName:fontName boldFontName:boldFontName fontSize:fontSize andFontColor:fontColor];
            
        case MeetingTypeQuarterly:
            return [Meeting newHeadingForPeriod:startDate_ formatKey:@"MAR_PERIODIC_MEETING" frequencyKey:@"FREQUENCY_4" withFontName:fontName boldFontName:boldFontName fontSize:fontSize andFontColor:fontColor];
            
        case MeetingTypeAnnually:
            return [Meeting newHeadingForPeriod:startDate_ formatKey:@"MAR_ANNUAL_MEETING" frequencyKey:@"FREQUENCY_NAME_ANNUAL" withFontName:fontName boldFontName:boldFontName fontSize:fontSize andFontColor:fontColor];
            
        default:
            WLog(@"Invalid meetingType: %i", meetingType_);
            return [Meeting newAttributedStringWithBoldWords:@"Invalid meetingType." boldWords:[NSArray array] withFontName:fontName boldFontName:boldFontName fontSize:fontSize andFontColor:fontColor];
    }
}

-(NSString*)htmlHeading
{
    switch (meetingType_) {
        case MeetingTypeWeekly:
            return [Meeting htmlHeadingForWeekIncludingDate:startDate_];
            
        case MeetingTypeMonthly:
            return [Meeting htmlHeadingForPeriod:startDate_ formatKey:@"MAR_PERIODIC_MEETING" frequencyKey:@"FREQUENCY_3"];
            
        case MeetingTypeQuarterly:
            return [Meeting htmlHeadingForPeriod:startDate_ formatKey:@"MAR_PERIODIC_MEETING" frequencyKey:@"FREQUENCY_4"];
            
        case MeetingTypeAnnually:
            return [Meeting htmlHeadingForPeriod:startDate_ formatKey:@"MAR_ANNUAL_MEETING" frequencyKey:@"FREQUENCY_6"];
            
        default:
            WLog(@"Invalid meetingType: %i", meetingType_);
            return [NSString stringWithFormat:@"Invalid meetingType: %i", meetingType_];
    }    
}

+(void)addWeeklyMeetings:(NSDate*)startDate endDate:(NSDate*)endDate meetings:(NSMutableArray*)meetings
{
    NSDate *weekStart = [Meeting dateForFirstWeeklyMeeting:startDate];        
    [Meeting addPeriodicMeetings:weekStart endDate:endDate meetings:meetings meetingType:MeetingTypeWeekly];
}

+(void)addMonthlyMeetings:(NSDate*)startDate endDate:(NSDate*)endDate meetings:(NSMutableArray*)meetings
{
    NSDate *monthStart = [Meeting dateForFirstMonthlyMeeting:startDate];  
    [Meeting addPeriodicMeetings:monthStart endDate:endDate meetings:meetings meetingType:MeetingTypeMonthly];
}

+(void)addQuarterlyMeetings:(NSDate*)startDate endDate:(NSDate*)endDate meetings:(NSMutableArray*)meetings
{
    NSDate *monthStart = [Meeting dateForFirstQuarterlyMeeting:startDate];    
    [Meeting addPeriodicMeetings:monthStart endDate:endDate meetings:meetings meetingType:MeetingTypeQuarterly];
}

+(void)addYearlyMeetings:(NSDate*)startDate endDate:(NSDate*)endDate meetings:(NSMutableArray*)meetings
{
    NSDate *monthStart = [Meeting dateForFirstAnnualMeeting:startDate];    
    [Meeting addPeriodicMeetings:monthStart endDate:endDate meetings:meetings meetingType:MeetingTypeAnnually];
}

- (NSString*)description
{    
    return [NSString stringWithFormat:
            @"type: %i, startDate: %@", 
            self.meetingType, self.startDate
            ];
}


#pragma mark - Private

+(void)addPeriodicMeetings:(NSDate*)startDate endDate:(NSDate*)endDate meetings:(NSMutableArray*)meetings meetingType:(MeetingType)meetingType
{  
    NSDateComponents *periodComponents = [[NSDateComponents alloc] init];
    switch (meetingType) {
        case MeetingTypeWeekly:
            [periodComponents setWeek:1];
            break;
        case MeetingTypeMonthly:
            [periodComponents setMonth:1];
            break;
        case MeetingTypeQuarterly:
            [periodComponents setMonth:3];
            break;
        case MeetingTypeAnnually:
            [periodComponents setYear:1];
            break;
        default:
            WLog(@"Invalid meetingType: %i", meetingType);
            break;
    }
    
    NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];
    NSDate *aPeriodLater = startDate;
    while ([aPeriodLater compare:endDate] != NSOrderedDescending) {
        Meeting *meeting = [[Meeting alloc] initWithType:meetingType startDate:aPeriodLater];
        [meetings addObject:meeting];
        [meeting release];
        
        aPeriodLater = [gregorian dateByAddingComponents:periodComponents toDate:aPeriodLater options:0];
    }
    [periodComponents release];
}

+(NSDate*)mondayOfWeekForDate:(NSDate*)aDate
{
    NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];
    NSDateComponents *weekdayComponents = [gregorian components:NSWeekdayCalendarUnit fromDate:aDate];
    
    // Create a date components to represent the number of days to subtract from the current date.
    // The weekday value for Monday in the Gregorian calendar is 2, so subtract 2 from the number of days to subtract from the date in question.  (If today is Monday, subtract 0 days.).  If today is Sunday (weekday = 1), then we want to subtract 6 days, so we go to the previous Monday.
    NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
    
    if ([weekdayComponents weekday] == 1) {
        [componentsToSubtract setDay:-6];
    } else {
        [componentsToSubtract setDay: 0 - ([weekdayComponents weekday] - 2)];    
    }
    
    NSDate *beginningOfWeek = [gregorian dateByAddingComponents:componentsToSubtract toDate:aDate options:0];
    
    // normalize to midnight
    NSDateComponents *components = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate: beginningOfWeek];
    beginningOfWeek = [gregorian dateFromComponents:components];
        
    // clean up
    [componentsToSubtract release];
    
    return beginningOfWeek; // autoreleased
}

+(NSDate*)dateForFirstWeeklyMeeting:(NSDate*)startDate
{
    NSDate *weekStart = [Meeting mondayOfWeekForDate:startDate];
    return weekStart;
}

+(NSDate*)dateForFirstMonthlyMeeting:(NSDate*)startDate
{
    return startDate;
}

+(NSDate*)dateForFirstQuarterlyMeeting:(NSDate*)startDate
{
    // it should always be the next quarter
    NSDateComponents *monthComponents = [[NSDateComponents alloc] init];
    [monthComponents setMonth:3];
    
    NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];
    NSDate *monthStart = [gregorian dateByAddingComponents:monthComponents toDate:startDate options:0];
    [monthComponents release];
    
    return monthStart;
}

+(NSDate*)dateForFirstAnnualMeeting:(NSDate*)startDate
{
    // it should always be the next year and month
    NSDateComponents *yearComponents = [[NSDateComponents alloc] init];
    [yearComponents setYear:1];
    
    NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];
    NSDate *monthStart = [gregorian dateByAddingComponents:yearComponents toDate:startDate options:0];
    [yearComponents release];
    
    return monthStart;
}

+(NSAttributedString*)newHeadingForWeekIncludingDate:(NSDate*)aDate withFontName:(NSString*)fontName boldFontName:(NSString*)boldFontName fontSize:(CGFloat)fontSize andFontColor:(UIColor*)fontColor
{
    // just get the Monday of this week
    NSString *weekStart = [[Meeting mondayOfWeekForDate:aDate] formattedDate1];
    NSString *format = LocalizedString(@"MAR_WEEKLY_MEETING", nil);
    NSString *frequency = [LocalizedString(@"FREQUENCY_1", nil) lowercaseString];
    NSString *heading = [NSString stringWithFormat:format, weekStart, frequency];
    NSAttributedString *attrHeading = [Meeting newAttributedStringWithBoldWords:heading boldWords:[NSArray arrayWithObjects:frequency, weekStart, nil] withFontName:fontName boldFontName:boldFontName fontSize:fontSize andFontColor:fontColor];
    return attrHeading;
}

+(NSString*)htmlHeadingForWeekIncludingDate:(NSDate*)aDate
{
    // just get the Monday of this week
    NSString *format = LocalizedString(@"MAR_WEEKLY_MEETING", nil);
    NSString *weekStart = [[Meeting mondayOfWeekForDate:aDate] formattedDate1];
    NSString *frequency = [LocalizedString(@"FREQUENCY_1", nil) lowercaseString];
    return [NSString stringWithFormat:format, strong(weekStart), strong(frequency)];
}

+(NSAttributedString*)newHeadingForPeriod:(NSDate*)aDate formatKey:(NSString*)formatKey frequencyKey:(NSString*)frequencyKey withFontName:(NSString*)fontName boldFontName:(NSString*)boldFontName fontSize:(CGFloat)fontSize andFontColor:(UIColor*)fontColor
{
    NSString *formattedDate = [aDate formattedDateForPeriodHeading];
    
    // assemble the string
    NSString *format = LocalizedString(formatKey, nil);
    NSString *frequency = [LocalizedString(frequencyKey, nil) lowercaseString];
    NSString *heading = [NSString stringWithFormat:format, formattedDate, frequency]; 
    return [Meeting newAttributedStringWithBoldWords:heading boldWords:[NSArray arrayWithObjects:frequency, formattedDate, nil] withFontName:fontName boldFontName:boldFontName fontSize:fontSize andFontColor:fontColor];
}

+(NSString*)htmlHeadingForPeriod:(NSDate*)aDate formatKey:(NSString*)formatKey frequencyKey:(NSString*)frequencyKey
{
    NSString *format = LocalizedString(formatKey, nil);
    NSString *formattedDate = [aDate formattedDateForPeriodHeading];
    NSString *frequency = [LocalizedString(frequencyKey, nil) lowercaseString];
    return [NSString stringWithFormat:format, strong(formattedDate), strong(frequency)]; 
}

+(NSAttributedString*)newAttributedStringWithBoldWords:(NSString*)string boldWords:(NSArray*)boldWords withFontName:(NSString*)fontName boldFontName:(NSString*)boldFontName fontSize:(CGFloat)fontSize andFontColor:(UIColor*)fontColor
{
    
	NSMutableAttributedString *attString = [[NSMutableAttributedString alloc]
                                            initWithString:string];
    
    CFStringRef fontCFString = (CFStringRef)fontName;
	CTFontRef font = CTFontCreateWithName(fontCFString, fontSize, NULL);

    CFStringRef boldFontCFString = (CFStringRef)boldFontName;
	CTFontRef boldFont = CTFontCreateWithName((CFStringRef)boldFontCFString, fontSize, NULL);
    
    // style for the base string
	[attString addAttribute:(id)kCTFontAttributeName
                      value:(id)font
                      range:NSMakeRange(0, [attString length])];
    
    // we only make the first occurence of boldWord bold
    for (NSString *boldWord in boldWords) {
        NSRange range = [string rangeOfString:boldWord];
        [attString addAttribute:(id)kCTFontAttributeName
                          value:(id)boldFont
                          range:range];
    }
    
	// set the color
	[attString addAttribute:(id)kCTForegroundColorAttributeName
                   value:(id)fontColor.CGColor
                   range:NSMakeRange(0, string.length)];
    
    CFRelease(font);
	CFRelease(boldFont);
    
    return attString;
}

@end
