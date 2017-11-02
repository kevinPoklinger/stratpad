//
//  NSNumber-StratPad.h
//  StratPad
//
//  Created by Eric Rogers on August 19, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//
//  Adds formatting and number parsing specific to StratPad.

extern const double minDisplayableValue;
extern const double maxDisplayableValue;

@interface NSNumber (NSNumber_StratPad)

// returns the number formatted as an integer, with no decimal places. i.e., 1,000
// will return a blank string instead of 0, if zeroDisplay = NO.
- (NSString*)decimalFormattedNumberWithZeroDisplay:(BOOL)zeroDisplay;

// grouped number, parentheses for negative, ### if it exceeds maxDisplayableValue, 0 if nil or 0
- (NSString*)decimalFormattedNumberForCurrencyDisplay;
@end
