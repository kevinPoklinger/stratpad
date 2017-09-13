//
//  UAKeychainUtils+StratPad.m
//  StratPad
//
//  Created by Julian Wood on 12-09-13.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "UAKeychainUtils+StratPad.h"
#import "NSUserDefaults+StratPad.h"

@implementation UAKeychainUtils (StratPad)

+(void)initialize
{
    // clear out the keychain between app installs (but not updates)
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults boolForKey:keyIsKeychainInited]) {
        ILog(@"Cleaning keychain.");
        [UAKeychainUtils deleteKeychainValue:keyChainVerified];
        [UAKeychainUtils deleteKeychainValue:keyChainYammerKey];
        
#if DEBUG
        // we don't normally clear out keyChainEcommerceAppTxnId - would like it to persist across app-installs
        [UAKeychainUtils deleteKeychainValue:keyChainEcommerceAppTxnId];
#endif
        
        [defaults setBool:YES forKey:keyIsKeychainInited];
    }
}

// note that we can just put @"YES" or @"NO" (or any other boolean string) to store booleans; use booleanValue to convert back to BOOL
+(void)putValue:(NSString*)value forKey:(NSString*)key
{
    // creating won't overwrite any previously existing values for this key, so delete it first
    [UAKeychainUtils deleteKeychainValue:key];
    [UAKeychainUtils createKeychainValueForUsername:value
                                       withPassword:@""
                                      forIdentifier:key];
}

+(void)updateValue:(NSString*)value forKey:(NSString*)key
{
    // the update routine doesn't work as expected, so delete and recreate
    [UAKeychainUtils deleteKeychainValue:key];
    [UAKeychainUtils putValue:value forKey:key];
}

+(NSString*)valueForKey:(NSString*)key
{
    return [UAKeychainUtils getUsername:key];
}

@end
