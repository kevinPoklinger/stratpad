/* Copyright 2017 Urban Airship and Contributors */

#import "UAKeychainUtils.h"

// C includes
#include <sys/types.h>
#include <sys/sysctl.h>
#import <Security/Security.h>

static NSString *cachedDeviceID_ = nil;

@interface UAKeychainUtils()
+ (NSMutableDictionary *)searchDictionaryWithIdentifier:(NSString *)identifier;

/**
 * Creates a new UA Device ID (UUID) and stores it in the keychain.
 *
 * @return The device ID.
 */
+ (NSString *)createDeviceID;
@end


@implementation UAKeychainUtils

+ (BOOL)createKeychainValueForUsername:(NSString *)username withPassword:(NSString *)password forIdentifier:(NSString *)identifier {
    NSMutableDictionary *userDictionary = [UAKeychainUtils searchDictionaryWithIdentifier:identifier];

    // Set access permission - we use the keychain for it's stickiness, not security,
    // So the least permissive setting is acceptable here
    [userDictionary setObject:(__bridge id)kSecAttrAccessibleAlways forKey:(__bridge id)kSecAttrAccessible];

    // Set username data
    [userDictionary setObject:username forKey:(__bridge id)kSecAttrAccount];

    // Set password data
    NSData *passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
    [userDictionary setObject:passwordData forKey:(__bridge id)kSecValueData];

    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)userDictionary, NULL);

    if (status == errSecSuccess) {
        return YES;
    }

    return NO;
}

+ (void)deleteKeychainValue:(NSString *)identifier {
    NSMutableDictionary *searchDictionary = [UAKeychainUtils searchDictionaryWithIdentifier:identifier];
    SecItemDelete((__bridge CFDictionaryRef)searchDictionary);
}

+ (BOOL)updateKeychainValueForUsername:(NSString *)username 
                          withPassword:(NSString *)password 
                         forIdentifier:(NSString *)identifier {

    //setup search dict, use username as query param
    NSMutableDictionary *searchDictionary = [self searchDictionaryWithIdentifier:identifier];
    [searchDictionary setObject:username forKey:(__bridge id)kSecAttrAccount];

    //update password
    NSMutableDictionary *updateDictionary = [NSMutableDictionary dictionary];
    NSData *passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
    [updateDictionary setObject:passwordData forKey:(__bridge id)kSecValueData];

    OSStatus status = SecItemUpdate((__bridge CFDictionaryRef)searchDictionary,
                                    (__bridge CFDictionaryRef)updateDictionary);

    if (status == errSecSuccess) {
        return YES;
    }

    return NO;
}

/**
 * Helper method to get the user credentials.
 *
 * @return The results dictionary with the username stored under the kSecAttrAccount key,
 * and the password stored under kSecValueData.
 */
+ (NSDictionary *)getUserCredentials:(NSString *)identifier {
    if (!identifier) {
        return nil;
    }

    NSMutableDictionary *searchQuery = [UAKeychainUtils searchDictionaryWithIdentifier:identifier];

    // Add search attributes
    [searchQuery setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];

    // Add search return types
    [searchQuery setObject:(id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
    [searchQuery setObject:(id)kCFBooleanTrue forKey:(__bridge id)kSecReturnAttributes];


    CFDictionaryRef resultDataRef = nil;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)searchQuery, (CFTypeRef *)&resultDataRef);
    NSDictionary *resultDict = ( NSDictionary *)resultDataRef;

    if (status == errSecSuccess && resultDict) {
        return resultDict;
    }

    return nil;
}

+ (NSString *)getPassword:(NSString *)identifier {
    NSDictionary *credentials = [self getUserCredentials:identifier];
    if (credentials) {
        return [[NSString alloc] initWithData:[credentials valueForKey:(__bridge id)kSecValueData] encoding:NSUTF8StringEncoding];
    }
    return nil;
}

+ (NSString *)getUsername:(NSString *)identifier {
    NSDictionary *credentials = [self getUserCredentials:identifier];
    return [[credentials objectForKey:(__bridge id)kSecAttrAccount] copy];
}

+ (NSMutableDictionary *)searchDictionaryWithIdentifier:(NSString *)identifier {
    NSMutableDictionary *searchDictionary = [NSMutableDictionary dictionary];

    [searchDictionary setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];

    //use identifier param and the bundle ID as keys
    NSData *encodedIdentifier = [identifier dataUsingEncoding:NSUTF8StringEncoding];
    [searchDictionary setObject:encodedIdentifier forKey:(__bridge id)kSecAttrGeneric];

    NSString *bundleID = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    [searchDictionary setObject:bundleID forKey:(__bridge id)kSecAttrService];

    return searchDictionary; 
}

#pragma mark -
#pragma UA Device ID

+ (NSString *)deviceModelName {
    size_t size;
    
    // Set 'oldp' parameter to NULL to get the size of the data
    // returned so we can allocate appropriate amount of space
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    
    // Allocate the space to store name
    char *name = malloc(size);
    
    // Get the platform name
    sysctlbyname("hw.machine", name, &size, NULL, 0);
    
    // Place name into a string
    NSString *machine = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
    
    // Done with this
    free(name);
    
    return machine;
}

+ (NSString *)createDeviceID {
    NSString *deviceID = [NSUUID UUID].UUIDString;

    NSMutableDictionary *keychainValues = [UAKeychainUtils searchDictionaryWithIdentifier:kUAKeychainDeviceIDKey];

    //set access permission - we use the keychain for its stickiness, not security,
    //so the least permissive setting is acceptable here
    [keychainValues setObject:(__bridge id)kSecAttrAccessibleAlwaysThisDeviceOnly forKey:(__bridge id)kSecAttrAccessible];

    //set model name (username) data
    [keychainValues setObject:[UAKeychainUtils deviceModelName] forKey:(__bridge id)kSecAttrAccount];

    //set device ID (password) data
    NSData *deviceIDData = [deviceID dataUsingEncoding:NSUTF8StringEncoding];
    [keychainValues setObject:deviceIDData forKey:(__bridge id)kSecValueData];

    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)keychainValues, NULL);

    if (status == errSecSuccess) {
        return deviceID;
    } else {
        return @"";
    }
}

+ (NSString *)getDeviceID {

    if (cachedDeviceID_) {
        return cachedDeviceID_;
    }

    //Get password next
    NSMutableDictionary *deviceIDQuery = [UAKeychainUtils searchDictionaryWithIdentifier:kUAKeychainDeviceIDKey];

    // Add search attributes
    [deviceIDQuery setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];

    // Add search return types
    [deviceIDQuery setObject:(id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
    [deviceIDQuery setObject:(id)kCFBooleanTrue forKey:(__bridge id)kSecReturnAttributes];

    CFDictionaryRef resultDataRef = nil;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)deviceIDQuery, (CFTypeRef *)&resultDataRef);

    NSDictionary *resultDict = ( NSDictionary *)resultDataRef;

    NSString *deviceID = nil;
    if (status == errSecSuccess) {

        if (resultDataRef) {

            // Check if we have the old attribute type
            if ([[[resultDict objectForKey:(__bridge id)kSecAttrAccessible] copy] isEqualToString:(__bridge NSString *)(kSecAttrAccessibleAlways)]) {
                // Update the deviceID attribute to kSecAttrAccessibleAlwaysThisDeviceOnly
                NSMutableDictionary *updateQuery = [NSMutableDictionary dictionary];

                // Set the new attribute
                [updateQuery setObject:(__bridge id)kSecAttrAccessibleAlwaysThisDeviceOnly forKey:(__bridge id)kSecAttrAccessible];

                // Perform the update
                OSStatus status = SecItemUpdate((__bridge CFDictionaryRef)[UAKeychainUtils searchDictionaryWithIdentifier:kUAKeychainDeviceIDKey], (__bridge CFDictionaryRef)updateQuery);
            }

            // Grab the device ID
            deviceID = [[NSString alloc] initWithData:[resultDict valueForKey:(__bridge id)kSecValueData] encoding:NSUTF8StringEncoding];
        } else {
            
        }
    }

    if (!deviceID) {
        [UAKeychainUtils deleteKeychainValue:kUAKeychainDeviceIDKey];
        deviceID = [UAKeychainUtils createDeviceID];
    }

    cachedDeviceID_ = [deviceID copy];

    return deviceID;
}

@end
