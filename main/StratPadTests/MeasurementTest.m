//
//  MeasurementTest.m
//  StratPad
//
//  Created by Julian Wood on April 25, 2012.
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

@interface MeasurementTest : CoreDataTestCase 
@end


@implementation MeasurementTest

-(void)testDates
{
    // designed to be run in MST
    
    NSString *dateString = @"20120216T23:31:10-0700";
    NSDate *date = [NSDate dateTimeFromISO8601:dateString];
    
    NSDate *midnight = [date dateWithZeroedTime];
    
    // year, month and day should be the same, not 02/17 (as it would be if this were taken straight from the UTC date)    
    NSString *dateStringForStratfile = [midnight stringForISO8601Date];
    STAssertEqualObjects(dateStringForStratfile, @"20120216", @"Oops");
    
    DLog(@"date: %@", midnight);
    DLog(@"date: %@", [midnight utcFormattedDateTime]);
    DLog(@"date: %@", [midnight localFormattedDateTime]);
    
    STAssertEqualObjects([midnight utcFormattedDateTime], @"02-16-2012 07:00", @"Oops");
    STAssertEqualObjects([midnight localFormattedDateTime], @"02-16-2012 00:00", @"Oops");
    
    
}


@end
