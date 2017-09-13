//
//  Tracking.h
//  NoodleBox
//
//  Created by Julian Wood on 11-12-26.
//  Copyright (c) 2011 Mobilesce Inc. All rights reserved.
//
//  Make sure you add your UANumber to your info.plist
//  TestFlight number is specific to developer account and doesn't need changing.
//  startup and shutdown in appdelegate

//  *** With the advent of 1.0, TestFlight is Production-ready, and these notes are simply for posterity ***
//  Add TESTFLIGHT to the PreProcessor Macros build setting to record
//  Not recommended for production use
//  Can add a new user-defined setting to build settings called EXCLUDED_SOURCE_FILE_NAMES and 
//   set the value to *libTestFlight.a to exclude the lib from app store config

// *** note, going to take TestFlight out of production (only)
// can cause this issue: https://github.com/pokeb/asi-http-request/issues/320
// also, not seeing any improvements in "Live" dashboard, nor is it symbolicating requests properly
// switch to Flurry and CrashLytics

#import <Foundation/Foundation.h>
#import "Chapter.h"

@interface Tracking : NSObject

+ (void)startup;
// pageNum should be 1-based
+ (void)pageView:(NSString *)pageName chapter:(Chapter*)chapter pageNum:(NSUInteger)pageNum;
+ (void)logEvent:(NSString*)eventName;
+ (void)logEvent:(NSString*)eventName withParameters:(NSDictionary *)parameters;
+ (void)shutdown;

+ (void)trackTransaction:(NSString*)transactionIdOrNil productId:(NSString*)productId;
+ (void)trackMarketingConversion;
+(void)trackAdMobConversion;

+ (void)trackUsage;

@end

// checkpoints

// we went to mobilesce.com
extern NSString* const kTrackingCheckPointWebMobilesce;

// events
extern NSString* const kTrackingEventAdImpression;
extern NSString* const kTrackingEventAdClick;
extern NSString* const kTrackingEventIAP;

extern NSString* const kTrackingEventYammerPostedFile;
extern NSString* const kTrackingEventYammerUpdatedFile;
extern NSString* const kTrackingEventYammerCommented;

extern NSString* const kTrackingEventRegistered;

extern NSString* const kTrackingEventPageView;

extern NSString* const kTrackingEventStratfileCreated;
extern NSString* const kTrackingEventStratfileBackedUp;
extern NSString* const kTrackingEventStratfileEmailed;
extern NSString* const kTrackingEventReportEmailed;
extern NSString* const kTrackingEventCSVEmailed;
extern NSString* const kTrackingEventDocxEmailed;
extern NSString* const kTrackingEventReportPrinted;