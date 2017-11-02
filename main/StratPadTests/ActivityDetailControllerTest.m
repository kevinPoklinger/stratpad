//
//  ActivityDetailControllerTest.m
//  StratPad
//
//  Created by Julian Wood on 11-11-06.
//  Copyright (c) 2011 Glassey Strategy. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "ActivityDetailViewController.h"
#import "Theme.h"
#import "MBCalendarButton.h"
#import "TestSupport.h"
#import "Activity.h"
#import "Objective.h"
#import "DataManager.h"
#import "NSDate-StratPad.h"

@interface ActivityDetailControllerTest : SenTestCase
- (NSDate*)dateFromString:(NSString*)dateString;
@end

@implementation ActivityDetailControllerTest

- (void)testIsValid
{
    Theme *theme = [TestSupport createThemeWithTitle:@"Test Theme" andFinancialWidth:1 andOrder:0];
    Objective *objective = [theme.objectives anyObject];
    Activity *activity = (Activity*)[DataManager createManagedInstance:NSStringFromClass([Activity class])];
    [objective addActivitiesObject:activity];
    
    ActivityDetailViewController *avc = [[ActivityDetailViewController alloc] initWithNibName:@"ActivityDetailView" bundle:nil andActivity:activity];
    UIView *view = avc.view; // force the buttons to instantiate
    DLog(@"%@", view);
    
    
    // 1. give a theme start and end date, try activity start dates before, during and after the valid period
    theme.startDate = [self dateFromString:@"2011-06-01"];
    theme.endDate = [self dateFromString:@"2011-11-15"];
    
    // nil is ok - akin to hitting clear
    STAssertTrue([avc isValid:nil forCalendarButton:avc.btnStartDate], @"Oops");
    
    // too early
    NSDate *tooEarlyDate = [self dateFromString:@"2011-05-01"];
    BOOL isValid = [avc isValid:tooEarlyDate forCalendarButton:avc.btnStartDate];
    STAssertFalse(isValid, @"Oops");

    // too late
    NSDate *tooLateDate = [self dateFromString:@"2011-12-01"];
    isValid = [avc isValid:tooLateDate forCalendarButton:avc.btnStartDate];
    STAssertFalse(isValid, @"Oops");
    
    // good
    NSDate *validDate = [self dateFromString:@"2011-08-07"];
    isValid = [avc isValid:validDate forCalendarButton:avc.btnStartDate];
    STAssertTrue(isValid, @"Oops");
    
    // 2. make sure the end dates are also validated

    // nil is ok - akin to hitting clear
    STAssertTrue([avc isValid:nil forCalendarButton:avc.btnEndDate], @"Oops");

    // too early
    tooEarlyDate = [self dateFromString:@"2011-05-01"];
    isValid = [avc isValid:tooEarlyDate forCalendarButton:avc.btnEndDate];
    STAssertFalse(isValid, @"Oops");

    // too late
    tooLateDate = [self dateFromString:@"2011-12-01"];
    isValid = [avc isValid:tooLateDate forCalendarButton:avc.btnEndDate];
    STAssertFalse(isValid, @"Oops");
    
    // good
    validDate = [self dateFromString:@"2011-06-22"];
    isValid = [avc isValid:validDate forCalendarButton:avc.btnEndDate];
    STAssertTrue(isValid, @"Oops");
    
    // 3. now make sure end date honours the activity start date
    
    activity.startDate = [self dateFromString:@"2011-07-04"];
    
    tooEarlyDate = [self dateFromString:@"2011-06-22"];
    isValid = [avc isValid:tooEarlyDate forCalendarButton:avc.btnEndDate];
    STAssertFalse(isValid, @"Oops");
        
    // good
    validDate = [self dateFromString:@"2011-07-07"];
    isValid = [avc isValid:validDate forCalendarButton:avc.btnEndDate];
    STAssertTrue(isValid, @"Oops");
    
    // 4. and that start date honours the activity end date
    
    activity.endDate = [self dateFromString:@"2011-10-30"];
    
    // too late
    tooLateDate = [self dateFromString:@"2011-11-01"];
    isValid = [avc isValid:tooLateDate forCalendarButton:avc.btnStartDate];
    STAssertFalse(isValid, @"Oops");
    
    // good
    validDate = [self dateFromString:@"2011-07-07"];
    isValid = [avc isValid:validDate forCalendarButton:avc.btnStartDate];
    STAssertTrue(isValid, @"Oops");
    

    
}

- (NSDate*)dateFromString:(NSString*)dateString
{
    // 2011-12-01 ie. yyyy-mm-dd
    return [NSDate dateTimeFromISO8601:[NSString stringWithFormat:@"%@T00:00:00+0000", [dateString stringByReplacingOccurrencesOfString:@"-" withString:@""]]];
}

@end
