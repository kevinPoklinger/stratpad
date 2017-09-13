//
//  EditionManager.m
//  StratPad
//
//  Created by Julian Wood on 11-12-08.
//  Copyright (c) 2011 Glassey Strategy. All rights reserved.
//

#import "EditionManager.h"
#import "SynthesizeSingleton.h"
#import "UIDevice+IdentifierAddition.h"
#import "RegistrationManager.h"
#import "UAKeychainUtils+StratPad.h"
#import "NSUserDefaults+StratPad.h"
#import "SBJson.h"
#import "AFNetworking.h"

@implementation EditionManager

SYNTHESIZE_SINGLETON_FOR_CLASS(EditionManager);

- (id)init {
    self = [super init];
    if (self) {
        // we placed localized names in the same file
        NSString *editionsPath = [[NSBundle mainBundle] pathForResource:@"Editions" ofType:@"plist"];
        editionsInfo_ = [[NSDictionary dictionaryWithContentsOfFile:editionsPath] retain];
        
        NSString *compatPath = [[NSBundle mainBundle] pathForResource:@"Compatibility Matrix" ofType:@"plist"];
        matrix_ = [[NSDictionary dictionaryWithContentsOfFile:compatPath] retain];        
    }
    return self;
}

- (void)dealloc
{
    [matrix_ release];
    [editionsInfo_ release];
    [super dealloc];
}


-(BOOL)isFree
{
    NSString *bundleId = [self baseProductId];
    return [bundleId isEqualToString:kProductIdFree];    
}

-(BOOL)isPlus
{
    NSString *bundleId = [self baseProductId];
    return [bundleId isEqualToString:kProductIdPlus];    
}

-(BOOL)isPremium
{
    NSString *bundleId = [self baseProductId];
    return [bundleId isEqualToString:kProductIdPremium];    
}

-(BOOL)isPlatinum
{
    NSString *bundleId = [self baseProductId];
    return [bundleId isEqualToString:kProductIdPlatinum];        
}


-(BOOL)isEffectivelyFree
{
    return [self isFree] && ![self isUpgraded];
}

-(BOOL)isEffectivelyPlus
{
    NSString *bundleId = [self baseProductId];
    return [bundleId isEqualToString:kProductIdPlus] || [self isUpgradedToPlus];
}

-(BOOL)isEffectivelyPremium
{
    NSString *bundleId = [self baseProductId];
    return [bundleId isEqualToString:kProductIdPremium] || [self isUpgradedToPremium];
}

-(BOOL)isUpgraded
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults]; 
    NSString *productId = [userDefaults stringForKey:keyProductId];
    return [self isIAP:productId];
}

-(BOOL)isIAP:(NSString*)productId
{
    NSRange aRange = [productId rangeOfString:@".iap."];
    return (productId != nil && aRange.location != NSNotFound);
}

-(NSString*)baseProductId
{
    NSDictionary *plistData = [[NSBundle mainBundle] infoDictionary];
    return [plistData valueForKey:@"CFBundleIdentifier"];
}

-(BOOL)isFeatureEnabled:(Feature)feature
{
    switch (feature) {
        case FeatureAddStratFiles:
            return [self isEffectivelyPremium] || [self isPlatinum];
        case FeatureDeleteStratFiles:
            return [self isEffectivelyPremium] || [self isPlatinum];
        case FeatureExtras:
            return [self isEffectivelyFree] || [self isEffectivelyPlus] || [self isEffectivelyPremium];
        case FeatureReadWriteAllStratFiles:
            return [self isEffectivelyPremium] || [self isPlatinum];
        case FeatureAddOneReadWriteFile:
            return [self isEffectivelyFree] || [self isEffectivelyPlus];
        case FeatureAds:
            return NO;
        case FeatureCanOpenStratFiles:
            return [self isEffectivelyPremium] || [self isPlatinum];
        case FeatureCanShareStratFiles:
            return [self isEffectivelyPremium] || [self isPlatinum];
        case FeatureLogoOnReport:
            return [self isEffectivelyPremium] || [self isPlatinum];
        case FeatureCanShareCsvFile:
            return [self isEffectivelyPremium] || [self isPlatinum];
        case FeatureHasStratBoard:
            return [self isStratBoardPurchased] || [self isPlatinum];
        case FeatureToolkit:
            return [self isEffectivelyPlus] || [self isEffectivelyPremium] || [self isPlatinum];
        case FeatureYammer:
            return [self isEffectivelyPlus] || [self isEffectivelyPremium] || [self isPlatinum];
        case FeaturePrint:
            return [self isEffectivelyPlus] || [self isEffectivelyPremium] || [self isPlatinum];
        case FeatureCanShareReports:
            return [self isEffectivelyPlus] || [self isEffectivelyPremium] || [self isPlatinum];
        case FeatureBackup:
            return [self isBackupEnabled];
        case FeatureAdMobConversion:
            // check base versions
            return [self isPremium] || [self isPlatinum];
        default:
            ELog(@"No such feature: %i", feature);
            return NO;
    }
}

-(NSArray*)inAppPurchasesForAllEditions
{
    return [NSArray arrayWithObjects:
            kProductIdFreeToPlusUpgrade, kProductIdFreeToPremiumUpgrade, kProductIdFreeToPlusToPremiumUpgrade,
            kProductIdPlusToPremiumUpgrade,
            kProductIdFree_Plus_Stratboard_ComboUpgrade, kProductIdFree_Premium_Stratboard_ComboUpgrade,
            kProductIdFreeToPlus_StratBoardUpgrade, kProductIdFreeToPremium_StratBoardUpgrade, kProductIdFreeToPlusToPremium_StratBoardUpgrade, kProductIdPlus_StratBoardUpgrade, kProductIdPlusToPremium_StratBoardUpgrade, kProductIdPremium_StratBoardUpgrade,
            nil];
}


-(NSArray*)inAppPurchasesForProduct
{
    if ([self isEffectivelyPremium]) {
        // 1 IAP, but they are different depending on how you got to premium (4 total)
        if ([self isFree]) {
            // only 1 is applicable; need to know how we upgraded in order to give correct IAP
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults]; 
            NSString *productId = [userDefaults stringForKey:keyProductId];
            if ([productId isEqualToString:kProductIdFreeToPremiumUpgrade]) {
                // bought free + premium IAP
                return [NSArray arrayWithObjects:kProductIdFreeToPremium_StratBoardUpgrade, nil];
            } else {
                // bought free + plus IAP + premium IAP
                return [NSArray arrayWithObjects:kProductIdFreeToPlusToPremium_StratBoardUpgrade, nil];
            }
        } else if ([self isPlus]) {
            // bought plus + premium IAP
            return [NSArray arrayWithObjects:kProductIdPlusToPremium_StratBoardUpgrade, nil];
        } else {
            // bought premium
            return [NSArray arrayWithObjects:kProductIdPremium_StratBoardUpgrade, nil];
        }
        
    } else if ([self isEffectivelyPlus]) {
        if ([self isPlus]) {
            // bought plus
            return [NSArray arrayWithObjects:kProductIdPlusToPremiumUpgrade, kProductIdPlus_StratBoardUpgrade, nil];            
        } else {
            // bought free + plus IAP
            return [NSArray arrayWithObjects:kProductIdFreeToPlusToPremiumUpgrade, kProductIdFreeToPlus_StratBoardUpgrade, nil];
        }
        
    } else if ([self isEffectivelyFree]) {
        // bought free
        return [NSArray arrayWithObjects:
                kProductIdFreeToPlusUpgrade, 
                kProductIdFreeToPremiumUpgrade,                                 
                kProductIdFree_Plus_Stratboard_ComboUpgrade,
                kProductIdFree_Premium_Stratboard_ComboUpgrade,
//                kProductIdFree_StratBoardUpgrade,
                nil];
        
    } else if ([self isPlatinum]) {
        // no IAP's for platinum
        return [NSArray array];
        
    } else {
        ELog(@"Unknown product!!");
        return [NSArray array];
    }
}

-(NSString*)versionString
{
    NSDictionary *plistData = [[NSBundle mainBundle] infoDictionary];    
	NSArray *versionParts = [[plistData objectForKey:@"CFBundleVersion"] componentsSeparatedByString:@" "];
    
    // unless we're setting date and time automatically to some nasty looking date, just display what's in plist
    //    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //    [dateFormatter setDateFormat:@"MM.dd.yy"];
    //    NSDate *buildDate = [dateFormatter dateFromString:[plistData objectForKey:@"MBBuildDate"]];
    //    [dateFormatter release];
	
    NSString *versionString = [NSString stringWithFormat:LocalizedString(@"version.string", nil),
                          [plistData objectForKey:@"CFBundleShortVersionString"], 
                          // accounts for $Rev: 407 $
                          [versionParts objectAtIndex: ([versionParts count] > 1 ? 1 : 0)],
                          [plistData objectForKey:@"MBBuildDate"]
                          ];
    return versionString;
}

-(NSString*)versionNumber
{
    NSDictionary *plistData = [[NSBundle mainBundle] infoDictionary];
    return [plistData objectForKey:@"CFBundleShortVersionString"];
}

-(NSString*)modelVersion
{
    NSString *momdPath = [[NSBundle mainBundle] pathForResource:@"StratPad" ofType:@"momd"];
    NSString *modelInfoPath = [momdPath stringByAppendingPathComponent:@"VersionInfo.plist"];
    
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:modelInfoPath];
    return [dict objectForKey:@"NSManagedObjectModel_CurrentVersionName"];
}

-(BOOL)isModelCompatible:(NSString*)modelVersion
{
    // eg. StratPad 1.1.2 (622) ( major.minor.revision (build) ) 
    // note that the build is the svn rev number of the last change to the model (ie the actual name of the xcdatamodel), not the current svn rev num
    NSArray *parts = [modelVersion componentsSeparatedByString:@" "];
    NSString *appName = [parts objectAtIndex:0];
    NSString *version = [parts objectAtIndex:1];
    NSString *build = [[parts objectAtIndex:2] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"()"]];
    NSArray *versionParts = [version componentsSeparatedByString:@"."];
    NSString *major = [versionParts objectAtIndex:0];
    NSString *minor = [versionParts objectAtIndex:1];
    NSString *revision = versionParts.count > 2 ? [versionParts objectAtIndex:2] : nil;
        
    DLog(@"Checking compatibility of provided modelVersion: %@ against current app model version: %@", modelVersion, [self modelVersion]);
    DLog(@"provided appName: %@, version: %@, build: %@", appName, version, build);
    DLog(@"provided major: %@, minor: %@, revision: %@", major, minor, revision);

    if ([modelVersion isEqualToString:[self modelVersion]]) {
        return YES;
    } else {        
                
        // check build numbers
        
        // must match a build in the compatibility matrix
        // every time we make a new model, we must add it to the compatibility matrix in its entirety
        // then we say which builds are compatible (can be imported on the fly, with adjustments as necessary)
        // the actual changes go into the xml parser, which deals with old models
        
        // we grab the list of build nums compatible with the current build num
        NSArray *builds = [matrix_ objectForKey:[self modelVersion]];
        BOOL compatible = NO;
        if (!builds) {
            WLog(@"No compatibility matrix for %@. Returning NO.", [self modelVersion]);
            compatible = NO;
        } else {
            compatible = ([builds indexOfObject:build] != NSNotFound);                
        }    
        
        return compatible;
    }
}

-(NSString*)normalizeVersion:(NSString*)version
{
    // blow out versions from 1.0 to 1.0.0, or 1 to 1.0.0
    NSArray *parts = [version componentsSeparatedByString:@"."];
    if (parts.count == 3) {
        return version;
    }
    else {
        NSMutableArray *normalParts = [NSMutableArray arrayWithCapacity:3];
        [normalParts addObjectsFromArray:parts];
        for (uint i = normalParts.count; i<3; ++i) {
            [normalParts addObject:@"0"];
        }
        return [normalParts componentsJoinedByString:@"."];
    }
}

-(NSComparisonResult)compareVersions:(NSString*)version otherVersion:(NSString*)otherVersion
{
    //  because "1" < "1.0" < "1.0.0", blow out all versions to 3 components
    NSString *normalVersion = [self normalizeVersion:version];
    NSString *normalOtherVersion = [self normalizeVersion:otherVersion];
    
    return [normalVersion compare:normalOtherVersion options:NSNumericSearch];
}

-(NSComparisonResult)compareModelVersions:(NSString*)modelVersion otherModelVersion:(NSString*)otherModelVersion
{
    NSCharacterSet *charSet = [NSCharacterSet characterSetWithCharactersInString:@"()"];
    NSArray *parts = [modelVersion componentsSeparatedByString:@" "];
    NSString *build = [[parts objectAtIndex:2] stringByTrimmingCharactersInSet:charSet];

    NSArray *oParts = [otherModelVersion componentsSeparatedByString:@" "];
    NSString *oBuild = [[oParts objectAtIndex:2] stringByTrimmingCharactersInSet:charSet];
    
    return [build compare:oBuild options:NSNumericSearch];
}


-(NSString*)productDisplayName
{
    // CFBundleName is supposed to be the short name (but we had it long, now shorter): StratPad Plus
    // CFBundleDisplayName supposed to be longer, but used for icon: StratPad
    // we've taken the super long name out of CFBundleName - still in editions.plist
    // both can be localized in InfoPlist.strings, but we're not going to do that
    // since it's tricky to give a localized version of this key per target (edition) - InfoPlist.strings
    NSDictionary *dict;
    
    if ([self isEffectivelyPremium]) {
        dict = [editionsInfo_ objectForKey:kProductIdPremium];
    } else if ([self isEffectivelyPlus]) {
        dict = [editionsInfo_ objectForKey:kProductIdPlus];
    } else if ([self isEffectivelyFree]) {
        dict = [editionsInfo_ objectForKey:kProductIdFree];
    } else if ([self isPlatinum]) {
        dict = [editionsInfo_ objectForKey:kProductIdPlatinum];    
        
    } else {
        dict = [NSDictionary dictionaryWithObject:@"Error: unknown product." forKey:@"displayName"];
        ELog(@"Unknown product!!");
    }
    
    NSString *identifier = [[LocalizedManager sharedManager] localeIdentifier];
    return [[dict objectForKey:@"displayName"] objectForKey:identifier];
}

-(NSString*)productShortName
{
    NSString *longName = [self productDisplayName];
    NSRange range = [longName rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@":"]];
    return [longName substringToIndex:range.location];
}

-(NSString*)originalProductShortName
{
    NSDictionary *dict;
    
    if ([self isPremium]) {
        dict = [editionsInfo_ objectForKey:kProductIdPremium];
    } else if ([self isPlus]) {
        dict = [editionsInfo_ objectForKey:kProductIdPlus];
    } else if ([self isFree]) {
        dict = [editionsInfo_ objectForKey:kProductIdFree];
    } else if ([self isPlatinum]) {
        dict = [editionsInfo_ objectForKey:kProductIdPlatinum];
        
    } else {
        dict = [NSDictionary dictionaryWithObject:@"Error: unknown product." forKey:@"displayName"];
        ELog(@"Unknown product!!");
    }
    
    NSString *longName = [[dict objectForKey:@"displayName"] objectForKey:@"en"];
    NSRange range = [longName rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@":"]];
    return [longName substringToIndex:range.location];
}


-(NSString*)appStoreURL
{    
    NSDictionary *dict;
    
    if ([self isPremium]) {
        dict = [editionsInfo_ objectForKey:kProductIdPremium];
    } else if ([self isPlus]) {
        dict = [editionsInfo_ objectForKey:kProductIdPlus];
    } else if ([self isFree]) {
        dict = [editionsInfo_ objectForKey:kProductIdFree];
    } else if ([self isPlatinum]) {
        dict = [editionsInfo_ objectForKey:kProductIdPlatinum];    
        
    } else {
        dict = [NSDictionary dictionaryWithObject:@"Error: unknown product." forKey:@"appStoreURL"];
        ELog(@"Unknown product!!");
    }
    
    return [dict objectForKey:@"appStoreURL"];
}

-(NSString*)appStoreURLForProductId:(NSString*)productId
{
    NSDictionary *dict;
    
    if ([productId hasSuffix:@"business"] || [productId hasSuffix:@"premium"]) {
        dict = [editionsInfo_ objectForKey:kProductIdPremium];
    } else if ([productId hasSuffix:@"plus"]) {
        dict = [editionsInfo_ objectForKey:kProductIdPlus];
    } else if ([productId hasSuffix:@"free"]) {
        dict = [editionsInfo_ objectForKey:kProductIdFree];
    } else if ([self isPlatinum]) {
        dict = [editionsInfo_ objectForKey:kProductIdPlatinum];    
        
    } else {
        dict = [NSDictionary dictionaryWithObject:@"Error: unknown product." forKey:@"appStoreURL"];
        ELog(@"Unknown product!! %@", productId);
    }
    
    return [dict objectForKey:@"appStoreURL"];

}

-(NSString*)urlScheme
{
    // schemes have to match the un-upgraded version of the product
    if ([self isFree]) {
        return @"stratpadfree";
    }
    else if ([self isPlus]) {
        return @"stratpadplus";
    }
    else if ([self isPremium]) {
        return @"stratpadpremium";
    }
    else if ([self isPlatinum]) {
        return @"stratpadplatinum";
    }
    else {
        return @"stratpad";
    }
}

#pragma mark - Private

// do we allow users to use the backup functionality?
-(BOOL)isBackupEnabled
{
    // just want to make sure the user is registered and verified
    return [[UAKeychainUtils valueForKey:keyChainVerified] boolValue];
}

// YES if we have recorded any of the StratBoard IAP purchases
-(BOOL)isStratBoardPurchased
{
    // as long as this key exists we're ok, but just be doubly sure
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *stratBoardProductID = [userDefaults stringForKey:keyStratboard];
    return [stratBoardProductID hasSuffix:@"stratbord"];
}

// YES if any combination of IAP or productID makes this a Plus product
-(BOOL)isUpgradedToPlus
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *productId = [userDefaults stringForKey:keyProductId];
    return [productId hasSuffix:@"plus"];
}

// YES if any combination of IAP or productID makes this a Premium product
-(BOOL)isUpgradedToPremium
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *productId = [userDefaults stringForKey:keyProductId];
    return [productId hasSuffix:@"premium"];
}

// YES if any combination of IAP or productID makes this a Pro product
-(BOOL)isUpgradedToPro
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *productId = [userDefaults stringForKey:keyProductId];
    return [productId hasSuffix:@"pro"];
}

#pragma mark - Product Info

-(void)fetchProductInfo:(NSString *)productId completion:(void (^)(NSDictionary *))completion
{
    // host url
    NSDictionary *config = [[NSBundle mainBundle] infoDictionary];
    NSURL *url = [NSURL URLWithString:[config objectForKey:@"MBRegistrationServer"]];
    AFHTTPClient *request = [AFHTTPClient clientWithBaseURL:url];
    
    // params
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            productId, @"productId",
                            [[EditionManager sharedManager] versionNumber], @"api",
                            nil];
    
    // post to server
    [request postPath:@"/productInfo"
           parameters:params
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  id json = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
                  DLog(@"ProductInfo: %@", json);
                                    
                  // complete using provided data
                  completion(json);
                  
              }
              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  ELog(@"Couldn't get productID. Using local data. %@", error);
                  completion([self productInfo:productId]);
              }
     ];

}

// private method used as a fallback to get productInfo if server connection fails somehow
-(NSDictionary*)productInfo:(NSString *)productId
{
    NSString *bundleId = [self baseProductId];
    NSDictionary *dict = [editionsInfo_ objectForKey:bundleId];
    if ([productId isEqualToString:bundleId]) {
        return [NSDictionary dictionaryWithObjectsAndKeys:
                productId, @"productId",
                [NSDecimalNumber decimalNumberWithString:[dict objectForKey:@"priceUS"]], @"price",
                [[dict objectForKey:@"displayName"] objectForKey:@"en"], @"name",
                nil];
    } else {
        NSDictionary *iap = [dict objectForKey:productId];
        return [NSDictionary dictionaryWithObjectsAndKeys:
                productId, @"productId",
                [NSDecimalNumber decimalNumberWithString:[iap objectForKey:@"priceUS"]], @"price",
                [iap objectForKey:@"refName"], @"name",
                nil];
    }

}

@end
