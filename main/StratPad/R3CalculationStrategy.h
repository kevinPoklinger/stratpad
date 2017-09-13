//
//  R3CalculationStrategy.h
//  StratPad
//
//  Created by Eric Rogers on August 29, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "StratFile.h"

@interface R3CalculationStrategy : NSObject {
 @private

    NSArray *themes_;
    
    // Array of calculation strategies, each corresponding to a theme.
    NSMutableArray *themeCalculationStrategies_;    
}

@property(nonatomic, readonly) NSArray *themes;

- (id)initWithStratFile:(StratFile*)stratFile andIsOptimistic:(BOOL)optimistic;

- (NSNumber*)changeInRevenueForThemeNumber:(NSUInteger)themeNumber year:(NSUInteger)year;
- (NSNumber*)changeInRevenueForYear:(NSUInteger)year;
- (NSNumber*)changeInRevenueForYearsAfter:(NSUInteger)year;

- (NSNumber*)changeInCOGSForThemeNumber:(NSUInteger)themeNumber year:(NSUInteger)year;
- (NSNumber*)changeInCOGSForYear:(NSUInteger)year;
- (NSNumber*)changeInCOGSForYearsAfter:(NSUInteger)year;

- (NSNumber*)changeInGrossMarginForThemeNumber:(NSUInteger)themeNumber year:(NSUInteger)year;
- (NSNumber*)totalChangeInGrossMarginForYear:(NSUInteger)year;
- (NSNumber*)totalChangeInGrossMarginForYearsAfter:(NSUInteger)year;

- (NSNumber*)changeInRadForThemeNumber:(NSUInteger)themeNumber year:(NSUInteger)year;
- (NSNumber*)changeInRadForYear:(NSUInteger)year;
- (NSNumber*)changeInRadForYearsAfter:(NSUInteger)year;

- (NSNumber*)changeInGaaForThemeNumber:(NSUInteger)themeNumber year:(NSUInteger)year;
- (NSNumber*)changeInGaaForYear:(NSUInteger)year;
- (NSNumber*)changeInGaaForYearsAfter:(NSUInteger)year;

- (NSNumber*)changeInSamForThemeNumber:(NSUInteger)themeNumber year:(NSUInteger)year;
- (NSNumber*)changeInSamForYear:(NSUInteger)year;
- (NSNumber*)changeInSamForYearsAfter:(NSUInteger)year;

- (NSNumber*)totalChangeInExpensesForThemeNumber:(NSUInteger)themeNumber year:(NSUInteger)year;
- (NSNumber*)totalChangeInExpensesForYear:(NSUInteger)year;
- (NSNumber*)totalChangeInExpensesForYearsAfter:(NSUInteger)year;

- (NSNumber*)netContributionForThemeNumber:(NSUInteger)themeNumber year:(NSUInteger)year;
- (NSNumber*)netContributionForYear:(NSUInteger)year;
- (NSNumber*)netContributionForYearsAfter:(NSUInteger)year;

- (NSNumber*)netCumulativeForThemeNumber:(NSUInteger)themeNumber year:(NSUInteger)year;
- (NSNumber*)netCumulativeForYear:(NSUInteger)year;
- (NSNumber*)netCumulativeForYearsAfter:(NSUInteger)year;

@end
