//
//  ThemeFinancialAnalysisCalculationStrategy.h
//  StratPad
//
//  Created by Eric Rogers on August 29, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//
//  Calculates the first two years of financial benefits for 
//  implementing a theme, relative to the strategy start
//  date for that theme.

#import "ThemeRevenueCalculator.h"
#import "ThemeCOGSCalculator.h"
#import "ThemeRADCalculator.h"
#import "ThemeGAACalculator.h"
#import "ThemeSAMCalculator.h"

@interface ThemeFinancialAnalysisCalculationStrategy : NSObject {
@private        
    
    NSUInteger themeDurationInMonths_;
    
    NSDate *calculationStartDate_;    
    
    // we'll calculate for up to 60 months, before leaving everything in subsequent years column
    NSUInteger calculationDurationInMonths_;
    
    // the offset in months from the strategy start to the start of the theme.
    // since we only store the actual values for the duration of the theme, and the strategy may start much earlier
    // so those values would be zero by definition
    NSUInteger themeOffset_;
    
    // calculators used to calculate the revenue, COGS, expense, and cost
    // benefits of implementing the theme.
    ThemeRevenueCalculator *revenueCalculator_;
    ThemeCOGSCalculator *cogsCalculator_;
    ThemeRADCalculator *radCalculator_;
    ThemeGAACalculator *gaaCalculator_;
    ThemeSAMCalculator *samCalculator_;
    
    // calculators used to calculate the contribution of activities 
    // in the theme.
    NSMutableArray *activityCalculators_;
}

// will return the strategy start date if relative to strategy start, otherwise
// returns the start date of the theme.
@property(nonatomic, readonly) NSDate *calculationStartDate;

// returns the number of months that this strategy calculates from the strategy start date.
@property(nonatomic, readonly) NSUInteger calculationDurationInMonths;

- (id)initWithTheme:(Theme*)theme isOptimistic:(BOOL)optimistic isRelativeToStrategyStart:(BOOL)relativeToStrategyStart;

- (NSNumber*)changeInRevenueForMonthNumber:(NSUInteger)monthNumber;
// 0-based year
- (NSNumber*)changeInRevenueForYear:(NSInteger)year;
- (NSNumber*)changeInRevenueForYearsAfter:(NSInteger)year;

- (NSNumber*)changeInCOGSForMonthNumber:(NSUInteger)monthNumber;
// 0-based year
- (NSNumber*)changeInCOGSForYear:(NSInteger)year;
- (NSNumber*)changeInCOGSForYearsAfter:(NSInteger)year;

- (NSNumber*)totalChangeInGrossMarginForMonthNumber:(NSUInteger)monthNumber;
// 0-based year
- (NSNumber*)totalChangeInGrossMarginForYear:(NSInteger)year;
- (NSNumber*)totalChangeInGrossMarginForYearsAfter:(NSInteger)year;

- (NSNumber*)changeInRadForMonthNumber:(NSUInteger)monthNumber;
// 0-based year
- (NSNumber*)changeInRadForYear:(NSInteger)year;
- (NSNumber*)changeInRadForYearsAfter:(NSInteger)year;

- (NSNumber*)changeInGaaForMonthNumber:(NSUInteger)monthNumber;
// 0-based year
- (NSNumber*)changeInGaaForYear:(NSInteger)year;
- (NSNumber*)changeInGaaForYearsAfter:(NSInteger)year;

- (NSNumber*)totalChangeInExpensesForMonthNumber:(NSUInteger)monthNumber;
// 0-based year
- (NSNumber*)totalChangeInExpensesForYear:(NSInteger)year;
- (NSNumber*)totalChangeInExpensesForYearsAfter:(NSInteger)year;

- (NSNumber*)changeInSamForMonthNumber:(NSUInteger)monthNumber;
// 0-based year
- (NSNumber*)changeInSamForYear:(NSInteger)year;
- (NSNumber*)changeInSamForYearsAfter:(NSInteger)year;


- (NSNumber*)netContributionForMonthNumber:(NSUInteger)monthNumber;
// 0-based year
- (NSNumber*)netContributionForYear:(NSInteger)year;
- (NSNumber*)netContributionForYearsAfter:(NSInteger)year;

- (NSNumber*)netCumulativeForMonthNumber:(NSUInteger)monthNumber;
// 0-based year
- (NSNumber*)netCumulativeForYear:(NSInteger)year;
- (NSNumber*)netCumulativeForYearsAfter:(NSInteger)year;

@end
