//
//  EditionManager.h
//  StratPad
//
//  Created by Julian Wood on 11-12-08.
//  Copyright (c) 2011 Glassey Strategy. All rights reserved.
//
//  The strategy is to place the unique productId in the NSUserDefaults.
//  If there is no productId in NSUserDefaults, then we use the bundleId in the info.plist as the id.
//  We have unique productIds for every in app purchase.
//
//  Remember, the reason we have multiple IAPs for the same thing:
//  Consider - we have Free upgraded to Plus -> we want to show the upgrades available for Plus users, not Free users
//           - technically though, they are still upgrades from Free, so we have to grab them all and filter out the irrelevant ones

#import <Foundation/Foundation.h>

/////// you can only have one of the following edition-upgrade iaps ///////

// free upgrades
// NB we've added in the .fix. where necessary because Apple killed our Free app and it's IAP's, and we can't re-use them
#define kProductIdFreeToPlusUpgrade                 @"com.glasseystrategy.stratpad.free.iap.fix.plus"
#define kProductIdFreeToPremiumUpgrade              @"com.glasseystrategy.stratpad.free.iap.fix.premium"
#define kProductIdFreeToPlusToPremiumUpgrade        @"com.glasseystrategy.stratpad.free.iap.fix.plus.premium"

// plus upgrades
#define kProductIdPlusToPremiumUpgrade              @"com.glasseystrategy.stratpad.plus.iap.premium"

// premium upgrades

/////// you can only have one of the following StratBoard iaps ///////

// stratboard upgrades - included in Platinum
// NB you can delete an IAP but you can never re-use its id!!! hence stratbord

// have to upgrade to plus and stratboard simultaneously
#define kProductIdFree_Plus_Stratboard_ComboUpgrade       @"com.glasseystrategy.stratpad.free.iap.combo.plus.stratbord"
//#define kProductIdFree_StratBoardUpgrade                @"com.glasseystrategy.stratpad.free.iap.stratbord"

#define kProductIdFree_Premium_Stratboard_ComboUpgrade  @"com.glasseystrategy.stratpad.free.iap.combo.premium.stratbord"

#define kProductIdFreeToPlus_StratBoardUpgrade          @"com.glasseystrategy.stratpad.free.iap.plus.stratbord"
#define kProductIdFreeToPremium_StratBoardUpgrade       @"com.glasseystrategy.stratpad.free.iap.premium.stratbord"
#define kProductIdFreeToPlusToPremium_StratBoardUpgrade @"com.glasseystrategy.stratpad.free.iap.plus.premium.stratbord"

#define kProductIdPlus_StratBoardUpgrade                @"com.glasseystrategy.stratpad.plus.iap.stratbord"
#define kProductIdPlusToPremium_StratBoardUpgrade       @"com.glasseystrategy.stratpad.plus.iap.premium.stratbord"

#define kProductIdPremium_StratBoardUpgrade             @"com.glasseystrategy.stratpad.premium.iap.stratbord"

/////// base product ids ///////

#define kProductIdFree                  @"com.glasseystrategy.stratpad.free"
#define kProductIdPlus                  @"com.glasseystrategy.stratpad.plus"
#define kProductIdPremium               @"com.glasseystrategy.stratpad.business"
#define kProductIdPlatinum              @"com.glasseystrategy.stratpad.platinum"

typedef enum {
    FeatureAddStratFiles,
    FeatureDeleteStratFiles,
    FeatureExtras,
    FeatureReadWriteAllStratFiles,
    FeatureAddOneReadWriteFile,
    FeatureAds,
    FeatureCanOpenStratFiles,
    FeatureCanShareStratFiles,
    FeatureLogoOnReport,
    FeatureCanShareCsvFile,
    FeatureHasStratBoard,
    FeatureToolkit,
    FeatureYammer,
    FeaturePrint,
    FeatureCanShareReports,
    FeatureBackup,
    FeatureAdMobConversion,
} Feature;

@interface EditionManager : NSObject
{
    NSDictionary *editionsInfo_;
    NSDictionary *matrix_;
}

+ (EditionManager *)sharedManager;


-(BOOL)isFeatureEnabled:(Feature)feature;

// returns YES if you have purchased any IAP
-(BOOL)isUpgraded;

// returns the product id of the base app
-(NSString*)baseProductId;

// returns yes if the productId represents an IAP
-(BOOL)isIAP:(NSString*)productId;

// full version, build number and build date
-(NSString*)versionString;

// the long name of this product, taking into account the IAP eg. StratPad Premium: Business Strategy...
-(NSString*)productDisplayName;

// the name of this product, taking into account the IAP (ie the effective edition name) eg. StratPad Premium
-(NSString*)productShortName;

// the name of this product, without the effect of any IAP
-(NSString*)originalProductShortName;

// just the short version, specified in the plist, under CFBundleShortVersionString. eg 1.1
-(NSString*)versionNumber;

// we grab this from the momd file - it will equal the current model seen on StratPad.xcdatamodeld file inspector eg. StratPad 1.1 (616)
-(NSString*)modelVersion;

// check to see if a CoreData modelVersion is compatible with the current Core Data model version
// ie. provide the model version in a .stratfile to see if it matches the model in the app, or if it is compatible
// we use this primarily when importing external .stratfiles into the program
// in general, we make sure that the previous 3 versions will import successfully into the current version
// todo: need to keep reference versions of several .stratfiles to prove this
-(BOOL)isModelCompatible:(NSString*)modelVersion;

// the URL to the app store for the base edition (ie not including any upgrades)
-(NSString*)appStoreURL;
-(NSString*)appStoreURLForProductId:(NSString*)productId;

// originally the free version, could be upgraded to something else though
-(BOOL)isFree;

// originally the plus version
-(BOOL)isPlus;

// originally the premium version
-(BOOL)isPremium;

// platinum - you can't upgrade to or upgrade this edition
-(BOOL)isPlatinum;

// isFree && not upgraded
-(BOOL)isEffectivelyFree;

// determines if this product should be treated as plus, whether it was upgraded via IAP or downloaded originally as Plus
-(BOOL)isEffectivelyPlus;

// determines if this product should be treated as premium, whether it was upgraded via IAP or downloaded originally as Premium
-(BOOL)isEffectivelyPremium;

// returns a list of IAP productIds matching the app's effective productId (CFBundleIdentifier)
-(NSArray*)inAppPurchasesForProduct;

// all IAP's for all editions of StratPad
-(NSArray*)inAppPurchasesForAllEditions;

// when constructing a url, the scheme that will target this particular edition of stratpad
-(NSString*)urlScheme;

// figure out the price in the USA for the productId (app or IAP)
// resultant dict (productInfo) will be passed to completion block with keys: productId, name, price
// if there is an error, the dict will be filled out using a local cache (Editions.plist)
- (void)fetchProductInfo:(NSString*)productId completion:(void (^)(NSDictionary *productInfo))completion;

// NSOrderedAscending if otherVersion (eg 1.4.5) is greater than version (eg 1.3.2 or 1.4)
-(NSComparisonResult)compareVersions:(NSString*)version otherVersion:(NSString*)otherVersion;

// eg StratPad 1.6 (1090) > StratPad 1.5.4 (987)
-(NSComparisonResult)compareModelVersions:(NSString*)modelVersion otherModelVersion:(NSString*)otherModelVersion;

@end
