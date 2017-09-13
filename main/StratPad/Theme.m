//
//  Theme.m
//  StratPad
//
//  Created by Eric on 11-08-16.
//  Copyright (c) 2011 Glassey Strategy. All rights reserved.
//

#import "Theme.h"
#import "StratFile.h"
#import "Objective.h"
#import "NSCalendar+Expanded.h"
#import "NSDate-StratPad.h"
#import "Activity.h"
#import "Metric.h"


@implementation Theme
@dynamic mandatory;
@dynamic title;
@dynamic startDate;
@dynamic endDate;
@dynamic order;
@dynamic responsible;
@dynamic stratFile;
@dynamic objectives;
@dynamic enhanceCustomerValue;
@dynamic enhanceUniqueness;

@dynamic revenueOneTime;
@dynamic revenueMonthly;
@dynamic revenueQuarterly;
@dynamic revenueAnnually;

@dynamic generalAndAdminOneTime;
@dynamic generalAndAdminMonthly;
@dynamic generalAndAdminQuarterly;
@dynamic generalAndAdminAnnually;

@dynamic researchAndDevelopmentOneTime;
@dynamic researchAndDevelopmentMonthly;
@dynamic researchAndDevelopmentQuarterly;
@dynamic researchAndDevelopmentAnnually;

@dynamic cogsOneTime;
@dynamic cogsMonthly;
@dynamic cogsQuarterly;
@dynamic cogsAnnually;

@dynamic cogsAnnuallyAdjustment;
@dynamic cogsMonthlyAdjustment;
@dynamic cogsQuarterlyAdjustment;
@dynamic generalAndAdminAnnuallyAdjustment;
@dynamic generalAndAdminMonthlyAdjustment;
@dynamic generalAndAdminQuarterlyAdjustment;
@dynamic researchAndDevelopmentAnnuallyAdjustment;
@dynamic researchAndDevelopmentMonthlyAdjustment;
@dynamic researchAndDevelopmentQuarterlyAdjustment;
@dynamic revenueAnnuallyAdjustment;
@dynamic revenueMonthlyAdjustment;
@dynamic revenueQuarterlyAdjustment;

@dynamic salesAndMarketingMonthly;
@dynamic salesAndMarketingQuarterly;
@dynamic salesAndMarketingAnnually;
@dynamic salesAndMarketingOneTime;

@dynamic salesAndMarketingAnnuallyAdjustment;
@dynamic salesAndMarketingMonthlyAdjustment;
@dynamic salesAndMarketingQuarterlyAdjustment;

@dynamic numberOfEmployeesAtThemeStart;
@dynamic numberOfEmployeesAtThemeEnd;

@dynamic percentCogsIsPayroll;
@dynamic percentResearchAndDevelopmentIsPayroll;
@dynamic percentGeneralAndAdminIsPayroll;
@dynamic percentSalesAndMarketingIsPayroll;


#pragma mark - Convenience

- (NSMutableArray*)objectivesSortedByOrder
{
    return [Theme objectivesSortedByOrder:self.objectives];
}

- (NSMutableArray*)objectivesSortedByActivityAndMetricDates
{
    NSMutableArray *objectives = [NSMutableArray array];
    [objectives addObjectsFromArray:[self.objectives allObjects]];
    [objectives sortUsingComparator:^NSComparisonResult(id o1, id o2) {
        Objective *obj1 = (Objective*)o1;
        Objective *obj2 = (Objective*)o2;
        
        // objectives have metrics and activities
        // metrics potentially have a target date
        // activities potentially have a start and an end date
        // we want to grab the earliest date out of all of these
        // if none exist, put it at the end
        
        NSDate *date1 = [obj1 earliestDate];
        NSDate *date2 = [obj2 earliestDate];
        
        return [date1 compare:date2];
    }];
    return objectives;
}

+ (NSMutableArray*)objectivesSortedByOrder:(NSSet*)objectives
{
    if (!objectives) {
        return [NSMutableArray array];
    }
    
    NSSortDescriptor *categoryDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"objectiveType.category" ascending:YES];
    NSSortDescriptor *orderDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
    
    NSArray *sortedObjectives = [objectives sortedArrayUsingDescriptors:[NSArray arrayWithObjects:categoryDescriptor, orderDescriptor, nil]];
    
    return [NSMutableArray arrayWithArray:sortedObjectives];    
}

+ (NSArray*)objectivesFilteredByCategory:(ObjectiveCategory)objectiveCategory objectives:(NSArray*)objectives
{
    NSSet *set = [NSSet setWithArray:objectives];
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        BOOL doesCategoryMatch = [[[(Objective*)evaluatedObject objectiveType] category] intValue] == objectiveCategory;
        BOOL isInUnion = [set containsObject:evaluatedObject];
        return doesCategoryMatch && isInUnion;
    }];
    NSSortDescriptor *sorDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
    return [[objectives filteredArrayUsingPredicate:predicate] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sorDescriptor]];
}

- (NSUInteger)themeWidth
{
    return [Theme themeWidth:self.objectives];
}

+ (NSUInteger)themeWidth:(NSSet*)objectives
{
    // max number of objectives of one particular type
    
    // dict of objectiveCategory -> ct
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:kNumberOfObectiveCategories];
    for (Objective *objective in objectives) {
        NSNumber *objectiveCategory = [[objective objectiveType] category];
        NSNumber *ct = [dict objectForKey:objectiveCategory];
        if (ct == nil) {
            ct = [NSNumber numberWithInt:1];
        } else {
            ct = [NSNumber numberWithInt:[ct intValue] + 1];                
        }
        [dict setObject:ct forKey:objectiveCategory];
    }
    
    // determine highest count
    NSUInteger themeWidth = 0;
    NSArray *cts = [dict allValues];
    for (NSNumber *ct in cts) {
        themeWidth = MAX(themeWidth, [ct intValue]);
    }
        
    // normalize to at least 2
    return MAX(2,themeWidth);    
}

- (NSDate*)normalizedStartDate
{
    if (self.startDate) {
        return self.startDate;
    } else {
        return [self.stratFile strategyStartDate];
    }
}

- (NSDate*)normalizedEndDate
{
    if (self.endDate) {
        return self.endDate;
    } else {
        return [self.stratFile strategyEndDate];
    }
}

- (NSUInteger)durationInMonths
{
    NSCalendar *calendar = [NSCalendar cachedGregorianCalendar];    
    
    NSDate *normalizedStartDate = [NSDate dateSetToFirstDayOfMonthForDate:[self normalizedStartDate]];
    
    NSDate *normalizedEndDate = [NSDate dateSetToFirstDayOfNextMonthForDate:[self normalizedEndDate]];
    
    // sometimes we have an end date in the past, and no start date (so it uses the current date)
    if ([normalizedStartDate isAfter:normalizedEndDate]) {
        return 1;
    }
    
    NSDateComponents *comps = [calendar components:NSMonthCalendarUnit 
                                          fromDate:normalizedStartDate
                                            toDate:normalizedEndDate
                                           options:0]; 
    NSInteger month = [comps month];
    
    return month;
}

- (NSUInteger)numberOfMonthsFromStrategyStart
{
    unsigned comparisonFlags = NSMonthCalendarUnit;
    NSCalendar *calendar = [NSCalendar cachedGregorianCalendar];    
    
    NSDate *normalizedStrategyStartDate = [NSDate dateSetToFirstDayOfMonthForDate:[[self stratFile] strategyStartDate]];    
    NSDate *normalizedThemeStartDate = [NSDate dateSetToFirstDayOfMonthForDate:[self normalizedStartDate]];
    
    NSDateComponents *comps = [calendar components:comparisonFlags 
                                          fromDate:normalizedStrategyStartDate
                                            toDate:normalizedThemeStartDate
                                           options:0]; 
    
    return [comps month];        
}

#pragma mark - Core Data

- (void)addObjectivesObject:(NSManagedObject *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"objectives" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"objectives"] addObject:value];
    [self didChangeValueForKey:@"objectives" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeObjectivesObject:(NSManagedObject *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"objectives" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"objectives"] removeObject:value];
    [self didChangeValueForKey:@"objectives" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addObjectives:(NSSet *)value {    
    [self willChangeValueForKey:@"objectives" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"objectives"] unionSet:value];
    [self didChangeValueForKey:@"objectives" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeObjectives:(NSSet *)value {
    [self willChangeValueForKey:@"objectives" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"objectives"] minusSet:value];
    [self didChangeValueForKey:@"objectives" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}

@end
