//
//  ThemeFinancialAnalysisMonthViewControllerTest.m
//  StratPad
//
//  Created by Julian Wood on 12-01-25.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "StratFile.h"
#import "Theme.h"
#import "ThemeDetailViewController.h"
#import "TestSupport.h"
#import "NSDate-StratPad.h"
#import "DataManager.h"
#import "Objective.h"
#import "Metric.h"
#import "Activity.h"
#import "NSNumber-StratPad.h"

@interface ThemeDetailViewControllerTest : SenTestCase
@end

@implementation ThemeDetailViewControllerTest

- (void)testCalculateNetBenefits
{
    Theme *theme = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    theme.title = @"Net Benefits Theme 1";
    theme.startDate = [TestSupport dateFromString:@"2012-06-01"];
    theme.endDate = [TestSupport dateFromString:@"2013-03-31"]; // 10 months
    theme.revenueMonthly = [NSNumber numberWithInt:5000];
    theme.revenueMonthlyAdjustment = [NSDecimalNumber decimalNumberWithString:@"25"];
    theme.cogsMonthly = [NSNumber numberWithInt:1500];
    theme.cogsMonthlyAdjustment = [NSDecimalNumber decimalNumberWithString:@"25"];
    theme.researchAndDevelopmentMonthly = [NSNumber numberWithInt:3500];
    theme.researchAndDevelopmentMonthlyAdjustment = [NSDecimalNumber decimalNumberWithString:@"25"];
    
    ThemeDetailViewController *vc = [[ThemeDetailViewController alloc] initWithNibName:nil bundle:nil andThemeOrNil:theme];
    NSDictionary *netBenefits = [vc calculateNetBenefits];
    
    STAssertEquals([[netBenefits objectForKey:@"monthly"] intValue], (int)0, @"Oops");
    STAssertEquals([[netBenefits objectForKey:@"total"] intValue], (int)0, @"Oops");
    STAssertNil([netBenefits objectForKey:@"annually"], @"", @"Oops");
    STAssertNil([netBenefits objectForKey:@"oneTime"], @"", @"Oops");
    STAssertNil([netBenefits objectForKey:@"quarterly"], @"", @"Oops");    
}

- (void)testThemeStartDate
{
    Theme *theme = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    theme.title = @"Test Theme 1";
    theme.startDate = [TestSupport dateFromString:@"2012-06-01"];
    theme.endDate = [TestSupport dateFromString:@"2013-03-31"];

    Objective *objective = (Objective*)[DataManager createManagedInstance:NSStringFromClass([Objective class])];
    [theme addObjectivesObject:objective];
    
    Metric *metric = (Metric*)[DataManager createManagedInstance:NSStringFromClass([Metric class])];
    metric.targetDate = [TestSupport dateFromString:@"2012-11-01"];
    [objective addMetricsObject:metric];

    // fire up the vc
    ThemeDetailViewController *vc = [[ThemeDetailViewController alloc] initWithNibName:nil bundle:nil andThemeOrNil:theme];
    UIView *view = [vc.view retain]; // make sure our buttons are instantiated
    [view release];
    
    // check a new valid theme start date
    BOOL isValid = [vc isValid:[TestSupport dateFromString:@"2012-06-06"] forCalendarButton:vc.btnStartDate];
    STAssertTrue(isValid, @"Ooops");

    // now make the theme start date equal the metric date (valid)
    isValid = [vc isValid:[TestSupport dateFromString:@"2012-11-01"] forCalendarButton:vc.btnStartDate];
    STAssertTrue(isValid, @"Ooops");
    
    // now make the theme start date gt the metric date (invalid)
    isValid = [vc isValid:[TestSupport dateFromString:@"2012-11-06"] forCalendarButton:vc.btnStartDate];
    STAssertFalse(isValid, @"Ooops");
    
    // now make the theme start date gt the end date (invalid)
    isValid = [vc isValid:[TestSupport dateFromString:@"2013-04-06"] forCalendarButton:vc.btnStartDate];
    STAssertFalse(isValid, @"Ooops");
    
    ////// let's work activities into the mix
    [objective removeMetricsObject:metric];

    Activity *activity = (Activity*)[DataManager createManagedInstance:NSStringFromClass([Activity class])];
    activity.startDate = [TestSupport dateFromString:@"2012-08-01"];
    activity.endDate = [TestSupport dateFromString:@"2013-03-31"];
    [objective addActivitiesObject:activity];
    
    // new valid theme start date
    isValid = [vc isValid:[TestSupport dateFromString:@"2012-07-06"] forCalendarButton:vc.btnStartDate];
    STAssertTrue(isValid, @"Ooops");

    // theme start date = act start date -> valid
    isValid = [vc isValid:[TestSupport dateFromString:@"2012-08-01"] forCalendarButton:vc.btnStartDate];
    STAssertTrue(isValid, @"Ooops");

    // theme start date > act start date -> invalid
    isValid = [vc isValid:[TestSupport dateFromString:@"2012-08-02"] forCalendarButton:vc.btnStartDate];
    STAssertFalse(isValid, @"Ooops");

    // theme start date > act end date -> invalid
    isValid = [vc isValid:[TestSupport dateFromString:@"2013-08-02"] forCalendarButton:vc.btnStartDate];
    STAssertFalse(isValid, @"Ooops");

    /////// now if we have no limit on the activity end date
    activity.startDate = [TestSupport dateFromString:@"2012-08-01"];
    activity.endDate = nil;
    
    // new valid theme start date
    isValid = [vc isValid:[TestSupport dateFromString:@"2012-07-06"] forCalendarButton:vc.btnStartDate];
    STAssertTrue(isValid, @"Ooops");
    
    // theme start date = act start date -> valid
    isValid = [vc isValid:[TestSupport dateFromString:@"2012-08-01"] forCalendarButton:vc.btnStartDate];
    STAssertTrue(isValid, @"Ooops");
    
    // theme start date > act start date -> invalid
    isValid = [vc isValid:[TestSupport dateFromString:@"2012-08-02"] forCalendarButton:vc.btnStartDate];
    STAssertFalse(isValid, @"Ooops");
    
    // theme start date > act end date -> invalid
    isValid = [vc isValid:[TestSupport dateFromString:@"2013-08-02"] forCalendarButton:vc.btnStartDate];
    STAssertFalse(isValid, @"Ooops");

    /////// now switch it to no start date
    activity.startDate = nil;
    activity.endDate = [TestSupport dateFromString:@"2013-03-31"];
    
    // new valid theme start date
    isValid = [vc isValid:[TestSupport dateFromString:@"2012-07-06"] forCalendarButton:vc.btnStartDate];
    STAssertTrue(isValid, @"Ooops");
    
    // valid
    isValid = [vc isValid:[TestSupport dateFromString:@"2012-08-01"] forCalendarButton:vc.btnStartDate];
    STAssertTrue(isValid, @"Ooops");
    
    // valid
    isValid = [vc isValid:[TestSupport dateFromString:@"2012-08-02"] forCalendarButton:vc.btnStartDate];
    STAssertTrue(isValid, @"Ooops");
    
    // theme start date > act end date -> invalid
    isValid = [vc isValid:[TestSupport dateFromString:@"2013-08-02"] forCalendarButton:vc.btnStartDate];
    STAssertFalse(isValid, @"Ooops");
        
}

- (void)testThemeEndDate
{
    Theme *theme = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    theme.title = @"Test Theme 1";
    theme.startDate = [TestSupport dateFromString:@"2012-06-01"];
    theme.endDate = [TestSupport dateFromString:@"2013-03-31"];
    
    Objective *objective = (Objective*)[DataManager createManagedInstance:NSStringFromClass([Objective class])];
    [theme addObjectivesObject:objective];
    
    Metric *metric = (Metric*)[DataManager createManagedInstance:NSStringFromClass([Metric class])];
    metric.targetDate = [TestSupport dateFromString:@"2012-11-01"];
    [objective addMetricsObject:metric];
    
    // fire up the vc
    ThemeDetailViewController *vc = [[ThemeDetailViewController alloc] initWithNibName:nil bundle:nil andThemeOrNil:theme];
    UIView *view = [vc.view retain]; // make sure our buttons are instantiated
    [view release];

    // check a new valid theme end date
    BOOL isValid = [vc isValid:[TestSupport dateFromString:@"2013-01-31"] forCalendarButton:vc.btnEndDate];
    STAssertTrue(isValid, @"Ooops");
    
    // match the metric date (valid)
    isValid = [vc isValid:[TestSupport dateFromString:@"2012-11-01"] forCalendarButton:vc.btnEndDate];
    STAssertTrue(isValid, @"Ooops");

    // precede the metric date - metric dates are allowed to exceed the theme date range (valid)
    isValid = [vc isValid:[TestSupport dateFromString:@"2012-10-01"] forCalendarButton:vc.btnEndDate];
    STAssertTrue(isValid, @"Ooops");
    
    
    ////// let's work activities into the mix
    [objective removeMetricsObject:metric];
    
    Activity *activity = (Activity*)[DataManager createManagedInstance:NSStringFromClass([Activity class])];
    activity.startDate = [TestSupport dateFromString:@"2012-08-01"];
    activity.endDate = [TestSupport dateFromString:@"2013-03-31"];
    [objective addActivitiesObject:activity];

    // new valid theme end date
    isValid = [vc isValid:[TestSupport dateFromString:@"2013-07-06"] forCalendarButton:vc.btnEndDate];
    STAssertTrue(isValid, @"Ooops");

    // theme and activity end on same day -> valid
    isValid = [vc isValid:[TestSupport dateFromString:@"2013-03-31"] forCalendarButton:vc.btnEndDate];
    STAssertTrue(isValid, @"Ooops");
    
    // theme end precedes activity end -> invalid
    isValid = [vc isValid:[TestSupport dateFromString:@"2013-02-31"] forCalendarButton:vc.btnEndDate];
    STAssertFalse(isValid, @"Ooops");
    

    /////// now if we have no limit on the activity end date
    activity.startDate = [TestSupport dateFromString:@"2012-08-01"];
    activity.endDate = nil;

    // new valid theme end date
    isValid = [vc isValid:[TestSupport dateFromString:@"2013-07-06"] forCalendarButton:vc.btnEndDate];
    STAssertTrue(isValid, @"Ooops");
    
    // theme end exceeds activity start (valid)
    isValid = [vc isValid:[TestSupport dateFromString:@"2013-03-31"] forCalendarButton:vc.btnEndDate];
    STAssertTrue(isValid, @"Ooops");
    
    // theme end exceeds activity start (valid)
    isValid = [vc isValid:[TestSupport dateFromString:@"2013-02-28"] forCalendarButton:vc.btnEndDate];
    STAssertTrue(isValid, @"Ooops");

    // theme end equals activity start (valid)
    isValid = [vc isValid:[TestSupport dateFromString:@"2012-08-01"] forCalendarButton:vc.btnEndDate];
    STAssertTrue(isValid, @"Ooops");
    
    // theme end precedes activity start (invalid)
    isValid = [vc isValid:[TestSupport dateFromString:@"2012-06-01"] forCalendarButton:vc.btnEndDate];
    STAssertFalse(isValid, @"Ooops");

    
    /////// now if we have no limit on the activity start date
    activity.startDate = nil;
    activity.endDate = [TestSupport dateFromString:@"2013-03-31"];
    
    // new valid theme end date
    isValid = [vc isValid:[TestSupport dateFromString:@"2013-07-06"] forCalendarButton:vc.btnEndDate];
    STAssertTrue(isValid, @"Ooops");
    
    // theme end equals activity end (valid)
    isValid = [vc isValid:[TestSupport dateFromString:@"2013-03-31"] forCalendarButton:vc.btnEndDate];
    STAssertTrue(isValid, @"Ooops");
    
    // theme end precedes activity end (invalid)
    isValid = [vc isValid:[TestSupport dateFromString:@"2013-02-28"] forCalendarButton:vc.btnEndDate];
    STAssertFalse(isValid, @"Ooops");
    


}

- (void)testNetBenefitFormattedNumber
{
    NSNumber *number = [NSNumber numberWithDouble:0];
    NSString *result = [number netBenefitFormattedNumber];
    STAssertEqualObjects(@"0", result, @"Oops");
    
    number = [NSNumber numberWithDouble:5000];
    result = [number netBenefitFormattedNumber];
    STAssertEqualObjects(@"5,000", result, @"Should have received 5,000, but got %@", result);
    
    number = [NSNumber numberWithDouble:-5000];
    result = [number netBenefitFormattedNumber];
    STAssertEqualObjects(@"(5,000)", result, @"Should have received (5,000), but got %@", result);
    
    number = [NSNumber numberWithDouble:minDisplayableValue];
    result = [number netBenefitFormattedNumber];
    STAssertEqualObjects(@"(99,999,999)", result, @"Should have received (99,999,999), but got %@", result);
    
    number = [NSNumber numberWithDouble:maxDisplayableValue];
    result = [number netBenefitFormattedNumber];
    STAssertEqualObjects(@"99,999,999", result, @"Should have received 99,999,999, but got %@", result);
    
    number = [NSNumber numberWithDouble:-100000000];
    result = [number netBenefitFormattedNumber];
    STAssertEqualObjects(@"#########", result, @"Should have received #########, but got %@", result);
    
    number = [NSNumber numberWithDouble:100000000];
    result = [number netBenefitFormattedNumber];
    STAssertEqualObjects(@"#########", result, @"Should have received #########, but got %@", result);
}



@end
