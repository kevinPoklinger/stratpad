//
//  ThemeExpenseCalculator.m
//  StratPad
//
//  Created by Eric Rogers on August 28, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "ThemeRADCalculator.h"

@implementation ThemeRADCalculator

- (id)initWithTheme:(Theme*)theme andIsOptimistic:(BOOL)optimistic
{
    self = [super initWithTheme:theme andIsOptimistic:optimistic];
    if (self) {
        self.oneTimeValue = theme.researchAndDevelopmentOneTime;
        self.monthlyValue = theme.researchAndDevelopmentMonthly;
        self.quarterlyValue = theme.researchAndDevelopmentQuarterly;
        self.annualValue = theme.researchAndDevelopmentAnnually;
        
        self.monthlyAdjustment = theme.researchAndDevelopmentMonthlyAdjustment;
        self.quarterlyAdjustment = theme.researchAndDevelopmentQuarterlyAdjustment;
        self.annualAdjustment = theme.researchAndDevelopmentAnnuallyAdjustment;
        
        [self calculate];
    }
    return self;
}

@end
