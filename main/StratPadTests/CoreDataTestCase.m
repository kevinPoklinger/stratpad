//
//  CoreDataTestCase.m
//  StratPad
//
//  Created by Julian Wood on 11-12-09.
//  Copyright (c) 2011 Glassey Strategy. All rights reserved.
//

#import "CoreDataTestCase.h"
#import "AppDelegate.h"

@implementation CoreDataTestCase

- (void) tearDown
{
    // flush out db errors
    NSManagedObjectContext *managedObjectContext = [(AppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
	NSError *error;
	if (![managedObjectContext save:&error]) {
		NSArray* detailedErrors = [[error userInfo] objectForKey:NSDetailedErrorsKey];
		if(detailedErrors != nil && [detailedErrors count] > 0) {
			for(NSError* detailedError in detailedErrors) {
				ELog(@"  DetailedError: %@", [detailedError userInfo]);
			}
		}
        STFail(@"Failed to save to data store: %@", [error localizedDescription]);

        [managedObjectContext rollback];
    }
}

@end
