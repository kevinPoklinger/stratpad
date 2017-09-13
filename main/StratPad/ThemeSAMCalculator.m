//
//  ThemeSAMCalculator.m
//  StratPad
//
//  Created by Julian Wood on 2013-05-16.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//

#import "ThemeSAMCalculator.h"

@implementation ThemeSAMCalculator

- (id)initWithTheme:(Theme*)theme andIsOptimistic:(BOOL)optimistic
{
    self = [super initWithTheme:theme andIsOptimistic:optimistic];
    if (self) {
        self.oneTimeValue = theme.salesAndMarketingOneTime;
        self.monthlyValue = theme.salesAndMarketingMonthly;
        self.quarterlyValue = theme.salesAndMarketingQuarterly;
        self.annualValue = theme.salesAndMarketingAnnually;
        
        self.monthlyAdjustment = theme.salesAndMarketingMonthlyAdjustment;
        self.quarterlyAdjustment = theme.salesAndMarketingQuarterlyAdjustment;
        self.annualAdjustment = theme.salesAndMarketingAnnuallyAdjustment;
        
        [self calculate];
    }
    return self;
}

@end

