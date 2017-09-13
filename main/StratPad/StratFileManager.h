//
//  StratFileManager.h
//  StratPad
//
//  Created by Eric Rogers on August 4, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "StratFile.h"
#import "StratFileWriter.h"
#import "NavigationConfig.h"

@interface StratFileManager : NSObject {
 @private
    StratFile *currentStratFile_;
    StratFileWriter *stratFileWriter_;
}

@property(nonatomic, readonly) StratFile *currentStratFile;

+ (StratFileManager*)sharedManager;

// NB that caller takes ownership
-(StratFile*)createManagedEmptyStratFile;

- (void)saveCurrentStratFile;

- (void)loadStratFile:(StratFile*)stratFile withChapterIndex:(ChapterIndex)chapterIndex;

- (void)deleteStratFile:(StratFile*)stratFile;

- (void)loadMostRecentStratFile;

- (BOOL)exportStratFileToXmlAtPath:(NSString*)path stratFile:(StratFile*)stratFile;

- (StratFile*)stratFileFromXmlAtPath:(NSString*)path;

- (void)importStratFile:(NSURL*)url;

- (void)importStratFileBackup:(NSURL*)url;

-(StratFile*)cloneStratFile:(StratFile*)stratFile;

@end
