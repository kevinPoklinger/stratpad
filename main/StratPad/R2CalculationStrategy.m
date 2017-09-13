//
//  R2CalculationStrategy.m
//  StratPad
//
//  Created by Eric Rogers on August 26, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "R2CalculationStrategy.h"
#import "Theme.h"
#import "ThemeFinancialAnalysisCalculationStrategy.h"


@implementation R2CalculationStrategy

@synthesize reportStartDate = reportStartDate_;

- (id)initWithStratFile:(StratFile*)stratFile andIsOptimistic:(BOOL)optimistic
{
    if ((self = [super init])) {

        reportStartDate_ = [[stratFile dateOfEarliestThemeOrToday] retain];
        
        themeCalculationStrategies_ = [[NSMutableArray alloc] initWithCapacity:stratFile.themes.count];

        for (Theme *theme in stratFile.themes) {
            ThemeFinancialAnalysisCalculationStrategy *themeCalculator = [[ThemeFinancialAnalysisCalculationStrategy alloc] initWithTheme:theme isOptimistic:optimistic isRelativeToStrategyStart:YES];
            [themeCalculationStrategies_ addObject:themeCalculator];            
            [themeCalculator release];
        }        
    }
    return self;
}


#pragma mark - Memory Management

- (void)dealloc
{
    [reportStartDate_ release];
    [themeCalculationStrategies_ release];
    
    [super dealloc];
}


#pragma mark - Revenue


- (NSNumber*)changeInRevenueForMonthNumber:(NSUInteger)monthNumber
{
    // sum the change in revenues for this month, for each theme
    double changeInRevenueForMonth = 0;
    for (ThemeFinancialAnalysisCalculationStrategy *strategy in themeCalculationStrategies_) {
        changeInRevenueForMonth += [[strategy changeInRevenueForMonthNumber:monthNumber] doubleValue];
    }
    
    return [NSNumber numberWithDouble:changeInRevenueForMonth];
}

- (NSNumber*)changeInRevenueForYear:(NSInteger)year
{
    // sum the changes in revenue for the first year, for each theme
    double firstYearChangeInRevenue = 0;
    for (ThemeFinancialAnalysisCalculationStrategy *strategy in themeCalculationStrategies_) {
        firstYearChangeInRevenue += [[strategy changeInRevenueForYear:year] doubleValue];
    }
    
    return [NSNumber numberWithDouble:firstYearChangeInRevenue];
}

- (NSNumber*)changeInRevenueForYearsAfter:(NSInteger)year
{
    // sum the changes in revenue for all but the first year, for each theme
    double subsYearsChangeInRevenue = 0;
    for (ThemeFinancialAnalysisCalculationStrategy *strategy in themeCalculationStrategies_) {
        subsYearsChangeInRevenue += [[strategy changeInRevenueForYearsAfter:year] doubleValue];
    }
    
    return [NSNumber numberWithDouble:subsYearsChangeInRevenue];
}


#pragma mark - COGS


- (NSNumber*)changeInCOGSForMonthNumber:(NSUInteger)monthNumber
{
    double subsYearsChangeInCOGS = 0;
    for (ThemeFinancialAnalysisCalculationStrategy *strategy in themeCalculationStrategies_) {
        subsYearsChangeInCOGS += [[strategy changeInCOGSForMonthNumber:monthNumber] doubleValue];
    }
    
    return [NSNumber numberWithDouble:subsYearsChangeInCOGS];
}

- (NSNumber*)changeInCOGSForYear:(NSInteger)year
{
    double firstYearChangeInCOGS = 0;
    for (ThemeFinancialAnalysisCalculationStrategy *strategy in themeCalculationStrategies_) {
        firstYearChangeInCOGS += [[strategy changeInCOGSForYear:year] doubleValue];
    }
    
    return [NSNumber numberWithDouble:firstYearChangeInCOGS];
}

- (NSNumber*)changeInCOGSForYearsAfter:(NSInteger)year
{
    double subsYearsChangeInCOGS = 0;
    for (ThemeFinancialAnalysisCalculationStrategy *strategy in themeCalculationStrategies_) {
        subsYearsChangeInCOGS += [[strategy changeInCOGSForYearsAfter:year] doubleValue];
    }
    
    return [NSNumber numberWithDouble:subsYearsChangeInCOGS];
}


#pragma mark - gross margin


- (NSNumber*)totalChangeInGrossMarginForMonthNumber:(NSUInteger)monthNumber
{
    double totalChange = 0;
    for (ThemeFinancialAnalysisCalculationStrategy *strategy in themeCalculationStrategies_) {
        totalChange += [[strategy totalChangeInGrossMarginForMonthNumber:monthNumber] doubleValue];
    }
    
    return [NSNumber numberWithDouble:totalChange];    
}

- (NSNumber*)totalChangeInGrossMarginForYear:(NSInteger)year
{
    double totalChange = 0;
    for (ThemeFinancialAnalysisCalculationStrategy *strategy in themeCalculationStrategies_) {
        totalChange += [[strategy totalChangeInGrossMarginForYear:year] doubleValue];
    }
    
    return [NSNumber numberWithDouble:totalChange];    
}

- (NSNumber*)totalChangeInGrossMarginForYearsAfter:(NSInteger)year
{
    double totalChange = 0;
    for (ThemeFinancialAnalysisCalculationStrategy *strategy in themeCalculationStrategies_) {
        totalChange += [[strategy totalChangeInGrossMarginForYearsAfter:year] doubleValue];
    }
    
    return [NSNumber numberWithDouble:totalChange];    
}


#pragma mark - R & D (expenses)


- (NSNumber*)changeInRadForMonthNumber:(NSUInteger)monthNumber
{
    double changeInExpenseSum = 0;
    for (ThemeFinancialAnalysisCalculationStrategy *strategy in themeCalculationStrategies_) {
        changeInExpenseSum += [[strategy changeInRadForMonthNumber:monthNumber] doubleValue];
    }
    
    return [NSNumber numberWithDouble:changeInExpenseSum];    
}

- (NSNumber*)changeInRadForYear:(NSInteger)year
{
    double firstYearChangeInExpenses = 0;
    for (ThemeFinancialAnalysisCalculationStrategy *strategy in themeCalculationStrategies_) {
        firstYearChangeInExpenses += [[strategy changeInRadForYear:year] doubleValue];
    }
    
    return [NSNumber numberWithDouble:firstYearChangeInExpenses];    
}

- (NSNumber*)changeInRadForYearsAfter:(NSInteger)year
{
    double subsYearsChangeInExpenses = 0;
    for (ThemeFinancialAnalysisCalculationStrategy *strategy in themeCalculationStrategies_) {
        subsYearsChangeInExpenses += [[strategy changeInRadForYearsAfter:year] doubleValue];
    }
    
    return [NSNumber numberWithDouble:subsYearsChangeInExpenses];    
}


#pragma mark - G & A (costs)


- (NSNumber*)changeInGaaForMonthNumber:(NSUInteger)monthNumber
{
    double changeInCosts = 0;
    for (ThemeFinancialAnalysisCalculationStrategy *strategy in themeCalculationStrategies_) {
        changeInCosts += [[strategy changeInGaaForMonthNumber:monthNumber] doubleValue];
    }
    
    return [NSNumber numberWithDouble:changeInCosts];    
}

- (NSNumber*)changeInGaaForYear:(NSInteger)year
{
    double firstYearChangeInCosts = 0;
    for (ThemeFinancialAnalysisCalculationStrategy *strategy in themeCalculationStrategies_) {
        firstYearChangeInCosts += [[strategy changeInGaaForYear:year] doubleValue];
    }
    
    return [NSNumber numberWithDouble:firstYearChangeInCosts];    
}

- (NSNumber*)changeInGaaForYearsAfter:(NSInteger)year
{
    double subsYearsChangeInCosts = 0;
    for (ThemeFinancialAnalysisCalculationStrategy *strategy in themeCalculationStrategies_) {
        subsYearsChangeInCosts += [[strategy changeInGaaForYearsAfter:year] doubleValue];
    }
    
    return [NSNumber numberWithDouble:subsYearsChangeInCosts];    
}


#pragma mark - S & M

- (NSNumber*)changeInSamForMonthNumber:(NSUInteger)monthNumber
{
    double changeInSam = 0;
    for (ThemeFinancialAnalysisCalculationStrategy *strategy in themeCalculationStrategies_) {
        changeInSam += [[strategy changeInSamForMonthNumber:monthNumber] doubleValue];
    }
    
    return [NSNumber numberWithDouble:changeInSam];
}

- (NSNumber*)changeInSamForYear:(NSInteger)year
{
    double firstYearChangeInSam = 0;
    for (ThemeFinancialAnalysisCalculationStrategy *strategy in themeCalculationStrategies_) {
        firstYearChangeInSam += [[strategy changeInSamForYear:year] doubleValue];
    }
    
    return [NSNumber numberWithDouble:firstYearChangeInSam];
}

- (NSNumber*)changeInSamForYearsAfter:(NSInteger)year
{
    double subsYearsChangeInSam = 0;
    for (ThemeFinancialAnalysisCalculationStrategy *strategy in themeCalculationStrategies_) {
        subsYearsChangeInSam += [[strategy changeInSamForYearsAfter:year] doubleValue];
    }
    
    return [NSNumber numberWithDouble:subsYearsChangeInSam];
}


#pragma mark - total theme expenses


- (NSNumber*)totalChangeInExpensesForMonthNumber:(NSUInteger)monthNumber
{
    double totalChange = 0;
    for (ThemeFinancialAnalysisCalculationStrategy *strategy in themeCalculationStrategies_) {
        totalChange += [[strategy totalChangeInExpensesForMonthNumber:monthNumber] doubleValue];
    }
    
    return [NSNumber numberWithDouble:totalChange];    
}

- (NSNumber*)totalChangeInExpensesForYear:(NSInteger)year
{
    double firstYearTotalChangeInExpenses = 0;
    for (ThemeFinancialAnalysisCalculationStrategy *strategy in themeCalculationStrategies_) {
        firstYearTotalChangeInExpenses += [[strategy totalChangeInExpensesForYear:year] doubleValue];
    }
    
    return [NSNumber numberWithDouble:firstYearTotalChangeInExpenses];    
}

- (NSNumber*)totalChangeInExpensesForYearsAfter:(NSInteger)year
{
    double subsYearsTotalChangeInExpenses = 0;
    for (ThemeFinancialAnalysisCalculationStrategy *strategy in themeCalculationStrategies_) {
        subsYearsTotalChangeInExpenses += [[strategy totalChangeInExpensesForYearsAfter:year] doubleValue];
    }
    
    return [NSNumber numberWithDouble:subsYearsTotalChangeInExpenses];    
}


#pragma mark - net contribution


- (NSNumber*)netContributionForMonthNumber:(NSUInteger)monthNumber
{
    double netContribution = 0;
    for (ThemeFinancialAnalysisCalculationStrategy *strategy in themeCalculationStrategies_) {
        netContribution += [[strategy netContributionForMonthNumber:monthNumber] doubleValue];
    }
    
    return [NSNumber numberWithDouble:netContribution];    
}

- (NSNumber*)netContributionForYear:(NSInteger)year
{
    double firstYearNetContribution = 0;
    for (ThemeFinancialAnalysisCalculationStrategy *strategy in themeCalculationStrategies_) {
        firstYearNetContribution += [[strategy netContributionForYear:year] doubleValue];
    }
    
    return [NSNumber numberWithDouble:firstYearNetContribution];    
}

- (NSNumber*)netContributionForYearsAfter:(NSInteger)year
{
    double subsYearsNetContribution = 0;
    for (ThemeFinancialAnalysisCalculationStrategy *strategy in themeCalculationStrategies_) {
        subsYearsNetContribution += [[strategy netContributionForYearsAfter:year] doubleValue];
    }
    
    return [NSNumber numberWithDouble:subsYearsNetContribution];    
}


#pragma mark - net cumulative


- (NSNumber*)netCumulativeForMonthNumber:(NSUInteger)monthNumber
{
    double netCumulative = 0;
    for (ThemeFinancialAnalysisCalculationStrategy *strategy in themeCalculationStrategies_) {
        netCumulative += [[strategy netCumulativeForMonthNumber:monthNumber] doubleValue];
    }
    
    return [NSNumber numberWithDouble:netCumulative];    
}

- (NSNumber*)netCumulativeForYear:(NSInteger)year
{
    double firstYearNetCumulative = 0;
    for (ThemeFinancialAnalysisCalculationStrategy *strategy in themeCalculationStrategies_) {
        firstYearNetCumulative += [[strategy netCumulativeForYear:year] doubleValue];
    }
    
    return [NSNumber numberWithDouble:firstYearNetCumulative];    
}

- (NSNumber*)netCumulativeForYearsAfter:(NSInteger)year
{
    double subsYearsNetCumulative = 0;
    for (ThemeFinancialAnalysisCalculationStrategy *strategy in themeCalculationStrategies_) {
        subsYearsNetCumulative += [[strategy netCumulativeForYearsAfter:year] doubleValue];
    }
    
    return [NSNumber numberWithDouble:subsYearsNetCumulative];    
}

@end

