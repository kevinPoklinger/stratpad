//
//  AppDelegate.h
//  StratPad
//
//  Created by Eric on 11-07-25.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

@interface AppDelegate : NSObject <UIApplicationDelegate> {
    // this will let us differentiate between app restarts and app resumes, after placing stratpad in the background
    BOOL wasBackgrounded_;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;

@end
