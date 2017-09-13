//
//  YammerStoredComment.m
//  StratPad
//
//  Created by Julian Wood on 2012-10-28.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "YammerStoredComment.h"
#import "DataManager.h"

@implementation YammerStoredComment

@dynamic commentId;
@dynamic threadId;
@dynamic creationDate;
@dynamic unread;

+(YammerStoredComment*)commentFromDict:(NSDictionary*)yammerCommentDict
{
    YammerStoredComment *comment = (YammerStoredComment*)[DataManager createManagedInstance:NSStringFromClass([self class])];
    
    comment.commentId = [yammerCommentDict objectForKey:@"id"];
    comment.threadId = [yammerCommentDict objectForKey:@"thread_id"];
    comment.creationDate = [NSDate dateTimeFromYammer:[yammerCommentDict objectForKey:@"created_at"]];
    comment.unread = [NSNumber numberWithBool:YES];
    return comment;
}

+(YammerStoredComment*)commentFromYammerComment:(YammerComment*)yammerComment
{
    YammerStoredComment *comment = (YammerStoredComment*)[DataManager createManagedInstance:NSStringFromClass([self class])];
    
    comment.commentId = [NSNumber numberWithUnsignedInteger:yammerComment.commentId];
    comment.threadId = [NSNumber numberWithUnsignedInteger:yammerComment.threadId];
    comment.creationDate = yammerComment.creationDate;
    comment.unread = [NSNumber numberWithBool:YES];
    return comment;
}

@end
