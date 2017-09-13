//
//  StratFile.m
//  StratPad
//
//  Created by Eric on 11-09-07.
//  Copyright (c) 2011 Glassey Strategy. All rights reserved.
//

#import "StratFile.h"
#import "Responsible.h"
#import "Theme.h"
#import "NSDate-StratPad.h"
#import "NSCalendar+Expanded.h"
#import "Chart.h"
#import "YammerPublishedReport.h"
#import "Financials.h"
#import "DataManager.h"
#import "NSString-Expanded.h"

@interface StratFile (Private)
+(uint) oct2Dec:(uint)oct;
@end

@implementation StratFile
@dynamic uuid;
@dynamic dateLastAccessed;
@dynamic industry;
@dynamic addressProblems;
@dynamic mediumTermStrategicGoal;
@dynamic competitorsDescription;
@dynamic keyProblems;
@dynamic dateCreated;
@dynamic businessModelDescription;
@dynamic expansionOptionsDescription;
@dynamic city;
@dynamic ultimateAspiration;
@dynamic dateModified;
@dynamic companyName;
@dynamic customersDescription;
@dynamic country;
@dynamic name;
@dynamic provinceState;
@dynamic themes;
@dynamic responsibles;
@dynamic permissions;
@dynamic model;
@dynamic yammerReports;
@dynamic financials;

- (void)awakeFromFetch
{
    // @since 1.6 - upgrades older stratfiles
    if (!self.financials) {
        self.financials = (Financials*)[DataManager createManagedInstance:NSStringFromClass([Financials class])];
    }
    
    // @since 1.6
    if (!self.uuid) {
        self.uuid = [NSString stringWithUUID];
    }
}

-(void)awakeFromInsert
{
    // when we make a brand new stratfile
    self.financials = (Financials*)[DataManager createManagedInstance:NSStringFromClass([Financials class])];
    self.uuid = [NSString stringWithUUID];
}

#pragma mark - Convenience

+(uint) oct2Dec:(uint)oct
{
    int n,r,s=0,i;
    n=oct;
    for(i=0;n!=0;i++)
    {
        r=n%10;
        s=s+r*(int)pow(8,i);
        n=n/10;
    }
    return s;
}

- (BOOL)isReadable:(UserType)userType
{
    // 0600 is 384 in decimal
    // 0600 & 0400 > 1 = owner-read
    // 384 & 256 > 1 = owner-read

    // 0400, 0040, 0004
    uint r = [StratFile oct2Dec:4*userType];
    uint perms = [StratFile oct2Dec:[self.permissions intValue]];
    uint readable = r & perms;
    return readable > 0;    
}

- (BOOL)isWritable:(UserType)userType
{
    uint w = [StratFile oct2Dec:2*userType];
    uint perms = [StratFile oct2Dec:[self.permissions intValue]];
    uint writable = w & perms;
    return writable > 0;    
}

- (NSMutableArray*)themesSortedByOrder
{
    if (!self.themes) {
        return [NSMutableArray array];
    }

    // ensure the array of themes is sorted by order.
    NSSortDescriptor *orderSort = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    NSArray *sortDescriptorArray = [NSArray arrayWithObjects: orderSort, nil];
    
    NSMutableArray *sortedThemes = [NSMutableArray arrayWithArray:[self.themes sortedArrayUsingDescriptors:sortDescriptorArray]];
    [orderSort release];
    return sortedThemes;
}

- (NSArray*)themesSortedByStartDate
{
    if (!self.themes) {
        return [NSMutableArray array];
    }

    // nil startdates ordered first
    NSSortDescriptor *orderSort = [[NSSortDescriptor alloc] initWithKey:@"startDate" ascending:YES];
    NSArray *sortDescriptorArray = [NSArray arrayWithObjects: orderSort, nil];
    
    NSArray *sortedThemes = [NSMutableArray arrayWithArray:[self.themes sortedArrayUsingDescriptors:sortDescriptorArray]];
    [orderSort release];
    return sortedThemes;
}

- (NSDate*)dateOfEarliestThemeOrToday
{
//    // this algo looks at all theme dates and gives us back the earliest one, or if no dates then today
//    // previously it only looked at theme start dates
//    NSDate *now = [NSDate dateWithZeroedTime];
//    if (self.themes.count == 0) {
//        return now;
//    }
//    else {
//        NSMutableArray *dates = [[NSMutableArray alloc] initWithCapacity:10];
//        for (Theme *theme in self.themes) {
//            if (theme.startDate) [dates addObject:theme.startDate];
//            if (theme.endDate) [dates addObject:theme.endDate];
//        }
//        if (dates.count == 0) {
//            return now;
//        }
//        [dates sortUsingComparator:^NSComparisonResult(NSDate *date1, NSDate *date2) {
//            return [date1 compare:date2];
//        }];
//        return [dates objectAtIndex:0];
//    }
    
    
    
    NSArray *sortedThemes = [self themesSortedByStartDate];
    
    NSDate *now = [NSDate dateWithZeroedTime];

    if (sortedThemes.count == 0) {
        return now;
    } else {
        Theme *firstTheme = ((Theme*)[sortedThemes objectAtIndex:0]);        
        
        if (firstTheme.startDate == nil) {
            // the next theme could easily have a startDate earlier than today
            for (Theme *theme in sortedThemes) {
                if (theme.startDate != nil) {
                    return [theme.startDate compare:now] == NSOrderedAscending ? theme.startDate : now;
                }
            }
            return now;
        } else {
            return firstTheme.startDate;
        }
    }
}

- (NSDate*)strategyStartDate
{
    return [self dateOfEarliestThemeOrToday];
}

- (NSDate*)strategyEndDate
{
    // latest theme date
    NSSortDescriptor *orderSort = [[NSSortDescriptor alloc] initWithKey:@"endDate" ascending:YES];
    NSArray *sortDescriptorArray = [NSArray arrayWithObjects: orderSort, nil];
    
    NSArray *sortedThemes = [NSMutableArray arrayWithArray:[self.themes sortedArrayUsingDescriptors:sortDescriptorArray]];
    [orderSort release];
    
    if ([sortedThemes count] > 0) 
    {
        NSDate *startDate = [self strategyStartDate];
        NSDate *endDate = [[sortedThemes lastObject] endDate];
        if (endDate) {
            // it has to be at least 1 month greater than startDate
            if ([endDate isBeforeOrEqual:startDate]) {
                NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];
                NSDateComponents *comps = [[NSDateComponents alloc] init];
                [comps setMonth:1];            
                endDate = [gregorian dateByAddingComponents:comps toDate:startDate options:0];
                [comps release];
            }
        } else {
            // they must have all been nil, so strategyStartDate+strategyDurationInYearsWhenNotDefined years
            NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];
            NSDateComponents *comps = [[NSDateComponents alloc] init];
            [comps setYear:strategyDurationInYearsWhenNotDefined];            
            endDate = [gregorian dateByAddingComponents:comps toDate:startDate options:0];
            [comps release];
        }
        
        // there's a possibility that if the end dates were null, or even the latest one was early, there are theme start dates ahead of our proposed end date
        NSSortDescriptor *orderSort = [NSSortDescriptor sortDescriptorWithKey:@"startDate" ascending:YES];
        NSArray *sortedThemes = [NSMutableArray arrayWithArray:[self.themes sortedArrayUsingDescriptors:[NSArray arrayWithObject:orderSort]]];
        NSDate *lastStartDate = [[sortedThemes lastObject] startDate];
        if (lastStartDate && [endDate isBeforeOrEqual:lastStartDate]) {
            NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];
            NSDateComponents *comps = [[NSDateComponents alloc] init];
            [comps setMonth:1];            
            endDate = [gregorian dateByAddingComponents:comps toDate:lastStartDate options:0];
            [comps release];
        }

        return endDate;

    }
    else {
        NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];
        NSDateComponents *comps = [[NSDateComponents alloc] init];
        [comps setYear:strategyDurationInYearsWhenNotDefined];
        NSDate *endDate = [gregorian dateByAddingComponents:comps toDate:[NSDate date] options:0];
        [comps release];
        return endDate;
    }
    
}

- (NSUInteger)strategyDurationInYears
{
    // 1 page for every 12 months in the strategy
    NSDate *startDate = [self strategyStartDate];
    NSDate *endDate = [self strategyEndDate];
    
    NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];    
    NSDateComponents *components = [gregorian components:NSMonthCalendarUnit
                                                fromDate:startDate
                                                  toDate:endDate options:0];
    NSInteger months = [components month];
    NSInteger years = ceil(months/12.f);
    return MIN(years, strategyDurationInYearsWhenNotDefined);
}

- (NSUInteger)strategyDurationInMonths
{
    NSDate *startDate = [self strategyStartDate];
    NSDate *endDate = [self strategyEndDate];
    
    NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];    
    NSDateComponents *components = [gregorian components:NSMonthCalendarUnit | NSDayCalendarUnit
                                                fromDate:startDate
                                                  toDate:endDate options:0];
    return [components month] + ([components day] > 0 ? 1 : 0);
}

-(BOOL)isPublishedToYammer:(NSString*)chapterNumber pageNumber:(NSUInteger)pageNumber;
{
    if ([chapterNumber isEqualToString:@"S1"]) {
        // special case - if the yamReport.chapterNumber is S1 and there is no yamReport.chart and the pageNumber is 0, then YES
        if (pageNumber == 0) {
            return [self isStratCardPublishedToYammer];
        } else {
            Chart *chart = [Chart chartAtPage:pageNumber stratFile:self];
            return [self isChartPublishedToYammer:chart];            
        }
    }
    else {
        return [self isChapterPublishedToYammer:chapterNumber];
    }
}

-(BOOL)isStratCardPublishedToYammer
{
    for (YammerPublishedReport *yamReport in self.yammerReports) {
        if ([yamReport.chapterNumber isEqualToString:@"S1"] && yamReport.chart == nil) {
            return YES;
        }
    }
    return NO;
}

-(BOOL)isChapterPublishedToYammer:(NSString*)chapterNumber
{
    for (YammerPublishedReport *yamReport in self.yammerReports) {
        if ([yamReport.chapterNumber isEqualToString:chapterNumber]) {
            return YES;
        }
    }
    return NO;
}

-(BOOL)isChartPublishedToYammer:(Chart*)chart
{
    if (!chart) {
        return NO;
    }
    for (YammerPublishedReport *yamReport in self.yammerReports) {
        if ([yamReport.chapterNumber isEqualToString:@"S1"]) {
            if ([chart.uuid isEqualToString:yamReport.chart.uuid]) {
                return YES;
            }
        }
    }
    return NO;
}


#pragma mark - Core Data

- (void)addThemesObject:(Theme *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"themes" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"themes"] addObject:value];
    [self didChangeValueForKey:@"themes" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeThemesObject:(Theme *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"themes" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"themes"] removeObject:value];
    [self didChangeValueForKey:@"themes" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addThemes:(NSSet *)value {    
    [self willChangeValueForKey:@"themes" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"themes"] unionSet:value];
    [self didChangeValueForKey:@"themes" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeThemes:(NSSet *)value {
    [self willChangeValueForKey:@"themes" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"themes"] minusSet:value];
    [self didChangeValueForKey:@"themes" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}


- (void)addResponsiblesObject:(Responsible *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"responsibles" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"responsibles"] addObject:value];
    [self didChangeValueForKey:@"responsibles" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeResponsiblesObject:(Responsible *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"responsibles" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"responsibles"] removeObject:value];
    [self didChangeValueForKey:@"responsibles" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addResponsibles:(NSSet *)value {    
    [self willChangeValueForKey:@"responsibles" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"responsibles"] unionSet:value];
    [self didChangeValueForKey:@"responsibles" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeResponsibles:(NSSet *)value {
    [self willChangeValueForKey:@"responsibles" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"responsibles"] minusSet:value];
    [self didChangeValueForKey:@"responsibles" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}

@end
