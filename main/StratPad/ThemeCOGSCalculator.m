//
//  ThemeCOGSCalculator.m
//  StratPad
//
//  Created by Eric Rogers on August 28, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "ThemeCOGSCalculator.h"

@implementation ThemeCOGSCalculator

- (id)initWithTheme:(Theme*)theme andIsOptimistic:(BOOL)optimistic
{
    self = [super initWithTheme:theme andIsOptimistic:optimistic];
    if (self) {
        self.oneTimeValue = theme.cogsOneTime;
        self.monthlyValue = theme.cogsMonthly;
        self.quarterlyValue = theme.cogsQuarterly;
        self.annualValue = theme.cogsAnnually;
        
        self.monthlyAdjustment = theme.cogsMonthlyAdjustment;
        self.quarterlyAdjustment = theme.cogsQuarterlyAdjustment;
        self.annualAdjustment = theme.cogsAnnuallyAdjustment;
        
        [self calculate];
    }
    return self;
}


@end
