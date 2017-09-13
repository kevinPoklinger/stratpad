//
//  CalculationsViewControllerTest.m
//  StratPad
//
//  Created by Julian Wood on 2013-06-19.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "CalculationsViewController.h"

@interface CalculationsViewControllerTest : SenTestCase
@end

@implementation CalculationsViewControllerTest

-(void)testFormattedNumberForAdjustmentCalculation
{
    // 0        -> ""
    // 12.0     -> 12
    // 12.01    -> 12.01
    // 12.011   -> 12.01
    // 1000.1   -> ####
    
    NSDecimalNumber *number = [NSDecimalNumber decimalNumberWithString:@"0"];
    NSString *result = [number formattedNumberForAdjustmentCalculation];
    STAssertEqualObjects(result, @"", @"Oops");
    
    number = [NSDecimalNumber decimalNumberWithString:@"12.0"];
    result = [number formattedNumberForAdjustmentCalculation];
    STAssertEqualObjects(result, @"12%", @"Oops");
    
    number = [NSDecimalNumber decimalNumberWithString:@"12.01"];
    result = [number formattedNumberForAdjustmentCalculation];
    STAssertEqualObjects(result, @"12.01%", @"Oops");
    
    number = [NSDecimalNumber decimalNumberWithString:@"12.011"];
    result = [number formattedNumberForAdjustmentCalculation];
    STAssertEqualObjects(result, @"12.01%", @"Oops");
    
    number = [NSDecimalNumber decimalNumberWithString:@"1000.1"];
    result = [number formattedNumberForAdjustmentCalculation];
    STAssertEqualObjects(result, @"####", @"Oops");
    
    number = [NSDecimalNumber decimalNumberWithString:@"999.99%"];
    result = [number formattedNumberForAdjustmentCalculation];
    STAssertEqualObjects(result, @"999.99%", @"Oops");
    
}


@end
