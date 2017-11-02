//
//  Tracking.m
//  NoodleBox
//
//  Created by Julian Wood on 11-12-26.
//  Copyright (c) 2011 Mobilesce Inc. All rights reserved.
//

#import "Tracking.h"
#import "TestFlight.h"
#import "Flurry.h"
#import "GAI.h"
#import "GAITracker.h"
#import "GAITransaction.h"
#import "EditionManager.h"
#import "NSString-Expanded.h"
#import "NSUserDefaults+StratPad.h"
#import "UAKeychainUtils+StratPad.h"
#import "AFNetworking.h"
#import "UIDevice+IdentifierAddition.h"
#import "DataManager.h"
#import "StratFile.h"
#import "GoogleConversionPing.h"
#import <CommonCrypto/CommonDigest.h>
#import "UIDevice+IdentifierAddition.h"
#import "RegistrationManager.h"

@implementation Tracking

+ (void)startup
{
    
}

+ (void)trackTransaction:(NSString*)transactionIdOrNil productId:(NSString*)productId
{
    
}

+(void)trackMarketingConversion
{
    
}

+(void)trackAdMobConversion
{
    
}

+ (NSString *)hashedISU {
    NSString *result = nil;
    NSString *isu = [[UIDevice currentDevice] uniqueDeviceIdentifier];
    
    if(isu) {
        unsigned char digest[16];
        NSData *data = [isu dataUsingEncoding:NSASCIIStringEncoding];
        CC_MD5([data bytes], [data length], digest);
        
        result = [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                  digest[0], digest[1],
                  digest[2], digest[3],
                  digest[4], digest[5],
                  digest[6], digest[7],
                  digest[8], digest[9],
                  digest[10], digest[11],
                  digest[12], digest[13],
                  digest[14], digest[15]];
        result = [result uppercaseString];
    }
    return result;
}


+ (void)pageView:(NSString *)pageName chapter:(Chapter*)chapter pageNum:(NSUInteger)pageNum
{

    
}

+ (void)logEvent:(NSString*)eventName
{

}

+ (void)logEvent:(NSString*)eventName withParameters:(NSDictionary *)parameters
{
    
    
}

+ (void)trackUsage
{
    
}

+ (void)shutdown
{
    // no-op
}

@end

NSString * const kTrackingCheckPointWebMobilesce        = @"Web Mobilesce";

NSString * const kTrackingEventAdImpression             = @"Ad Impression";
NSString * const kTrackingEventAdClick                  = @"Ad Click";
NSString * const kTrackingEventIAP                      = @"IAP";

NSString * const kTrackingEventYammerPostedFile         = @"Yammer: Posted File";
NSString * const kTrackingEventYammerUpdatedFile        = @"Yammer: Updated File";
NSString * const kTrackingEventYammerCommented          = @"Yammer: Commented on File";

NSString * const kTrackingEventRegistered               = @"Registration: Submitted form";

NSString * const kTrackingEventPageView                 = @"Page viewed.";

NSString* const kTrackingEventStratfileCreated          = @"StratFile created";
NSString* const kTrackingEventStratfileBackedUp         = @"StratFile backed up";
NSString* const kTrackingEventReportEmailed             = @"Report emailed";
NSString* const kTrackingEventStratfileEmailed          = @"StratFile emailed";
NSString* const kTrackingEventCSVEmailed                = @"CSV emailed";
NSString* const kTrackingEventDocxEmailed               = @"Docx emailed";
NSString* const kTrackingEventReportPrinted             = @"Report printed";
