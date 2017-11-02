//
//  MeetingAgendaReport.h
//  StratPad
//
//  Created by Julian Wood on 9/15/11.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AbstractReportDelegate.h"

// IMPORTANT to note that these impls appeared to be getting used elsewhere, though I don't think that was the intention - remove this after we see everything is working correctly
// it's here just so we can test

@interface NSDate (MeetingAgendaReport)
// true only if the day is at least one less than in date
-(BOOL)isBeforeDay:(NSDate*)date;

// true only if the day is at least one more than in date
-(BOOL)isAfterDay:(NSDate*)date;
@end


@interface MeetingAgendaReport : AbstractReportDelegate<PrintReportDelegate> {
    NSMutableArray *meetings_;
    BOOL hasMorePages_;

    // font names for the report
    NSString *fontName_;
    NSString *boldFontName_;
    NSString *obliqueFontName_;
    NSString *checkmarkFontName_;
    
    // font size for the report
    CGFloat fontSize_;
    
    // font color for the report
    UIColor *fontColor_;

    // just to let us know if we are currently drawing for print or screen
    BOOL isPrint_;
    
    NSNumber *lastDrawBlockYOffset_;
}

@property(nonatomic,readonly) NSArray *meetings;

+ (NSDate*)strategyStartDate;
+ (NSDate*)strategyEndDate;

- (NSString*)html;

@end
