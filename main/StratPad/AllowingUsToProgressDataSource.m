//
//  AllowingUsToProgressDataSource.m
//  StratPad
//
//  Created by Eric Rogers on September 25, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "AllowingUsToProgressDataSource.h"
#import "NSDate-StratPad.h"
#import "Settings.h"
#import "DataManager.h"
#import "R2CalculationStrategy.h"

@interface AllowingUsToProgressDataSource ()
@end


@interface AllowingUsToProgressDataSource (Private)

- (void)calculateRevenueValuesUsingStrategy:(R2CalculationStrategy*)strategy;
- (void)calculateCOGSValuesUsingStrategy:(R2CalculationStrategy*)strategy;
- (void)calculateGrossMarginValuesUsingStrategy:(R2CalculationStrategy*)strategy;

- (void)calculateRadValuesUsingStrategy:(R2CalculationStrategy*)strategy;
- (void)calculateGaaValuesUsingStrategy:(R2CalculationStrategy*)strategy;
- (void)calculateSamValuesUsingStrategy:(R2CalculationStrategy*)strategy;
- (void)calculateTotalExpenseValuesUsingStrategy:(R2CalculationStrategy*)strategy;

- (void)calculateContributionValuesUsingStrategy:(R2CalculationStrategy*)strategy;
- (void)calculateCumulativeContributionValuesUsingStrategy:(R2CalculationStrategy*)strategy;

// returns YES if any values are either less than -99,000 or greater than 99,000.
- (BOOL)shouldDivideValuesByOneThousand;

// replaces all values with their value divided by 1,000.
- (void)divideValuesByOneThousand;

@end

@implementation AllowingUsToProgressDataSource

@synthesize columnDates = columnDates_;

@synthesize revenueValues = revenueValues_;
@synthesize cogsValues = cogsValues_;
@synthesize grossMarginValues = grossMarginValues_;

@synthesize radValues = radValues_;
@synthesize gaaValues = gaaValues_;
@synthesize samValues = samValues_;
@synthesize totalExpenseValues = totalExpenseValues_;

@synthesize contributionValues = contributionValues_;
@synthesize cumulativeContributionValues = cumulativeContributionValues_;

@synthesize significantDigitsTruncated = significantDigitsTruncated_;

- (id)init
{
    if ((self = [super init])) {
        self.orderedFinancialHeadings = [NSArray arrayWithObjects:
                                         [LocalizedString(@"REVENUE", nil) capitalizedString],
                                         LocalizedString(@"COGS", nil),
                                         LocalizedString(@"GROSS_PROFIT", nil),
                                         LocalizedString(@"RESEARCH_AND_DEVELOPMENT", nil),
                                         LocalizedString(@"GENERAL_AND_ADMINISTRATIVE", nil),
                                         LocalizedString(@"SALES_AND_MARKETING", nil),
                                         LocalizedString(@"TOTAL_EXPENSES", nil),
                                         LocalizedString(@"CONTRIBUTION", nil),
                                         LocalizedString(@"CUMULATIVE_CONTRIBUTION", nil),
                                         nil];        
    }
    return self;
}

- (id)initWithStratFile:(StratFile*)stratFile
{
    if ((self = [self init])) {

        NSUInteger duration = [stratFile strategyDurationInMonths];
        interval_ = [ChartDataSource columnIntervalForStrategyDuration:duration];
        
        columnDates_ = [[ChartDataSource calculateColumnStartDatesFromDate:[stratFile dateOfEarliestThemeOrToday] withIntervalInMonths:interval_] retain];
        
        Settings *settings = (Settings*)[DataManager objectForEntity:NSStringFromClass([Settings class]) sortDescriptorsOrNil:nil predicateOrNil:nil];        
        R2CalculationStrategy *calculationStrategy = [[R2CalculationStrategy alloc] initWithStratFile:stratFile andIsOptimistic:[settings.isCalculationOptimistic boolValue]];
        
        // calculate the values for each financial category
        [self calculateRevenueValuesUsingStrategy:calculationStrategy];
        [self calculateCOGSValuesUsingStrategy:calculationStrategy];
        [self calculateGrossMarginValuesUsingStrategy:calculationStrategy];
        
        [self calculateRadValuesUsingStrategy:calculationStrategy];
        [self calculateGaaValuesUsingStrategy:calculationStrategy];
        [self calculateSamValuesUsingStrategy:calculationStrategy];
        [self calculateTotalExpenseValuesUsingStrategy:calculationStrategy];
        
        [self calculateContributionValuesUsingStrategy:calculationStrategy];
        [self calculateCumulativeContributionValuesUsingStrategy:calculationStrategy];
        
        // check to see if we have any values greater than 99,000.  
        significantDigitsTruncated_ = [self shouldDivideValuesByOneThousand];        
        if (significantDigitsTruncated_) {
            [self divideValuesByOneThousand];
        }            
        
        [calculationStrategy release];
        
    }
    return self;
}

- (void)dealloc
{
    [columnDates_ release];
    [_orderedFinancialHeadings release];
    
    [revenueValues_ release];
    [cogsValues_ release];
    [grossMarginValues_ release];
    
    [radValues_ release];
    [gaaValues_ release];
    [samValues_ release];
    [totalExpenseValues_ release];
    
    [contributionValues_ release];
    [cumulativeContributionValues_ release];
    
    [super dealloc];
}

- (NSArray*)financialValuesForHeading:(NSString*)financialHeading
{
    // we need to do it each time, because we often change up the actual values array
    int idx = [_orderedFinancialHeadings indexOfObject:financialHeading];
    switch (idx) {
        case 0: return revenueValues_;
        case 1: return cogsValues_;
        case 2: return grossMarginValues_;
        case 3: return radValues_;
        case 4: return gaaValues_;
        case 5: return samValues_;
        case 6: return totalExpenseValues_;
        case 7: return contributionValues_;
        case 8: return cumulativeContributionValues_;
        default:
            ELog(@"Couldn't find financial heading:%@", financialHeading);
            return nil;
    }
    
}


- (void)calculateRevenueValuesUsingStrategy:(R2CalculationStrategy*)strategy
{
    revenueValues_ = [[NSMutableArray array] retain];
    double sum;
    
    for (NSUInteger i = 0; i < 8; i++) {
        sum = 0;
        
        for (NSUInteger j = 0; j < interval_; j++) {
            sum += [[strategy changeInRevenueForMonthNumber:(i*interval_)+j] doubleValue];
        }
        [revenueValues_ addObject:[NSNumber numberWithDouble:sum]];
    }
}

- (void)calculateCOGSValuesUsingStrategy:(R2CalculationStrategy*)strategy
{
    cogsValues_ = [[NSMutableArray array] retain];
    double sum;
    
    for (NSUInteger i = 0; i < 8; i++) {
        sum = 0;
        
        for (NSUInteger j = 0; j < interval_; j++) {
            sum += [[strategy changeInCOGSForMonthNumber:(i*interval_)+j] doubleValue];
        }
        [cogsValues_ addObject:[NSNumber numberWithDouble:sum]];
    }    
}

- (void)calculateGrossMarginValuesUsingStrategy:(R2CalculationStrategy*)strategy
{
    grossMarginValues_ = [[NSMutableArray array] retain];
    double sum;
    
    for (NSUInteger i = 0; i < 8; i++) {
        sum = 0;
        
        for (NSUInteger j = 0; j < interval_; j++) {
            sum += [[strategy totalChangeInGrossMarginForMonthNumber:(i*interval_)+j] doubleValue];
        }
        [grossMarginValues_ addObject:[NSNumber numberWithDouble:sum]];
    }    
}

- (void)calculateRadValuesUsingStrategy:(R2CalculationStrategy*)strategy
{
    radValues_ = [[NSMutableArray array] retain];
    double sum;
    
    for (NSUInteger i = 0; i < 8; i++) {
        sum = 0;
        
        for (NSUInteger j = 0; j < interval_; j++) {
            sum += [[strategy changeInRadForMonthNumber:(i*interval_)+j] doubleValue];
        }
        [radValues_ addObject:[NSNumber numberWithDouble:sum]];
    }        
}

- (void)calculateGaaValuesUsingStrategy:(R2CalculationStrategy*)strategy
{
    gaaValues_ = [[NSMutableArray array] retain];
    double sum;
    
    for (NSUInteger i = 0; i < 8; i++) {
        sum = 0;
        
        for (NSUInteger j = 0; j < interval_; j++) {
            sum += [[strategy changeInGaaForMonthNumber:(i*interval_)+j] doubleValue];
        }
        [gaaValues_ addObject:[NSNumber numberWithDouble:sum]];
    }            
}

- (void)calculateSamValuesUsingStrategy:(R2CalculationStrategy*)strategy
{
    samValues_ = [[NSMutableArray array] retain];
    double sum;
    
    for (NSUInteger i = 0; i < 8; i++) {
        sum = 0;
        
        for (NSUInteger j = 0; j < interval_; j++) {
            sum += [[strategy changeInSamForMonthNumber:(i*interval_)+j] doubleValue];
        }
        [samValues_ addObject:[NSNumber numberWithDouble:sum]];
    }
}



- (void)calculateTotalExpenseValuesUsingStrategy:(R2CalculationStrategy*)strategy
{
    totalExpenseValues_ = [[NSMutableArray array] retain];
    double sum;
    
    for (NSUInteger i = 0; i < 8; i++) {
        sum = 0;
        
        for (NSUInteger j = 0; j < interval_; j++) {
            sum += [[strategy totalChangeInExpensesForMonthNumber:(i*interval_)+j] doubleValue];
        }
        [totalExpenseValues_ addObject:[NSNumber numberWithDouble:sum]];
    }                
}

- (void)calculateContributionValuesUsingStrategy:(R2CalculationStrategy*)strategy
{
    contributionValues_ = [[NSMutableArray array] retain];
    double sum;
    
    for (NSUInteger i = 0; i < 8; i++) {
        sum = 0;
        
        for (NSUInteger j = 0; j < interval_; j++) {
            sum += [[strategy netContributionForMonthNumber:(i*interval_)+j] doubleValue];
        }
        [contributionValues_ addObject:[NSNumber numberWithDouble:sum]];
    }                    
}

- (void)calculateCumulativeContributionValuesUsingStrategy:(R2CalculationStrategy*)strategy
{
    cumulativeContributionValues_ = [[NSMutableArray array] retain];
    double cumulativeValue = 0;
    
    // since the cumulative contributions are already summed, we just need to include those at indexes
    // 2, 5, 8, ...
    for (NSUInteger i = 0; i < 8; i++) {
        cumulativeValue = [[strategy netCumulativeForMonthNumber:(i+1)*interval_-1] doubleValue];
        [cumulativeContributionValues_ addObject:[NSNumber numberWithDouble:cumulativeValue]];
    }                        
}

- (BOOL)shouldDivideValuesByOneThousand
{
    NSArray *allValues = [NSArray arrayWithObjects:
                          revenueValues_,
                          cogsValues_,
                          grossMarginValues_,
                          radValues_,
                          gaaValues_,
                          samValues_,
                          totalExpenseValues_,
                          contributionValues_,
                          cumulativeContributionValues_,
                          nil];
    double val;
    for (NSArray *values in allValues) {
        for (NSNumber *value in values) {
            val = [value doubleValue];
            if (val < -99999 || val > 99999) {
                return YES;
            }        
        }
    }
    
    return NO;    
}

- (void)divideValuesByOneThousand
{
    NSArray *allValues = [NSArray arrayWithObjects:
                          revenueValues_,
                          cogsValues_,
                          grossMarginValues_,
                          radValues_,
                          gaaValues_,
                          samValues_,
                          totalExpenseValues_,
                          contributionValues_,
                          cumulativeContributionValues_,
                          nil];
    
    double value;    
    for (NSMutableArray *values in allValues) {    
        for (uint i = 0; i < values.count; i++) {
            value = [[values objectAtIndex:i] doubleValue];
            [values replaceObjectAtIndex:i withObject:[NSNumber numberWithDouble:value/1000]];        
        }    
    }
}

@end

