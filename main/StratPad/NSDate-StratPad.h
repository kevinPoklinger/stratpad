//
//  NSDate-StratPad.h
//  StratPad
//
//  Created by Julian Wood on 11-08-19.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

@interface NSTimeZone (StratPad)
+ (NSTimeZone*)utcTimeZone;
@end

@interface NSDate (NSDate_StratPad)

// returns the current date for the current locale, with a UTC offset to the local time zone. eg. 02/22/2012
-(NSString*)defaultFormattedDateForLocalTimeZone;

// returns string with a medium format in local timezone, e.g., Aug 22, 2011
- (NSString*)mediumFormattedDateForLocalTimeZone;

// returns string with a long format with a UTC offset to the local time zone, e.g., August 22, 2011
-(NSString*)longFormattedDateForLocalTimeZone;

// locale independent date formats for the reports; August 4, 2012
-(NSString*)formattedDate2;

// date for the current tz and locale, including 24h time. Jun 3, 2012 4:08 PM
-(NSString*)formattedDateTimeForLocalTimeZone;

// just the single char string for the month, using the local tz and the user's chosen language
-(NSString*)monthNameChar;

// full month name, using the local tz and the user's chosen language
-(NSString*)monthName;

// abbreviated month name eg Aug
-(NSString*)monthNameAbbreviated;

// locale independent for the date selection component popover; Aug 4, 2012
- (NSString*)formattedDate1;

// locale-specific short format for month and year, used in reports as column headings; Jan '12
- (NSString*)formattedMonthYear;



// parse a date from an iso8601 formatted string, including time and tz info
// remember, an NSDate doesn't hold any tz info - it is simply the number of seconds since a reference time
+(NSDate*)dateTimeFromISO8601:(NSString*)str;

// parse a date in local tz from an iso8601 formatted string, ignoring any time or timezone info
+(NSDate*)dateFromISO8601:(NSString *)str;



// create an iso8601 fully formatted string from a date with time and local tz info
-(NSString*)stringForISO8601DateTime;

// create an iso8601 formatted string for the date only, ignoring time and timezone
// your date object should be in the local tz (tz shown to user), and it will be stored as that same date
-(NSString*)stringForISO8601Date;



// returns a UTC date with it's time set to 00:00:00Z.
-(NSDate*)dateWithZeroedTime;

// returns the current date at Greenwich with it's time set to 00:00:00 (midnight)
+(NSDate*)dateWithZeroedTime;



// returns NSOrderedAscending if this date is less than the given date.
// returns NSOrderedSame if the two dates have the same day, month, and year.
// returns NSOrderedDescending if this date is greater than the given date.
- (NSComparisonResult)compareDayMonthAndYearTo:(NSDate*)date;

- (NSComparisonResult)compareIgnoringTime:(NSDate*)date;
- (BOOL)isEqualIgnoringTime:(NSDate*)date;
- (BOOL)isAfterIgnoringTime:(NSDate*)date;
- (BOOL)isAfterOrEqualIgnoringTime:(NSDate*)date;
- (BOOL)isBeforeIgnoringTime:(NSDate*)date;
- (BOOL)isBeforeOrEqualIgnoringTime:(NSDate*)date;

// returns a UTC date set to the first day in the month of the given date.
+(NSDate*)dateSetToFirstDayOfMonthForDate:(NSDate*)date;

// returns a UTC date set to the first day of the next month for the given date.
+ (NSDate*)dateSetToFirstDayOfNextMonthForDate:(NSDate*)date;

// returns a UTC date set to the first day of the first month of the given interval
// one interval will always start in january
+ (NSDate*)dateSetToFirstDayOfMonthOfInterval:(NSUInteger)months forDate:(NSDate*)date;

- (BOOL)isAfter:(NSDate*)date;
- (BOOL)isAfterOrEqual:(NSDate*)date;
- (BOOL)isBefore:(NSDate*)date;
- (BOOL)isBeforeOrEqual:(NSDate*)date;

// self >= startdate && <= endDate; nil dates are handled as infinite limits
- (BOOL)inRangeWithStartDate:(NSDate*)startDate andEndDate:(NSDate*)endDate;

@end

