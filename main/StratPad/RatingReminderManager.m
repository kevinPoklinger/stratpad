//
//  RatingReminderManager.m
//  StratPad
//
//  Created by Eric Rogers on September 30, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "RatingReminderManager.h"
#import "SynthesizeSingleton.h"
#import "DataManager.h"
#import "Settings.h"
#import "EditionManager.h"

NSTimeInterval const numSecondsInDay = 24*60*60;

@interface RatingReminderManager (Private)
- (void)milestoneComplete;
- (void)showRatingReminder;
- (void)visitAppStoreToRateApp;
- (void)markAppAsRated;
@end

@implementation RatingReminderManager

SYNTHESIZE_SINGLETON_FOR_CLASS(RatingReminderManager);

- (id)init
{
    if ((self = [super init])) {
        Settings *settings = (Settings*)[DataManager objectForEntity:NSStringFromClass([Settings class]) sortDescriptorsOrNil:nil predicateOrNil:nil];        
        
        // we want the user to rate new versions of the application.  So reset the appRated setting flag if 
        // the current version of the app is different than the one that was last rated.
        if (![[[EditionManager sharedManager] versionNumber] isEqualToString:[settings lastVersionRated]]) {
            appRated_ = NO;
            settings.appRated = [NSNumber numberWithBool:appRated_];
            [DataManager saveManagedInstances];
        } else {
            appRated_ = [settings.appRated boolValue];    
        }
    }
    return self;
}

#pragma mark - Public

- (void)userEnteredStratFileName
{
    if (!stratFileNameEntered_) {
        stratFileNameEntered_ = YES;
        [self milestoneComplete];
    }
}

- (void)userCreatedTheme
{
    if (!themeCreated_) {
        themeCreated_ = YES;
        [self milestoneComplete];
    }
}

- (void)userVisitedFirstReport
{
    if (!firstReportVisited_) {
        firstReportVisited_ = YES;
        [self milestoneComplete];
    }
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        // go to app store.        
        [self markAppAsRated];
        [self visitAppStoreToRateApp];
        
    } else if (buttonIndex == 1) {
        // later...schedule a notification a day from now...
        [self performSelector:@selector(showRatingReminder) withObject:nil afterDelay:numSecondsInDay];
        
    } else {
        // already rated...don't show again.
        [self markAppAsRated];
    }
}


#pragma mark - Private

- (void)milestoneComplete
{    
    if (!appRated_ && stratFileNameEntered_ && themeCreated_ && firstReportVisited_) {
        [self showRatingReminder];
    }
}

- (void)showRatingReminder
{
    UIAlertView *ratingReminder = [[UIAlertView alloc] initWithTitle:LocalizedString(@"RATE_REMINDER_TITLE", nil) 
                                                             message:LocalizedString(@"RATE_REMINDER_MESSAGE", nil)
                                                            delegate:self
                                                   cancelButtonTitle:nil 
                                                   otherButtonTitles:LocalizedString(@"RATE_AND_REVIEW", nil), 
                                   LocalizedString(@"LATER", nil), LocalizedString(@"ALREADY_RATED", nil), nil];
    [ratingReminder show];
    [ratingReminder release];
}

- (void)visitAppStoreToRateApp
{    
    NSURL *url = [[NSURL alloc] initWithString:[[EditionManager sharedManager] appStoreURL]];
    [[UIApplication sharedApplication] openURL:url];		
    [url release];
}

- (void)markAppAsRated
{    
    appRated_ = YES;
    
    Settings *settings = (Settings*)[DataManager objectForEntity:NSStringFromClass([Settings class]) sortDescriptorsOrNil:nil predicateOrNil:nil];
    settings.appRated = [NSNumber numberWithBool:appRated_];
    settings.lastVersionRated = [[EditionManager sharedManager] versionNumber];
    [DataManager saveManagedInstances];
}

@end
