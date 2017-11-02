//
//  ThemeCostCalculator.m
//  StratPad
//
//  Created by Eric Rogers on August 29, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "ThemeGAACalculator.h"

@implementation ThemeGAACalculator

- (id)initWithTheme:(Theme*)theme andIsOptimistic:(BOOL)optimistic
{
    self = [super initWithTheme:theme andIsOptimistic:optimistic];
    if (self) {
        self.oneTimeValue = theme.generalAndAdminOneTime;
        self.monthlyValue = theme.generalAndAdminMonthly;
        self.quarterlyValue = theme.generalAndAdminQuarterly;
        self.annualValue = theme.generalAndAdminAnnually;
        
        self.monthlyAdjustment = theme.generalAndAdminMonthlyAdjustment;
        self.quarterlyAdjustment = theme.generalAndAdminQuarterlyAdjustment;
        self.annualAdjustment = theme.generalAndAdminAnnuallyAdjustment;
        
        [self calculate];
    }
    return self;
}

@end
