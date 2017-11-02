//
//  YammerStoredComment.h
//  StratPad
//
//  Created by Julian Wood on 2012-10-28.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//
//  Serves as a cache of messages downloaded from Yammer, so that we can evaluate read/unread status
//  These are not serialized.

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "YammerComment.h"

@interface YammerStoredComment : NSManagedObject

@property (nonatomic, retain) NSNumber * commentId;
@property (nonatomic, retain) NSNumber * threadId;
@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSNumber * unread;

+(YammerStoredComment*)commentFromDict:(NSDictionary*)yammerCommentDict;
+(YammerStoredComment*)commentFromYammerComment:(YammerComment*)yammerComment;

@end
