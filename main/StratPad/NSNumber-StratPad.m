//
//  NSNumber-StratPad.m
//  StratPad
//
//  Created by Eric Rogers on August 19, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "NSNumber-StratPad.h"

const double minDisplayableValue = -99999999;
const double maxDisplayableValue = 999999999;

@implementation NSNumber (NSNumber_StratPad)

- (NSString*)decimalFormattedNumberWithZeroDisplay:(BOOL)zeroDisplay
{
    if (!zeroDisplay && [self doubleValue] == 0) {
        return @"";
    }
    
    if ([self doubleValue] > maxDisplayableValue || [self doubleValue] < minDisplayableValue) {
        return @"#########";
    }
        
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setMaximumFractionDigits:0];
        
    NSString *formattedNumber = [formatter stringFromNumber:self];
    [formatter release];
    
    return formattedNumber;
}

- (NSString*)decimalFormattedNumberForCurrencyDisplay
{
    if ([self intValue] == 0) {
        return @"0";
    }
    
    if ([self doubleValue] > maxDisplayableValue || [self doubleValue] < minDisplayableValue) {
        return @"#########";
    }
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setNegativeFormat:@"(#,##0)"];
    [formatter setMaximumFractionDigits:0];
    
    NSString *formattedNumber = [formatter stringFromNumber:self];
    [formatter release];
    
    return formattedNumber;
}



@end
