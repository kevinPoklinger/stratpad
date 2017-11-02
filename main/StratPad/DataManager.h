//
//  DataManager.h
//  StratPad
//
//  Created by Eric Rogers on August 16, 2010.
//  Copyright 2010 Mobilesce Inc. All rights reserved.
//

@interface DataManager : NSObject {
}

+ (NSArray*)arrayForEntity:(NSString*)entityName sortDescriptorsOrNil:(NSArray*)sortDescriptors;
+ (NSArray*)arrayForEntity:(NSString*)entityName sortDescriptorsOrNil:(NSArray*)sortDescriptors predicateOrNil:(NSPredicate*)predicate;
+ (NSMutableArray *)mutableArrayForEntity:(NSString*)entityName;
+ (NSUInteger)countForEntity:(NSString*)entityName predicateOrNil:(NSPredicate*)predicate;
+ (NSManagedObject*)createManagedInstance:(NSString *)entityName;
+ (BOOL)saveManagedInstances;
+ (void)rollback;
+ (void)deleteManagedInstance:(NSManagedObject *)obj;
+ (void)refreshManagedInstance:(NSManagedObject *)obj;

// allows you to eg count: the number of results, without instantiating all the resultant objects
// see NSExpression for functions available
+ (NSNumber *)aggregateOperation:(NSString *)function 
					 onAttribute:(NSString *)attributeName 
				   withPredicate:(NSPredicate *)predicate 
					   forEntity:(NSString*)entityName;

/**
 * Grab the first object returned from a query.
 * @param   the entity type
 * @param   any sorting paramaters
 * @param   the predicate used to filter the query
 * @return  a single object or nil
 */
+ (NSObject*)objectForEntity:(NSString*)entityName sortDescriptorsOrNil:(NSArray*)sortDescriptors predicateOrNil:(NSPredicate*)predicate;

@end
