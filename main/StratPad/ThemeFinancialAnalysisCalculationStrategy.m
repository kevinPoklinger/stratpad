//
//  ThemeFinancialAnalysisCalculationStrategy.m
//  StratPad
//
//  Created by Eric Rogers on August 29, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "ThemeFinancialAnalysisCalculationStrategy.h"
#import "StratFile.h"
#import "NSDate-StratPad.h"
#import "Objective.h"
#import "ActivityCalculator.h"

@implementation ThemeFinancialAnalysisCalculationStrategy

@synthesize calculationStartDate = calculationStartDate_;
@synthesize calculationDurationInMonths = calculationDurationInMonths_;

- (id)initWithTheme:(Theme*)theme isOptimistic:(BOOL)optimistic isRelativeToStrategyStart:(BOOL)relativeToStrategyStart
{
    if ((self = [super init])) {
        
        themeDurationInMonths_ = [theme durationInMonths];
        
        revenueCalculator_ = [[ThemeRevenueCalculator alloc] initWithTheme:theme andIsOptimistic:optimistic];
        cogsCalculator_ = [[ThemeCOGSCalculator alloc] initWithTheme:theme andIsOptimistic:optimistic];
        radCalculator_ = [[ThemeRADCalculator alloc] initWithTheme:theme andIsOptimistic:optimistic];
        gaaCalculator_ = [[ThemeGAACalculator alloc] initWithTheme:theme andIsOptimistic:optimistic];
        samCalculator_ = [[ThemeSAMCalculator alloc] initWithTheme:theme andIsOptimistic:optimistic];
        
        // include an activity calculator for each activity in the theme.
        activityCalculators_ = [[NSMutableArray array] retain];
        ActivityCalculator *activityCalculator = nil;
        for (Objective *objective in theme.objectives) {
            for (Activity *activity in objective.activities) {
                activityCalculator = [[ActivityCalculator alloc] initWithActivity:activity andIsOptimistic:optimistic];
                [activityCalculators_ addObject:activityCalculator];
                [activityCalculator release];
            }
        }
        
        if (relativeToStrategyStart) {
            // determine the offset from the strategy start to the start of the theme.
            calculationStartDate_ = [[[theme stratFile] strategyStartDate] retain];
            themeOffset_ = [theme numberOfMonthsFromStrategyStart];
        } else {
            // begin from the start of the theme.
            calculationStartDate_ = [[theme normalizedStartDate] retain];
            themeOffset_ = 0;
        } 
        
        // should be themeOffset + themeDuration, iff relativeToStrategyStart; otherwise themDuration, up to a max of strategyDurationInYearsWhenNotDefined
        uint duration = themeOffset_ + themeDurationInMonths_;
        calculationDurationInMonths_ = MIN(strategyDurationInYearsWhenNotDefined * 12, (relativeToStrategyStart ? duration : themeDurationInMonths_));

    }
    return self;
}

- (void)dealloc
{
    [calculationStartDate_ release];
    
    [revenueCalculator_ release];
    [cogsCalculator_ release];
    [radCalculator_ release];
    [gaaCalculator_ release];
    [samCalculator_ release];
    [activityCalculators_ release];
    
    [super dealloc];
}

- (NSString*)description
{
    return [NSString stringWithFormat:
            @"Revenue Calculations: %@, COGS Calculations: %@, R & D Calculations: %@, G & A Calculations: %@, S & M Calculations: %@",
            revenueCalculator_, cogsCalculator_, radCalculator_, gaaCalculator_, samCalculator_];
}

#pragma mark - Revenue

- (NSNumber*)changeInRevenueForMonthNumber:(NSUInteger)monthNumber
{
    int idx = monthNumber - themeOffset_;
    if (idx >= 0 && idx < themeDurationInMonths_) {
        return [revenueCalculator_.monthlyCalculations objectAtIndex:idx]; 
    } else {
        return [NSNumber numberWithDouble:0];
    }
}

- (NSNumber*)changeInRevenueForYear:(NSInteger)year
{
    double total = 0;
    
    for (uint i = 0; i < 12; i++) {
        total += [[self changeInRevenueForMonthNumber:i+year*12] doubleValue];
    }
    
    return [NSNumber numberWithDouble:total];    
}

- (NSNumber*)changeInRevenueForYearsAfter:(NSInteger)year
{
    double total = 0;
    
    for (uint i = year*12+12; i < calculationDurationInMonths_; i++) {
        total += [[self changeInRevenueForMonthNumber:i] doubleValue];
    }
    
    return [NSNumber numberWithDouble:total];
}


#pragma mark - COGS


- (NSNumber*)changeInCOGSForMonthNumber:(NSUInteger)monthNumber
{
    int idx = monthNumber - themeOffset_;
    if (idx >= 0 && idx < themeDurationInMonths_) {
        return [cogsCalculator_.monthlyCalculations objectAtIndex:idx]; 
    } else {
        return [NSNumber numberWithDouble:0];
    }
}

- (NSNumber*)changeInCOGSForYear:(NSInteger)year
{
    double total = 0;
    
    for (uint i = 0; i < 12; i++) {
        total += [[self changeInCOGSForMonthNumber:i+year*12] doubleValue];
    }
    
    return [NSNumber numberWithDouble:total];
}

- (NSNumber*)changeInCOGSForYearsAfter:(NSInteger)year;
{
    double total = 0;
    
    for (uint i = year*12+12; i < calculationDurationInMonths_; i++) {
        total += [[self changeInCOGSForMonthNumber:i] doubleValue];
    }
    
    return [NSNumber numberWithDouble:total];
}


#pragma mark - Gross Margin = Revenue - COGS


- (NSNumber*)totalChangeInGrossMarginForMonthNumber:(NSUInteger)monthNumber
{
    double revenueChange = [[self changeInRevenueForMonthNumber:monthNumber] doubleValue];
    double cogsChange = [[self changeInCOGSForMonthNumber:monthNumber] doubleValue];        
    return [NSNumber numberWithDouble:revenueChange - cogsChange];    
}

- (NSNumber*)totalChangeInGrossMarginForYear:(NSInteger)year
{
    double revenueChange = [[self changeInRevenueForYear:year] doubleValue];
    double cogsChange = [[self changeInCOGSForYear:year] doubleValue];
    
    return [NSNumber numberWithDouble:revenueChange - cogsChange];        
}

- (NSNumber*)totalChangeInGrossMarginForYearsAfter:(NSInteger)year
{
    double revenueChange = [[self changeInRevenueForYearsAfter:year] doubleValue];
    double cogsChange = [[self changeInCOGSForYearsAfter:year] doubleValue];
    
    return [NSNumber numberWithDouble:revenueChange - cogsChange];            
}


#pragma mark - R & D


- (NSNumber*)changeInRadForMonthNumber:(NSUInteger)monthNumber
{
    int idx = monthNumber - themeOffset_;
    if (idx >= 0 && idx < themeDurationInMonths_) {
        return [radCalculator_.monthlyCalculations objectAtIndex:idx]; 
    } else {
        return [NSNumber numberWithDouble:0];
    }
}

- (NSNumber*)changeInRadForYear:(NSInteger)year
{
    double total = 0;
    
    for (uint i = 0; i < 12; i++) {
        total += [[self changeInRadForMonthNumber:i+year*12] doubleValue];
    }
    
    return [NSNumber numberWithDouble:total];
}

- (NSNumber*)changeInRadForYearsAfter:(NSInteger)year
{
    double total = 0;
    
    for (uint i = year*12+12; i < calculationDurationInMonths_; i++) {
        total += [[self changeInRadForMonthNumber:i] doubleValue];
    }
    
    return [NSNumber numberWithDouble:total];
}


#pragma mark - G & A, including activity costs


- (NSNumber*)changeInGaaForMonthNumber:(NSUInteger)monthNumber
{
    int idx = monthNumber - themeOffset_;
    if (idx >= 0 && idx < themeDurationInMonths_) {
        
        // we need to figure out if the month we are calculating falls in the range of any 
        // activities in the theme.  If it does, then we include the monthly calculation for the 
        // corresponding activity calculator.
        double totalCostForMonth = 0;
        Activity *activity = nil;
        NSUInteger activityOffset = 0;
        NSUInteger activityDurationInMonths = 0;
        for (ActivityCalculator *calculator in activityCalculators_) {
            
            activity = calculator.activity;
            activityDurationInMonths = [activity durationInMonths];
            activityOffset = [activity numberOfMonthsFromThemeStart];

            if (monthNumber >= (themeOffset_ + activityOffset) 
                && monthNumber < (themeOffset_ + activityOffset + activityDurationInMonths)) {
                totalCostForMonth += [[calculator.monthlyCalculations objectAtIndex:idx - activityOffset] doubleValue];
            }
        }
        
        totalCostForMonth += [[gaaCalculator_.monthlyCalculations objectAtIndex:idx] doubleValue];
        return [NSNumber numberWithDouble:totalCostForMonth]; 
        
    } else {
        return [NSNumber numberWithDouble:0];
    }
}

- (NSNumber*)changeInGaaForYear:(NSInteger)year
{
    double total = 0;
    
    for (uint i = 0; i < 12; i++) {
        total += [[self changeInGaaForMonthNumber:i+year*12] doubleValue];
    }
    
    return [NSNumber numberWithDouble:total];
}

- (NSNumber*)changeInGaaForYearsAfter:(NSInteger)year
{
    double total = 0;
    
    for (uint i = year*12+12; i < calculationDurationInMonths_; i++) {
        total += [[self changeInGaaForMonthNumber:i] doubleValue];
    }
    
    return [NSNumber numberWithDouble:total];
}


#pragma mark - S & M

- (NSNumber*)changeInSamForMonthNumber:(NSUInteger)monthNumber
{
    int idx = monthNumber - themeOffset_;
    if (idx >= 0 && idx < themeDurationInMonths_) {
        return [samCalculator_.monthlyCalculations objectAtIndex:idx];
    } else {
        return [NSNumber numberWithDouble:0];
    }
}

- (NSNumber*)changeInSamForYear:(NSInteger)year
{
    double total = 0;
    
    for (uint i = 0; i < 12; i++) {
        total += [[self changeInSamForMonthNumber:i+year*12] doubleValue];
    }
    
    return [NSNumber numberWithDouble:total];
}

- (NSNumber*)changeInSamForYearsAfter:(NSInteger)year
{
    double total = 0;
    
    for (uint i = year*12+12; i < calculationDurationInMonths_; i++) {
        total += [[self changeInSamForMonthNumber:i] doubleValue];
    }
    
    return [NSNumber numberWithDouble:total];
}

#pragma mark - Total expenses


- (NSNumber*)totalChangeInExpensesForMonthNumber:(NSUInteger)monthNumber
{
    double radChange = [[self changeInRadForMonthNumber:monthNumber] doubleValue];
    double gaaChange = [[self changeInGaaForMonthNumber:monthNumber] doubleValue];
    double samChange = [[self changeInSamForMonthNumber:monthNumber] doubleValue];
    return [NSNumber numberWithDouble:radChange + gaaChange + samChange];
}

- (NSNumber*)totalChangeInExpensesForYear:(NSInteger)year
{
    double radChange = [[self changeInRadForYear:year] doubleValue];
    double gaaChange = [[self changeInGaaForYear:year] doubleValue];
    double samChange = [[self changeInSamForYear:year] doubleValue];
    
    return [NSNumber numberWithDouble:radChange + gaaChange + samChange];
}

- (NSNumber*)totalChangeInExpensesForYearsAfter:(NSInteger)year
{
    double radChange = [[self changeInRadForYearsAfter:year] doubleValue];
    double gaaChange = [[self changeInGaaForYearsAfter:year] doubleValue];
    double samChange = [[self changeInSamForYearsAfter:year] doubleValue];
    
    return [NSNumber numberWithDouble:radChange + gaaChange + samChange];
}


#pragma mark - net contribution


- (NSNumber*)netContributionForMonthNumber:(NSUInteger)monthNumber
{
    double totalChangeInGrossMargin = [[self totalChangeInGrossMarginForMonthNumber:monthNumber] doubleValue];
    double totalChangeInExpenses = [[self totalChangeInExpensesForMonthNumber:monthNumber] doubleValue];        
    return [NSNumber numberWithDouble:totalChangeInGrossMargin - totalChangeInExpenses];
}

- (NSNumber*)netContributionForYear:(NSInteger)year
{
    double firstYearChangeInGrossMargin = [[self totalChangeInGrossMarginForYear:year] doubleValue];
    double firstYearChangeInExpenses = [[self totalChangeInExpensesForYear:year] doubleValue];
    
    return [NSNumber numberWithDouble:firstYearChangeInGrossMargin - firstYearChangeInExpenses];
}

- (NSNumber*)netContributionForYearsAfter:(NSInteger)year
{
    double subsYearsChangeInGrossMargin = [[self totalChangeInGrossMarginForYearsAfter:year] doubleValue];
    double subsYearsChangeInExpenses = [[self totalChangeInExpensesForYearsAfter:year] doubleValue];
    
    return [NSNumber numberWithDouble:subsYearsChangeInGrossMargin - subsYearsChangeInExpenses];
}

#pragma mark - net cumulative

- (NSNumber*)netCumulativeForMonthNumber:(NSUInteger)monthNumber
{
    double previousNetCumlative = monthNumber == 0 ? 0 : [[self netCumulativeForMonthNumber:monthNumber - 1] doubleValue];
    double netContribution = [[self netContributionForMonthNumber:monthNumber] doubleValue];
    
    return [NSNumber numberWithDouble:previousNetCumlative + netContribution];    
}

- (NSNumber*)netCumulativeForYear:(NSInteger)year
{
    return [self netCumulativeForMonthNumber:year*12+11];
}

- (NSNumber*)netCumulativeForYearsAfter:(NSInteger)year
{
    uint lastMonth = calculationDurationInMonths_ == 0 ? 0 : calculationDurationInMonths_ - 1;
    return [self netCumulativeForMonthNumber:lastMonth];    
}

@end
