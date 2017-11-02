//
//  MetricTest.m
//  StratPad
//
//  Created by Eric Rogers on September 24, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "Metric.h"
#import "Measurement.h"
#import "DataManager.h"
#import "CoreDataTestCase.h"

@interface MetricTest : CoreDataTestCase 
@end


@implementation MetricTest

/*
 * Test the parseNumberFromTargetValue method when the target value is nil.
 */
- (void)testParseNumberFromTargetValue1
{
    Metric *metric = (Metric*)[DataManager createManagedInstance:NSStringFromClass([Metric class])];
    NSNumber *result = [metric parseNumberFromTargetValue];
    STAssertNil(result, @"Parsed value should have been nil, but was %@", result);                                                    
}

/*
 * Test the parseNumberFromTargetValue method when the target value is an empty string.
 */
- (void)testParseNumberFromTargetValue2
{
    Metric *metric = (Metric*)[DataManager createManagedInstance:NSStringFromClass([Metric class])];
    metric.targetValue = @"";
    NSNumber *result = [metric parseNumberFromTargetValue];
    STAssertNil(result, @"Parsed value should have been nil, but was %@", result);                                                    
}

/*
 * Test the parseNumberFromTargetValue method when the target value is a string
 * containing alpha characters.
 */
- (void)testParseNumberFromTargetValue3
{
    Metric *metric = (Metric*)[DataManager createManagedInstance:NSStringFromClass([Metric class])];
    metric.targetValue = @"1234 Hello";
    NSNumber *result = [metric parseNumberFromTargetValue];
    STAssertNil(result, @"Parsed value should have been nil, but was %@", result);                                                    
}

/*
 * Test the parseNumberFromTargetValue method when the target value is a string
 * containing only numeric characters.
 */
- (void)testParseNumberFromTargetValue4
{
    Metric *metric = (Metric*)[DataManager createManagedInstance:NSStringFromClass([Metric class])];
    metric.targetValue = @"1234";

    NSNumber *result = [metric parseNumberFromTargetValue];
    STAssertNotNil(result, @"Parsed value should not have been nil");                                                    
    STAssertTrue([result doubleValue] == 1234, @"Result should have been equal to 1234 but was %@", result);
    
    metric.targetValue = @"0";
    result = [metric parseNumberFromTargetValue];
    STAssertNotNil(result, @"Parsed value should not have been nil");                                                    
    STAssertTrue([result doubleValue] == 0, @"Result should have been equal to 0 but was %@", result);
}

/*
 * Test the parseNumberFromTargetValue method when the target value is a string
 * containing numeric characters, currency symbols, commas, and plus and minus symbols.
 */
- (void)testParseNumberFromTargetValue5
{
    Metric *metric = (Metric*)[DataManager createManagedInstance:NSStringFromClass([Metric class])];
    metric.targetValue = @"+1234";

    NSNumber *result = [metric parseNumberFromTargetValue];
    STAssertNotNil(result, @"Parsed value should not have been nil");                                                    
    STAssertTrue([result doubleValue] == 1234, @"Result should have been equal to 1234 but was %@", result);

    metric.targetValue = @"+1,234";
    result = [metric parseNumberFromTargetValue];
    STAssertNotNil(result, @"Parsed value should not have been nil");                                                    
    STAssertTrue([result doubleValue] == 1234, @"Result should have been equal to 1234 but was %@", result);

    metric.targetValue = @"-1,234";
    result = [metric parseNumberFromTargetValue];
    STAssertNotNil(result, @"Parsed value should not have been nil");                                                    
    STAssertTrue([result doubleValue] == -1234, @"Result should have been equal to -1234 but was %@", result);

    metric.targetValue = @"1,234";
    result = [metric parseNumberFromTargetValue];
    STAssertNotNil(result, @"Parsed value should not have been nil");                                                    
    STAssertTrue([result doubleValue] == 1234, @"Result should have been equal to 1234 but was %@", result);

    metric.targetValue = @"$1234";
    result = [metric parseNumberFromTargetValue];
    STAssertNotNil(result, @"Parsed value should not have been nil");                                                    
    STAssertTrue([result doubleValue] == 1234, @"Result should have been equal to 1234 but was %@", result);

    metric.targetValue = @"-$1,234";
    result = [metric parseNumberFromTargetValue];
    STAssertNotNil(result, @"Parsed value should not have been nil");                                                    
    STAssertTrue([result doubleValue] == -1234, @"Result should have been equal to 1234 but was %@", result);
}

-(void)testHasMeasurements
{
    Metric *metric = (Metric*)[DataManager createManagedInstance:NSStringFromClass([Metric class])];
    metric.summary = @"Test meas count";
    
    STAssertFalse(metric.hasMeasurements, @"Oops");
    
    Measurement *measurement = (Measurement*)[DataManager createManagedInstance:NSStringFromClass([Measurement class])];
    measurement.value = [NSNumber numberWithInt:25];
    [metric addMeasurementsObject:measurement];
    
    [DataManager saveManagedInstances];
    
    STAssertTrue(metric.hasMeasurements, @"Ooops");
}

@end
