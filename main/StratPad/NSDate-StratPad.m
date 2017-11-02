//
//  NSDate-StratPad.m
//  StratPad
//
//  Created by Julian Wood on 11-08-19.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "NSDate-StratPad.h"
#import "NSCalendar+Expanded.h"

#define ISO_TIMEZONE_UTC_FORMAT     @"Z"
#define ISO_TIMEZONE_OFFSET_FORMAT  @"%+02d%02d"
#define ISO8601_DATE_FORMAT         @"yyyyMMdd"
#define ISO8601_DATE_TIME_FORMAT    @"yyyyMMdd'T'HH:mm:ssZ"
#define UTC_TIMEZONE                [NSTimeZone timeZoneWithName:@"UTC"]

@implementation NSTimeZone (StratPad)

+ (NSTimeZone*)utcTimeZone
{
    static NSTimeZone *utcTimeZone = nil;
    
    if (!utcTimeZone) {
        utcTimeZone = [UTC_TIMEZONE retain];
    }
    return utcTimeZone;    
}

@end

@implementation NSDate (NSDate_StratPad)

#pragma mark - FORMATTERS

-(NSString*)defaultFormattedDateForLocalTimeZone
{
    // note that this date format will change depending on locale
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSString *formatString = [NSDateFormatter dateFormatFromTemplate:@"yyyy.MM.dd" options:0
                                                              locale:[NSLocale currentLocale]];
    [formatter setDateFormat:formatString];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    [formatter setLocale:[NSLocale currentLocale]];        

    NSString *formattedDate = [formatter stringFromDate:self];
    [formatter release];
    
    return formattedDate;
}

- (NSString*)mediumFormattedDateForLocalTimeZone
{
    // note that this date format will change depending on locale
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeStyle:NSDateFormatterNoStyle];
    [formatter setDateStyle:NSDateFormatterMediumStyle];        
    [formatter setLocale:[NSLocale currentLocale]];        
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    
    NSString *formattedDate = [formatter stringFromDate:self];
    [formatter release];
    
    return formattedDate;    
}

-(NSString*)longFormattedDateForLocalTimeZone
{
    // note that this date format will change depending on locale
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeStyle:NSDateFormatterNoStyle];
    [formatter setDateStyle:NSDateFormatterLongStyle];        
    [formatter setLocale:[NSLocale currentLocale]];   
    [formatter setTimeZone:[NSTimeZone localTimeZone]];

    NSString *formattedDate = [formatter stringFromDate:self];
    [formatter release];
    
    return formattedDate;        
}

- (NSString*)formattedDate1
{
    // locale dependent, tz-sensitive
    // used for agenda items in R8; R5
    // Aug 4, 2012
    // formatter is cached for speed on repetitive tasks (ie StratPad must be restarted when locales change)
    static NSDateFormatter* sDate1Formatter = nil;
    
    if (!sDate1Formatter) {
        NSString *identifier = [[LocalizedManager sharedManager] localeIdentifier];
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:identifier];
        NSString *format = [NSDateFormatter dateFormatFromTemplate:@"MMM d, yyyy" options:0 locale:locale];
        sDate1Formatter = [[NSDateFormatter alloc] init];
        [sDate1Formatter setDateFormat:format];
        [sDate1Formatter setTimeZone:[NSTimeZone localTimeZone]];
        [sDate1Formatter setLocale:locale];
        [locale release];
    }
    return [sDate1Formatter stringFromDate:self];
}


- (NSString*)formattedDate2
{
    // formatter is cached for speed on repetitive tasks (ie StratPad must be restarted when locales change)
    // locale dependent, tz-sensitive
    // used in most reports
    // August 4, 2012
    
    static NSDateFormatter *sDate2Formatter = nil;
    
    if (!sDate2Formatter) {
        NSString *identifier = [[LocalizedManager sharedManager] localeIdentifier];
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:identifier];
        NSString *format = [NSDateFormatter dateFormatFromTemplate:@"MMMM d, yyyy" options:0 locale:locale];
        sDate2Formatter = [[NSDateFormatter alloc] init];
        [sDate2Formatter setDateFormat:format];
        [sDate2Formatter setTimeZone:[NSTimeZone localTimeZone]];
        [sDate2Formatter setLocale:locale];
        [locale release];
    }
    return [sDate2Formatter stringFromDate:self];
}

-(NSString*)formattedDateTimeForLocalTimeZone
{
    NSString *identifier = [[LocalizedManager sharedManager] localeIdentifier];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:identifier];
    NSString *format = [NSDateFormatter dateFormatFromTemplate:@"MMM d, yyyy h:mm a" options:0 locale:locale];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    [formatter setLocale:locale];
    NSString *formattedDate = [formatter stringFromDate:self];
    [formatter release];
    [locale release];
    return formattedDate;    
}

-(NSString*)monthNameChar
{
    static NSDateFormatter* sMFormatter = nil;
    
    if (!sMFormatter) {
        NSString *identifier = [[LocalizedManager sharedManager] localeIdentifier];
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:identifier];
        sMFormatter = [[NSDateFormatter alloc] init];
        [sMFormatter setDateFormat:@"MMMMM"];
        [sMFormatter setLocale:locale];
        [sMFormatter setTimeZone:[NSTimeZone localTimeZone]];
        [locale release];
    }
    return [sMFormatter stringFromDate:self];
}

-(NSString*)monthNameAbbreviated
{
    static NSDateFormatter* sMonFormatter = nil;
    
    if (!sMonFormatter) {
        NSString *identifier = [[LocalizedManager sharedManager] localeIdentifier];
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:identifier];
        sMonFormatter = [[NSDateFormatter alloc] init];
        [sMonFormatter setDateFormat:@"MMM"];
        [sMonFormatter setLocale:locale];
        [sMonFormatter setTimeZone:[NSTimeZone localTimeZone]];
        [locale release];
    }
    return [sMonFormatter stringFromDate:self];
}

-(NSString*)monthName
{
    static NSDateFormatter* sMonthFormatter = nil;
    
    if (!sMonthFormatter) {
        // use the locale chosen by the user
        NSString *identifier = [[LocalizedManager sharedManager] localeIdentifier];
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:identifier];
        sMonthFormatter = [[NSDateFormatter alloc] init];
        [sMonthFormatter setDateFormat:@"MMMM"];
        [sMonthFormatter setLocale:locale];
        [sMonthFormatter setTimeZone:[NSTimeZone localTimeZone]];
        [locale release];
    }
    return [sMonthFormatter stringFromDate:self];
}

- (NSString*)formattedMonthYear
{
    static NSDateFormatter* sMonthYearFormatter = nil;
    
    if (!sMonthYearFormatter) {
        NSString *identifier = [[LocalizedManager sharedManager] localeIdentifier];
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:identifier];
        sMonthYearFormatter = [[NSDateFormatter alloc] init];
        [sMonthYearFormatter setDateFormat:@"MMM ''yy"];
        [sMonthYearFormatter setLocale:locale];
        [sMonthYearFormatter setTimeZone:[NSTimeZone localTimeZone]];
        [locale release];
    }
    
    return [sMonthYearFormatter stringFromDate:self];
}



#pragma mark - ISO8601


+(NSDate*)dateFromISO8601:(NSString *)str 
{
    // we are going to ignore anything beyond the date format
    // ie only look at yyyyMMdd
    // we will generate a date in the local time zone which matches the year, month and day given
    // the time will be zeroed out (ie midnight local)
    if ([str length] > 8) {
        str = [str substringToIndex:8];
    }
    static NSDateFormatter* sISO8601 = nil;
    
    if (!sISO8601) {
        sISO8601 = [[NSDateFormatter alloc] init];
        [sISO8601 setTimeStyle:NSDateFormatterNoStyle];
        [sISO8601 setDateFormat:ISO8601_DATE_FORMAT];        
        [sISO8601 setTimeZone:[NSTimeZone localTimeZone]];
        [sISO8601 setCalendar:[NSCalendar cachedGregorianCalendar]];
    }
     NSDate *date = [sISO8601 dateFromString:str];
     return date;    
}

-(NSString*)stringForISO8601Date
{
    // regardless of what time or tz the date is in, we are just going to store the yyyyMMdd
    static NSDateFormatter* sISO8601DateFormatter = nil;
    
    if (!sISO8601DateFormatter) {
        sISO8601DateFormatter = [[NSDateFormatter alloc] init];
        [sISO8601DateFormatter setTimeStyle:NSDateFormatterNoStyle];
        [sISO8601DateFormatter setDateFormat:ISO8601_DATE_FORMAT];
    }
    [sISO8601DateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    return [sISO8601DateFormatter stringFromDate:self];
}


+(NSDate*)dateTimeFromISO8601:(NSString *)str 
{
    static NSDateFormatter* sISO8601 = nil;
    
    if (!sISO8601) {
        sISO8601 = [[NSDateFormatter alloc] init];
        [sISO8601 setTimeStyle:NSDateFormatterFullStyle];
        [sISO8601 setDateFormat:ISO8601_DATE_TIME_FORMAT];
        // tz is in the str
    }
    
    // remove any extraneous Z's
    if ([str hasSuffix:@"Z"]) {
        str = [str substringToIndex:(str.length-1)];
    }
    
    return [sISO8601 dateFromString:str];
}

-(NSString*)stringForISO8601DateTime
{
    static NSDateFormatter* sISO8601Formatter = nil;
    
    if (!sISO8601Formatter) {
        sISO8601Formatter = [[NSDateFormatter alloc] init];
        [sISO8601Formatter setTimeStyle:NSDateFormatterFullStyle];
        [sISO8601Formatter setDateFormat:ISO8601_DATE_TIME_FORMAT];
        [sISO8601Formatter setTimeZone:[NSTimeZone localTimeZone]];
    }
    return[sISO8601Formatter stringFromDate:self];
}

#pragma mark - Convenience


- (NSDate*)dateWithZeroedTime
{
    // this is used exclusively to facilitate date and interval calculations
    // we are normalizing the hours and tz so that they don't enter the equation
    // do not use this for serializing - use the iso8601 functions
    
    // so if we are given a date, we need to evaluate it in the local tz and make it midnight (00:00) of that same local day
    
    NSUInteger flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    // don't use the cached calendar, because we muck around with different regions and tz's in the tests
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    gregorian.timeZone = [NSTimeZone localTimeZone];
    NSDateComponents *comps = [gregorian components:flags fromDate:self];
    NSDate *date = [gregorian dateFromComponents:comps];
    [gregorian release];
    return date;
}

+(NSDate*)dateWithZeroedTime
{
    return [[NSDate date] dateWithZeroedTime];
}

+ (NSDate*)dateSetToFirstDayOfMonthForDate:(NSDate*)date
{
    // this needs to return the first of the month at midnight UTC
    
    // we need to evaluate this in the context of the local timezone
    // - eg we will get a UTC time here of say Jan 31, at 23:00 ( = Feb 1, 00:00 CET (ie Paris))
    // - so we need to evaluate in CET so that we end up with Feb 1, not Jan 1
    
    NSUInteger flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];
    NSDateComponents *comps = [gregorian components:flags fromDate:date];
    
    // now we do need a utc calendar, in order to get the utc date
    gregorian = [NSCalendar cachedGregorianCalendar];
    NSDateComponents *comps2 = [[NSDateComponents alloc] init];
    [comps2 setDay:1];
    [comps2 setMonth:comps.month];
    [comps2 setYear:comps.year];
    
    NSDate *firstOfMonthDate = [gregorian dateFromComponents:comps2];
    [comps2 release];
    
    return firstOfMonthDate;
}

+ (NSDate*)dateSetToFirstDayOfMonthOfInterval:(NSUInteger)months forDate:(NSDate*)date
{
    // so if we're given Mar 7, and interval 2, then we return mar 1
    // Apr 8 and 2 -> mar 1
    // Apr 8 and 3 -> apr 1
    // Apr 8 and 6 -> jan 1
    // feb 4 and 2 -> jan 1
    // that way we'll always land on january at some point
    
    // determine the nth interval from jan which covers the date
    // eg. Mar 7 and 2 -> the second interval covers it, so we take the first day of the first month of the 2nd 2 month interval -> Mar 1
    
    // date set to first of year
    NSUInteger flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];
    NSDateComponents *comps = [gregorian components:flags fromDate:date];
    [comps setMonth:1];
    [comps setDay:1];
    [comps setHour:0];
    [comps setMinute:0];
    [comps setSecond:0];
    NSDate *yearStart = [gregorian dateFromComponents:comps];
    
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    uint numIntervals = ceilf(12.f/months);
    for (int i=0; i<numIntervals; ++i) {
        [offsetComponents setMonth:months*(i+1)];
        NSDate *endIntervalDate = [gregorian dateByAddingComponents:offsetComponents
                                                          toDate:yearStart options:0]; 
        if ([endIntervalDate isAfterIgnoringTime:date]) {
            [offsetComponents setMonth:months*i];
            break;
        } else if ([endIntervalDate isEqualIgnoringTime:date]) {
            [offsetComponents setMonth:months*(i+1)];
            break;
        }
    }

    NSDate *firstOfInterval = [gregorian dateByAddingComponents:offsetComponents toDate:yearStart options:0];
    [offsetComponents release];
    return firstOfInterval;    
}

+ (NSDate*)dateSetToFirstDayOfNextMonthForDate:(NSDate*)date
{
    // get the date set to the first day of its month.
    NSDate *tempDate = [NSDate dateSetToFirstDayOfMonthForDate:date];
    
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setMonth:1];

    // UTC calendar to match our expectation from the above date
    NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];
    NSDate *nextMonthDate = [gregorian dateByAddingComponents:comps toDate:tempDate options:0];
    [comps release];    
    return nextMonthDate;
}

#pragma mark - Comparison ignoring time convenience

- (NSComparisonResult)compareDayMonthAndYearTo:(NSDate*)date
{
    NSAssert(date != nil, @"Date parameter must be non-nil.");
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];
    NSDateComponents *comps1 = [gregorian components:unitFlags fromDate:self];    
    NSDateComponents *comps2 = [gregorian components:unitFlags fromDate:date];    
    
    if ([comps1 year] < [comps2 year]) {
        return NSOrderedAscending;
    } else if ([comps1 year] > [comps2 year]) {
        return NSOrderedDescending;
    } else {
        
        if ([comps1 month] < [comps2 month]) {
            return NSOrderedAscending;
        } else if ([comps1 month] > [comps2 month]) {
            return NSOrderedDescending;
        } else {
            
            if ([comps1 day] < [comps2 day]) {
                return NSOrderedAscending;
            } else if ([comps1 day] > [comps2 day]) {
                return NSOrderedDescending;
            } else {
                return NSOrderedSame;
            }
        }
    }
}

- (NSComparisonResult)compareIgnoringTime:(NSDate*)date
{
    return [self compareDayMonthAndYearTo:date];
}

- (BOOL)isEqualIgnoringTime:(NSDate*)date
{
    return [self compareDayMonthAndYearTo:date] == NSOrderedSame;
}

- (BOOL)isAfterIgnoringTime:(NSDate*)date
{
    return [self compareDayMonthAndYearTo:date] == NSOrderedDescending;
}

- (BOOL)isAfterOrEqualIgnoringTime:(NSDate*)date
{
    return ![self isBeforeIgnoringTime:date];
}

- (BOOL)isBeforeIgnoringTime:(NSDate*)date
{
    return [self compareDayMonthAndYearTo:date] == NSOrderedAscending;
}

- (BOOL)isBeforeOrEqualIgnoringTime:(NSDate*)date
{
    return ![self isAfterIgnoringTime:date];
}

#pragma mark - Comparison convenience

- (BOOL)isAfter:(NSDate*)date
{
    return [self compare:date] == NSOrderedDescending;
}

- (BOOL)isAfterOrEqual:(NSDate*)date
{
    return ![self isBefore:date];
}

- (BOOL)isBefore:(NSDate*)date
{
    return [self compare:date] == NSOrderedAscending;
}

- (BOOL)isBeforeOrEqual:(NSDate*)date
{
    return ![self isAfter:date];
}

- (BOOL)inRangeWithStartDate:(NSDate*)startDate andEndDate:(NSDate*)endDate
{
    if (startDate && endDate) {
        // >= startdate && <= endDate
        return [self isAfterOrEqual:startDate] && [self isBeforeOrEqual:endDate];        
    }
    else if (startDate) {
        return [self isAfterOrEqual:startDate];
    }
    else if (endDate) {
        return [self isBeforeOrEqual:endDate];
    }
    else {
        return YES;
    }
}


@end
