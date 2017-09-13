//
//  RegistrationManager.m
//  StratPad
//
//  Created by Julian Wood on 12-09-12.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//
// TODO: transition to https://github.com/AFNetworking/AFNetworking (and thus ios >=5 only)

#import "RegistrationManager.h"
#import "SynthesizeSingleton.h"
#import "ASIFormDataRequest.h"
#import "SBJSon/SBJson.h"
#import "EditionManager.h"
#import "UserNotificationDisplayManager.h"
#import "UAKeychainUtils+StratPad.h"
#import "RootViewController.h"
#import "NSString-Expanded.h"
#import "ThankYouViewController.h"
#import "RegisterOrSkipViewController.h"
#import "NSDate-StratPad.h"
#import "RegisterWelcomeViewController.h"
#include <sys/utsname.h>
#import "PageViewController.h"
#import "RootViewController.h"
#import "AppDelegate.h"
#import "Tracking.h"
#import "UIDevice+IdentifierAddition.h"
#import "NSString-Expanded.h"
#import "AFNetworking.h"
#import "RegisterOrSkipViewController.h"
#import "MBLoadingView.h"

// this must match the appid hard coded into GAE service
#define gaeappid        @"189f81a71001cc46c410d55c473af810"

@interface RegistrationManager ()

// the popover shown thanking the user after validation
@property (nonatomic,retain) UIPopoverController *registrationPopover;

@end

@implementation RegistrationManager

@synthesize isValidatingEmail;

SYNTHESIZE_SINGLETON_FOR_CLASS(RegistrationManager)

#pragma mark - Lifecycle

- (id)init
{
    self = [super init];
    if (self) {
        [ASIHTTPRequest setShouldThrottleBandwidthForWWAN:NO];
    }
    return self;
}

- (void)dealloc
{
    [_registrationPopover release];
    [super dealloc];
}

#pragma mark - Register

-(void)registerEmail:(NSString*)email firstName:(NSString*)firstName lastName:(NSString*)lastName callback:(RegisterCallback) callback {
    mCallback = callback;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    // trim whitespace
    NSString *nEmail = [[email lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *nFirstName = [firstName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *nLastName = [lastName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSDictionary *config = [[NSBundle mainBundle] infoDictionary];
    NSString *urlString = [[config objectForKey:@"MBRegistrationServer"] stringByAppendingString:@"/register"];
    NSURL *url = [NSURL URLWithString:urlString];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostValue:nEmail forKey:@"email"];
    [request setPostValue:nFirstName forKey:@"firstName"];
    [request setPostValue:nLastName forKey:@"lastName"];
    [request setPostValue:[[EditionManager sharedManager] productShortName] forKey:@"effectiveEdition"];
    [request setPostValue:[[EditionManager sharedManager] originalProductShortName] forKey:@"edition"];
    [request setPostValue:[[EditionManager sharedManager] versionNumber] forKey:@"version"];
    [request setPostValue:[[UIDevice currentDevice] uniqueGlobalDeviceIdentifier] forKey:@"deviceId"];
    [request setPostValue:gaeappid forKey:@"appid"];
    
    // demographics
    NSLocale *locale = [NSLocale currentLocale];
    NSString *countryCode = [locale objectForKey: NSLocaleCountryCode];
    NSString *country = [locale displayNameForKey: NSLocaleCountryCode value: countryCode];
    NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
    
    [request setPostValue:[RegistrationManager modelAsString] forKey:@"deviceModel"];
    [request setPostValue:[[UIDevice currentDevice] systemVersion] forKey:@"osVersion"];
    [request setPostValue:country forKey:@"country"];
    [request setPostValue:language forKey:@"language"];
    [request setPostValue:[[EditionManager sharedManager] versionNumber] forKey:@"api"];
    
    [request setTimeOutSeconds:10];
    [request setShouldContinueWhenAppEntersBackground:YES];
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(registerFinished:)];
    [request setDidFailSelector:@selector(registerFailed:)];
    
    [request startAsynchronous];
    
    // store values locally, used when user goes to verify
    [userDefaults setValue:nEmail forKey:keyEmail];
    [userDefaults setValue:nFirstName forKey:keyFirstName];
    [userDefaults setValue:nLastName forKey:keyLastName];
    
    // we don't want the user to just bypass the whole system by changing a bool pref
    [UAKeychainUtils putValue:@"NO" forKey:keyChainVerified];
    
    [Tracking logEvent:kTrackingEventRegistered];
}


-(void)registerEmail:(NSString*)email firstName:(NSString*)firstName lastName:(NSString*)lastName
{
    // curl -d "appid=189f81a71001cc46c410d55c473af810&email=jwoodchip@gmail.com&firstName=Julian&lastName=Wood&edition=Platinum&version=1.4.2" https://istratpad.appspot.com
    
    // note that 1.5 delivered the effective edition to registration; 1.5.1 delivered the original edition; 1.5.2 delivers orginal edition and effective edition - all at the time of registration; any upgrades will also set both original and effective editions
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    // trim whitespace
    NSString *nEmail = [[email lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *nFirstName = [firstName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *nLastName = [lastName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

    NSDictionary *config = [[NSBundle mainBundle] infoDictionary];
    NSString *urlString = [[config objectForKey:@"MBRegistrationServer"] stringByAppendingString:@"/register"];
    NSURL *url = [NSURL URLWithString:urlString];

    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostValue:nEmail forKey:@"email"];
    [request setPostValue:nFirstName forKey:@"firstName"];
    [request setPostValue:nLastName forKey:@"lastName"];
    [request setPostValue:[[EditionManager sharedManager] productShortName] forKey:@"effectiveEdition"];
    [request setPostValue:[[EditionManager sharedManager] originalProductShortName] forKey:@"edition"];
    [request setPostValue:[[EditionManager sharedManager] versionNumber] forKey:@"version"];    
    [request setPostValue:[[UIDevice currentDevice] uniqueGlobalDeviceIdentifier] forKey:@"deviceId"];
    [request setPostValue:gaeappid forKey:@"appid"];
    
    // demographics
    NSLocale *locale = [NSLocale currentLocale];
    NSString *countryCode = [locale objectForKey: NSLocaleCountryCode];
    NSString *country = [locale displayNameForKey: NSLocaleCountryCode value: countryCode];
    NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
    
    [request setPostValue:[RegistrationManager modelAsString] forKey:@"deviceModel"];
    [request setPostValue:[[UIDevice currentDevice] systemVersion] forKey:@"osVersion"];
    [request setPostValue:country forKey:@"country"];
    [request setPostValue:language forKey:@"language"];
    [request setPostValue:[[EditionManager sharedManager] versionNumber] forKey:@"api"];
    
    
    NSLog(@"%@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@", url, nEmail, nFirstName, nLastName, [[EditionManager sharedManager] productShortName], [[EditionManager sharedManager] originalProductShortName], [[EditionManager sharedManager] versionNumber], [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier], gaeappid, [RegistrationManager modelAsString], [[UIDevice currentDevice] systemVersion], country, language, [[EditionManager sharedManager] versionNumber]);
    
    [request setTimeOutSeconds:10];
    [request setShouldContinueWhenAppEntersBackground:YES];
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(registerFinished:)];
    [request setDidFailSelector:@selector(registerFailed:)];
    
    [request startAsynchronous];
    
    // store values locally, used when user goes to verify
    [userDefaults setValue:nEmail forKey:keyEmail];
    [userDefaults setValue:nFirstName forKey:keyFirstName];
    [userDefaults setValue:nLastName forKey:keyLastName];
    
    // we don't want the user to just bypass the whole system by changing a bool pref
    [UAKeychainUtils putValue:@"NO" forKey:keyChainVerified];
    
    [Tracking logEvent:kTrackingEventRegistered];
    
    
    
    //[[NSUserDefaults standardUserDefaults] setInteger:RegistrationStatusSubmitted forKey:keyRegistrationStatus];

}

- (void)registerFinished:(ASIHTTPRequest *)theRequest
{
    // parse json
    if ([theRequest responseStatusCode] != 200) {
                        
        [self registerFailed:theRequest];
    } else {
        
        DLog(@"result: %@", [theRequest responseString]);
        
        // success
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSDictionary *json = [jsonParser objectWithString:[theRequest responseString]];
        [jsonParser release];
        
        // if number of rows is 1, then we are good
        int rows = [[json objectForKey:@"rows"] intValue];
        if (rows == 1) {
            
            // we don't store the token/regKey any more - it is always getting out of sync
            
            [[NSUserDefaults standardUserDefaults] setInteger:RegistrationStatusSubmitted forKey:keyRegistrationStatus];
            
            [[UserNotificationDisplayManager sharedManager] showMessage:LocalizedString(@"REGISTRATION_SUCCESS_MESSAGE", nil)];
            
        } else {
            WLog(@"Failed email registration: %@", [json objectForKey:@"error"]);
            [self registerFailed:theRequest];
        }
        
        //mCallback(true);
        [_mController.loadingView dismiss];
        [_mController dismissPopover];
    }
    
    // reset these for good measure, in case we have to start over
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:keyShownCount];
    [userDefaults removeObjectForKey:keyLastShownDate];
}

- (void)registerFailed:(ASIHTTPRequest *)theRequest
{    
    NSError *error = theRequest.error;
    [[UserNotificationDisplayManager sharedManager] showErrorMessage:LocalizedString(@"REGISTER_ERROR_MESSAGE", nil)];
    ELog(@"Register email post error: %@. URL: %@", error, theRequest.url);
    [_mController.loadingView dismiss];
}


#pragma mark - Validate

-(NSString*)regKey:(NSString*)email
{
//# take the email
//# swap strings on either side of the @ - eg stratpad.com@julian
//# remove non-alphanumeric, non-lc - eg stratpadcomjulian
//# ascii encode (decimal) - &#115;&#116;&#114;&#097;&#116;&#112;&#097;&#100;&#099;&#111;&#109;&#106;&#117;&#108;&#105;&#097;&#110;
//# (n+1)*3 - &#348;...
//# replace 348351...
//# md5

    if (!email || [email isBlank]) {
        return nil;
    }
    
    NSArray *parts = [email componentsSeparatedByString:@"@"];
    if (parts.count < 2) {
        return nil;
    }
    
    NSString *s = [NSString stringWithFormat:@"%@%@", [parts objectAtIndex:1], [parts objectAtIndex:0]];
    s = [s stringByReplacingOccurrencesOfString:@"[^a-z]"
                                                 withString:@""
                                                    options:NSRegularExpressionSearch
                                                      range:NSMakeRange(0, s.length)];
    NSMutableString *a =[NSMutableString string];
    for (uint i=0; i<s.length; ++i) {
        unichar c = [s characterAtIndex:i];
        [a appendFormat:@"%i", ((int)c+1)*3];
    }
    return [a md5];
}

-(void)checkValidation
{
    //    curl "http://localhost:8081/153/checkValidation?appid=189f81a71001cc46c410d55c473af810&email=julian@mobilesce.com"
    
    if (![[UAKeychainUtils valueForKey:keyChainVerified] boolValue]) {
        
        isValidatingEmail = YES;

        // host url
        NSDictionary *config = [[NSBundle mainBundle] infoDictionary];
        NSURL *url = [NSURL URLWithString:[config objectForKey:@"MBRegistrationServer"]];
        AFHTTPClient *request = [AFHTTPClient clientWithBaseURL:url];
        
        // params
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *email = [userDefaults stringForKey:keyEmail];
        if (!email) {
            // no email entered yet - no sense in checking
            DLog(@"No email entered yet - not checking validation.");
            isValidatingEmail = NO;
            return;
        }
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                email, @"email",
                                gaeappid, @"appid",
                                [[EditionManager sharedManager] versionNumber], @"api",
                                nil];
        
        // post to server
        [request getPath:@"/153/checkValidation"
              parameters:params
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     isValidatingEmail = NO;
                     
                     NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
                     DLog(@"Validation check: %@", json);
                     
                     if ([[json objectForKey:@"valid"] boolValue]) {
                         // this is just for completeness
                         [[NSUserDefaults standardUserDefaults] setInteger:RegistrationStatusValidated forKey:keyRegistrationStatus];
                         
                         // this one is the real source of truth
                         [UAKeychainUtils updateValue:@"YES" forKey:keyChainVerified];
                         
                         // notify
                         [self showThankYouPopover];
                     }
         
                 }
                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     isValidatingEmail = NO;

                     // silent
                     ELog(@"Couldn't check validation: %@", error);
                 }
         ];
                
    }

}

-(void)validateEmail:(NSString*)email regKey:(NSString*)regKey
{
//    Now we check with the server to see if you are valid, rather than telling the server we are valid.
//
//    Two scenarios now:
//    1. We check our "user-validated" flag, and if no, then we check with the server and update
//      - if no, remind the user to register/validate
//    2. User enters the key manually (eg offline)
//      - update our "user-validated" flag if warranted
//      - we should tell the server the user validated, when we can (basically this is the same as before)
    
//   keyChainVerified (in the KeyChain) is what we check to see if the user is fully registered and validated
//   keyRegistrationStatus (in NSUserDefaults) is what we check to see if the user has submitted a registration, validated a registration, or done nothing
    
    
    // we don't really need to check the email
    // we also don't need to trim and lower the email - the server does that anyway
    
    // turn this off after showing the reminder (or completing validation), which is what checks this flag
    isValidatingEmail = YES;
    
    if (!email || !regKey) {
        WLog(@"Registration validation failed with nil email or registration key.")
        [[UserNotificationDisplayManager sharedManager] showErrorMessage:LocalizedString(@"VALIDATION_ERROR_MESSAGE_NIL_ARG", nil)];
//        isValidatingEmail = NO;
        return;
    }
    
    // check regKey validity (can generate regKey from email)
    if (![regKey isEqualToString:[self regKey:email]]) {
        WLog(@"Invalid regKey.")
        [[UserNotificationDisplayManager sharedManager] showErrorMessage:LocalizedString(@"VALIDATION_ERROR_MESSAGE_BAD_TOKEN", nil)];
//        isValidatingEmail = NO;
        return;
    }
    
    // re-validating if we've already validated successfully is a noop
    BOOL isValidated = [[UAKeychainUtils valueForKey:keyChainVerified] boolValue];
    if (isValidated) {
        WLog(@"User to trying to re-register an already registered StratPad. Ignoring.")
        [[UserNotificationDisplayManager sharedManager] showErrorMessage:LocalizedString(@"VALIDATION_WARNING_MESSAGE_ALREADY_VALIDATED", nil)];
//        isValidatingEmail = NO;
        return;
    }
        
    // tell server we are valid
    // curl -d "appid=189f81a71001cc46c410d55c473af810&email=jwoodchip@gmail.com&regKey=regKey" http://localhost:8080/validate    
    
    // host url
    NSDictionary *config = [[NSBundle mainBundle] infoDictionary];
    NSURL *url = [NSURL URLWithString:[config objectForKey:@"MBRegistrationServer"]];
    AFHTTPClient *request = [AFHTTPClient clientWithBaseURL:url];
    
    // params
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            email, @"email",
                            [self regKey:email], @"regKey",
                            gaeappid, @"appid",
                            [[EditionManager sharedManager] versionNumber], @"api",
                            nil];
    
    // post to server
    [request postPath:@"/153/validate"
           parameters:params
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  isValidatingEmail = NO;
                  
                  NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
                  DLog(@"Validated: %@", json);
                                    
                  // if number of rows is 1, then we are good
                  int rows = [[json objectForKey:@"rows"] intValue];
                  if (rows == 1) {
                      // store the registration process as complete
                      
                      // this is just for completeness
                      [[NSUserDefaults standardUserDefaults] setInteger:RegistrationStatusValidated forKey:keyRegistrationStatus];
                      
                      // this one is the real source of truth
                      [UAKeychainUtils updateValue:@"YES" forKey:keyChainVerified];
                      
                      // notify
                      [self showThankYouPopover];
                      
                  } else {
                      WLog(@"Failed email verification: %@", [json objectForKey:@"error"]);
                      [[UserNotificationDisplayManager sharedManager] showErrorMessage:LocalizedString(@"VALIDATION_ERROR_MESSAGE", nil)];
                  }

              }
              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  isValidatingEmail = NO;
                  [[UserNotificationDisplayManager sharedManager] showErrorMessage:LocalizedString(@"VALIDATION_ERROR_MESSAGE", nil)];
                  ELog(@"Validate email post error: %@. URL: %@", error, operation.request.URL);
              }
     ];

    
}


#pragma mark - Upload backup

-(void)uploadBackup:(NSString*)path stratfile:(StratFile*)stratfile
{
    // first need to fetch a url with a session id for this upload
    NSDictionary *config = [[NSBundle mainBundle] infoDictionary];
    NSString *urlString = [[config objectForKey:@"MBRegistrationServer"] stringByAppendingString:@"/uploadurl"];
    NSURL *url = [NSURL URLWithString:urlString];

    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    [request setPostValue:gaeappid forKey:@"appid"];
    [request setPostValue:[[EditionManager sharedManager] versionNumber] forKey:@"api"];

    [request setTimeOutSeconds:10];
    [request setShouldContinueWhenAppEntersBackground:YES];
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(fetchUploadURLFinished:)];
    [request setDidFailSelector:@selector(fetchUploadURLFailed:)];
    
    [request setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:path, @"path", stratfile, @"stratfile", nil]];
    
    [request startAsynchronous];
}

- (void)fetchUploadURLFinished:(ASIHTTPRequest *)theRequest
{
    if ([theRequest responseStatusCode] != 200) {
        
        // failure
        [self fetchUploadURLFailed:theRequest];
    } else {
                
        // success
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSDictionary *json = [jsonParser objectWithString:[theRequest responseString]];
        [jsonParser release];
        
        BOOL success = [[json objectForKey:@"success"] boolValue];
        if (success) {
            // now we can send off the file to this URL
            NSString *path = [theRequest.userInfo objectForKey:@"path"];
            StratFile *stratfile = [theRequest.userInfo objectForKey:@"stratfile"];
            [self uploadToURL:[json objectForKey:@"url"] path:path stratfile:stratfile];

        } else {
            ELog(@"Failed retrieval of upload URL for backups: %@", [json objectForKey:@"error"]);
            [self fetchUploadURLFailed:theRequest];
        }
    }
}

- (void)fetchUploadURLFailed:(ASIHTTPRequest *)theRequest
{
    NSError *error = theRequest.error;
    [[UserNotificationDisplayManager sharedManager] showErrorMessage:LocalizedString(@"BACKUP_UPLOAD_ERROR_MESSAGE", nil)];
    ELog(@"Couldn't get session for uploading '%@'. Error: %@. URL: %@", [theRequest.userInfo objectForKey:@"path"], error, theRequest.url);
}

- (void)uploadToURL:(NSString*)url path:(NSString*)path stratfile:(StratFile*)stratfile
{
    NSURL *uploadURL = [NSURL URLWithString:url];
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:uploadURL];
    
    // recipient
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *email = [NSString stringWithFormat:@"%@ %@ <%@>",
                           [defaults objectForKey:keyFirstName],
                           [defaults objectForKey:keyLastName],
                           [defaults objectForKey:keyEmail]];

    // subject and body text
    NSString *subject = [NSString stringWithFormat:LocalizedString(@"BACKUP_STRATFILE_SUBJECT", nil), [stratfile name]];
    NSString *emailBody = [NSString stringWithFormat:LocalizedString(@"BACKUP_STRATFILE_BODY", nil), [stratfile name]];
        
    [request setPostValue:email forKey:@"recipient"];
    [request setPostValue:subject forKey:@"subject"];
    [request setPostValue:emailBody forKey:@"body"];
    
    [request setPostValue:gaeappid forKey:@"appid"];
    [request setPostValue:[[EditionManager sharedManager] versionNumber] forKey:@"api"];
    
	[request setTimeOutSeconds:20];
	[request setShouldContinueWhenAppEntersBackground:YES];
    //	[request_ setUploadProgressDelegate:progressIndicator];
	[request setDelegate:[self retain]];
	[request setDidFailSelector:@selector(uploadFailed:)];
	[request setDidFinishSelector:@selector(uploadFinished:)];
    
    NSString *filename = [path lastPathComponent];
    [request setFile:path withFileName:filename andContentType:@"application/stratpad" forKey:@"file"];
    
	[request startAsynchronous];
}

- (void)uploadFinished:(ASIHTTPRequest *)theRequest
{
    if ([theRequest responseStatusCode] != 200) {
        [self uploadFailed:theRequest];
    } else {
        
        // success
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSDictionary *json = [jsonParser objectWithString:[theRequest responseString]];
        [jsonParser release];
        
        BOOL success = [[json objectForKey:@"success"] boolValue];
        if (success) {
            [[UserNotificationDisplayManager sharedManager] showMessage:LocalizedString(@"BACKUP_UPLOAD_SUCCESS_MESSAGE", nil), [[NSUserDefaults standardUserDefaults] stringForKey:keyEmail]];
        } else {
            ELog(@"Failed sending of backup: %@", [json objectForKey:@"error"]);
            [[UserNotificationDisplayManager sharedManager] showErrorMessage:LocalizedString(@"BACKUP_UPLOAD_ERROR_MESSAGE", nil)];
        }
    }
}

- (void)uploadFailed:(ASIHTTPRequest *)theRequest
{
    NSError *error = theRequest.error;
    [[UserNotificationDisplayManager sharedManager] showErrorMessage:LocalizedString(@"BACKUP_UPLOAD_ERROR_MESSAGE", nil)];
    ELog(@"Couldn't upload backup. Error: %@. URL: %@", error, theRequest.url);
}

#pragma mark - Invalidate

// we're going to call action on target with one param: either an error or nil
-(void)invalidateRegistration:(id)target action:(SEL)action
{
    // sanity checks
    BOOL isValidated = [[UAKeychainUtils valueForKey:keyChainVerified] boolValue];
    if (!isValidated) {
        WLog(@"Email has not yet been validated. Ignoring.")
        NSError *error = [NSError errorWithDomain:@"com.stratpad.error.registration.invalidate"
                                             code:-1001
                                         userInfo:nil];
        [target performSelector:action withObject:error];
        return;
    }
    
    NSString *email = [[NSUserDefaults standardUserDefaults] objectForKey:keyEmail];
    if (!email || [email isBlank]) {
        WLog(@"No stored email. Ignoring.")
        NSError *error = [NSError errorWithDomain:@"com.stratpad.error.registration.invalidate"
                                             code:-1002
                                         userInfo:nil];
        [target performSelector:action withObject:error];
        return;
    }
    
    // update record on server matching our token email combination
    // curl -d "appid=189f81a71001cc46c410d55c473af810&email=jwoodchip@gmail.com&token=aToken" http://localhost:8080/invalidate
    
    // host url
    NSDictionary *config = [[NSBundle mainBundle] infoDictionary];
    NSURL *url = [NSURL URLWithString:[config objectForKey:@"MBRegistrationServer"]];
    AFHTTPClient *request = [AFHTTPClient clientWithBaseURL:url];
    
    // params
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            email, @"email",
                            [self regKey:email], @"regKey",
                            gaeappid, @"appid",
                            [[EditionManager sharedManager] versionNumber], @"api",
                            nil];
    
    // post to server
    [request postPath:@"/153/invalidate"
           parameters:params
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  id json = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
                  DLog(@"Invalidated: %@", json);
                  
                  // regardless of response (might have only affected 0 rows), we will let the user enter another email
                  [target performSelector:action withObject:nil];
                  
              }
              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  ELog(@"Couldn't invalidate email: %@", error);
                  [target performSelector:action withObject:error];
              }
     ];
 }


#pragma mark - Upgrade

-(void)upgradeStratPad:(BOOL)isEditionUpgraded isStratBoardUpgraded:(BOOL)isStratBoardUpgraded
{
    // sanity checks    
    BOOL isValidated = [[UAKeychainUtils valueForKey:keyChainVerified] boolValue];
    if (!isValidated) {
        WLog(@"Email has not yet been validated. Ignoring.")
        return;
    }
    
    NSString *email = [[NSUserDefaults standardUserDefaults] objectForKey:keyEmail];
    if (!email || [email isBlank]) {
        WLog(@"No stored email. Ignoring.")
        return;
    }
    
    if (!isEditionUpgraded && !isStratBoardUpgraded) {
        WLog(@"Nothing upgraded. Ignoring.")
        return;
    }
        
    // update record on server matching our token email combination
    NSDictionary *config = [[NSBundle mainBundle] infoDictionary];
    NSString *urlString = [[config objectForKey:@"MBRegistrationServer"] stringByAppendingString:@"/upgrade"];
    NSURL *url = [NSURL URLWithString:urlString];

    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostValue:email forKey:@"email"];
    [request setPostValue:[self regKey:email] forKey:@"regKey"];
    [request setPostValue:gaeappid forKey:@"appid"];
    [request setPostValue:[[EditionManager sharedManager] versionNumber] forKey:@"api"];

    // figure out the upgrades
    if (isStratBoardUpgraded) {
        [request setPostValue:@"True" forKey:@"stratboard"];
    }
    if (isEditionUpgraded) {
        [request setPostValue:[[EditionManager sharedManager] productShortName] forKey:@"effectiveEdition"];
        [request setPostValue:[[EditionManager sharedManager] originalProductShortName] forKey:@"edition"];
    }
    
    [request setTimeOutSeconds:10];
    [request setShouldContinueWhenAppEntersBackground:YES];
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(upgradeStratPadFinished:)];
    [request setDidFailSelector:@selector(upgradeStratPadFailed:)];
        
    [request startAsynchronous];
}

- (void)upgradeStratPadFinished:(ASIHTTPRequest *)theRequest
{
    // parse json
    if ([theRequest responseStatusCode] != 200) {
        
        [self upgradeStratPadFailed:theRequest];
        
    } else {
        
        // silent success
        DLog(@"result: %@", [theRequest responseString]);
        
    }
}

- (void)upgradeStratPadFailed:(ASIHTTPRequest *)theRequest
{
    // silent error - does it really matter if the register upgrade didn't work? What can the user do about it?
    NSError *error = theRequest.error;
    ELog(@"Upgrade registration post error: %@. URL: %@", error, theRequest.url);
}


#pragma mark - Private

- (void)showThankYouPopover
{
    if (self.registrationPopover) {
        [self.registrationPopover dismissPopoverAnimated:NO];
    }
    
    RootViewController *rootViewController = (RootViewController*)[[[UIApplication sharedApplication] keyWindow] rootViewController];
    ThankYouViewController *thankYouVC = [[ThankYouViewController alloc] initWithNibName:nil bundle:nil];

    UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:thankYouVC];
    self.registrationPopover = popover;
    [popover release];
    [_registrationPopover presentPopoverFromRect:CGRectMake(0, 0, 1024, 748) // stick it in the middle
                                        inView:rootViewController.view
                      permittedArrowDirections:0 // no arrows
                                      animated:YES];
    
    // get rid of keyboard if it happens to be up
    AppDelegate* appDelegate = (((AppDelegate*) [UIApplication sharedApplication].delegate));
    RootViewController *rootVC = (RootViewController*)[appDelegate.window rootViewController];
    PageViewController *pageVC = [rootVC pageViewController];
    [pageVC endEditing];
    
    [thankYouVC release];
}

#pragma mark - Public

-(void)showRelevantReminderInView:(UIView*)view
{
    // can show either part of the 2 registration screens, or simply a green notification reminder
    // the isValidatingEmail flag just means that we are busy validating you with the server - so not a good time to show a reminder
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL isVerified = [[UAKeychainUtils valueForKey:keyChainVerified] boolValue];
    NSDate *lastShownDate = [NSDate dateTimeFromISO8601:[defaults stringForKey:keyLastShownDate]];
    BOOL shownToday = lastShownDate ? [[NSDate date] compareDayMonthAndYearTo:lastShownDate] == NSOrderedSame : NO;
    NSInteger showCount = [defaults integerForKey:keyShownCount];
    RegistrationStatus registrationStatus = [[NSUserDefaults standardUserDefaults] integerForKey:keyRegistrationStatus];
    
    // show the welcome dialog if not shown today, and we don't have a verified email
    if (!isVerified && registrationStatus == RegistrationStatusNone && !shownToday && showCount < 3 && !isValidatingEmail) {
    
        // hide keyboard if user happened to be editing something
        AppDelegate* appDelegate = (((AppDelegate*) [UIApplication sharedApplication].delegate));
        RootViewController *rootVC = (RootViewController*)[appDelegate.window rootViewController];
        [rootVC.view endEditing:YES];

        if (showCount >= 1) {
            RegisterOrSkipViewController *regVC = [[RegisterOrSkipViewController alloc] initWithNibName:nil bundle:nil];
            [regVC showPopoverInView:view];
            [regVC release];
        }
        else {
            RegisterWelcomeViewController *regVC = [[RegisterWelcomeViewController alloc] initWithNibName:nil bundle:nil];
            [regVC showPopoverInView:view];
            [regVC release];
        }
        
        // update status - note that you are forced to press Next in the welcome VC so you always see the form
        [defaults setValue:[[NSDate date] stringForISO8601DateTime] forKey:keyLastShownDate];
        [defaults setInteger:showCount+1 forKey:keyShownCount];
    }
    // if we just have an unverified email, show a reminder
    else if (!isVerified && registrationStatus == RegistrationStatusSubmitted && !isValidatingEmail) {
        [[UserNotificationDisplayManager sharedManager] showMessageAfterDelay:1.5f message:LocalizedString(@"REGISTER_REMINDER_MESSAGE", nil)];
    }
    // if we have no email, and it's the same day, then we show a different reminder
    else if (!isVerified && !isValidatingEmail) {
        //[[UserNotificationDisplayManager sharedManager] showMessageAfterDelay:1.5f message:LocalizedString(@"REGISTER_ANYTIME", nil)];
        RegisterOrSkipViewController *regVC = [[RegisterOrSkipViewController alloc] initWithNibName:nil bundle:nil];
        [regVC showPopoverInView:view];
        [regVC release];
    }
    
    isValidatingEmail = NO;

}

+(NSString*)modelAsString
{
    struct utsname platform;
    int rc = uname(&platform);
    if(rc == -1)
    {
        // Error...
        return [[UIDevice currentDevice] model];
    }
    else
    {
        // Convert C-string to NSString
        return [NSString stringWithCString:platform.machine encoding:NSUTF8StringEncoding];
    }
}

@end
