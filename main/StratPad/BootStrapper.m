//
//  BootStrapper.m
//  StratPad
//
//  Created by Julian Wood on 12-09-10.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "BootStrapper.h"
#import "EditionManager.h"
#import "StratFile.h"
#import "Settings.h"
#import "DataManager.h"
#import "NSDate-StratPad.h"
#import "StratFileManager.h"
#import "UpgradeManager.h"
#import "ObjectiveType.h"
#import "Frequency.h"
#import "NSUserDefaults+StratPad.h"
#import "YammerComment.h"
#import "Chart.h"

@implementation BootStrapper

- (void)bootstrap
{
    DLog(@"Checking for bootstrap.");

    // simple check for a bootstrapped db
    Settings *settings = (Settings*)[DataManager objectForEntity:NSStringFromClass([Settings class])
                                            sortDescriptorsOrNil:nil
                                                  predicateOrNil:nil];
    BOOL isBootstrapped = (settings != nil);
    if (!isBootstrapped) {
        [self bootstrapSettings];
		[self bootstrapFrequencies];
		[self bootstrapObjectiveTypes];
        [self bootstrapSampleFiles];
        [self bootstrapTestData];
		
        [DataManager saveManagedInstances];
        DLog(@"Finished bootstrapping.");
    } else {
        // already bootstrapped, may have some other work to do for updating
        // NB that you can use awakeFromInsert and awakeFromFetch, in the Entity, to perform some of these tasks
        
    }
    
    [self cleanup];
    
    DLog(@"Finished cleanup.");
    
}

-(void)bootstrapSampleFiles
{
    // load up sample files for this app version
#if INCLUDE_TEST_FILES
    // for ad hoc and debug, we include a bunch of files
    // make sure that you add these to the EXCLUDED_SOURCE_FILE_NAMES build param
    NSMutableArray *sampleStratFiles = [NSMutableArray arrayWithObjects:@"Produktutveckling Av Växel", @"Rapid, Iterative Product and Market Development", @"sample1", @"sample2", @"R8", @"R9", @"V-Soft Strategy", @"Shelley's 10K", @"Lorem Ipsum", @"SMB Market Focus", @"2012_2013 Expansion Strategy", @"Financial Calculation Workbook", @"Get to Market!", @"2012 Test", @"Rounded StratFile", @"SPS", @"B&ES Growth Plan - Towards 2020 Vision", @"Blueprint to 2016", @"Nurture Factory", @"STRATPAD PLANNING (F5 debugging version)", @"myObservatory.com", @"Mantra Yoga Carlsbad", @"Project Systems", @"پروژه گسترش آرتا ابزار", nil];
    
#else
    // for app store, we only have 3 in premium, 3+1 blank in Plus
    NSMutableArray *sampleStratFiles = [NSMutableArray arrayWithObjects:@"SMB Market Focus", @"2012_2013 Expansion Strategy",  @"Get to Market!", nil];
    
#endif
        
    NSString *path;
    for (NSString *filename in sampleStratFiles) {
        // includes only the files in the resource bundle matching the system settings
        path = [[NSBundle mainBundle] pathForResource:filename ofType:@"xml"];
        
        // this places the stratfile into the db
        StratFile *stratFile = [[StratFileManager sharedManager] stratFileFromXmlAtPath:path];
 
#if INCLUDE_TEST_FILES
        stratFile.permissions = @"0600";
#else
        // sample stratfiles are read-only - must be cloned
        stratFile.permissions = @"0400";
#endif
    }
    
    // create empty rw file for Free/Plus
    // note also that we will load this stratfile (My StratFile) for Plus and Free at the outset, by virtue of that stratfile being the last to be created/accessed
    if ([[EditionManager sharedManager] isFeatureEnabled:FeatureAddOneReadWriteFile]) {
        [UpgradeManager addOneReadWriteFile];
    }
    
    [DataManager saveManagedInstances];
    DLog(@"Finished bootstrapping sample files.");
}

- (void)bootstrapFrequencies
{
    for (int i=0, ct=7; i < ct; i++) {
        Frequency *frequency = (Frequency*)[DataManager createManagedInstance:NSStringFromClass([Frequency class])];
        [frequency setCategory:[NSNumber numberWithInt:i]];
        frequency.order = [NSNumber numberWithInt:i];
    }
    
    [DataManager saveManagedInstances];
    DLog(@"Finished bootstrapping frequencies.");
}

- (void)bootstrapObjectiveTypes
{
    // let's keep all 6 objective types, even though we currently only have 4 in use. Should make it easier to upgrade through the bootstrap
    for (int i = 0, ct=6; i < ct; i++) {
        ObjectiveType *objectiveType = (ObjectiveType*)[DataManager createManagedInstance:NSStringFromClass([ObjectiveType class])];
        [objectiveType setCategory:[NSNumber numberWithInt:i]];
        objectiveType.order = [NSNumber numberWithInt:i];
    }
    
    [DataManager saveManagedInstances];
    DLog(@"Finished bootstrapping objective types.");
}

- (void)bootstrapSettings
{
    Settings *settings = (Settings*)[DataManager createManagedInstance:NSStringFromClass([Settings class])];
    [settings setIsCalculationOptimistic:[NSNumber numberWithBool:YES]];
    [settings setVersion:[[EditionManager sharedManager] versionNumber]];
    
    // set default to the dollar
    [settings setCurrency:@"$"];
    
    [DataManager saveManagedInstances];
    DLog(@"Finished bootstrapping settings.");
}

-(void)cleanup
{
    // in 1.3 Plus, an Ad Hoc build made it onto the store, and consequently users briefly had access to the test Stratfiles
    // so for 1.3.1, we need to look for these files and remove them
    // since they can't be edited, we can just look by stratfile dateCreated
    // dateCreated is not unique
    
    DLog(@"Cleaning up.");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // do it for Plus only, v 1.3.x
    if ([[EditionManager sharedManager] isPlus] && ![defaults boolForKey:keyAreSampleFilesCleanedUpFor13] && [[[EditionManager sharedManager] versionNumber] hasPrefix:@"1.3"]) {
        
        DLog(@"Cleaning up old sample stratfiles.");
        
        NSArray *stratFilesToDelete = [NSArray arrayWithObjects:
                                       [NSArray arrayWithObjects:@"20120214T15:55:23-0800", @"2012 Test", nil],
                                       [NSArray arrayWithObjects:@"20120415T21:39:48+0100", @"B&ES Growth Plan - Towards 2020 Vision", nil],
                                       [NSArray arrayWithObjects:@"20120508T23:06:49-0400", @"Blueprint to 2016", nil],
                                       [NSArray arrayWithObjects:@"20111105T21:22:09-0600", @"Financial Calculation Workbook", nil],
                                       [NSArray arrayWithObjects:@"20111004T11:20:19-0600", @"Lorem Ipsum", nil],
                                       [NSArray arrayWithObjects:@"20111115T19:22:08+0000", @"Nurture Factory", nil],
                                       [NSArray arrayWithObjects:@"20110915T23:51:17-0600", @"R8", nil],
                                       [NSArray arrayWithObjects:@"20111115T11:22:08-0800", @"R9 Test", nil],
                                       [NSArray arrayWithObjects:@"20111109T17:40:45-0800", @"Rapid, Iterative Product and Market Development", nil],
                                       [NSArray arrayWithObjects:@"20120216T13:29:16-0700", @"Rounded StratFile", nil],
                                       [NSArray arrayWithObjects:@"20110910T18:02:59-0600", @"Business Plan", nil],
                                       [NSArray arrayWithObjects:@"20110915T12:13:56-0700", @"Untitled StratFile", nil],
                                       [NSArray arrayWithObjects:@"20110922T08:03:46-0700", @"Shelley's 10K", nil],
                                       [NSArray arrayWithObjects:@"20111115T11:22:08-0800", @"SPS", nil],
                                       [NSArray arrayWithObjects:@"20120214T15:55:23-0800", @"STRATPAD PLANNING (F5 debugging version)", nil],
                                       [NSArray arrayWithObjects:@"20110915T19:48:46-0700", @"V-Soft Strategy", nil],
                                       nil];
        
        for (NSArray *stratfileProps in stratFilesToDelete) {
            NSDate *dateCreated = [NSDate dateTimeFromISO8601:[stratfileProps objectAtIndex:0]];
            NSString *name = [stratfileProps objectAtIndex:1];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dateCreated=%@ && name=%@", dateCreated, name];
            StratFile *stratfile = (StratFile*)[DataManager objectForEntity:NSStringFromClass([StratFile class])
                                                       sortDescriptorsOrNil:nil
                                                             predicateOrNil:predicate];
            [DataManager deleteManagedInstance:stratfile];
        }
        
        [defaults setBool:YES forKey:@"areSampleFilesCleanedUpFor1.3"];
    }
    
}

-(void)bootstrapTestData
{
#if DEBUG
    // add some YammerPublications to V-Soft
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name=%@", @"V-Soft Strategy"];
    StratFile *stratfile1 = (StratFile*)[DataManager objectForEntity:NSStringFromClass([StratFile class])
                                               sortDescriptorsOrNil:nil
                                                     predicateOrNil:predicate];
    
    predicate = [NSPredicate predicateWithFormat:@"name=%@", @"Get to Market!"];
    StratFile *stratfile2 = (StratFile*)[DataManager objectForEntity:NSStringFromClass([StratFile class])
                                                sortDescriptorsOrNil:nil
                                                      predicateOrNil:predicate];

    
    if (!stratfile1.yammerReports.count) {
        // connect to existing, published reports on yammer
        
        // add a YammerPublishedReport (with threads)
        YammerPublishedReport *yammerReport1 = (YammerPublishedReport*)[DataManager createManagedInstance:NSStringFromClass([YammerPublishedReport class])];
        yammerReport1.stratFile = stratfile1;
        yammerReport1.attachmentId = [NSNumber numberWithInt:7133273];
        yammerReport1.chapterNumber = @"R1";
        yammerReport1.permalink = @"externalstratpaddiscussion";
        
        // https://www.yammer.com/externalstratpaddiscussion/#/Threads/show?threadId=221831870
        YammerPublishedThread *thread1 = (YammerPublishedThread*)[DataManager createManagedInstance:NSStringFromClass([YammerPublishedThread class])];
        thread1.threadStarterId = [NSNumber numberWithInt:221831870];
        thread1.creationDate = [NSDate dateTimeFromYammer:@"2012/10/12 08:13:38 +0000"];
        [yammerReport1 addThreadsObject:thread1];
        
        
        // and a second, in StratBoard charts
        YammerPublishedReport *yammerReport2 = (YammerPublishedReport*)[DataManager createManagedInstance:NSStringFromClass([YammerPublishedReport class])];
        yammerReport2.stratFile = stratfile1;
        yammerReport2.attachmentId = [NSNumber numberWithInt:7191659];
        yammerReport2.chapterNumber = @"S1";
        yammerReport2.chart = [Chart chartWithUUID:@"DEF61FA4-094B-4FFB-9DA9-EA453F842AB1"];
        yammerReport2.permalink = @"externalstratpaddiscussion";
        
        YammerPublishedThread *thread2 = (YammerPublishedThread*)[DataManager createManagedInstance:NSStringFromClass([YammerPublishedThread class])];
        thread2.threadStarterId = [NSNumber numberWithInt:223363904];
        thread2.creationDate = [NSDate dateTimeFromYammer:@"2012/10/16 17:59:32 +0000"];
        [yammerReport2 addThreadsObject:thread2];
        
        // and a third, also in StratBoard charts
        YammerPublishedReport *yammerReport3 = (YammerPublishedReport*)[DataManager createManagedInstance:NSStringFromClass([YammerPublishedReport class])];
        yammerReport3.stratFile = stratfile1;
        yammerReport3.attachmentId = [NSNumber numberWithInt:7198836];
        yammerReport3.chapterNumber = @"S1";
        yammerReport3.chart = [Chart chartWithUUID:@"5F422F34-707C-4CDF-9775-D93C5103DFD4"];
        yammerReport3.permalink = @"externalstratpaddiscussion";
        
        YammerPublishedThread *thread3 = (YammerPublishedThread*)[DataManager createManagedInstance:NSStringFromClass([YammerPublishedThread class])];
        thread3.threadStarterId = [NSNumber numberWithInt:223543003];
        thread3.creationDate = [NSDate dateTimeFromYammer:@"2012/10/17 04:43:01 +0000"];
        [yammerReport3 addThreadsObject:thread3];

        
        // and a fourth, with two threads
        YammerPublishedReport *yammerReport4 = (YammerPublishedReport*)[DataManager createManagedInstance:NSStringFromClass([YammerPublishedReport class])];
        yammerReport4.stratFile = stratfile1;
        yammerReport4.attachmentId = [NSNumber numberWithInt:7286195];
        yammerReport4.chapterNumber = @"R6";
        yammerReport4.permalink = @"externalstratpaddiscussion";
        
        // the originating thread: "Hopefully this will show up as read"
        YammerPublishedThread *thread4 = (YammerPublishedThread*)[DataManager createManagedInstance:NSStringFromClass([YammerPublishedThread class])];
        thread4.threadStarterId = [NSNumber numberWithInt:225549015]; 
        thread4.creationDate = [NSDate dateTimeFromYammer:@"2012/10/22 21:27:25 +0000"];
        [yammerReport4 addThreadsObject:thread4];

        YammerPublishedThread *thread5 = (YammerPublishedThread*)[DataManager createManagedInstance:NSStringFromClass([YammerPublishedThread class])];
        thread5.threadStarterId = [NSNumber numberWithInt:225549572];
        thread5.creationDate = [NSDate dateTimeFromYammer:@"2012/10/22 21:28:45 +0000"];
        [yammerReport4 addThreadsObject:thread5];
        
        
        // and a fifth in a different stratfile
        // add a YammerPublishedReport (with threads)
        YammerPublishedReport *yammerReport5 = (YammerPublishedReport*)[DataManager createManagedInstance:NSStringFromClass([YammerPublishedReport class])];
        yammerReport5.stratFile = stratfile2;
        yammerReport5.attachmentId = [NSNumber numberWithInt:7472875];
        yammerReport5.chapterNumber = @"R4";
        yammerReport5.permalink = @"externalstratpaddiscussion";
        
        YammerPublishedThread *thread6 = (YammerPublishedThread*)[DataManager createManagedInstance:NSStringFromClass([YammerPublishedThread class])];
        thread6.threadStarterId = [NSNumber numberWithInt:229367119];
        thread6.creationDate = [NSDate dateTimeFromYammer:@"2012/11/01 20:59:10 +0000"];
        [yammerReport5 addThreadsObject:thread6];

        [DataManager saveManagedInstances];
        
    }
    
#endif
}


@end
