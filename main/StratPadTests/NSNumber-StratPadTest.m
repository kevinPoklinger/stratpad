//
//  NSNumber+StratPadTest.m
//  StratPad
//
//  Created by Eric Rogers on 11-09-13.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "NSNumber-StratPad.h"

@interface NSNumber_StratPadTest : SenTestCase
@end

@implementation NSNumber_StratPadTest

- (void)testDecimalFormattedNumberWithZeroDisplay
{
    NSNumber *number = [NSNumber numberWithDouble:0];
    NSString *result = [number decimalFormattedNumberWithZeroDisplay:NO];
    STAssertEqualObjects(@"", result, @"Oops");

    result = [number decimalFormattedNumberWithZeroDisplay:YES];
    STAssertEqualObjects(@"0", result, @"Should have received 0, but got %@", result);

    number = [NSNumber numberWithDouble:5000];
    result = [number decimalFormattedNumberWithZeroDisplay:NO];
    STAssertEqualObjects(@"5,000", result, @"Should have received 5,000, but got %@", result);

    result = [number decimalFormattedNumberWithZeroDisplay:YES];
    STAssertEqualObjects(@"5,000", result, @"Should have received 5,000, but got %@", result);

    number = [NSNumber numberWithDouble:minDisplayableValue];
    result = [number decimalFormattedNumberWithZeroDisplay:NO];
    STAssertEqualObjects(@"-99,999,999", result, @"Should have received -99,999,999, but got %@", result);

    number = [NSNumber numberWithDouble:minDisplayableValue];
    result = [number decimalFormattedNumberWithZeroDisplay:YES];
    STAssertEqualObjects(@"-99,999,999", result, @"Should have received -99,999,999, but got %@", result);

    number = [NSNumber numberWithDouble:maxDisplayableValue];
    result = [number decimalFormattedNumberWithZeroDisplay:NO];
    STAssertEqualObjects(@"99,999,999", result, @"Should have received 99,999,999, but got %@", result);

    number = [NSNumber numberWithDouble:maxDisplayableValue];
    result = [number decimalFormattedNumberWithZeroDisplay:YES];
    STAssertEqualObjects(@"99,999,999", result, @"Should have received 99,999,999, but got %@", result);

    number = [NSNumber numberWithDouble:-100000000];
    result = [number decimalFormattedNumberWithZeroDisplay:NO];
    STAssertEqualObjects(@"#########", result, @"Should have received #########, but got %@", result);

    number = [NSNumber numberWithDouble:-100000000];
    result = [number decimalFormattedNumberWithZeroDisplay:YES];
    STAssertEqualObjects(@"#########", result, @"Should have received #########, but got %@", result);

    number = [NSNumber numberWithDouble:100000000];
    result = [number decimalFormattedNumberWithZeroDisplay:NO];
    STAssertEqualObjects(@"#########", result, @"Should have received #########, but got %@", result);

    number = [NSNumber numberWithDouble:100000000];
    result = [number decimalFormattedNumberWithZeroDisplay:YES];
    STAssertEqualObjects(@"#########", result, @"Should have received #########, but got %@", result);
}


@end
