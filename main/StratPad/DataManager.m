//
//  DataManager.m
//  StratPad
//
//  Created by Eric Rogers on August 16, 2010.
//  Copyright 2010 Mobilesce Inc. All rights reserved.
//

#import "DataManager.h"
#import "AppDelegate.h"
#import "BootStrapper.h"

@implementation DataManager

+ (void)initialize
{
    // the first time we use DataManager, we'll bootstrap; should be after didFinishLaunchingWithOptions
    DLog(@"Initing DataManager");
    BootStrapper *bootStrapper = [[BootStrapper alloc] init];
    [bootStrapper bootstrap];
    [bootStrapper release];
}

+ (NSArray*)arrayForEntity:(NSString*)entityName sortDescriptorsOrNil:(NSArray*)sortDescriptors 
{
	NSManagedObjectContext *managedObjectContext = [(AppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];

	if (sortDescriptors) {
		[request setSortDescriptors:sortDescriptors];
	}
	
	NSError *error;
	NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
	if (results == nil) {
		// Handle the error.
		ELog(@"Unable to retrieve entities for: %@.", entityName);
	}
	[request release];
	
	return results;		
}

+ (NSArray*)arrayForEntity:(NSString*)entityName sortDescriptorsOrNil:(NSArray*)sortDescriptors predicateOrNil:(NSPredicate*)predicate
{
	NSManagedObjectContext *managedObjectContext = [(AppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
	
	if (sortDescriptors) {
		[request setSortDescriptors:sortDescriptors];
	}
	
	if (predicate) {
		[request setPredicate:predicate];
	}
	
	NSError *error;
	NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
	if (results == nil) {
		// Handle the error.
		ELog(@"Unable to retrieve entities for: %@.", entityName);
	}
	[request release];
	
	return results;	
}

+ (NSUInteger)countForEntity:(NSString*)entityName predicateOrNil:(NSPredicate*)predicate
{
	NSManagedObjectContext *managedObjectContext = [(AppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
		
	if (predicate) {
		[request setPredicate:predicate];
	}
	
	NSError *error;
	NSUInteger results = [managedObjectContext countForFetchRequest:request error:&error];
	if (results == NSNotFound) {
		// Handle the error.
		ELog(@"Unable to count entities for: %@. %@", entityName, error);
        results = 0;
	}
	[request release];
	
	return results;	
}

+ (NSObject*)objectForEntity:(NSString*)entityName sortDescriptorsOrNil:(NSArray*)sortDescriptors predicateOrNil:(NSPredicate*)predicate
{
    NSManagedObjectContext *managedObjectContext = [(AppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
    [request setFetchLimit:1];
	
	if (sortDescriptors) {
		[request setSortDescriptors:sortDescriptors];
	}
	
	if (predicate) {
		[request setPredicate:predicate];
	}
	
	NSError *error;
	NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
	[request release];
	if (results == nil) {
		// Handle the error.
		ELog(@"Unable to retrieve entities for: %@.", entityName);
	}
    if ([results count] == 0) {
        return nil;
    } else {
        return [results objectAtIndex:0];
    }
}


+ (NSMutableArray *)mutableArrayForEntity:(NSString*)entityName 
{
	NSManagedObjectContext *managedObjectContext = [(AppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
	
	NSError *error;
	NSMutableArray *mutableResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
	if (mutableResults == nil) {
		// Handle the error.
		ELog(@"Unable to retrieve entities for: %@.", entityName);
	}
	[request release];
	
	return [mutableResults autorelease];	
}

+ (BOOL)saveManagedInstances 
{
	BOOL success = YES;
	NSManagedObjectContext *managedObjectContext = [(AppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
	NSError *error;
	if (![managedObjectContext save:&error]) {
		
		success = NO;
		
		// Handle the error.
		ELog(@"Failed to save to data store: %@", [error localizedDescription]);
		NSArray* detailedErrors = [[error userInfo] objectForKey:NSDetailedErrorsKey];
		if(detailedErrors != nil && [detailedErrors count] > 0) {
			for(NSError* detailedError in detailedErrors) {
				ELog(@"  DetailedError: %@", [detailedError userInfo]);
			}
		}
		else {
			ELog(@"UserInfo: %@", [error userInfo]);
		}					
	}	
	return success;
}

+ (void)rollback 
{
	NSManagedObjectContext *managedObjectContext = [(AppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
	[managedObjectContext rollback];
}

+ (void)deleteManagedInstance:(NSManagedObject *)obj 
{
    if (!obj) return;
	NSManagedObjectContext *managedObjectContext = [(AppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
	[managedObjectContext deleteObject:obj];
	[self saveManagedInstances];
}   

+ (void)refreshManagedInstance:(NSManagedObject *)obj 
{
	NSManagedObjectContext *managedObjectContext = [(AppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
	[managedObjectContext refreshObject: obj mergeChanges: YES];	
}

+ (NSManagedObject*)createManagedInstance:(NSString *)entityName 
{
	NSManagedObjectContext *managedObjectContext = [(AppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
	return [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:managedObjectContext];
}

+ (NSNumber *)aggregateOperation:(NSString *)function 
					 onAttribute:(NSString *)attributeName 
				   withPredicate:(NSPredicate *)predicate 
					   forEntity:(NSString*)entityName
{
	NSManagedObjectContext *managedObjectContext = [(AppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];

	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *theEntity = [NSEntityDescription entityForName:entityName inManagedObjectContext:managedObjectContext];
	[request setEntity:theEntity];
	[request setResultType:NSDictionaryResultType];      
	
	// Create an expression for the key path.
	NSExpression *theKeyPathExpression = [NSExpression expressionForKeyPath:attributeName];
	NSExpression *theMaxExpression = [NSExpression expressionForFunction:function 
															   arguments:[NSArray arrayWithObject:theKeyPathExpression]
									  ];
	
	// Create an expression description using the theMaxExpression and returning a Number.
	NSExpressionDescription *theExpressionDescription = [[NSExpressionDescription alloc] init];
	[theExpressionDescription setName:@"results"];
	[theExpressionDescription setExpression:theMaxExpression];
	[theExpressionDescription setExpressionResultType:NSInteger16AttributeType];
	[request setPropertiesToFetch:[NSArray arrayWithObject:theExpressionDescription]];
	[theExpressionDescription release];
	
	if (predicate != nil)
        [request setPredicate:predicate];
	
	// Execute the fetch.
	NSError *theError;
	NSArray *theResultsArray = [managedObjectContext executeFetchRequest:request error:&theError];
	[request release];
	
	if (theResultsArray == nil) {
		ELog(@"Unable to aggregate entities for: %@.", entityName);
	} else {
		if ([theResultsArray count] > 0) {
			return [[theResultsArray objectAtIndex:0] objectForKey:@"results"];
		}
	}
	return 0;
}

@end
