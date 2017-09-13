//
//  YammerPublishedReport.h
//  StratPad
//
//  Created by Julian Wood on 12-10-02.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//
//  A conversation belonging to a YammerPublishedReport.
//  Note that we do not share publications with other users, so we don't marshall them.


#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class YammerPublishedReport;

@interface YammerPublishedThread : NSManagedObject

// the thread id, which equals the message id of the root message
@property (nonatomic, retain) NSNumber * threadStarterId;

// this is the creation date of the root message
// we need this so that we can sort the threads, and thus identify the thread original to the file posting (it's the oldest)
@property (nonatomic, retain) NSDate * creationDate;

// inverse
@property (nonatomic, retain) YammerPublishedReport *report;

@end
