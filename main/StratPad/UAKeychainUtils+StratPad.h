//
//  UAKeychainUtils+StratPad.h
//  StratPad
//
//  Created by Julian Wood on 12-09-13.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//
//  Note there is no way to reset these values on device (other than programmatically). If you delete the app, they are still there! Therefore, we clear these 3 keys out on any first runs, as indicated by a key in NSUserDefaults. ie. Just delete the simulator build and it will behave normally.
//  These Keychain values must be namespaced to your app, right? Yes.
//  On the simulator you can clear them out by resetting contents and settings, or by deleting eg.:
//     ~/Library/Application Support/iPhone Simulator/5.1/Library/Keychains

#import <Foundation/Foundation.h>
#import "UAKeychainUtils.h"

// stored on verification after tapping the email, in the keychain; cleared on app-reinstall; verified is synonym for validated
#define keyChainVerified                    @"registrationVerified"

// we store several values in this chain: the username represents the network permalink; the password represents the permanent auth token; cleared on app-reinstall
#define keyChainYammerKey                   @"yammerToken"

// we have to invent a txn id for the app purchase, which is recorded on first run of the app; this is to try and stop recording the txn in duplicate;
#define keyChainEcommerceAppTxnId                       @"eCommerceAppTxnId"


@interface UAKeychainUtils (StratPad)
+(void)putValue:(NSString*)value forKey:(NSString*)key;
+(void)updateValue:(NSString*)value forKey:(NSString*)key;
+(NSString*)valueForKey:(NSString*)key;
// delete is the same
@end
