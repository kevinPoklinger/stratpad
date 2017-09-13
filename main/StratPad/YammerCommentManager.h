//
//  YammerCommentManager.h
//  StratPad
//
//  Created by Julian Wood on 12-09-24.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YammerComment.h"
#import "Chart.h"

@interface YammerCommentManager : NSObject;

// init
+ (YammerCommentManager *)sharedManager;

-(void)updateCommentCounts;

// all the threads about a given file; the fileId is the attachmentId from Yammer; we get the root message, the attachment, and the latest 2 replies
-(void)fetchConversationsForFile:(NSNumber*)fileId forNetwork:(NSString*)permalink target:(id)target action:(SEL)action;

// post a comment in reply to another comment (typically the root comment in our impl)
-(void)postComment:(NSString*)text inReplyTo:(YammerComment*)yammerComment forNetwork:(NSString*)permalink target:(id)target action:(SEL)action;

// dealing with storage and retrieval of unread comments
-(void)markAsRead:(NSArray*)yammerComments forNetwork:(NSString*)permalink;

// gets all the messages in a thread - used when the user presses more
// expecting to see "indexPath" key in the userInfo
-(void)fetchThread:(NSNumber*)threadId forNetwork:(NSString*)permalink target:(id)target action:(SEL)action userInfo:(NSDictionary*)userInfo;

// if we successfully log in, fire an event so the sidebar can update itself, the comments can be fetched
- (void)fireYammerLoggedInEvent;

// send a file to yammer
// @param path              - the path to an existing pdf
// @param filename          - the filename to use for the upload process
// @param originalThreadId  - the comment to which we are replying; can be nil
// @param message           - the text of the comment
// @param groupId           - yammer id for the group - can be nil
// @param forNetwork        - permalink for the network; nil will use the existing chosen, logged in network
// @param target            - object to notify on completion
// @param action            - action to invoke on completion - sent 2 params: an NSDictionary of the message (or nil) and an error (or nil)
-(void)uploadToYammer:(NSString*)path filename:(NSString*)filename inReplyTo:(NSNumber*)originalThreadId
              message:(NSString*)message groupId:(NSNumber*)groupId
           forNetwork:(NSString*)permalink target:(id)target action:(SEL)action;

// determine various counts based on the existing messages in core data
- (NSUInteger)unreadMessageCount;
- (NSUInteger)unreadMessageCountForStratFile:(StratFile*)stratfile;
- (NSUInteger)unreadMessageCountForChapterNumber:(NSString*)chapterNumber stratFile:(StratFile*)stratfile;
- (NSUInteger)unreadMessageCountForChart:(Chart*)chart stratFile:(StratFile*)stratfile;


@end

@interface YammerCommentManager (Protected)

- (void)mergeCommentsForNetwork:(NSString*)permalink messages:(NSArray*)messageDicts;
-(void)markAsRead:(NSArray*)yammerComments forNetwork:(NSString*)permalink;

@end
