//
//  AppDelegate.m
//  StratPad
//
//  Created by Eric on 11-07-25.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "AppDelegate.h"
#import "RootViewController.h"
#import "EditionManager.h"
#import "DataManager.h"
#import "OpenStratFileUpgradeAlertView.h"

#import "EventManager.h"
#import "RegistrationManager.h"
#import "UAKeychainUtils+StratPad.h"
#import "UserNotificationDisplayManager.h"
#import "YammerCommentManager.h"
#import "NSUserDefaults+StratPad.h"
#import "NSString-Expanded.h"
#import "NSManagedObjectModel+KCOrderedAccessorFix.h"

@interface AppDelegate (Private)
- (void)initAirship:(NSDictionary*)launchOptions;
@end

@implementation AppDelegate

@synthesize window=_window;

@synthesize managedObjectContext=__managedObjectContext;
@synthesize managedObjectModel=__managedObjectModel;
@synthesize persistentStoreCoordinator=__persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
#if DEBUG
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
#endif
    
    
    // E-commerce
    [self recordEcommerceTransaction];
    
    NSDictionary *plistData = [[NSBundle mainBundle] infoDictionary];
    MB_LOG_LEVEL = [[plistData valueForKey:@"MBLogLevel"] intValue];    
 
	ILog(@"%@. %@",[[EditionManager sharedManager] productDisplayName], [[EditionManager sharedManager] versionString]); // StratPad Premium: Version 1.1. Build 614:615M. 12.08.2011 15:34:34 MST
    
    // our standard set of user defaults
    [[NSUserDefaults standardUserDefaults] registerDefaults:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [NSNumber numberWithBool:NO], keyIsWelcomeShown,
      nil]];
    
    // set up APNS with Urban Airship
    [self initAirship:launchOptions];
    
    DLog(@"Finished basic startup sequence.")

    DLog(@"Starting first view.")
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    RootViewController *rootController = [[RootViewController alloc] initWithNibName:@"RootView" bundle:nil];
    self.window.rootViewController = rootController;
    [rootController release];
    [self.window makeKeyAndVisible];

    DLog(@"Finished first view and startup.")

    return YES;
}

void uncaughtExceptionHandler(NSException *exception) {
    NSLog(@"CRASH: %@", exception);
    NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
    // Internal error reporting
}

-(void)recordEcommerceTransaction
{
    // we don't want to record everyone updating to 1.5.2 as a txn, thus check to see if they have a certain key from their keychain already set
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // if this key happens to be in our defaults, then we know they are updating from the era of 1.4.x (25% of users)
    id was14x = [defaults objectForKey:@"isTrainingShown"];
    BOOL isUpdateFrom14x = (was14x != nil);
    
    // the keyIsKeychainInited has been around since 958 (which is 1.5)
    // 75% of our users are on 1.5 or greater, as of Dec 7, 2012
    id was15x = [defaults objectForKey:keyIsKeychainInited];
    BOOL isUpdateFrom15xOrGreater = (was15x != nil);
    
    // as long as we're not an update, this is a new install
    BOOL isNewInstall = !(isUpdateFrom14x || isUpdateFrom15xOrGreater);
    
    // record the txn if necessary
}


- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    // we have url's to open stratpad. eg stratpad:// or strapadfree:// coming from emails, webpages
    // we have .stratfile
    // we have .stratbak
    
    NSString *scheme = [url scheme];
    if ([scheme hasPrefix:@"stratpad"]) {
        // we just have simple urls like stratpad://register?...
        DLog(@"Received open request: %@", url);
        
        // we don't do anything special
    }
    else
    if ([[EditionManager sharedManager] isFeatureEnabled:FeatureCanOpenStratFiles] && [url isFileURL] && [[url pathExtension] isEqualToString:@"stratfile"]) {

        DLog(@"file received: %@; %@; %@", url, sourceApplication, annotation);
        [[StratFileManager sharedManager] importStratFile:url];
        
    }
    else if ([url isFileURL] && [[url pathExtension] isEqualToString:@"stratbak"]) {
        
        DLog(@"file received: %@; %@; %@", url, sourceApplication, annotation);
        
        if ([[EditionManager sharedManager] isFeatureEnabled:FeatureBackup]) {
            [[StratFileManager sharedManager] importStratFileBackup:url];
        }
        else {
            // you need to be registered
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"REGISTER_ALERT_TITLE", nil)
                                                            message:LocalizedString(@"REGISTER_ALERT_MESSAGE", nil)
                                                           delegate:nil
                                                  cancelButtonTitle:LocalizedString(@"CANCEL", nil)
                                                  otherButtonTitles:LocalizedString(@"OK", nil), nil];
            [alert show];
            [alert release];
        }
        
    }
    
    else {
        // unless we have some fabricated URL by someone, this is going to be a .stratfile that we aren't allowed to open
        // need to upgrade
        OpenStratFileUpgradeAlertView *alert = [[OpenStratFileUpgradeAlertView alloc] init];
        [alert show];
        [alert release];
    }

    // continue opening StratPad
    return  YES;
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(nullable UIWindow *)window {
    return UIInterfaceOrientationMaskLandscape;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    [self saveContext];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    
    RootViewController *rootViewController = (RootViewController*)self.window.rootViewController;
    [rootViewController dismissAllMenus];
    
    wasBackgrounded_ = YES;

    [self saveContext];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
    DLog(@"enter foreground");
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    [self initAirship:nil];
    
    // kick off a request to yammer for any new messages, so that the UI can update
    [[YammerCommentManager sharedManager] updateCommentCounts];
    
    // this is always called, in addition to everything else, whenever the app takes focus again
    // the thing to remember is that a memory condition while doing other stuff on the iPad will clear out StratPad, so that sometimes when you come back to StratPad, you resume where you left off, but other times it is basically restarting
    // the problem with reminder dialogs is that we have a splash screen, and we don't want to show those dialogs then

    BOOL isSplashScreenShowing = [(RootViewController*)self.window.rootViewController isSplashScreenShowing];
    if (wasBackgrounded_ && !isSplashScreenShowing) {
        DLog(@"resumed");

        // we show the actual registration dialog the first time through the app, after the splash screen, in -[RootViewController stratPadReady:]
        // we also show this reminder at the same code location, when the app is restarting, but after the splash screen
        [[RegistrationManager sharedManager] showRelevantReminderInView:self.window.rootViewController.view];
        
        // check validation
        [[RegistrationManager sharedManager] checkValidation];

    } else {
        DLog(@"restarted");
    }
    
    // usage
    
            
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // only called when the app exits, not when backgrounding
    
    [[NSUserDefaults standardUserDefaults] synchronize];

    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - Memory Management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    WLog(@"Application received a memory warning.");
}

- (void)dealloc
{
    [_window release];
    [__managedObjectContext release];
    [__managedObjectModel release];
    [__persistentStoreCoordinator release];
    [super dealloc];
}

#pragma mark - Core Data stack

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            ELog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}


/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil)
    {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        
        //Undo Support
    	NSUndoManager *anUndoManager = [[NSUndoManager	alloc] init];
    	[__managedObjectContext setUndoManager:anUndoManager];
    	[anUndoManager release];
        
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"StratPad" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    // this is a fix for Core Data ordered sets
    [__managedObjectModel kc_generateOrderedSetAccessors];
    
    return __managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *path = [docDir stringByAppendingPathComponent:@"StratPad.sqlite"];
    NSURL *storeURL = [NSURL fileURLWithPath:path];
    
#if CLEAN_DB
	ILog(@"Cleaning DB.");
	[[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    // note this doesn't get rid of momd
#endif
    
    // Performing automatic lightweight migration by passing the following dictionary as the options parameter:
	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:							 
							 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,							 
							 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];

    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error])
    {
        ELog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    

    return __persistentStoreCoordinator;
}

- (void) initAirship:(NSDictionary*)launchOptions
{
    
}


@end
