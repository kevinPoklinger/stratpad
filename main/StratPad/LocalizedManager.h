//
//  LocalizedManager.h
//  StratPad
//
//  Created by Vitaliy Nevgadaylov on 12.07.12.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//
//  Extend LMViewController to get automatic loading of the appropriate localized nib and strings.
//  Anybody listening to the kLMLocaleChanged event will be notified that the localized bundle has changed
//  Note that any viewcontroller subclassing LMViewController will already be listening to this event - can't just add another target
//
//  Note that at startup, we will get the user's preferred language and use that if possible
//  This can be overridden on an app-specific basis

#import <Foundation/Foundation.h>

extern NSString * const kLMLocaleChanged;

@interface LocalizedManager : NSObject {
    
    NSBundle *bundle_;
}

// array of identifiers for existing localizations
@property (nonatomic,retain,readonly) NSArray *supportedLanguages;

// constructor
+ (LocalizedManager *)sharedManager;

// get a translated string from the current bundle
- (NSString *)localizedStringForKey:(NSString *)key;

// gives access to the currently loaded bundle of localized resources
- (NSBundle *)currentBundle;

// the current globally loaded bundle identifier; typically a string such as "en" or "es"
- (NSString *)localeIdentifier;

// to switch the globally loaded bundle; typically a string such as "en" or "es"
// fires a kLMLocaleChanged event
- (void)setLocaleIdentifier:(NSString *)identifier;

@end