//
//  LocalizedManager.m
//  StratPad
//
//  Created by Vitaliy Nevgadaylov on 12.07.12.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "LocalizedManager.h"
#import "SynthesizeSingleton.h"
#import "NSUserDefaults+StratPad.h"


NSString * const kLMLocaleChanged = @"LMLocaleChanged";

@implementation LocalizedManager

SYNTHESIZE_SINGLETON_FOR_CLASS(LocalizedManager);

@synthesize supportedLanguages = supportedLanguages_;


- (id)init 
{    
    self = [super init];
    if (self) {
        // this will give the list of identifiers used in the System Preferences - about 34 languages
        // the first item is the user's global system preferred language, others are fallbacks
        NSArray *languages = [[NSUserDefaults standardUserDefaults] objectForKey:keyAppleLanguages];
        
        // this will either be the user's preferred language from the system, or the one that we've replaced it with when we instant switch languages
        NSString *preferredLanguage = [languages objectAtIndex:0];
        
        supportedLanguages_ = [[NSArray arrayWithObjects:@"en", @"es", @"es-MX", nil] retain];
            
        // if we support the preferred language, then go ahead
        if ([supportedLanguages_ indexOfObject:preferredLanguage] != NSNotFound) {

            // set the bundle to the preferred, supported language
            bundle_ = [[NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:preferredLanguage ofType:@"lproj"]] retain];
            
        } else {
            
            // set the bundle to english
            bundle_ = [[NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"en" ofType:@"lproj"]] retain];
            
        }
        
        
    }
    return self;
}


- (NSBundle*)currentBundle 
{    
    return bundle_;
}


- (NSString*)localizedStringForKey:(NSString*)key 
{    
    return [bundle_ localizedStringForKey:key value:nil table:nil];
}

- (void)setLocaleIdentifier:(NSString*)identifier 
{
    // for our app only, we change the languages list order when asked
    // this is persisted between app runs, and is used for retrieving resources
    [[NSUserDefaults standardUserDefaults] setObject: [NSArray arrayWithObject:identifier] forKey:keyAppleLanguages];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
//    // set the current bundle to the one matching the new identifier (note no fallbacks)
//    [bundle_ release];
//    bundle_ = nil;
//    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:identifier ofType:@"lproj"];
//    DLog(@"new bundle path: %@", bundlePath);
//    bundle_ = [[NSBundle bundleWithPath:bundlePath] retain];
//    if(bundle_ == nil) {
//        bundle_ = [[NSBundle mainBundle] retain];
//    }
    
//    // notify interested classes
//    [LocalizedManager fireLocaleChanged];
}


- (NSString *)localeIdentifier 
{
    // this gets the current locale identifier (the first in the list)
    NSArray *identifiers = [[NSUserDefaults standardUserDefaults] objectForKey:keyAppleLanguages];
    if([identifiers count] > 1) {
        NSDictionary *dict = [NSLocale componentsFromLocaleIdentifier:[[NSLocale currentLocale] localeIdentifier]];
        return [dict objectForKey:@"kCFLocaleLanguageCodeKey"];
    }
    return [identifiers objectAtIndex:0];    
}


//+ (void)fireLocaleChanged
//{
//	NSNotification *notification = [NSNotification notificationWithName:kLMLocaleChanged object:nil userInfo:nil];
//	[[NSNotificationQueue defaultQueue] enqueueNotification:notification postingStyle:NSPostASAP];		
//}

@end
