//
//  ObjectiveTest.m
//  StratPad
//
//  Created by Julian on 12-02-09.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "Theme.h"
#import "StratFile.h"
#import "DataManager.h"
#import "NSCalendar+Expanded.h"
#import "NSDate-StratPad.h"
#import "TestSupport.h"
#import <SenTestingKit/SenTestingKit.h>
#import "AppDelegate.h"
#import "CoreDataTestCase.h"
#import "Metric.h"
#import "Activity.h"

@interface ObjectiveTest : CoreDataTestCase {    
}
@end


@implementation ObjectiveTest

- (void)testLatestDate
{    
    Objective *obj = (Objective*)[DataManager createManagedInstance:NSStringFromClass([Objective class])];
    obj.summary = @"Obj1";
    
    Metric *metric = (Metric*)[DataManager createManagedInstance:NSStringFromClass([Metric class])];
    metric.summary = @"Metric1";
    metric.targetDate = [TestSupport dateFromString:@"2011-12-01"];
    [obj addMetricsObject:metric];
    
    Activity *activity1 = (Activity*)[DataManager createManagedInstance:NSStringFromClass([Activity class])];
    activity1.action = @"Activity1";
    activity1.startDate = [TestSupport dateFromString:@"2011-12-30"];
    activity1.endDate = [TestSupport dateFromString:@"2012-02-15"];
    [obj addActivitiesObject:activity1];
    
    Activity *activity2 = (Activity*)[DataManager createManagedInstance:NSStringFromClass([Activity class])];
    activity2.action = @"Activity1";
    activity2.startDate = [TestSupport dateFromString:@"2012-01-30"];
    activity2.endDate = [TestSupport dateFromString:@"2012-02-25"];
    [obj addActivitiesObject:activity2];
    
    // activity has the latest date
    NSDate *latestDate = [obj latestDate];
    STAssertEqualObjects(latestDate, [TestSupport dateFromString:@"2012-02-25"], @"Oops");
    
    [DataManager rollback];
}

- (void)testEarliestDate
{    
    Objective *obj = (Objective*)[DataManager createManagedInstance:NSStringFromClass([Objective class])];
    obj.summary = @"Obj1";
    
    Metric *metric = (Metric*)[DataManager createManagedInstance:NSStringFromClass([Metric class])];
    metric.summary = @"Metric1";
    metric.targetDate = [TestSupport dateFromString:@"2011-12-01"];
    [obj addMetricsObject:metric];
    
    Activity *activity1 = (Activity*)[DataManager createManagedInstance:NSStringFromClass([Activity class])];
    activity1.action = @"Activity1";
    activity1.startDate = [TestSupport dateFromString:@"2011-12-30"];
    activity1.endDate = [TestSupport dateFromString:@"2012-02-15"];
    [obj addActivitiesObject:activity1];
    
    Activity *activity2 = (Activity*)[DataManager createManagedInstance:NSStringFromClass([Activity class])];
    activity2.action = @"Activity1";
    activity2.startDate = [TestSupport dateFromString:@"2012-01-30"];
    activity2.endDate = [TestSupport dateFromString:@"2012-02-25"];
    [obj addActivitiesObject:activity2];
    
    // metric has the earliest date
    NSDate *earliestDate = [obj earliestDate];
    STAssertEqualObjects(earliestDate, [TestSupport dateFromString:@"2011-12-01"], @"Oops");
    
    // activity start has the earliest date
    activity2.startDate = [TestSupport dateFromString:@"2011-09-30"];
    earliestDate = [obj earliestDate];
    STAssertEqualObjects(earliestDate, [TestSupport dateFromString:@"2011-09-30"], @"Oops");
    
    // no activity start dates
    activity1.startDate = nil;
    activity2.startDate = nil;
    earliestDate = [obj earliestDate];
    STAssertEqualObjects(earliestDate, [TestSupport dateFromString:@"2011-12-01"], @"Oops");
    
    // no metric target date or activity start dates
    activity1.startDate = nil;
    activity2.startDate = nil;
    metric.targetDate = nil;
    earliestDate = [obj earliestDate];
    STAssertEqualObjects(earliestDate, [TestSupport dateFromString:@"2012-02-15"], @"Oops");
    
    // no dates at all
    activity1.startDate = nil;
    activity1.endDate = nil;
    activity2.startDate = nil;
    activity2.endDate = nil;
    metric.targetDate = nil;
    earliestDate = [obj earliestDate];
    STAssertNil(earliestDate, @"Oops");
    
    [DataManager rollback];
}

@end
