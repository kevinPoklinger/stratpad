//
//  YammerComment.h
//  StratPad
//
//  Created by Julian Wood on 12-09-24.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YammerGroup.h"
#import "YammerUser.h"
#import "YammerNetwork.h"

@interface NSDate (YammerComment)
+(NSDate*)dateTimeFromYammer:(NSString *)str;
-(NSString*)stringForYammerDateTime;
@end

@interface YammerComment : NSObject

// who sent the message? <sender_id>
@property (nonatomic, retain) YammerUser *sender;

// to which group? can be nil <group_id>
@property (nonatomic, retain) YammerGroup *group;

// and to which network? <network_id>
@property (nonatomic, retain) YammerNetwork *network;

// the thread to which this comment belongs <thread_id>
@property (nonatomic, assign) NSUInteger threadId;

// the unique id of this comment <id>
@property (nonatomic, assign) NSUInteger commentId;

// the text of the comment <body><plain>
@property (nonatomic, retain) NSString *text;

// the date this message was posted <created_at>, format: "2012/09/26 21:43:46 +0000", in UTC
@property (nonatomic, retain) NSDate *creationDate;

// true if this is a new message that hasn't been seen by the user
@property (nonatomic, assign) BOOL isUnread;

-(NSDictionary*)dictionaryForPrefs;

// unmarshall from preferences
+(YammerComment*)commentFromPrefs:(NSDictionary*)yammerCommentDict;

// from JSON
+(YammerComment*)commentFromDict:(NSDictionary*)yammerCommentDict;

@end
