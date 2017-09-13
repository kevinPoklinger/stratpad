//
//  ObjectiveType.m
//  StratPad
//
//  Created by Eric on 11-09-13.
//  Copyright (c) 2011 Glassey Strategy. All rights reserved.
//

#import "ObjectiveType.h"
#import "Objective.h"
#import "DataManager.h"

@implementation ObjectiveType
@dynamic order;
@dynamic category;
@dynamic objective;

NSUInteger const kNumberOfObectiveCategories = 6;


#pragma mark - Convenience

+ (NSArray*)objectiveTypesSortedByOrder
{
    NSSortDescriptor *orderSort = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects: orderSort, nil];    
    NSArray *result = [DataManager arrayForEntity:NSStringFromClass([ObjectiveType class]) sortDescriptorsOrNil:sortDescriptors];
    [orderSort release];
    return result;    
}

+ (ObjectiveType*)objectiveTypeForCategory:(ObjectiveCategory)category
{
    NSArray *objectiveTypes = [DataManager mutableArrayForEntity:NSStringFromClass([ObjectiveType class])];
    
    for (ObjectiveType *type in objectiveTypes) {
        if ([type categoryRaw] == category) {
            return type;                             
        }
    }
    WLog(@"No ObjectiveType for category!! %i", category);
    return nil;
}

- (NSString*)nameForCurrentLocale
{
    NSMutableString *key = [NSMutableString stringWithString:@"OBJECTIVE_TYPE_"];
    switch (self.category.intValue) {
        case ObjectiveCategoryFinancial:
            [key appendString:@"FINANCIAL"];
            break;
        case ObjectiveCategoryCustomer:
            [key appendString:@"CUSTOMER"];
            break;
        case ObjectiveCategoryProcess:
            [key appendString:@"PROCESS"];
            break;
        case ObjectiveCategoryStaff:
            [key appendString:@"STAFF"];
            break;
        case ObjectiveCategoryCommunity:
            [key appendString:@"COMMUNITY"];
            break;
        case ObjectiveCategoryFunder:
            [key appendString:@"FUNDER"];
            break;
        default:
            ELog(@"Unknown objective type: %i", self.category.intValue);
            break;
    }
    
    return LocalizedString(key, nil);    
}

- (ObjectiveCategory)categoryRaw 
{
    return (ObjectiveCategory)[[self category] intValue];
}

- (void)setCategoryRaw:(ObjectiveCategory)category
{
    [self setCategory:[NSNumber numberWithInt:category]];
}

+ (NSSet *)keyPathsForValuesAffectingCategoryRaw 
{
    return [NSSet setWithObject:@"category"];
}


#pragma mark - Core Data

- (void)addObjectiveObject:(Objective *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"objective" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"objective"] addObject:value];
    [self didChangeValueForKey:@"objective" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeObjectiveObject:(Objective *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"objective" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"objective"] removeObject:value];
    [self didChangeValueForKey:@"objective" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addObjective:(NSSet *)value {    
    [self willChangeValueForKey:@"objective" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"objective"] unionSet:value];
    [self didChangeValueForKey:@"objective" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeObjective:(NSSet *)value {
    [self willChangeValueForKey:@"objective" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"objective"] minusSet:value];
    [self didChangeValueForKey:@"objective" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}


@end
