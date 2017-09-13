//
//  RandomManager.h
//  YouDidIt
//
//  Created by Julian Wood on 10-11-08.
//  Copyright 2010 Mobilesce Inc. All rights reserved.
//
//  Gives random ints given a unique key and an upper limit (exclusive). Each time you ask for a random int with 
//  the same key, the result will be removed from the possible returns, until all possibilities have been exhausted.
//  
//  It doesn't clear out its cache at any point, so there's a possible improvement. 
//  Also if you use the same unique key in multiple places, you will get wires crossed up!

@interface RandomManager : NSObject {
@private
    // not really threadsafe, but not sure if we need it - see http://stackoverflow.com/questions/1986736/nsmutabledictionary-thread-safety
	NSMutableDictionary *cache_;
}

+ (RandomManager *)sharedManager;
- (int)random:(NSString*)key numberOfObjects:(int)numberOfObjects;
- (void)clear;

@end

