//
//  RatingReminderManager.h
//  StratPad
//
//  Created by Eric Rogers on September 30, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//
//  Singleton that displays a rating reminder to the user when
//  the user has completed specific milestones in the application.

extern NSTimeInterval const numSecondsInDay;

@interface RatingReminderManager : NSObject {
@private
    // flag indicating whether or not the user has rated the app.
    BOOL appRated_;
    
    // flag indicating whether or not the user has entered a name for a StratFile.
    BOOL stratFileNameEntered_;
    
    // flag indicating whether or not the user has created a theme.
    BOOL themeCreated_;
    
    // flag indicating whether or not the user has visited the R1 report.
    BOOL firstReportVisited_;
}

+ (RatingReminderManager*)sharedManager;

// flags that the user has reached the milestone of entering a name for a StratFile, 
// and will display a rating reminder if necessary.
- (void)userEnteredStratFileName;

// flags that the user has reached the milestone of creating a theme,
// and will display a rating reminder if necessary.
- (void)userCreatedTheme;

// flags that the user has reached the milestone of visiting the R1 report,
// and will display a rating reminder if necessary.
- (void)userVisitedFirstReport;

@end
