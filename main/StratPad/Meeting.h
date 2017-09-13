//
//  Meeting.h
//  StratPad
//
//  Created by Julian Wood on 9/19/11.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//
// meeting has a header, body and a footer
// meeting can have several agenda items
// the header figures out if we are weekly or other and displays the corresponding text
    // the only thing that is periodic is a metric
    // so group all the metrics together?? and then if agenda items have a start date within a weekly metric, place it in that meeting?
// the footer figures out all the responsible people from the agenda items

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>
#import "Frequency.h"

typedef enum {
    MeetingTypeWeekly,
    MeetingTypeMonthly,
    MeetingTypeQuarterly,
    MeetingTypeAnnually
} MeetingType;

@interface Meeting : NSObject {
    MeetingType meetingType_;
    NSDate *startDate_;
    NSMutableSet *agendaItems_;
}

@property (nonatomic,assign,readonly) MeetingType meetingType;
@property (nonatomic,retain,readonly) NSDate *startDate;
@property (nonatomic,retain,readonly) NSMutableSet *agendaItems;

-(id)initWithType:(MeetingType)meetingType startDate:(NSDate*)startDate;

// comparision between Frequency and MeetingType
-(BOOL)matchesFrequency:(Frequency*)frequency;
-(NSString*)frequencyString;

// calculates an appropriate heading for this meeting, available as NSAttributed string or html
-(NSAttributedString*)newHeadingWithFontName:(NSString*)fontName boldFontName:(NSString*)boldFontName fontSize:(CGFloat)fontSize andFontColor:(UIColor*)fontColor;
-(NSString*)htmlHeading;

// the people responsible in any particular meeting (a collection of agendaitems)
-(NSString*)responsiblePhrase;

// first meeting is on the following Monday and includes one for every subsequent Monday in the date range
+(void)addWeeklyMeetings:(NSDate*)startDate endDate:(NSDate*)endDate meetings:(NSMutableArray*)meetings;

// one for every month fully covered in the date range, starting next month
+(void)addMonthlyMeetings:(NSDate*)startDate endDate:(NSDate*)endDate meetings:(NSMutableArray*)meetings;

// one for every quarter fully covered in the date range, starting next quarter
+(void)addQuarterlyMeetings:(NSDate*)startDate endDate:(NSDate*)endDate meetings:(NSMutableArray*)meetings;

// one for every year fully covered in the date range, starting next year
+(void)addYearlyMeetings:(NSDate*)startDate endDate:(NSDate*)endDate meetings:(NSMutableArray*)meetings;

@end
