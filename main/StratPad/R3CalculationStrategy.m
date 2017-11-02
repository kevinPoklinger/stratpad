//
//  R3CalculationStrategy.m
//  StratPad
//
//  Created by Eric Rogers on August 29, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "R3CalculationStrategy.h"
#import "ThemeFinancialAnalysisCalculationStrategy.h"


@implementation R3CalculationStrategy

@synthesize themes = themes_;

- (id)initWithStratFile:(StratFile*)stratFile andIsOptimistic:(BOOL)optimistic
{
    if ((self = [super init])) {
        themes_ = [[stratFile themesSortedByOrder] retain];
        themeCalculationStrategies_ = [[NSMutableArray alloc] initWithCapacity:themes_.count];
                
        ThemeFinancialAnalysisCalculationStrategy *themeCalculator;
        for (Theme *theme in themes_) {
            themeCalculator = [[ThemeFinancialAnalysisCalculationStrategy alloc] initWithTheme:theme isOptimistic:optimistic isRelativeToStrategyStart:YES];
            [themeCalculationStrategies_ addObject:themeCalculator];            
            [themeCalculator release];
        }        
    }
    return self;
}


#pragma mark - Memory Management

- (void)dealloc
{
    [themes_ release];
    [themeCalculationStrategies_ release];
    
    [super dealloc];
}


#pragma mark - Revenue

- (NSNumber*)changeInRevenueForThemeNumber:(NSUInteger)themeNumber year:(NSUInteger)year
{
    ThemeFinancialAnalysisCalculationStrategy *strategy = [themeCalculationStrategies_ objectAtIndex:themeNumber];
    return [strategy changeInRevenueForYear:year];
}

- (NSNumber*)changeInRevenueForYear:(NSUInteger)year
{
    double changeInRevenue = 0;
    for (ThemeFinancialAnalysisCalculationStrategy *strategy in themeCalculationStrategies_) {
        changeInRevenue += [[strategy changeInRevenueForYear:year] doubleValue];
    }
    
    return [NSNumber numberWithDouble:changeInRevenue];
}

- (NSNumber*)changeInRevenueForYearsAfter:(NSUInteger)year
{
    double subsYearsChangeInRevenue = 0;
    for (ThemeFinancialAnalysisCalculationStrategy *strategy in themeCalculationStrategies_) {
        subsYearsChangeInRevenue += [[strategy changeInRevenueForYearsAfter:year] doubleValue];
    }
    
    return [NSNumber numberWithDouble:subsYearsChangeInRevenue];
}


#pragma mark - COGS


- (NSNumber*)changeInCOGSForThemeNumber:(NSUInteger)themeNumber year:(NSUInteger)year
{
    ThemeFinancialAnalysisCalculationStrategy *strategy = [themeCalculationStrategies_ objectAtIndex:themeNumber];
    return [strategy changeInCOGSForYear:year];
}

- (NSNumber*)changeInCOGSForYear:(NSUInteger)year
{
    double changeInCOGS = 0;
    for (ThemeFinancialAnalysisCalculationStrategy *strategy in themeCalculationStrategies_) {
        changeInCOGS += [[strategy changeInCOGSForYear:year] doubleValue];
    }
    
    return [NSNumber numberWithDouble:changeInCOGS];
}

- (NSNumber*)changeInCOGSForYearsAfter:(NSUInteger)year
{
    double subsYearsChangeInCOGS = 0;
    for (ThemeFinancialAnalysisCalculationStrategy *strategy in themeCalculationStrategies_) {
        subsYearsChangeInCOGS += [[strategy changeInCOGSForYearsAfter:year] doubleValue];
    }
    
    return [NSNumber numberWithDouble:subsYearsChangeInCOGS];
}


#pragma mark - Gross margin


- (NSNumber*)changeInGrossMarginForThemeNumber:(NSUInteger)themeNumber year:(NSUInteger)year
{
    ThemeFinancialAnalysisCalculationStrategy *strategy = [themeCalculationStrategies_ objectAtIndex:themeNumber];
    return [strategy totalChangeInGrossMarginForYear:year];
}

- (NSNumber*)totalChangeInGrossMarginForYear:(NSUInteger)year
{
    double totalChange = 0;
    for (ThemeFinancialAnalysisCalculationStrategy *strategy in themeCalculationStrategies_) {
        totalChange += [[strategy totalChangeInGrossMarginForYear:year] doubleValue];
    }
    
    return [NSNumber numberWithDouble:totalChange];
}

- (NSNumber*)totalChangeInGrossMarginForYearsAfter:(NSUInteger)year
{
    double totalChange = 0;
    for (ThemeFinancialAnalysisCalculationStrategy *strategy in themeCalculationStrategies_) {
        totalChange += [[strategy totalChangeInGrossMarginForYearsAfter:year] doubleValue];
    }
    
    return [NSNumber numberWithDouble:totalChange];
}


#pragma mark - R & D


- (NSNumber*)changeInRadForThemeNumber:(NSUInteger)themeNumber year:(NSUInteger)year
{
    ThemeFinancialAnalysisCalculationStrategy *strategy = [themeCalculationStrategies_ objectAtIndex:themeNumber];
    return [strategy changeInRadForYear:year];
}

- (NSNumber*)changeInRadForYear:(NSUInteger)year
{
    double changeInExpenses = 0;
    for (ThemeFinancialAnalysisCalculationStrategy *strategy in themeCalculationStrategies_) {
        changeInExpenses += [[strategy changeInRadForYear:year] doubleValue];
    }
    
    return [NSNumber numberWithDouble:changeInExpenses];
}

- (NSNumber*)changeInRadForYearsAfter:(NSUInteger)year
{
    double subsYearsChangeInExpenses = 0;
    for (ThemeFinancialAnalysisCalculationStrategy *strategy in themeCalculationStrategies_) {
        subsYearsChangeInExpenses += [[strategy changeInRadForYearsAfter:year] doubleValue];
    }
    
    return [NSNumber numberWithDouble:subsYearsChangeInExpenses];
}


#pragma mark - G & A


- (NSNumber*)changeInGaaForThemeNumber:(NSUInteger)themeNumber year:(NSUInteger)year
{
    ThemeFinancialAnalysisCalculationStrategy *strategy = [themeCalculationStrategies_ objectAtIndex:themeNumber];
    return [strategy changeInGaaForYear:year];
}

- (NSNumber*)changeInGaaForYear:(NSUInteger)year
{
    double changeInCosts = 0;
    for (ThemeFinancialAnalysisCalculationStrategy *strategy in themeCalculationStrategies_) {
        changeInCosts += [[strategy changeInGaaForYear:year] doubleValue];
    }
    
    return [NSNumber numberWithDouble:changeInCosts];
}

- (NSNumber*)changeInGaaForYearsAfter:(NSUInteger)year
{
    double subsYearsChangeInCosts = 0;
    for (ThemeFinancialAnalysisCalculationStrategy *strategy in themeCalculationStrategies_) {
        subsYearsChangeInCosts += [[strategy changeInGaaForYearsAfter:year] doubleValue];
    }
    
    return [NSNumber numberWithDouble:subsYearsChangeInCosts];
}


#pragma mark - S & M


- (NSNumber*)changeInSamForThemeNumber:(NSUInteger)themeNumber year:(NSUInteger)year
{
    ThemeFinancialAnalysisCalculationStrategy *strategy = [themeCalculationStrategies_ objectAtIndex:themeNumber];
    return [strategy changeInSamForYear:year];
}

- (NSNumber*)changeInSamForYear:(NSUInteger)year
{
    double changeInCosts = 0;
    for (ThemeFinancialAnalysisCalculationStrategy *strategy in themeCalculationStrategies_) {
        changeInCosts += [[strategy changeInSamForYear:year] doubleValue];
    }
    
    return [NSNumber numberWithDouble:changeInCosts];
}

- (NSNumber*)changeInSamForYearsAfter:(NSUInteger)year
{
    double subsYearsChangeInCosts = 0;
    for (ThemeFinancialAnalysisCalculationStrategy *strategy in themeCalculationStrategies_) {
        subsYearsChangeInCosts += [[strategy changeInSamForYearsAfter:year] doubleValue];
    }
    
    return [NSNumber numberWithDouble:subsYearsChangeInCosts];
}


#pragma mark - total expenses


- (NSNumber*)totalChangeInExpensesForThemeNumber:(NSUInteger)themeNumber year:(NSUInteger)year
{
    ThemeFinancialAnalysisCalculationStrategy *strategy = [themeCalculationStrategies_ objectAtIndex:themeNumber];
    return [strategy totalChangeInExpensesForYear:year];
}

- (NSNumber*)totalChangeInExpensesForYear:(NSUInteger)year
{
    double totalChangeInExpenses = 0;
    for (ThemeFinancialAnalysisCalculationStrategy *strategy in themeCalculationStrategies_) {
        totalChangeInExpenses += [[strategy totalChangeInExpensesForYear:year] doubleValue];
    }
    
    return [NSNumber numberWithDouble:totalChangeInExpenses];    
}

- (NSNumber*)totalChangeInExpensesForYearsAfter:(NSUInteger)year
{
    double subsYearsTotalChangeInExpenses = 0;
    for (ThemeFinancialAnalysisCalculationStrategy *strategy in themeCalculationStrategies_) {
        subsYearsTotalChangeInExpenses += [[strategy totalChangeInExpensesForYearsAfter:year] doubleValue];
    }
    
    return [NSNumber numberWithDouble:subsYearsTotalChangeInExpenses];    
}


#pragma mark - net contribution


- (NSNumber*)netContributionForThemeNumber:(NSUInteger)themeNumber year:(NSUInteger)year
{
    ThemeFinancialAnalysisCalculationStrategy *strategy = [themeCalculationStrategies_ objectAtIndex:themeNumber];
    return [strategy netContributionForYear:year];
}

- (NSNumber*)netContributionForYear:(NSUInteger)year
{
    double netContribution = 0;
    for (ThemeFinancialAnalysisCalculationStrategy *strategy in themeCalculationStrategies_) {
        netContribution += [[strategy netContributionForYear:year] doubleValue];
    }
    
    return [NSNumber numberWithDouble:netContribution];    
}

- (NSNumber*)netContributionForYearsAfter:(NSUInteger)year
{
    double subsYearsNetContribution = 0;
    for (ThemeFinancialAnalysisCalculationStrategy *strategy in themeCalculationStrategies_) {
        subsYearsNetContribution += [[strategy netContributionForYearsAfter:year] doubleValue];
    }
    
    return [NSNumber numberWithDouble:subsYearsNetContribution];    
}


#pragma mark - net cumulative


- (NSNumber*)netCumulativeForThemeNumber:(NSUInteger)themeNumber year:(NSUInteger)year
{
    ThemeFinancialAnalysisCalculationStrategy *strategy = [themeCalculationStrategies_ objectAtIndex:themeNumber];
    return [strategy netCumulativeForYear:year];
}

- (NSNumber*)netCumulativeForYear:(NSUInteger)year
{
    double netCumulative = 0;
    for (ThemeFinancialAnalysisCalculationStrategy *strategy in themeCalculationStrategies_) {
        netCumulative += [[strategy netCumulativeForYear:year] doubleValue];
    }
    
    return [NSNumber numberWithDouble:netCumulative];    
}

- (NSNumber*)netCumulativeForYearsAfter:(NSUInteger)year
{
    double subsYearsNetCumulative = 0;
    for (ThemeFinancialAnalysisCalculationStrategy *strategy in themeCalculationStrategies_) {
        subsYearsNetCumulative += [[strategy netCumulativeForYearsAfter:year] doubleValue];
    }
    
    return [NSNumber numberWithDouble:subsYearsNetCumulative];    
}

@end
