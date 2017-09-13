//
//  EditionManagerTest.m
//  StratPad
//
//  Created by Julian Wood on 12-01-02.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "EditionManager.h"
#import "NSUserDefaults+StratPad.h"

@interface EditionManagerTest : SenTestCase {
    NSString *productId_;
}

@end

@implementation EditionManagerTest


-(void)setUp
{
    // store the productId for restoring at the end of the test
    // note that this only applies for IAP's; the primary app id is stored in the info.plist
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    productId_ = [[userDefaults stringForKey:keyProductId] retain];
}

- (void)tearDown
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:productId_ forKey:keyProductId];
}

- (void)dealloc
{
    [productId_ release];
    [super dealloc];
}

- (void)testIsFeatureEnabled
{
    // note that we normally run tests under Premium
    // this test will adjust, depending on the test target
    
    NSDictionary *plistData = [[NSBundle mainBundle] infoDictionary];
    NSString *bundleId = [plistData valueForKey:@"CFBundleIdentifier"];
    DLog(@"bundleId: %@", bundleId);
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults]; 
    BOOL isEnabled;
    
    // checks only the bundleId of the Build Phase->Target Dependency->Info.plist
    if ([[EditionManager sharedManager] isPremium]) {
        
        isEnabled = [[EditionManager sharedManager] isFeatureEnabled:FeatureAddStratFiles];
        STAssertTrue(isEnabled, @"Premium should include feature: %i", FeatureAddStratFiles);
        
        isEnabled = [[EditionManager sharedManager] isFeatureEnabled:FeatureDeleteStratFiles];
        STAssertTrue(isEnabled, @"Premium should include feature: %i", FeatureDeleteStratFiles);
        
        isEnabled = [[EditionManager sharedManager] isFeatureEnabled:FeatureCanShareReports];
        STAssertTrue(isEnabled, @"Premium should include feature: %i", FeatureCanShareReports);

        
    } else if ([[EditionManager sharedManager] isPlus]) {

        BOOL isEnabled = [[EditionManager sharedManager] isFeatureEnabled:FeatureAddStratFiles];
        STAssertFalse(isEnabled, @"Plus should not include feature: %i", FeatureAddStratFiles);
        
        isEnabled = [[EditionManager sharedManager] isFeatureEnabled:FeatureDeleteStratFiles];
        STAssertFalse(isEnabled, @"Plus should not include feature: %i", FeatureDeleteStratFiles);
        
        isEnabled = [[EditionManager sharedManager] isFeatureEnabled:FeatureCanShareReports];
        STAssertTrue(isEnabled, @"Plus should include feature: %i", FeatureCanShareReports);
        
        // plus to premium IAP
        [userDefaults setValue:kProductIdPlusToPremiumUpgrade forKey:keyProductId];
        
        isEnabled = [[EditionManager sharedManager] isFeatureEnabled:FeatureAddStratFiles];
        STAssertTrue(isEnabled, @"Premium IAP should include feature: %i", FeatureAddStratFiles);
        
        isEnabled = [[EditionManager sharedManager] isFeatureEnabled:FeatureDeleteStratFiles];
        STAssertTrue(isEnabled, @"Premium IAP should include feature: %i", FeatureDeleteStratFiles);
        
        isEnabled = [[EditionManager sharedManager] isFeatureEnabled:FeatureCanShareReports];
        STAssertTrue(isEnabled, @"Premium IAP should include feature: %i", FeatureCanShareReports);

        
    } else if ([[EditionManager sharedManager] isFree]) {
        
        // free to premium IAP
        [userDefaults setValue:kProductIdFreeToPremiumUpgrade forKey:keyProductId];
        
        BOOL isEnabled = [[EditionManager sharedManager] isFeatureEnabled:FeatureAddStratFiles];
        STAssertTrue(isEnabled, @"Premium IAP should include feature: %i", FeatureAddStratFiles);
        
        isEnabled = [[EditionManager sharedManager] isFeatureEnabled:FeatureDeleteStratFiles];
        STAssertTrue(isEnabled, @"Premium IAP should include feature: %i", FeatureDeleteStratFiles);
        
        isEnabled = [[EditionManager sharedManager] isFeatureEnabled:FeatureCanShareReports];
        STAssertTrue(isEnabled, @"Premium IAP should include feature: %i", FeatureCanShareReports);
        
        // free to plus IAP
        [userDefaults setValue:kProductIdFreeToPlusUpgrade forKey:keyProductId];
        
        isEnabled = [[EditionManager sharedManager] isFeatureEnabled:FeatureAddStratFiles];
        STAssertFalse(isEnabled, @"Plus IAP should not include feature: %i", FeatureAddStratFiles);
        
        isEnabled = [[EditionManager sharedManager] isFeatureEnabled:FeatureDeleteStratFiles];
        STAssertFalse(isEnabled, @"Plus IAP should not include feature: %i", FeatureDeleteStratFiles);
        
        isEnabled = [[EditionManager sharedManager] isFeatureEnabled:FeatureCanShareReports];
        STAssertTrue(isEnabled, @"Plus IAP should include feature: %i", FeatureCanShareReports);

        // free to plus to premium IAP
        [userDefaults setValue:kProductIdFreeToPlusToPremiumUpgrade forKey:keyProductId];
        
        isEnabled = [[EditionManager sharedManager] isFeatureEnabled:FeatureAddStratFiles];
        STAssertTrue(isEnabled, @"Premium IAP should include feature: %i", FeatureAddStratFiles);
        
        isEnabled = [[EditionManager sharedManager] isFeatureEnabled:FeatureDeleteStratFiles];
        STAssertTrue(isEnabled, @"Premium IAP should include feature: %i", FeatureDeleteStratFiles);
        
        isEnabled = [[EditionManager sharedManager] isFeatureEnabled:FeatureCanShareReports];
        STAssertTrue(isEnabled, @"Premium IAP should include feature: %i", FeatureCanShareReports);
        
    }
   
}

// is the current app model compatible with these .stratfile model numbers? can we deal with them?
// update compatibility matrix.plist with compatible versions as a function of the current version
// note that we are testing the current version against these ones, so asserts will change
- (void)testIsModelCompatible 
{
    // eg. if current model is StratPad 1.4 (918), is that compatible with StratPad 1.1.2 (622)
    // 
    BOOL isCompatible = [[EditionManager sharedManager] isModelCompatible:@"StratPad 1.1.2 (622)"];
    STAssertTrue(isCompatible, @"Oops");

    isCompatible = [[EditionManager sharedManager] isModelCompatible:@"StratPad 1.1.2 (617)"];
    STAssertFalse(isCompatible, @"Oops");

    isCompatible = [[EditionManager sharedManager] isModelCompatible:@"StratPad 1.1.2 (537)"];
    STAssertFalse(isCompatible, @"Oops");

    // doesn't exist
    isCompatible = [[EditionManager sharedManager] isModelCompatible:@"StratPad 1.2 (665)"];
    STAssertFalse(isCompatible, @"Oops");

    isCompatible = [[EditionManager sharedManager] isModelCompatible:@"StratPad 1.2 (668)"];
    STAssertTrue(isCompatible, @"Oops");

    isCompatible = [[EditionManager sharedManager] isModelCompatible:@"StratPad 1.1 (622)"];
    STAssertTrue(isCompatible, @"Oops");

    isCompatible = [[EditionManager sharedManager] isModelCompatible:@"StratPad 1.2.1 (738)"];
    STAssertTrue(isCompatible, @"Oops");

    
}

- (void)testCompareVersions
{
    NSComparisonResult result = [[EditionManager sharedManager] compareVersions:@"1.3.5" otherVersion:@"1.4"];
    STAssertTrue(result == NSOrderedAscending, @"Oops");

    result = [[EditionManager sharedManager] compareVersions:@"1.3.5" otherVersion:@"1.4.1"];
    STAssertTrue(result == NSOrderedAscending, @"Oops");

    result = [[EditionManager sharedManager] compareVersions:@"1.3.5" otherVersion:@"1"];
    STAssertTrue(result == NSOrderedDescending, @"Oops");

    result = [[EditionManager sharedManager] compareVersions:@"1.3.5" otherVersion:@"1.2"];
    STAssertTrue(result == NSOrderedDescending, @"Oops");

    result = [[EditionManager sharedManager] compareVersions:@"1.3.0" otherVersion:@"1.3"];
    STAssertTrue(result == NSOrderedSame, @"Oops");
    
    result = [[EditionManager sharedManager] compareVersions:@"1.6" otherVersion:@"1.4.1"];
    STAssertTrue(result == NSOrderedDescending, @"Oops");
}

-(void)testCompareModelVersions
{
    NSComparisonResult result = [[EditionManager sharedManager] compareModelVersions:@"StratPad 1.3 (617)" otherModelVersion:@"StratPad 1.5.4 (957)"];
    STAssertTrue(result == NSOrderedAscending, @"Oops");

    result = [[EditionManager sharedManager] compareModelVersions:@"StratPad 1.7 (1200)" otherModelVersion:@"StratPad 1.6 (1090)"];
    STAssertTrue(result == NSOrderedDescending, @"Oops");

    result = [[EditionManager sharedManager] compareModelVersions:@"StratPad 1.6.0 (1200)" otherModelVersion:@"StratPad 1.6 (1200)"];
    STAssertTrue(result == NSOrderedSame, @"Oops");

}

- (void)testAppStoreURLForProductId
{
    NSString *url = [[EditionManager sharedManager] appStoreURLForProductId:kProductIdPremium];
    STAssertEqualObjects(@"http://itunes.apple.com/app/stratpad-for-business/id465233220?mt=8", url, @"Oops");
    
    url = [[EditionManager sharedManager] appStoreURLForProductId:kProductIdFree];
    STAssertEqualObjects(@"http://itunes.apple.com/app/stratpad-free-strategic-business/id540225053?ls=1&mt=8", url, @"Oops");

    url = [[EditionManager sharedManager] appStoreURLForProductId:kProductIdPlus];
    STAssertEqualObjects(@"http://itunes.apple.com/app/stratpad-plus-strategy-business/id486654615?mt=8", url, @"Oops");
    
    
    // IAPS
    url = [[EditionManager sharedManager] appStoreURLForProductId:kProductIdPlusToPremiumUpgrade];
    STAssertEqualObjects(@"http://itunes.apple.com/app/stratpad-for-business/id465233220?mt=8", url, @"Oops");
}

@end
