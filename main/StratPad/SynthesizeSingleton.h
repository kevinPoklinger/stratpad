//
//  SynthesizeSingleton.h
//  CocoaWithLove
//
//  Created by Matt Gallagher on 20/10/08.
//  Copyright 2008 Matt Gallagher. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//
//  Use this simply by creating a standard .h/.m file, and then in .m: SYNTHESIZE_SINGLETON_FOR_CLASS(name_of_class);
//

#define SYNTHESIZE_SINGLETON_FOR_CLASS(classname) \
 \
static classname *sharedManager = nil; \
 \
+ (id)sharedManager \
{ \
	@synchronized(self) \
	{ \
		if (sharedManager == nil) \
		{ \
			sharedManager = [[super alloc] init]; \
		} \
	} \
	 \
	return sharedManager; \
} \
 \
+ (id)allocWithZone:(NSZone *)zone \
{ \
	@synchronized(self) \
	{ \
		if (sharedManager == nil) \
		{ \
			sharedManager = [super allocWithZone:zone]; \
		} \
	} \
	 \
	return sharedManager; \
} \
 \
- (id)copyWithZone:(NSZone *)zone \
{ \
	return self; \
} \
 \
- (id)retain \
{ \
	return self; \
} \
 \
- (NSUInteger)retainCount \
{ \
	return UINT_MAX; \
} \
 \
- (oneway void)release \
{ \
} \
 \
- (id)autorelease \
{ \
	return self; \
}
