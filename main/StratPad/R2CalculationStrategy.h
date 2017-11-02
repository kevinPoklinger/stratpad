//
//  R2CalculationStrategy.h
//  StratPad
//
//  Created by Eric Rogers on August 26, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "R2CalculationStrategy.h"
#import "StratFile.h"

@interface R2CalculationStrategy : NSObject {
        
    NSDate *reportStartDate_;
    
    // Array of calculation strategies, each corresponding to a theme.
    NSMutableArray *themeCalculationStrategies_;    
}

@property(nonatomic, readonly) NSDate *reportStartDate;

- (id)initWithStratFile:(StratFile*)stratFile andIsOptimistic:(BOOL)optimistic;

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

- (NSNumber*)changeInSamForMonthNumber:(NSUInteger)monthNumber;
// 0-based year
- (NSNumber*)changeInSamForYear:(NSInteger)year;
- (NSNumber*)changeInSamForYearsAfter:(NSInteger)year;

- (NSNumber*)totalChangeInExpensesForMonthNumber:(NSUInteger)monthNumber;
// 0-based year
- (NSNumber*)totalChangeInExpensesForYear:(NSInteger)year;
- (NSNumber*)totalChangeInExpensesForYearsAfter:(NSInteger)year;

- (NSNumber*)netContributionForMonthNumber:(NSUInteger)monthNumber;
// 0-based year
- (NSNumber*)netContributionForYear:(NSInteger)year;
- (NSNumber*)netContributionForYearsAfter:(NSInteger)year;

- (NSNumber*)netCumulativeForMonthNumber:(NSUInteger)monthNumber;
// 0-based year
- (NSNumber*)netCumulativeForYear:(NSInteger)year;
- (NSNumber*)netCumulativeForYearsAfter:(NSInteger)year;

@end
