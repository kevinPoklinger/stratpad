//
//  ChartTest.m
//  StratPad
//
//  Created by Julian Wood on March 15, 2012.
//  Copyright 2012 Glassey Strategy. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "Chart.h"
#import "DataManager.h"
#import "CoreDataTestCase.h"
#import "StratFile.h"
#import "TestSupport.h"
#import "Metric.h"
#import "Measurement.h"
#import "NSDate-StratPad.h"

@interface ChartTest : CoreDataTestCase 
@end


@implementation ChartTest

- (void)testChartsSortedByOrderForStratFile
{
    StratFile *stratFile = [TestSupport createTestStratFile];

    NSArray *charts = [Chart chartsSortedByOrderForStratFile:stratFile];
    
    // even though there are 2 charts, only 1 is a primary
    STAssertEquals([charts count], (uint)1, @"Oops");

}

- (void)testStartDate
{
    StratFile *stratFile = [TestSupport createTestStratFile];
    
    NSArray *charts = [Chart chartsSortedByOrderForStratFile:stratFile];
    Chart *chart = [charts objectAtIndex:0];
    
    STAssertEquals([chart.metric.measurements count], (uint)3, @"Oops");
    
    NSDate *startDate = [chart startDate];
    STAssertTrue([startDate compareIgnoringTime:[NSDate dateFromISO8601:@"20121001"]] == NSOrderedSame, @"Oops");
    
    // it should include the target date
    chart.metric.targetDate = [NSDate dateFromISO8601:@"20110304"];
    startDate = [chart startDate]; 
    STAssertTrue([startDate compareIgnoringTime:[NSDate dateFromISO8601:@"20110301"]] == NSOrderedSame, @"Oops");    
}

- (void)testDurationInMonths
{
    StratFile *stratFile = [TestSupport createTestStratFile];
    
    NSArray *charts = [Chart chartsSortedByOrderForStratFile:stratFile];
    Chart *chart = [charts objectAtIndex:0];

    NSUInteger duration = [chart durationInMonths];
    STAssertEquals(duration, (uint)1, @"Oops");

    // increase the target date
    [chart.metric setTargetDate:[NSDate dateFromISO8601:@"20121115"]];
    duration = [chart durationInMonths];
    STAssertEquals(duration, (uint)2, @"Oops");
    

}

- (void)testChartCalculations
{
    uint chartDuration = 17; // mo.

    uint gridDuration = [Chart gridDurationForChartDuration:chartDuration];
    STAssertEquals(gridDuration, (uint)24, @"Oops");
    
    uint interval = [Chart intervalForDuration:gridDuration];
    STAssertEquals(interval, (uint)1, @"Oops");
    
    // number of segments is thus 24/1 = 24
    // ----
    
    chartDuration = 3; // mo.
    
    gridDuration = [Chart gridDurationForChartDuration:chartDuration];
    STAssertEquals(gridDuration, (uint)12, @"Oops");
    
    interval = [Chart intervalForDuration:gridDuration];
    STAssertEquals(interval, (uint)1, @"Oops");
    
    // number of segments is thus 12/1 = 12
    // ----
    

    chartDuration = 45; // mo.
    
    gridDuration = [Chart gridDurationForChartDuration:chartDuration];
    STAssertEquals(gridDuration, (uint)48, @"Oops");
    
    interval = [Chart intervalForDuration:gridDuration];
    STAssertEquals(interval, (uint)2, @"Oops");
    
    // number of segments is thus 48/2 = 24
    // ----

}

-(void)testGetYMax
{
    CGFloat yMax = [Chart getYMax:7200];
    STAssertEquals(yMax, 8000.f, @"Oops");
    
    yMax = [Chart getYMax:135];
    STAssertEquals(yMax, 200.f, @"Oops");
    
    yMax = [Chart getYMax:4300];
    STAssertEquals(yMax, 5000.f, @"Oops");
    
    yMax = [Chart getYMax:8.7];
    STAssertEquals(yMax, 10.f, @"Oops");
    
    yMax = [Chart getYMax:48.3];
    STAssertEquals(yMax, 80.f, @"Oops");
    
}

@end
