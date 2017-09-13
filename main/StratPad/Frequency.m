//
//  Frequency.m
//  StratPad
//
//  Created by Eric on 11-09-13.
//  Copyright (c) 2011 Glassey Strategy. All rights reserved.
//

#import "Frequency.h"
#import "Activity.h"
#import "Objective.h"
#import "DataManager.h"

@implementation Frequency

@dynamic order;
@dynamic category;
@dynamic activity;
@dynamic objectives;


#pragma mark - Convenience

+ (NSArray*)frequenciesSortedByOrder
{
    NSSortDescriptor *orderSort = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects: orderSort, nil];    
    NSArray *result = [DataManager arrayForEntity:NSStringFromClass([Frequency class]) sortDescriptorsOrNil:sortDescriptors];
    [orderSort release];
    return result;    
}

+ (Frequency*)frequencyForCategory:(FrequencyCategory)category
{
    NSArray *frequencies = [DataManager mutableArrayForEntity:NSStringFromClass([Frequency class])];
    
    for (Frequency *frequency in frequencies) {
        if ([frequency categoryRaw] == category) {
            return frequency;                             
        }
    }
    return nil;
}

- (NSString*)nameForCurrentLocale
{
    NSString *key = [NSString stringWithFormat:@"FREQUENCY_%i", self.category.integerValue];
    return LocalizedString(key, nil);    
}

- (NSString*)abbreviationForCurrentLocale
{
    NSString *key = [NSString stringWithFormat:@"FREQUENCY_ABBREVIATION_%i", self.category.integerValue];
    return LocalizedString(key, nil);
}

- (FrequencyCategory)categoryRaw 
{
    return (FrequencyCategory)[[self category] intValue];
}

- (void)setCategoryRaw:(FrequencyCategory)category
{
    [self setCategory:[NSNumber numberWithInt:category]];
}

+ (NSSet *)keyPathsForValuesAffectingCategoryRaw 
{
    return [NSSet setWithObject:@"category"];
}


#pragma  mark - Core Data

- (void)addActivityObject:(Activity *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"activity" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"activity"] addObject:value];
    [self didChangeValueForKey:@"activity" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeActivityObject:(Activity *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"activity" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"activity"] removeObject:value];
    [self didChangeValueForKey:@"activity" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addActivity:(NSSet *)value {    
    [self willChangeValueForKey:@"activity" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"activity"] unionSet:value];
    [self didChangeValueForKey:@"activity" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeActivity:(NSSet *)value {
    [self willChangeValueForKey:@"activity" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"activity"] minusSet:value];
    [self didChangeValueForKey:@"activity" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}


- (void)addObjectivesObject:(Objective *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"objectives" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"objectives"] addObject:value];
    [self didChangeValueForKey:@"objectives" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeObjectivesObject:(Objective *)value {
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
