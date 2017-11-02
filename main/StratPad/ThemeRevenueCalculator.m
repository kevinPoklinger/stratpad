//
//  ThemeRevenueCalculator.m
//  StratPad
//
//  Created by Eric Rogers on August 28, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "ThemeRevenueCalculator.h"

@implementation ThemeRevenueCalculator

- (id)initWithTheme:(Theme*)theme andIsOptimistic:(BOOL)optimistic
{
    self = [super initWithTheme:theme andIsOptimistic:optimistic];
    if (self) {
        self.oneTimeValue = theme.revenueOneTime;
        self.monthlyValue = theme.revenueMonthly;
        self.quarterlyValue = theme.revenueQuarterly;
        self.annualValue = theme.revenueAnnually;
        
        self.monthlyAdjustment = theme.revenueMonthlyAdjustment;
        self.quarterlyAdjustment = theme.revenueQuarterlyAdjustment;
        self.annualAdjustment = theme.revenueAnnuallyAdjustment;
        
        [self calculate];
    }
    return self;
}

@end
