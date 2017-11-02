//
//  YammerPublishedReport.h
//  StratPad
//
//  Created by Julian Wood on 12-09-25.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//
//  When we publish a report to Yammer, we record pertinent info here, so that we can keep track of comments.
//  Comments = Messages
//  Note that we do not share publications with other users, so we don't marshall them.

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "YammerPublishedThread.h"
#import "Chart.h"

@class StratFile;

@interface YammerPublishedReport : NSManagedObject

// the id in the attachment itself
@property (nonatomic, retain) NSNumber * attachmentId;

// this will be like R1, R4, S1
@property (nonatomic, retain) NSString * chapterNumber;

// this is the network permalink, to which we published this file
@property (nonatomic, retain) NSString * permalink;

// only relevant for StratBoard; if chapterNumber is S1 and no uuid, then this is StratCard
// NB that the user can change the order of charts, and thus page numbers
@property (nonatomic, retain) Chart *chart;



// inverse relationship
@property (nonatomic, retain) StratFile *stratFile;

// the id of the message which started this thread = root message = message which has the attachment = thread id
// there can be multiple threads about a file - we store the first one straight away
// these are all YammerPublishedThread's
@property (nonatomic, retain) NSSet *threads;

@end

@interface YammerPublishedReport (CoreDataGeneratedAccessors)

- (void)addThreadsObject:(YammerPublishedThread *)value;
- (void)removeThreadsObject:(YammerPublishedThread *)value;
- (void)addThreads:(NSSet *)values;
- (void)removeThreads:(NSSet *)values;

@end
