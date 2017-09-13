//
//  Theme.h
//  StratPad
//
//  Created by Eric on 11-08-16.
//  Copyright (c) 2011 Glassey Strategy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ObjectiveType.h"

@class StratFile, Responsible;

@interface Theme : NSManagedObject 

// inverse relationships
@property (nonatomic, retain) StratFile * stratFile;

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * endDate;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSNumber * mandatory;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSNumber * enhanceUniqueness;
@property (nonatomic, retain) NSNumber * enhanceCustomerValue;
@property (nonatomic, retain) Responsible * responsible;
@property (nonatomic, retain) NSSet* objectives;

@property (nonatomic, retain) NSNumber * revenueMonthly;
@property (nonatomic, retain) NSNumber * revenueQuarterly;
@property (nonatomic, retain) NSNumber * revenueAnnually;
@property (nonatomic, retain) NSNumber * revenueOneTime;

@property (nonatomic, retain) NSNumber * cogsMonthly;
@property (nonatomic, retain) NSNumber * cogsQuarterly;
@property (nonatomic, retain) NSNumber * cogsAnnually;
@property (nonatomic, retain) NSNumber * cogsOneTime;

// move from expenses to R&D - 1.6
@property (nonatomic, retain) NSNumber * researchAndDevelopmentMonthly;
@property (nonatomic, retain) NSNumber * researchAndDevelopmentQuarterly;
@property (nonatomic, retain) NSNumber * researchAndDevelopmentAnnually;
@property (nonatomic, retain) NSNumber * researchAndDevelopmentOneTime;

// move from costs to G&A - 1.6
@property (nonatomic, retain) NSNumber * generalAndAdminMonthly;
@property (nonatomic, retain) NSNumber * generalAndAdminQuarterly;
@property (nonatomic, retain) NSNumber * generalAndAdminAnnually;
@property (nonatomic, retain) NSNumber * generalAndAdminOneTime;

// new - 1.6
@property (nonatomic, retain) NSNumber * salesAndMarketingMonthly;
@property (nonatomic, retain) NSNumber * salesAndMarketingQuarterly;
@property (nonatomic, retain) NSNumber * salesAndMarketingAnnually;
@property (nonatomic, retain) NSNumber * salesAndMarketingOneTime;




@property (nonatomic, retain) NSDecimalNumber * revenueAnnuallyAdjustment;
@property (nonatomic, retain) NSDecimalNumber * revenueMonthlyAdjustment;
@property (nonatomic, retain) NSDecimalNumber * revenueQuarterlyAdjustment;

@property (nonatomic, retain) NSDecimalNumber * cogsAnnuallyAdjustment;
@property (nonatomic, retain) NSDecimalNumber * cogsMonthlyAdjustment;
@property (nonatomic, retain) NSDecimalNumber * cogsQuarterlyAdjustment;

// move from expenses to R&D - 1.6
@property (nonatomic, retain) NSDecimalNumber * researchAndDevelopmentAnnuallyAdjustment;
@property (nonatomic, retain) NSDecimalNumber * researchAndDevelopmentMonthlyAdjustment;
@property (nonatomic, retain) NSDecimalNumber * researchAndDevelopmentQuarterlyAdjustment;

// move from costs to G&A - 1.6
@property (nonatomic, retain) NSDecimalNumber * generalAndAdminAnnuallyAdjustment;
@property (nonatomic, retain) NSDecimalNumber * generalAndAdminMonthlyAdjustment;
@property (nonatomic, retain) NSDecimalNumber * generalAndAdminQuarterlyAdjustment;

// new - 1.6
@property (nonatomic, retain) NSDecimalNumber * salesAndMarketingAnnuallyAdjustment;
@property (nonatomic, retain) NSDecimalNumber * salesAndMarketingMonthlyAdjustment;
@property (nonatomic, retain) NSDecimalNumber * salesAndMarketingQuarterlyAdjustment;

// new - 1.6
@property (nonatomic, retain) NSNumber * numberOfEmployeesAtThemeStart;
@property (nonatomic, retain) NSNumber * numberOfEmployeesAtThemeEnd;

// new - 1.6
// how much of each expense (including COGS but not revenue) is related to payroll
// we will not add an adjustment for these values
@property (nonatomic, retain) NSNumber * percentCogsIsPayroll;
@property (nonatomic, retain) NSNumber * percentResearchAndDevelopmentIsPayroll;
@property (nonatomic, retain) NSNumber * percentGeneralAndAdminIsPayroll;
@property (nonatomic, retain) NSNumber * percentSalesAndMarketingIsPayroll;


- (NSMutableArray*)objectivesSortedByOrder;
+ (NSMutableArray*)objectivesSortedByOrder:(NSSet*)objectives;

// look at each objective's activities and return the earliest start date
- (NSMutableArray*)objectivesSortedByActivityAndMetricDates;

// will take your ordered objectives and return the subset that matches the provided category
+ (NSArray*)objectivesFilteredByCategory:(ObjectiveCategory)objectiveCategory objectives:(NSArray*)objectives;

- (NSUInteger)themeWidth;
+ (NSUInteger)themeWidth:(NSSet*)objectives;

- (NSDate*)normalizedStartDate;
- (NSDate*)normalizedEndDate;

// returns the duration in months for the theme.
- (NSUInteger)durationInMonths;

// returns the number of months from the strategy start date to the theme
// start date.
- (NSUInteger)numberOfMonthsFromStrategyStart;

- (void)addObjectivesObject:(NSManagedObject *)value;
- (void)removeObjectivesObject:(NSManagedObject *)value;

- (void)addObjectives:(NSSet *)value;
- (void)removeObjectives:(NSSet *)value;

// - if a theme has no start date, then assume the first day of the stratfile
- (NSDate*)normalizedStartDate;

// - if a theme has no end date then assume the end date is 24 months from the start date    
- (NSDate*)normalizedEndDate;

@end
