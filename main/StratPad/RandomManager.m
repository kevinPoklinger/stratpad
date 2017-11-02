//
//  RandomManager.m
//  YouDidIt
//
//  Created by Julian Wood on 10-11-08.
//  Copyright 2010 Mobilesce Inc. All rights reserved.
//

#import "RandomManager.h"
#import "SynthesizeSingleton.h"

@implementation RandomManager

SYNTHESIZE_SINGLETON_FOR_CLASS(RandomManager);

- (id)init
{
	ILog(@"Initing RandomManager.");
	if (self != nil) {
		cache_ = [[NSMutableDictionary dictionaryWithCapacity:20] retain];
		return self;
	} else {
		ELog(@"Couldn't init RandomManager.");
		return nil;
	}
}

- (int)random:(NSString*)key numberOfObjects:(int)numberOfObjects
{
	// retrieve an array of indexes from cache, or add into cache
	NSMutableArray *cacheObjects = [cache_ objectForKey:key];
	if (cacheObjects == nil || [cacheObjects count] == 0) {
		cacheObjects = [self cachableIndexArray:numberOfObjects];
		[cache_ setObject:cacheObjects forKey:key];
	}
	
	// grab a random object
	int idx = arc4random()%[cacheObjects count];
	id obj = [cacheObjects objectAtIndex:idx];
	
	// remove object from cache
	[cacheObjects removeObjectAtIndex:idx];
	
	return [obj intValue];
}

- (NSMutableArray*)cachableIndexArray:(int)numberOfIndexes
{
	NSMutableArray *mary = [NSMutableArray arrayWithCapacity:numberOfIndexes];
	for (int i=0; i<numberOfIndexes; ++i) {
		[mary addObject:[NSNumber numberWithInt:i]];
	}
	return mary;
}

- (void)clear
{
	[cache_ removeAllObjects];
}

- (void)dealloc
{	
	[cache_ release];
	[super dealloc];	
}
  
@end
