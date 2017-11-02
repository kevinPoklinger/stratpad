//
//  NSUserDefaults+StratPad.h
//  StratPad
//
//  Created by Julian Wood on 12-09-17.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults (StratPad)

// *** Registration keys ***

// userDefaults keys, stored immediately, regardless of server success
#define keyEmail                            @"registration.email"
#define keyFirstName                        @"registration.firstName"
#define keyLastName                         @"registration.lastName"

#define keyShownCount                       @"registration.shownCount"
#define keyLastShownDate                    @"registration.lastShownDate"
#define keyRegistrationStatus               @"registration.status"

// *** Miscellaneous keys ***

// this was to allow us to correct a mistake in 1.3 Plus
#define keyAreSampleFilesCleanedUpFor13     @"areSampleFilesCleanedUpFor1.3"

// special key which gives us a list of languages
#define keyAppleLanguages                   @"AppleLanguages"

// format string to see if we've shown the welcome message for a particular version
#define keyHasShownWelcomeFormat            @"hasShownWelcome-%@"

// YammerManager keys to store user choices between sessions
#define keyPreferredYammerGroup             @"preferredYammerGroup"
#define keyPreferredYammerNetwork           @"preferredYammerNetwork"

// because the keychain persists through app deletions, we must reset it (synonymous with first run)
#define keyIsKeychainInited                 @"isKeychainInited"

// true the first time we run the app, false thereafter
#define keyIsWelcomeShown                   @"isWelcomeShown"

// a dictionary of booleans, storing whether or not we should print a chart; defaults to true
#define keyChartPrinting                    @"chartPrinting"

// if we successfully convert an admob
#define keyAdmobConversionReported          @"admobConversionReported"

// *** EditionManager ***

// this is where we store the IAP product. eg com.glasseystrategy.stratpad.free.iap.plus.pro
#define keyProductId                        @"productId"

// this is where we store the StratBoard IAP product id. eg. com.glasseystrategy.stratpad.free.iap.plus.stratbord
// to deal with an AppStore issue (can't delete or reuse ids), we had to mispell stratboard in the value, and occasionally use .fix. in the value as well
#define keyStratboard                       @"stratboard"




// *** not defined here:

// in ChartSelectionViewController, we store some prefs under the charts UUID


// NB. no impl for this category

@end
