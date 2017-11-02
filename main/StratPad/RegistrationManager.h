//
//  RegistrationManager.h
//  StratPad
//
//  Created by Julian Wood on 12-09-12.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSUserDefaults+StratPad.h"
#import "StratFile.h"

@class RegisterOrSkipViewController;

// values for keyRegistrationStatus in NSUserDefaults
typedef enum {
    RegistrationStatusNone,         // form hasn't been submitted
    RegistrationStatusSubmitted,    // form has been submitted
    RegistrationStatusValidated     // user has received email and successfully validated stratpad
} RegistrationStatus;


typedef void (^RegisterCallback)(BOOL bSuccess);

RegisterCallback mCallback;

@interface RegistrationManager : NSObject

// true while we are validating the email provided to us after clicking a link in the received email
// prevent appdelegate from reminding us to check our email
@property (nonatomic, assign) BOOL isValidatingEmail;

// identify the different stages of registration (not currently using)
@property (nonatomic, assign) RegistrationStatus registrationStatus;

@property (nonatomic, assign) RegisterOrSkipViewController* mController;

// init
+ (RegistrationManager *)sharedManager;

-(void)uploadBackup:(NSString*)path stratfile:(StratFile*)stratfile;

-(void)registerEmail:(NSString*)email firstName:(NSString*)firstName lastName:(NSString*)lastName;
-(void)validateEmail:(NSString*)email regKey:(NSString*)regKey;
-(void)checkValidation;

-(void)registerEmail:(NSString*)email firstName:(NSString*)firstName lastName:(NSString*)lastName callback:(RegisterCallback) callback;

// provide a target and action to be called, on success only
-(void)invalidateRegistration:(id)target action:(SEL)action;

// notify our server that either stratpad or stratboard (or both) was upgraded
-(void)upgradeStratPad:(BOOL)isEditionUpgraded isStratBoardUpgraded:(BOOL)isStratBoardUpgraded;

// figures out what stage of registration you are at, and shows you the welcome, the form, or a reminder notification
-(void)showRelevantReminderInView:(UIView*)view;

// gives us a string like e.g. "iPad2,2"
+(NSString*)modelAsString;


@end
