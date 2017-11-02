//
//  PermissionChecker.m
//  StratPad
//
//  Created by Julian Wood on 2013-06-13.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//

#import "PermissionChecker.h"
#import "EditionManager.h"
#import "RootViewController.h"
#import "PageViewController.h"

#define CLONE 0
#define UPGRADE 1

@interface PermissionChecker ()
@property (nonatomic, retain) StratFile *stratFile;
@property (nonatomic,retain) RootViewController *rootViewController;
@end


@implementation PermissionChecker

- (id)initWithStratFile:(StratFile*)stratFile
{
    self = [super init];
    if (self) {
        self.stratFile = stratFile;
        self.rootViewController = (RootViewController*)[[[UIApplication sharedApplication] keyWindow] rootViewController];
    }
    return self;
}

-(BOOL)isReadWrite
{
    return [_stratFile isWritable:UserTypeOwner] && [_stratFile isReadable:UserTypeOwner];
}

-(BOOL)checkReadWrite
{
    if ([self isReadWrite]) {
        return YES;
    } else {
        if ([[EditionManager sharedManager] isFeatureEnabled:FeatureAddStratFiles]) {
            // offer to clone
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"READONLY_SAMPLE_FILE_CLONE_TITLE", nil)
                                                            message:LocalizedString(@"READONLY_SAMPLE_FILE_CLONE_MESSAGE", nil)
                                                           delegate:self
                                                  cancelButtonTitle:LocalizedString(@"CANCEL", nil)
                                                  otherButtonTitles:LocalizedString(@"OK", nil), nil];
            alert.tag = CLONE;
            [alert show];
            [alert release];
            
        }
        else {
            // inform and offer to upgrade so that they can clone
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"READONLY_SAMPLE_FILE_UPGRADE_TITLE", nil)
                                                            message:LocalizedString(@"READONLY_SAMPLE_FILE_UPGRADE_MESSAGE", nil)
                                                           delegate:self
                                                  cancelButtonTitle:LocalizedString(@"CANCEL", nil)
                                                  otherButtonTitles:LocalizedString(@"OK", nil), nil];
            alert.tag = UPGRADE;
            [alert show];
            [alert release];
            
        }
        return NO;
    }

}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex ) {
        if (alertView.tag == UPGRADE) {
            // open the extras menu for an upgrade
            [_rootViewController showUpgradePopover:nil event:nil];
        }
        else if (alertView.tag == CLONE) {
            // go ahead and make a copy of this stratfile, open it to the same place
            
            StratFileManager *stratman = [StratFileManager sharedManager];
            StratFile *clone = [stratman cloneStratFile:stratman.currentStratFile];
            
            PageViewController *pageVC = _rootViewController.pageViewController;
            
            [stratman loadStratFile:clone withChapterIndex:pageVC.currentChapter.chapterIndex];
        }
    }
}

- (void)dealloc
{
    [_rootViewController release];
    [_stratFile release];
    [super dealloc];
}


@end
