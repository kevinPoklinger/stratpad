//
//  Responsible.m
//  StratPad
//
//  Created by Eric on 11-09-07.
//  Copyright (c) 2011 Glassey Strategy. All rights reserved.
//

#import "Responsible.h"
#import "Activity.h"
#import "StratFile.h"
#import "Theme.h"
#import "DataManager.h"


@implementation Responsible
@dynamic summary;
@dynamic stratFile;
@dynamic activities;
@dynamic themes;

#pragma mark - Convenience

+ (Responsible*)responsibleWithSummary:(NSString*)summary forStratFile:(StratFile*)stratFile
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"summary=%@ && stratFile=%@",summary, stratFile];    
    return (Responsible*)[DataManager objectForEntity:NSStringFromClass([Responsible class]) sortDescriptorsOrNil:nil predicateOrNil:predicate];
}


#pragma mark - Core Data

- (void)addActivitiesObject:(Activity *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"activities" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"activities"] addObject:value];
    [self didChangeValueForKey:@"activities" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeActivitiesObject:(Activity *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"activities" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"activities"] removeObject:value];
    [self didChangeValueForKey:@"activities" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addActivities:(NSSet *)value {    
    [self willChangeValueForKey:@"activities" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"activities"] unionSet:value];
    [self didChangeValueForKey:@"activities" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeActivities:(NSSet *)value {
    [self willChangeValueForKey:@"activities" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"activities"] minusSet:value];
    [self didChangeValueForKey:@"activities" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}


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


@end
