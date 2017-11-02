//
//  StratFileManager.m
//  StratPad
//
//  Created by Eric Rogers on August 4, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "StratFileManager.h"
#import "SynthesizeSingleton.h"
#import "DataManager.h"
#import "Theme.h"
#import "EventManager.h"
#import "Frequency.h"
#import "Objective.h"
#import "ObjectiveType.h"
#import "Activity.h"
#import "Settings.h"
#import "Responsible.h"
#import "StratFileParser.h"
#import "EditionManager.h"
#import "NSUserDefaults+StratPad.h"
#import "NSDataAdditions.h"
#import "NSString-Expanded.h"
#import "Financials.h"
#import "EmployeeDeductions.h"
#import "SalesTax.h"
#import "IncomeTax.h"
#import "OpeningBalances.h"
#import "ImportStratFileViewController.h"
#import "RootViewController.h"

static NSString *SALT = @"STRATPADRULEZ";

@interface StratFileManager (Private)
@end

@implementation StratFileManager

@synthesize currentStratFile = currentStratFile_;

SYNTHESIZE_SINGLETON_FOR_CLASS(StratFileManager);

- (void)dealloc
{
    [currentStratFile_ release];
    [super dealloc];
}

- (void)saveCurrentStratFile
{
    currentStratFile_.dateModified = [NSDate date];
    [DataManager saveManagedInstances];
    TLog(@"Saved: %@", currentStratFile_);
}

- (void)loadStratFile:(StratFile*)stratFile withChapterIndex:(ChapterIndex)chapterIndex
{
    [EventManager fireStratFileWillLoadEventWithChapterIndex:chapterIndex];
    
    [currentStratFile_ release]; currentStratFile_ = nil;
    currentStratFile_ = [stratFile retain];
    currentStratFile_.dateLastAccessed = [NSDate date];
    
    [EventManager fireStratFileLoadedEventWithChapterIndex:chapterIndex];
    
    TLog(@"Loaded: %@", currentStratFile_);
}

- (void)loadMostRecentStratFile
{        
    // grab the most recent accessed StratFile.
    // there is always at least 1 strafile
    NSSortDescriptor *mostRecentSort = [[NSSortDescriptor alloc] initWithKey:@"dateLastAccessed" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObjects: mostRecentSort, nil];    
    StratFile *mostRecent = (StratFile*)[DataManager objectForEntity:NSStringFromClass([StratFile class]) sortDescriptorsOrNil:sortDescriptors predicateOrNil:nil];
    [mostRecentSort release];
    
    // the first time we run stratpad, show welcome, and thereafter, show F1
    // note also that we will load My StratFile for Plus and Free at the outset, by virtue of that stratfile being the last to be created/accessed
    BOOL isWelcomeShown = [[NSUserDefaults standardUserDefaults] boolForKey:keyIsWelcomeShown];
    if (isWelcomeShown) {
        [self loadStratFile:mostRecent withChapterIndex:ChapterIndexAboutYourStrategy];
    } else {
        [self loadStratFile:mostRecent withChapterIndex:ChapterIndexWelcome];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:keyIsWelcomeShown];
    }
}

- (void)deleteStratFile:(StratFile*)stratFile
{
    DLog(@"Deleting: %@", stratFile.name);
    NSDictionary *stratFileInfo = [NSDictionary dictionaryWithObjectsAndKeys:stratFile.name, @"name", nil];
    [DataManager deleteManagedInstance:stratFile];
    [EventManager fireStratFileDeletedEvent:stratFileInfo];
}

- (BOOL)exportStratFileToXmlAtPath:(NSString*)path stratFile:(StratFile*)stratFile
{
#if DEBUG
    BOOL shouldEncode = NO;
#else
    BOOL shouldEncode = YES;
#endif
    
    stratFileWriter_ = [[StratFileWriter alloc] initWithStratFile:(StratFile*)stratFile];
        
    [stratFileWriter_ writeStratFile:NO];
        
    // get the resulting XML string
    NSData* xml = [stratFileWriter_ toData];
    
    // we'll do a pretty trivial base64 encoding + a little salt to obfuscate the file
    NSString *encoded = [NSString stringWithFormat:@"%@%@%@", @"a", [SALT md5], [xml base64Encoding] ];
    NSData *encodedData = [encoded dataUsingEncoding:NSUTF8StringEncoding];
    
    BOOL success = NO;
    if (shouldEncode) {
        success = [encodedData writeToFile:path atomically:NO];
    } else {
        success = [xml writeToFile:path atomically:NO];
    }
    
    [stratFileWriter_ release], stratFileWriter_ = nil;
    
    return success;
}

- (StratFile*)stratFileFromXmlAtPath:(NSString*)path
{
    return [self stratFileFromXmlAtPath:path failWithMismatchedEmails:NO];
}

-(StratFile*)createManagedEmptyStratFile
{
    // we also add default values in the model (not so good) and the Entity itself (awakeFromInsert or awakeFromFetch)
    StratFile *stratFile = (StratFile*)[DataManager createManagedInstance:NSStringFromClass([StratFile class])];
    
    stratFile.name = LocalizedString(@"UNNAMED_STRATFILE_TITLE", nil);
    stratFile.companyName = LocalizedString(@"UNNAMED_COMPANY", nil);
    
    stratFile.dateCreated = [NSDate date];
    stratFile.dateModified = [NSDate date];
    stratFile.dateLastAccessed = [NSDate date];
    
    stratFile.permissions = @"0600";
    
    stratFile.model = [[EditionManager sharedManager] modelVersion];
    
    [DataManager saveManagedInstances];
    
    return stratFile;    
}

- (void)importStratFile:(NSURL*)url
{
    // import file
    NSString *path = [url path];
    
    @try {
        // this actually has some capability for dealing with older model formats
        StratFile *stratFileToImport = [[StratFileManager sharedManager] stratFileFromXmlAtPath:path];
        
        if ([[EditionManager sharedManager] isModelCompatible:stratFileToImport.model]) {
            // make sure we're unique; note that we have a pretty loose definition of unique
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uuid = %@ or name = %@", stratFileToImport.uuid, stratFileToImport.name];
            NSArray *stratFiles = [DataManager arrayForEntity:NSStringFromClass([StratFile class])
                                         sortDescriptorsOrNil:nil
                                               predicateOrNil:predicate];
            if ([stratFiles count] > 1) {
                // ie. an old one and the new one have the same uuid
                StratFile *existingStratFile = nil;
                for (StratFile *stratFile in stratFiles) {
                    if (stratFile != stratFileToImport) {
                        existingStratFile = stratFile;
                    }
                }
                
                RootViewController *rootViewController = (RootViewController*)[[[UIApplication sharedApplication] keyWindow] rootViewController];
                ImportStratFileViewController *importVC = [[ImportStratFileViewController alloc] initWithExistingStratFile:existingStratFile importedStratFile:stratFileToImport];
                [importVC showPopoverInView:rootViewController.view];
                [importVC release];                
            }
            else {
                // just a stratfile that doesn't currently exist in StratPad
                [DataManager saveManagedInstances];

                UIAlertView *success = [[UIAlertView alloc] initWithTitle:LocalizedString(@"IMPORT_SUCCESS_TITLE", nil)
                                                                  message:[NSString stringWithFormat:LocalizedString(@"IMPORT_SUCCESS_BODY", nil), stratFileToImport.name]
                                                                 delegate:nil
                                                        cancelButtonTitle:nil
                                                        otherButtonTitles:LocalizedString(@"OK", nil), nil];
                [success show];
                [success release];

                // load it up
                [[StratFileManager sharedManager] loadStratFile:stratFileToImport withChapterIndex:ChapterIndexAboutYourStrategy];
            }
            
        } else {
            // if stratfile model greater than current model (ie someone with a newer version of stratpad sends to an old version of stratpad)
            NSString *reason;
            if ([[EditionManager sharedManager] compareModelVersions:[[EditionManager sharedManager] modelVersion]
                                                   otherModelVersion:stratFileToImport.model] == NSOrderedAscending) {
                reason = LocalizedString(@"STRATFILE_CREATED_BY_NEWER_STRATPAD", nil);
            }
            else {
                reason = LocalizedString(@"INCOMPATIBLE_STRATFILE_EXC", nil);
            }
            
            @throw [NSException exceptionWithName:@"IncompatibleStratFileException"
                                           reason:reason
                                         userInfo:[NSDictionary dictionaryWithObject:stratFileToImport forKey:@"stratfile"]];
        }
        
    }
    @catch (NSException *exception) {
        ELog(@"Failed import of stratfile at path: %@", path);
        ELog(@"Reason: %@", [exception reason]);
        ELog(@"Stack trace: %@", [exception callStackSymbols]);
        
        // have to remove that StratFile
        StratFile *stratFile = [exception.userInfo objectForKey:@"stratfile"];
        NSString *stratFileName = stratFile.name;
        if (stratFile) {
            [DataManager deleteManagedInstance:stratFile];
        }
        
        // remove the file
        NSError *error;
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        if ([fileMgr removeItemAtPath:path error:&error] != YES) {
            WLog(@"Unable to delete file: %@", [error localizedDescription]);
        }
        
        UIAlertView *failure = [[UIAlertView alloc] initWithTitle:LocalizedString(@"IMPORT_FAIL_TITLE", nil)
                                                          message:[NSString stringWithFormat:LocalizedString(@"IMPORT_FAIL_BODY", nil), stratFileName, exception.reason]
                                                         delegate:nil
                                                cancelButtonTitle:nil
                                                otherButtonTitles:LocalizedString(@"OK", nil), nil];
        [failure show];
        [failure release];
        
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [DataManager saveManagedInstances];
    
    if (alertView.tag == 555) {
        // imported stratfile is the latest one
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"dateLastAccessed" ascending:NO];
        StratFile *importedStratFile = (StratFile*)[DataManager objectForEntity:NSStringFromClass([StratFile class])
                                                           sortDescriptorsOrNil:[NSArray arrayWithObject:sortDescriptor]
                                                                 predicateOrNil:nil];
        
        if (buttonIndex == [alertView cancelButtonIndex]) {

            // delete the imported stratfile
            [DataManager deleteManagedInstance:importedStratFile];

        }
        else {
            // delete the old My stratfile
            
            // original stratfile is the older one with the same permissions
            sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"dateLastAccessed" ascending:YES];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"permissions = %@", @"0600"];
            StratFile *originalStratFile = (StratFile*)[DataManager objectForEntity:NSStringFromClass([StratFile class])
                                                 sortDescriptorsOrNil:[NSArray arrayWithObject:sortDescriptor]
                                                       predicateOrNil:predicate];
            
            [DataManager deleteManagedInstance:originalStratFile];
            
            // load up the newly imported one
            [[StratFileManager sharedManager] loadStratFile:importedStratFile withChapterIndex:ChapterIndexAboutYourStrategy];

        }
        
    }
    
}

-(StratFile*)cloneStratFile:(StratFile*)stratFile
{
    // easiest way to do this is to export the stratFile, then import it as a clone with a new uuid
    NSString *xmlPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"tempClonedStratFile"];
    [self exportStratFileToXmlAtPath:xmlPath stratFile:stratFile];
    
    StratFile *clone = [self stratFileFromXmlAtPath:xmlPath failWithMismatchedEmails:NO];
    clone.uuid = [NSString stringWithUUID];
    clone.name = [clone.name stringByAppendingFormat:@" %@", LocalizedString(@"STRATFILE_COPY_SUFFIX", nil)];
    clone.permissions = @"0600";
    
    [DataManager saveManagedInstances];
    
    return clone;
}

- (void)importStratFileBackup:(NSURL*)url
{
    // import file
    NSString *path = [url path];
    
    @try {
        // this actually has some capability for dealing with older model formats
        StratFile *importedStratFile = [[StratFileManager sharedManager] stratFileFromXmlAtPath:path failWithMismatchedEmails:YES];
        
        // last access date; leave modified date alone
        importedStratFile.dateLastAccessed = [NSDate date];
        
        if ([[EditionManager sharedManager] isModelCompatible:importedStratFile.model]) {
            
            if ([[EditionManager sharedManager] isFree] || [[EditionManager sharedManager] isEffectivelyPlus]) {
                // for free and plus, you only have one read/write file, and 3 sample files (read-only); no ability to add more
                // for premium and platinum, you just have 3 sample read/write files
                // we want to ask if we should overwrite that file - they could potentially backup any of the 4
                
                // we can only identify existing My StratFile's by deduction, in Plus and Premium
                // the sample files are read-only, so their title/creationDate are known
                
                // in premium and platinum, we can identify by their creationdate (name changes depending on locale)
                
                // My StratFile is the file with 0600 permissions
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"permissions = %@", @"0600"];
                StratFile *myStratFile = (StratFile*)[DataManager objectForEntity:NSStringFromClass([StratFile class])
                                                             sortDescriptorsOrNil:nil
                                                                   predicateOrNil:predicate];

                
                // so, what we want to do is ask if they want to replace the existing file (no matter what - it has a matching name)                
                UIAlertView *replace = [[UIAlertView alloc] initWithTitle:LocalizedString(@"IMPORT_BACKUP_REPLACE_TITLE", nil)
                                                                  message:[NSString stringWithFormat:LocalizedString(@"IMPORT_BACKUP_REPLACE_BODY", nil), myStratFile.name ,importedStratFile.name]
                                                                 delegate:self
                                                        cancelButtonTitle:LocalizedString(@"CANCEL", nil)
                                                        otherButtonTitles:LocalizedString(@"OK", nil), nil];
                replace.tag = 555;
                [replace show];
                [replace release];
            }
            else {
             
                // for premium and platinum just finish off the import
                
                // make sure we're unique
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name = %@", importedStratFile.name];
                NSArray *stratFiles = [DataManager arrayForEntity:NSStringFromClass([StratFile class])
                                             sortDescriptorsOrNil:nil
                                                   predicateOrNil:predicate];
                if ([stratFiles count] > 1) {
                    // can't be zero, so must be multiple instances with the same name
                    // just update it's name so it doesn't conflict; user can change later if necessary
                    importedStratFile.name = [importedStratFile.name stringByAppendingFormat:@" backup"];
                }
                
                [DataManager saveManagedInstances];
                
                UIAlertView *success = [[UIAlertView alloc] initWithTitle:LocalizedString(@"IMPORT_BACKUP_SUCCESS_TITLE", nil)
                                                                  message:[NSString stringWithFormat:LocalizedString(@"IMPORT_BACKUP_SUCCESS_BODY", nil), importedStratFile.name]
                                                                 delegate:nil
                                                        cancelButtonTitle:nil
                                                        otherButtonTitles:LocalizedString(@"OK", nil), nil];
                [success show];
                [success release];
                
                // load it up
                [[StratFileManager sharedManager] loadStratFile:importedStratFile withChapterIndex:ChapterIndexAboutYourStrategy];

            }
            
        } else {
            @throw [NSException exceptionWithName:@"IncompatibleStratFileException"
                                           reason:LocalizedString(@"INCOMPATIBLE_STRATFILE_EXC", nil)
                                         userInfo:[NSDictionary dictionaryWithObject:importedStratFile forKey:@"stratfile"]];
        }
        
    }
    @catch (NSException *exception) {
        ELog(@"Failed import of stratfile backup at path: %@", path);
        ELog(@"Reason: %@", [exception reason]);
        ELog(@"Stack trace: %@", [exception callStackSymbols]);
        
        // have to remove that StratFile
        StratFile *stratFile = [exception.userInfo objectForKey:@"stratfile"];
        if (stratFile) {
            [DataManager deleteManagedInstance:stratFile];
        }
        
        // remove the file
        NSError *error;
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        if ([fileMgr removeItemAtPath:path error:&error] != YES) {
            WLog(@"Unable to delete file: %@", [error localizedDescription]);
        }
        
        UIAlertView *failure = [[UIAlertView alloc] initWithTitle:LocalizedString(@"IMPORT_BACKUP_FAIL_TITLE", nil)
                                                          message:[NSString stringWithFormat:LocalizedString(@"IMPORT_BACKUP_FAIL_BODY", nil), [path lastPathComponent], exception.reason]
                                                         delegate:nil
                                                cancelButtonTitle:nil
                                                otherButtonTitles:LocalizedString(@"OK", nil), nil];
        [failure show];
        [failure release];
        
    }
    
}

#pragma mark - Private

- (StratFile*)stratFileFromXmlAtPath:(NSString*)path failWithMismatchedEmails:(BOOL)failWithMismatchedEmails
{
    NSAssert([[NSFileManager defaultManager] fileExistsAtPath:path], @"File has to exist: %@", path);
    
    StratFile *stratFile = (StratFile*)[DataManager createManagedInstance:NSStringFromClass([StratFile class])];
    
    NSData *xmlData = [NSData dataWithContentsOfFile:path];
    
    // do a quick check to see if this is an encoded stratfile
    Byte *buffer = (Byte*)malloc(10);
    [xmlData getBytes:buffer length:10];
    NSString *firstBytes = [[NSString alloc] initWithBytes:buffer length:10 encoding:NSUTF8StringEncoding];
    
    NSData *decodedData;
    NSString *salt = [SALT md5];
    
    if ([salt hasPrefix:[firstBytes substringFromIndex:1]]) {
        NSString *joinedString = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
        NSString *encodedString = [joinedString substringFromIndex:[salt length]+1];
        [joinedString release];
        decodedData = [NSData dataWithBase64EncodedString:encodedString];
    } else {
        decodedData = xmlData;
    }
    [firstBytes release];
    free(buffer);
    
    StratFileParser *parser = [[StratFileParser alloc] initWithStratFile:stratFile xmlData:decodedData];
    parser.failWithMismatchedEmails = failWithMismatchedEmails;
    [parser parse];
    [parser release];
    
    return stratFile;
}



@end
