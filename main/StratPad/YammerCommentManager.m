//
//  YammerCommentManager.m
//  StratPad
//
//  Created by Julian Wood on 12-09-24.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

//    1. Grab the latest 20 from each network.
//    2. Filter for messages relevant to reports that have been published to stratpad. These are all initially unread.
//    3. Check the local cache to see if any are read, and update (the messages and the cache).
//    4. Compute unread counts from this list of 20, in total, for stratfiles, and for reports.
//    5. When displaying the threaded conversation, show bullets beside only those messages from the 20 that were determined to be unread and relevant.
//    6. If the bullet count doesn't match the unread count, place a bullet on the more cell.
//    7. Evaluate messages as in 5 when pressing the more button.

// Note there is a data export API which would presumably allow us to download all the messages - no official URL though.
// There is also https://www.yammer.com/api/v1/networks/current.json and the unseen_message_count property, which does increment properly, but no way to decrement other than on the Yammer website, even though a GET is suggested to work. https://www.yammer.com/yammerdevelopersnetwork/#/Threads/show?threadId=110562315
// there is now also https://www.yammer.com/api/v1/threads/[:id].json which does something differently about getting a thread

/*
 
 Here's how the cache works:
 1. After grabbing the latest 20 messages from Yammer, check the cache to see if any are read (they start life as unread)
 2. We merge the two arrays:
    a. Add any messages in new set to the existing set
    b. Maintain order
    c. New messages are unread
 
 */


#import "YammerCommentManager.h"
#import "SynthesizeSingleton.h"
#import "YammerManager.h"
#import "EditionManager.h"
#import "UAKeychainUtils.h"
#import "SBJson.h"
#import "ASIFormDataRequest.h"
#import "NSString-Expanded.h"
#import "NSUserDefaults+StratPad.h"
#import "DataManager.h"
#import "EventManager.h"
#import "NSDate-StratPad.h"
#import "YammerThread.h"
#import "NSString-Expanded.h"
#import "YammerStoredComment.h"
#import "Chart.h"

@interface YammerCommentManager() {
    @private
    
    // note that updateCommentCounts can be called by way of applicationDidBecomeActive: and from kEVENT_STRATFILE_LOADED observer in the SideBarViewController
    // we only want to act on one of those events
    BOOL fetchCommentsInProgress_;
}

// every time we get some new comments, we update this dict and fire an event
// every time we read some comments, we update this dict and fire an event
// attachmentID -> unreadCt
@property (nonatomic,retain) NSMutableDictionary *unreadCts;

@end

@implementation YammerCommentManager

SYNTHESIZE_SINGLETON_FOR_CLASS(YammerCommentManager)

- (id)init
{
    self = [super init];
    if (self) {
        self.unreadCts = [NSMutableDictionary dictionaryWithCapacity:5];
    }
    return self;
}

-(void)updateCommentCounts
{
    if ([[EditionManager sharedManager] isFeatureEnabled:FeatureYammer]) {
        if (fetchCommentsInProgress_) {
            return;
        }
        
        [[YammerManager sharedManager] fetchNetworks:self action:@selector(networkFetchFinished:error:)];

        fetchCommentsInProgress_ = YES;
    }
}

-(void)networkFetchFinished:(NSArray*)networks error:(NSError*)error
{
    // at this point, we could ask for another updateCommentCounts
    fetchCommentsInProgress_ = NO;
    
    if (!error) {
        DLog(@"networks: %@", networks);
                
        for (YammerNetwork *network in networks) {
        
            NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                           network.permalink, @"permalink",
                                           [NSNumber numberWithUnsignedInt:20], @"limit",
                                           nil];
            NSDictionary *networkDefaults = [[NSUserDefaults standardUserDefaults] dictionaryForKey:network.permalink];
            if (networkDefaults) {
                YammerComment *lastFetchedComment = [YammerComment commentFromPrefs:[networkDefaults objectForKey:@"lastFetchedComment"]];
                if (lastFetchedComment.commentId) {
                    [params setObject:[NSNumber numberWithUnsignedInt:lastFetchedComment.commentId] forKey:@"newer_than"];
                }
            }

            [self fetchCommentsWithParams:params];
        }
        
//        - for testing a single network
//        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                       @"externalstratpaddiscussion", @"permalink",
//                                       [NSNumber numberWithUnsignedInt:20], @"limit",
//                                       nil];
//        [self fetchCommentsWithParams:params];
        
    } else {
        ELog(@"error: %@", error);
    }
}

#pragma mark - comments for a File

// we're going to call action on target with three params: the first is a dict of threads (each of which is an array of msg) or nil, second is an error or nil, third is a dict of userinfo, with a key of attachment (the json dict for the attachment of the original threads root comment)
-(void)fetchConversationsForFile:(NSNumber*)fileId forNetwork:(NSString*)permalink target:(id)target action:(SEL)action
{
    if (!fileId) {
        ELog(@"You have to provide a file id to fetch comments. Ignoring.")
        return;
    }

    // note this is limited to 20 messages, regardless of what we specify
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSArray arrayWithObject:fileId], @"args",
                            @"extended", @"threaded",
                            permalink, @"permalink",
                            nil];
    NSURL *url = [[YammerManager sharedManager] urlForAPI:YammerApiCallFileMessage
                                                   params:params];
    ASIHTTPRequest *request = [[YammerManager sharedManager] requestWithURL:url];
	[request setTimeOutSeconds:10];
	[request setShouldContinueWhenAppEntersBackground:YES];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(fetchConversationsForFileFinished:)];
	[request setDidFailSelector:@selector(fetchConversationsForFileFailed:)];
    
    // we'll want to notify our caller with the result, when the fetch finishes
    [request setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                          target, @"target",
                          NSStringFromSelector(action), @"action",
                          permalink, @"permalink",
                          fileId, @"fileId",
                          nil]];
    
    DLog(@"Fetching conversations for: %@ with url: %@", fileId, url);

	[request startAsynchronous];
}

- (void)fetchConversationsForFileFinished:(ASIHTTPRequest *)theRequest
{
    if ([theRequest responseStatusCode] >= 400) {
        
        // problem
        
        // {"body":["Please include a message"]}
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSDictionary *json = [jsonParser objectWithString:[theRequest responseString]];
        [jsonParser release];
        
        id target = [theRequest.userInfo objectForKey:@"target"];
        SEL action = NSSelectorFromString([theRequest.userInfo objectForKey:@"action"]);
        NSError *error = [NSError errorWithDomain:@"com.stratpad.error.yammer.conversations"
                                             code:[theRequest responseStatusCode]
                                         userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                   [[json objectForKey:@"body"] objectAtIndex:0], NSLocalizedDescriptionKey,
                                                   [theRequest responseStatusMessage], NSLocalizedFailureReasonErrorKey,
                                                   nil]];
        ELog(@"Response failure fetching conversations for file: %@", error);
        ELog(@"Request: %@", theRequest.url);
        ELog(@"Info: %@", error.userInfo);
                
        NSInvocation* invoc = [NSInvocation invocationWithMethodSignature:[target methodSignatureForSelector:action]];
        [invoc setTarget:target];
        [invoc setSelector:action];
        [invoc setArgument:&error atIndex:3];
        [invoc invoke];

        
    } else {
        
        TLog(@"response: %@", [theRequest responseString]);
        
        // success
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSDictionary *json = [jsonParser objectWithString:[theRequest responseString]];
        [jsonParser release];
                
        // Organize into threads
        
        // refs lookup
        NSMutableDictionary *refs = [NSMutableDictionary dictionaryWithCapacity:10];
        NSArray *refsArray = [json objectForKey:@"references"];
        for (NSDictionary *refDict in refsArray) {
            // store types thread, user, etc - problem is message will trump types of thread with the same id
            if (![[refDict objectForKey:@"type"] isEqualToString:@"message"]) {
                [refs setObject:refDict forKey:[refDict objectForKey:@"id"]];
            }
        }
                
        // figure out root messages for threads
        // threadId -> NSMutableArray of YammerComment
        NSMutableDictionary *threads = [NSMutableDictionary dictionaryWithCapacity:10];
        NSDictionary *rootMessageDict = nil;
        for (NSDictionary *msgDict in [json objectForKey:@"messages"]) {
            YammerComment *cmt = [YammerComment commentFromDict:msgDict];
            YammerStoredComment *storedComment = (YammerStoredComment*)[DataManager objectForEntity:NSStringFromClass([YammerStoredComment class])
                                                                               sortDescriptorsOrNil:nil
                                                                                     predicateOrNil:[NSPredicate predicateWithFormat:@"commentId = %u", cmt.commentId]];
            if (!storedComment) {
                // if we haven't seen this message, we need to store it as unread
                storedComment = [YammerStoredComment commentFromDict:msgDict];
                [DataManager saveManagedInstances];
            }
            cmt.sender = [YammerUser yammerUserFromDict:[refs objectForKey:[msgDict objectForKey:@"sender_id"]]];
            cmt.group = [YammerGroup yammerGroupFromDict:[refs objectForKey:[msgDict objectForKey:@"group_id"]]];
            cmt.isUnread = [storedComment.unread boolValue];
            
//            cmt.network =
            NSMutableArray *thread = [NSMutableArray arrayWithObject:cmt];
            [threads setObject:thread forKey:[NSNumber numberWithInt:cmt.threadId]];
            
            // do we have an attachment?
            NSArray *attachments = [msgDict objectForKey:@"attachments"];
            if (attachments.count) {
                NSNumber *attachmentId = [[attachments objectAtIndex:0] objectForKey:@"id"];
                if ([attachmentId isEqualToNumber:[theRequest.userInfo objectForKey:@"fileId"]]) {
                    rootMessageDict = msgDict;
                }
            }
        }
        
        // add any replies
        NSDictionary *replies = [json objectForKey:@"threaded_extended"];
        NSArray *threadIds = [replies allKeys];
        for (NSNumber *threadId in threadIds) {
            NSArray *repliesToThread = [replies objectForKey:threadId];
            for (NSDictionary *msgDict in repliesToThread) {
                YammerComment *cmt = [YammerComment commentFromDict:msgDict];
                YammerStoredComment *storedComment = (YammerStoredComment*)[DataManager objectForEntity:NSStringFromClass([YammerStoredComment class])
                                                                                   sortDescriptorsOrNil:nil
                                                                                         predicateOrNil:[NSPredicate predicateWithFormat:@"commentId = %u", cmt.commentId]];
                if (!storedComment) {
                    // if we haven't seen this message, we need to store it as unread
                    storedComment = [YammerStoredComment commentFromDict:msgDict];
                    [DataManager saveManagedInstances];
                }
                cmt.sender = [YammerUser yammerUserFromDict:[refs objectForKey:[msgDict objectForKey:@"sender_id"]]];
                cmt.group = [YammerGroup yammerGroupFromDict:[refs objectForKey:[msgDict objectForKey:@"group_id"]]];
                cmt.isUnread = [storedComment.unread boolValue];
                
                //            cmt.network =
                NSMutableArray *thread = [threads objectForKey:[NSNumber numberWithInt:cmt.threadId]];
                [thread addObject:cmt];
            }
        }
                        
        // sort each thread, from oldest to newest (interesting comments at the bottom)
        for (NSMutableArray *thread in threads.allValues) {
            [thread sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                NSDate *date1 = [(YammerComment*)obj1 creationDate];
                NSDate *date2 = [(YammerComment*)obj2 creationDate];
                return [date1 compare:date2];
            }];
        }
        
        // organize into YammerThread
        NSMutableDictionary *yammerThreads = [NSMutableDictionary dictionaryWithCapacity:threads.count];
        for (NSNumber *threadId in threads.allKeys) {
            NSMutableArray *thread = [threads objectForKey:threadId];
            
            YammerThread *yammerThread = [[YammerThread alloc] init];
            yammerThread.comments = thread;
                        
            [yammerThreads setObject:yammerThread forKey:threadId];
            [yammerThread release];
        }
        
        // now figure out if threads have more messages available
        for (YammerThread *yammerThread in yammerThreads.allValues) {
            // we need to look at the references array, where the id = this threadid
            // in there, look at updates: this is the count of all comments in the thread, including the root comment
            NSNumber *threadId = [NSNumber numberWithInt:[(YammerComment*)[yammerThread.comments objectAtIndex:0] commentId]];
            NSDictionary *ref = [refs objectForKey:threadId];
            yammerThread.totalComments = [[[ref objectForKey:@"stats"] objectForKey:@"updates"] unsignedIntegerValue];

            // if we don't have as many comments in our thread, there must be more waiting
            yammerThread.hasMoreComments = yammerThread.comments.count < yammerThread.totalComments ? YES : NO;
        }
        
        // get the dict for the attachment in the root thread of the oldest thread
                
        id target = [theRequest.userInfo objectForKey:@"target"];
        SEL action = NSSelectorFromString([theRequest.userInfo objectForKey:@"action"]);
        
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:rootMessageDict forKey:@"message"];
        
        // provide the attachment name from the oldest thread starter comment
        NSInvocation* invoc = [NSInvocation invocationWithMethodSignature:[target methodSignatureForSelector:action]];
        [invoc setTarget:target];
        [invoc setSelector:action];
        [invoc setArgument:&yammerThreads atIndex:2];
        [invoc setArgument:&userInfo atIndex:4];
        [invoc invoke];

    }
}

- (void)fetchConversationsForFileFailed:(ASIHTTPRequest *)theRequest
{
    NSError *error = [NSError errorWithDomain:@"com.stratpad.error.yammer.conversations"
                                         code:[theRequest responseStatusCode]
                                     userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                               [NSString stringWithFormat:@"Couldn't fetch file conversations. Problem: %@", [[theRequest error] localizedDescription]], NSLocalizedDescriptionKey,
                                               [theRequest responseStatusMessage], NSLocalizedFailureReasonErrorKey,
                                               nil]];
    ELog(@"Request failed fetching conversations for file: %@", error);
    ELog(@"Request: %@", theRequest.url);
    ELog(@"Info: %@", error.userInfo);
    
    id target = [theRequest.userInfo objectForKey:@"target"];
    SEL action = NSSelectorFromString([theRequest.userInfo objectForKey:@"action"]);
    
    NSInvocation* invoc = [NSInvocation invocationWithMethodSignature:[target methodSignatureForSelector:action]];
    [invoc setTarget:target];
    [invoc setSelector:action];
    [invoc setArgument:&error atIndex:3];
    [invoc invoke];

}



#pragma mark - all recent comments in a network

-(void)fetchCommentsWithParams:(NSDictionary*)params
{
    // params contains the permalink, which will focus messages on a network
    NSURL *url = [[YammerManager sharedManager] urlForAPI:YammerApiCallAllNewMessages params:params];
    ASIHTTPRequest *request = [[YammerManager sharedManager] requestWithURL:url];
	[request setTimeOutSeconds:10];
	[request setShouldContinueWhenAppEntersBackground:YES];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(fetchCommentsFinished:)];
	[request setDidFailSelector:@selector(fetchCommentsFailed:)];
    
    [request setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                          [params objectForKey:@"permalink"], @"permalink",
                          nil]];
    
	[request startAsynchronous];
    fetchCommentsInProgress_ = YES;
}

- (void)fetchCommentsFinished:(ASIHTTPRequest *)theRequest
{
    if ([theRequest responseStatusCode] >= 400) {
        
        // problem
        
        // {"body":["Please include a message"]}
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSDictionary *json = [jsonParser objectWithString:[theRequest responseString]];
        [jsonParser release];
        
        NSError *error = [NSError errorWithDomain:@"com.stratpad.error.yammer.comments"
                                             code:[theRequest responseStatusCode]
                                         userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                   [[json objectForKey:@"body"] objectAtIndex:0], NSLocalizedDescriptionKey,
                                                   [theRequest responseStatusMessage], NSLocalizedFailureReasonErrorKey,
                                                   nil]];
        ELog(@"Response failure fetching all comments: %@", error);
        ELog(@"Request: %@", theRequest.url);
        ELog(@"Info: %@", error.userInfo);
                        
    } else {
        
        DLog(@"url: %@", [theRequest url]);
        TLog(@"response: %@", [theRequest responseString]);
        
        // success
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSDictionary *json = [jsonParser objectWithString:[theRequest responseString]];
        [jsonParser release];

        // just make these results available
        NSString *permalink = [theRequest.userInfo objectForKey:@"permalink"];
        NSArray *messages = [json objectForKey:@"messages"];
        [self mergeCommentsForNetwork:permalink messages:messages];
        
        // update prefs
        if (messages.count) {
            // the newest message is first - we're using last in the context of the most recent message seen - the last seen
            NSDictionary *lastMsgDict = [messages objectAtIndex:0];
            YammerComment *lastCmt = [YammerComment commentFromDict:lastMsgDict];
            NSDictionary *networkDefaults = [NSDictionary dictionaryWithObject:[lastCmt dictionaryForPrefs] forKey:@"lastFetchedComment"];
            [[NSUserDefaults standardUserDefaults] setObject:networkDefaults forKey:permalink];
        }

        [YammerCommentManager fireYammerCommentsUpdated];

#if DEBUG
        for (NSDictionary *msgDict in messages) {
            DLog(@"msg: %@, %@", [msgDict objectForKey:@"id"], [[msgDict objectForKey:@"body"] objectForKey:@"plain"]);
        }
        
        NSArray *stratFiles = [DataManager arrayForEntity:NSStringFromClass([StratFile class]) sortDescriptorsOrNil:nil];
        for (StratFile *stratfile in stratFiles) {
            TLog(@"stratfile: %@, ct: %u", stratfile.name, [[YammerCommentManager sharedManager] unreadMessageCountForStratFile:stratfile]);
        }
#endif

    }
    fetchCommentsInProgress_ = NO;
}

- (void)fetchCommentsFailed:(ASIHTTPRequest *)theRequest
{
    fetchCommentsInProgress_ = NO;

    NSError *error = [NSError errorWithDomain:@"com.stratpad.error.yammer.comments"
                                         code:[theRequest responseStatusCode]
                                     userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                               [NSString stringWithFormat:@"Couldn't fetch all comments. Problem: %@", [[theRequest error] localizedDescription]], NSLocalizedDescriptionKey,
                                               [theRequest responseStatusMessage], NSLocalizedFailureReasonErrorKey,
                                               nil]];
    ELog(@"Request failed fetching all comments: %@", error);
    ELog(@"Request: %@", theRequest.url);
    ELog(@"Info: %@", error.userInfo);
}

#pragma mark - post comment

// we're going to call action on target with two params: the first is a YammerComment or nil, second is an error or nil
-(void)postComment:(NSString*)text inReplyTo:(YammerComment*)yammerComment forNetwork:(NSString*)permalink target:(id)target action:(SEL)action
{
    NSURL *url = [[YammerManager sharedManager] urlForAPI:YammerApiCallPostMessage params:[NSDictionary dictionaryWithObject:permalink forKey:@"permalink"]];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    // add content
    [request setPostValue:text forKey:@"body"];
    if (yammerComment.group) {
        [request setPostValue:[NSNumber numberWithInt:yammerComment.group.groupId] forKey:@"group_id"];
    }
    [request setPostValue:[NSNumber numberWithInt:yammerComment.commentId] forKey:@"replied_to_id"];
    
    // add auth
    [[YammerManager sharedManager] addAuthToRequest:request];
    
	[request setTimeOutSeconds:10];
	[request setShouldContinueWhenAppEntersBackground:YES];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(postCommentFinished:)];
	[request setDidFailSelector:@selector(postCommentFailed:)];
    
    // we'll want to notify our caller with the result, when the fetch finishes
    [request setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                          target, @"target",
                          NSStringFromSelector(action), @"action",
                          permalink, @"permalink",
                          nil]];
    
	[request startAsynchronous];
}

- (void)postCommentFinished:(ASIHTTPRequest *)theRequest
{
    id target = [theRequest.userInfo objectForKey:@"target"];
    SEL action = NSSelectorFromString([theRequest.userInfo objectForKey:@"action"]);

    if ([theRequest responseStatusCode] >= 400) {
        
        // problem
        
        // {"body":["Please include a message"]}
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSDictionary *json = [jsonParser objectWithString:[theRequest responseString]];
        [jsonParser release];
        
        NSError *error = [NSError errorWithDomain:@"com.stratpad.error.yammer.comments"
                                             code:[theRequest responseStatusCode]
                                         userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                   [[json objectForKey:@"body"] objectAtIndex:0], NSLocalizedDescriptionKey,
                                                   [theRequest responseStatusMessage], NSLocalizedFailureReasonErrorKey,
                                                   nil]];
        ELog(@"Response failure posting comment: %@", error);
        ELog(@"Request: %@", theRequest.url);
        ELog(@"Info: %@", error.userInfo);
        
        [target performSelector:action withObject:nil withObject:error];
        
    } else {
                
        // success
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSDictionary *json = [jsonParser objectWithString:[theRequest responseString]];
        [jsonParser release];
        
        // refs lookup
        NSMutableDictionary *refs = [NSMutableDictionary dictionaryWithCapacity:10];
        NSArray *refsArray = [json objectForKey:@"references"];
        for (NSDictionary *refDict in refsArray) {
            [refs setObject:refDict forKey:[refDict objectForKey:@"id"]];
        }
        
        NSDictionary *msg = [[json objectForKey:@"messages"] objectAtIndex:0];
        YammerComment *cmt = [[YammerComment alloc] init];
        cmt.threadId = [[msg objectForKey:@"thread_id"] unsignedIntValue];
        cmt.text = [[msg objectForKey:@"body"] objectForKey:@"plain"];
        cmt.commentId = [[msg objectForKey:@"id"] unsignedIntValue];
        cmt.creationDate = [NSDate dateTimeFromYammer:[msg objectForKey:@"created_at"]];
        cmt.sender = [YammerUser yammerUserFromDict:[refs objectForKey:[msg objectForKey:@"sender_id"]]];
        cmt.group = [YammerGroup yammerGroupFromDict:[refs objectForKey:[msg objectForKey:@"group_id"]]];
        cmt.isUnread = NO;
        //            cmt.network =
        
        // we've seen this comment so make sure it is stored as read
        [self markAsRead:[NSArray arrayWithObject:cmt] forNetwork:[theRequest.userInfo objectForKey:@"permalink"]];
        
        [target performSelector:action withObject:cmt withObject:nil];
        [cmt release];
    }
}

- (void)postCommentFailed:(ASIHTTPRequest *)theRequest
{
    id target = [theRequest.userInfo objectForKey:@"target"];
    SEL action = NSSelectorFromString([theRequest.userInfo objectForKey:@"action"]);

    NSError *error = [NSError errorWithDomain:@"com.stratpad.error.yammer.comments"
                                         code:[theRequest responseStatusCode]
                                     userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                               [NSString stringWithFormat:@"Couldn't post comment. Problem: %@", [[theRequest error] localizedDescription]], NSLocalizedDescriptionKey,
                                               [theRequest responseStatusMessage], NSLocalizedFailureReasonErrorKey,
                                               nil]];
    ELog(@"Request failed posting comment: %@", error);
    ELog(@"Request: %@", theRequest.url);
    ELog(@"Info: %@", error.userInfo);
    
    [target performSelector:action withObject:nil withObject:error];
    
}

#pragma mark - all comments for a thread (to fill in "more")


-(void)fetchThread:(NSNumber*)threadId forNetwork:(NSString*)permalink target:(id)target action:(SEL)action userInfo:(NSDictionary*)userInfo
{    
    NSAssert(threadId != nil, @"You have to provide a thread id to fetch comments.");
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSArray arrayWithObject:threadId], @"args",
                            permalink, @"permalink",
                            nil];
    NSURL *url = [[YammerManager sharedManager] urlForAPI:YammerApiCallThread
                                                   params:params];
    ASIHTTPRequest *request = [[YammerManager sharedManager] requestWithURL:url];
	[request setTimeOutSeconds:10];
	[request setShouldContinueWhenAppEntersBackground:YES];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(fetchThreadFinished:)];
	[request setDidFailSelector:@selector(fetchThreadFailed:)];
    
    // we'll want to notify our caller with the result, when the fetch finishes
    [request setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                          target, @"target",
                          NSStringFromSelector(action), @"action",
                          userInfo, @"userInfo",
                          permalink, @"permalink",
                          nil]];
    
    DLog(@"Fetching conversations for: %@ with url: %@", threadId, url);
    
	[request startAsynchronous];
}

- (void)fetchThreadFinished:(ASIHTTPRequest *)theRequest
{
    id target = [theRequest.userInfo objectForKey:@"target"];
    SEL action = NSSelectorFromString([theRequest.userInfo objectForKey:@"action"]);
    NSDictionary *userInfo = [theRequest.userInfo objectForKey:@"userInfo"];

    if ([theRequest responseStatusCode] >= 400) {
        
        // problem
        
        // {"body":["Please include a message"]}
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSDictionary *json = [jsonParser objectWithString:[theRequest responseString]];
        [jsonParser release];
        
        NSError *error = [NSError errorWithDomain:@"com.stratpad.error.yammer.comments"
                                             code:[theRequest responseStatusCode]
                                         userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                   [[json objectForKey:@"body"] objectAtIndex:0], NSLocalizedDescriptionKey,
                                                   [theRequest responseStatusMessage], NSLocalizedFailureReasonErrorKey,
                                                   nil]];
        ELog(@"Response failure fetching thread: %@", error);
        ELog(@"Request: %@", theRequest.url);
        ELog(@"Info: %@", error.userInfo);
        
        NSInvocation* invoc = [NSInvocation invocationWithMethodSignature:[target methodSignatureForSelector:action]];
        [invoc setTarget:target];
        [invoc setSelector:action];
        [invoc setArgument:&error atIndex:3];
        [invoc setArgument:&userInfo atIndex:4];
        [invoc invoke];
                
    } else {
        
        DLog(@"url: %@", [theRequest url]);
        TLog(@"response: %@", [theRequest responseString]);
        
        // success
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSDictionary *json = [jsonParser objectWithString:[theRequest responseString]];
        [jsonParser release];
        
        // refs lookup
        NSMutableDictionary *refs = [NSMutableDictionary dictionaryWithCapacity:10];
        NSArray *refsArray = [json objectForKey:@"references"];
        for (NSDictionary *refDict in refsArray) {
            // store types thread, user, etc - problem is message will trump types of thread with the same id
            if (![[refDict objectForKey:@"type"] isEqualToString:@"message"]) {
                [refs setObject:refDict forKey:[refDict objectForKey:@"id"]];
            }
        }
        
        // store these messages
        NSString *permalink = [theRequest.userInfo objectForKey:@"permalink"];
        [self mergeCommentsForNetwork:permalink messages:[json objectForKey:@"messages"]];
        
        // assemble into a thread
        NSArray *messages = [json objectForKey:@"messages"];
        NSMutableArray *comments = [NSMutableArray arrayWithCapacity:messages.count];
        // this is ordered from newest to oldest (oldest being the root, with the attachment); we order it in the opposite direction
        for (int i=messages.count-1; i>=0; --i) {
            NSDictionary *msg = [messages objectAtIndex:i];
            YammerComment *cmt = [YammerComment commentFromDict:msg];
            YammerStoredComment *storedComment = (YammerStoredComment*)[DataManager objectForEntity:NSStringFromClass([YammerStoredComment class])
                                                                               sortDescriptorsOrNil:nil
                                                                                     predicateOrNil:[NSPredicate predicateWithFormat:@"commentId = %u", cmt.commentId]];
            if (!storedComment) {
                // if we haven't seen this message, we need to store it as unread
                storedComment = [YammerStoredComment commentFromDict:msg];
                [DataManager saveManagedInstances];
            }
            cmt.sender = [YammerUser yammerUserFromDict:[refs objectForKey:[msg objectForKey:@"sender_id"]]];
            cmt.group = [YammerGroup yammerGroupFromDict:[refs objectForKey:[msg objectForKey:@"group_id"]]];
            cmt.isUnread = [storedComment.unread boolValue];
            
            //            cmt.network =
            [comments addObject:cmt];
        }
        
        YammerThread *yammerThread = [[YammerThread alloc] init];
        yammerThread.comments = comments;
                
        NSInvocation* invoc = [NSInvocation invocationWithMethodSignature:[target methodSignatureForSelector:action]];
        [invoc setTarget:target];
        [invoc setSelector:action];
        [invoc setArgument:&yammerThread atIndex:2];
        [invoc setArgument:&userInfo atIndex:4];
        [invoc invoke];
        
        [yammerThread release];

    }
}

- (void)fetchThreadFailed:(ASIHTTPRequest *)theRequest
{
    
    NSError *error = [NSError errorWithDomain:@"com.stratpad.error.yammer.comments"
                                         code:[theRequest responseStatusCode]
                                     userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                               [NSString stringWithFormat:@"Couldn't fetch thread. Problem: %@", [[theRequest error] localizedDescription]], NSLocalizedDescriptionKey,
                                               [theRequest responseStatusMessage], NSLocalizedFailureReasonErrorKey,
                                               nil]];
    ELog(@"Request failed fetching thread: %@", error);
    ELog(@"Request: %@", theRequest.url);
    ELog(@"Info: %@", error.userInfo);
    
    id target = [theRequest.userInfo objectForKey:@"target"];
    SEL action = NSSelectorFromString([theRequest.userInfo objectForKey:@"action"]);
    NSDictionary *userInfo = [theRequest.userInfo objectForKey:@"userInfo"];

    NSInvocation* invoc = [NSInvocation invocationWithMethodSignature:[target methodSignatureForSelector:action]];
    [invoc setTarget:target];
    [invoc setSelector:action];
    [invoc setArgument:&error atIndex:3];
    [invoc setArgument:&userInfo atIndex:4];
    [invoc invoke];

}

#pragma mark - post file with comment

-(void)uploadToYammer:(NSString*)path filename:(NSString*)filename inReplyTo:(NSNumber*)originalThreadId message:(NSString*)message groupId:(NSNumber*)groupId
           forNetwork:(NSString*)permalink target:(id)target action:(SEL)action
{
    // if network is nil, then we will just use the last network chosen by the user
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    if (permalink) {
        [params setObject:permalink forKey:@"permalink"];
    }
    
    NSURL *url = [[YammerManager sharedManager] urlForAPI:YammerApiCallPostMessage params:params];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    if (originalThreadId) {
        [request setPostValue:originalThreadId forKey:@"replied_to_id"];
    }
    
    [request setPostValue:message forKey:@"body"];
    if (groupId) {
        [request setPostValue:groupId forKey:@"group_id"];
    }

    [request setFile:path withFileName:filename andContentType:nil forKey:@"attachment1"];

    // add auth
    [[YammerManager sharedManager] addAuthToRequest:request];

    // misc
	[request setTimeOutSeconds:60];
	[request setShouldContinueWhenAppEntersBackground:YES];
	[request setDelegate:self];
	[request setDidFailSelector:@selector(uploadFailed:)];
	[request setDidFinishSelector:@selector(uploadFinished:)];
    
    // we'll want to notify our caller with the result, when the fetch finishes
    [request setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                          target, @"target",
                          NSStringFromSelector(action), @"action",
                          permalink, @"permalink",
                          nil]];
    
	[request startAsynchronous];
    
}

- (void)uploadFailed:(ASIHTTPRequest *)theRequest
{
    id target = [theRequest.userInfo objectForKey:@"target"];
    SEL action = NSSelectorFromString([theRequest.userInfo objectForKey:@"action"]);
    
    NSError *error = [NSError errorWithDomain:@"com.stratpad.error.yammer.comments"
                                         code:[theRequest responseStatusCode]
                                     userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                               [NSString stringWithFormat:@"Couldn't upload file. Problem: %@", [[theRequest error] localizedDescription]], NSLocalizedDescriptionKey,
                                               [theRequest responseStatusMessage], NSLocalizedFailureReasonErrorKey,
                                               nil]];
    ELog(@"Request failed uploading file: %@", error);
    ELog(@"Request: %@", theRequest.url);
    ELog(@"Info: %@", error.userInfo);
    
    [target performSelector:action withObject:nil withObject:error];

    
}

- (void)uploadFinished:(ASIHTTPRequest *)theRequest
{
    DLog(@"Finished uploading %llu bytes of data",[theRequest postLength]);
        
    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
    NSDictionary *json = [jsonParser objectWithString:[theRequest responseString]];
    [jsonParser release];
    
    id target = [theRequest.userInfo objectForKey:@"target"];
    SEL action = NSSelectorFromString([theRequest.userInfo objectForKey:@"action"]);
    
    if ([theRequest responseStatusCode] >= 400) {
                
        NSError *error = [NSError errorWithDomain:@"com.stratpad.error.yammer.comments"
                                             code:[theRequest responseStatusCode]
                                         userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                   [[json objectForKey:@"body"] objectAtIndex:0], NSLocalizedDescriptionKey,
                                                   [theRequest responseStatusMessage], NSLocalizedFailureReasonErrorKey,
                                                   nil]];
        ELog(@"Response failure uploading file: %@", error);
        ELog(@"Request: %@", theRequest.url);
        ELog(@"Info: %@", error.userInfo);
        
        [target performSelector:action withObject:nil withObject:error];
        
    } else {
        
        // success
        [target performSelector:action withObject:json withObject:nil];

    }
}


#pragma mark - Private

+ (void)fireYammerCommentsUpdated
{
    NSNotification *notification = [NSNotification notificationWithName:kEVENT_YAMMER_COMMENTS_UPDATED object:nil userInfo:nil];
	[[NSNotificationQueue defaultQueue] enqueueNotification:notification postingStyle:NSPostASAP];
}

- (void)fireYammerLoggedInEvent
{
    [self updateCommentCounts];
    
    NSNotification *notification = [NSNotification notificationWithName:kEVENT_YAMMER_LOGGED_IN object:nil userInfo:nil];
	[[NSNotificationQueue defaultQueue] enqueueNotification:notification postingStyle:NSPostASAP];    
}

#pragma mark - Protected

-(void)markAsRead:(NSArray*)yammerComments forNetwork:(NSString*)permalink
{
    for (YammerComment *comment in yammerComments) {
        YammerStoredComment *storedComment = (YammerStoredComment*)[DataManager objectForEntity:NSStringFromClass([YammerStoredComment class])
                                                                           sortDescriptorsOrNil:nil
                                                                                 predicateOrNil:[NSPredicate predicateWithFormat:@"commentId = %u", comment.commentId]];
        if (!storedComment) {
            storedComment = [YammerStoredComment commentFromYammerComment:comment];
        }
        storedComment.unread = NO;
    }
    [DataManager saveManagedInstances];
    
    // refresh the counts
    [self countUnreadMessageInYammerPublishedReports];
}

- (void)mergeCommentsForNetwork:(NSString*)permalink messages:(NSArray*)messageDicts
{
    // just save all relevant messages
    
    // all published reports for all stratfiles
    NSArray *publishedReports = [DataManager arrayForEntity:NSStringFromClass([YammerPublishedReport class]) sortDescriptorsOrNil:nil];
    
    // lookup sets
    NSMutableSet *publishedThreadIds = [[NSMutableSet alloc] initWithCapacity:10];
    NSMutableSet *publishedAttachmentIds = [[NSMutableSet alloc] initWithCapacity:10];
    for (YammerPublishedReport *yamReport in publishedReports) {
        for (YammerPublishedThread *thread in yamReport.threads) {
            [publishedThreadIds addObject:thread.threadStarterId];
        }
        [publishedAttachmentIds addObject:yamReport.attachmentId];
    }
    
    // store each of these message ids
    NSMutableArray *secondRun = [NSMutableArray arrayWithCapacity:20];
    for (NSDictionary *msgDict in messageDicts) {
        
        NSNumber *threadId = [NSNumber numberWithInt:[[msgDict objectForKey:@"thread_id"] intValue]];

        // do we have an attachment?
        NSArray *attachments = [msgDict objectForKey:@"attachments"];
        NSNumber *attachmentId = nil;
        if (attachments.count) {
            attachmentId = [NSNumber numberWithInt:[[[attachments objectAtIndex:0] objectForKey:@"id"] intValue]];
        }

        if ([publishedThreadIds containsObject:threadId] || [publishedAttachmentIds containsObject:attachmentId]) {

            // see if this comment already exists
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"commentId = %@", [msgDict objectForKey:@"id"]];
            YammerStoredComment *comment = (YammerStoredComment*)[DataManager objectForEntity:NSStringFromClass([YammerStoredComment class])
                                                                         sortDescriptorsOrNil:nil
                                                                               predicateOrNil:predicate];
            if (!comment) {
                // store the comment
                [YammerStoredComment commentFromDict:msgDict];
                
                // is this a new conversation started on yammer, about our file?
                if (![publishedThreadIds containsObject:threadId]) {
                    
                    // get the correct YammerPublishedReport and add a YammerPublishedThread (it's the only way we can know about new threads)
                    for (YammerPublishedReport *yamReport in publishedReports) {
                        if (yamReport.attachmentId.intValue == attachmentId.intValue) {
                            YammerPublishedThread *thread = (YammerPublishedThread*)[DataManager createManagedInstance:NSStringFromClass([YammerPublishedThread class])];
                            thread.threadStarterId = threadId;
                            thread.creationDate = [NSDate dateTimeFromYammer:[msgDict objectForKey:@"created_at"]];
                            
                            [yamReport addThreadsObject:thread];
                            
                            // update published threads lookup set
                            [publishedThreadIds addObject:threadId];
                            break;
                        }
                    }
                    
                }
                [DataManager saveManagedInstances];
            }
            
        }
        else {
            // it's possible we have a new thread, with a new reply - if the reply comes first, it won't get recorded because it doesn't have an attachment, and we don't yet know about its thread parent
            // so we'll need to check again to see if its thread root has an attachment
            [secondRun addObject:msgDict];
        }
    }
    
    // check again for replies that are new, that came before their root thread was processed
    if (secondRun.count) {
        for (NSDictionary *msgDict in secondRun) {
            // we want to see if the root thread is now stored in the db
            NSNumber *threadId = [NSNumber numberWithInt:[[msgDict objectForKey:@"thread_id"] intValue]];
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"threadId = %@", threadId];
            YammerStoredComment *rootComment = (YammerStoredComment*)[DataManager objectForEntity:NSStringFromClass([YammerStoredComment class])
                                                                             sortDescriptorsOrNil:nil
                                                                                   predicateOrNil:predicate];
            if (rootComment) {
                // store this new reply then
                [YammerStoredComment commentFromDict:msgDict];
            }
        }
        
        [DataManager saveManagedInstances];
    }
    
    // cleanup
    [publishedThreadIds release];
    [publishedAttachmentIds release];
    
    // refresh message counts
    [self countUnreadMessageInYammerPublishedReports];
}

#pragma mark - Handle message counting


- (NSUInteger)unreadMessageCount
{
    // we have to look through all our stratfiles to get the count
    NSArray *stratFiles = [DataManager arrayForEntity:NSStringFromClass([StratFile class]) sortDescriptorsOrNil:nil];
    NSUInteger ctr = 0;
    for (StratFile *stratfile in stratFiles) {
        ctr += [self unreadMessageCountForStratFile:stratfile];
    }
    
    return ctr;
}

- (NSUInteger)unreadMessageCountForStratFile:(StratFile*)stratfile
{    
    // eg. we published R1 with thread id 1234 and R6 with thread id 2345
    NSSet *publishedReports = stratfile.yammerReports;
    
    // count
    NSUInteger ctr = 0;
    for (YammerPublishedReport *yamReport in publishedReports) {
        ctr += [[self.unreadCts objectForKey:yamReport.attachmentId] unsignedIntValue];
    }
    return ctr;
}

-(NSUInteger)unreadMessageCountForChapterNumber:(NSString*)chapterNumber stratFile:(StratFile*)stratfile
{    
    // eg. we published R1 with thread id 1234 and R6 with thread id 2345
    NSSet *publishedReports = stratfile.yammerReports;
    
    // count
    NSUInteger ctr = 0;
    for (YammerPublishedReport *yamReport in publishedReports) {
        if ([yamReport.chapterNumber isEqualToString:chapterNumber]) {
            ctr += [[self.unreadCts objectForKey:yamReport.attachmentId] unsignedIntValue];
        }
    }
    return ctr;
}

-(NSUInteger)unreadMessageCountForChart:(Chart*)chart stratFile:(StratFile*)stratfile
{    
    // eg. we published R1 with thread id 1234 and R6 with thread id 2345
    NSSet *publishedReports = stratfile.yammerReports;
    
    // count
    NSUInteger ctr = 0;
    for (YammerPublishedReport *yamReport in publishedReports) {
        if ([yamReport.chapterNumber isEqualToString:@"S1"] && [chart.uuid isEqualToString:yamReport.chart.uuid]) {
            ctr += [[self.unreadCts objectForKey:yamReport.attachmentId] unsignedIntValue];
        }
    }
    return ctr;
}

#pragma mark - Private

- (void)countUnreadMessageInYammerPublishedReports
{
    // at this point all relevant messages have already been stored in core data
    // they also have their unread status updated
    // all we have to do is retrieve them and report counts appropriately
    
    [self.unreadCts removeAllObjects];
    
    // ThreadId->count
    NSMutableDictionary *counts = [NSMutableDictionary dictionaryWithCapacity:10];    
    
    // we need to have done a mergeCommentsForNetwork:messages: by this point, which will ensure that relevant messages have been stored
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"unread = %@", [NSNumber numberWithBool:YES]];
    NSArray *unreadMessages = [DataManager arrayForEntity:NSStringFromClass([YammerStoredComment class])
                                     sortDescriptorsOrNil:nil
                                           predicateOrNil:predicate];
    
    // organize into counts by thread
    for (YammerStoredComment *comment in unreadMessages) {
        // now count it
        NSNumber *ctr = [counts objectForKey:comment.threadId];
        if (!ctr) {
            ctr = [NSNumber numberWithInt:1];
        } else {
            ctr = [NSNumber numberWithInt:ctr.intValue+1];
        }
        [counts setObject:ctr forKey:comment.threadId];
    }
    
    // results - tally the unread for each yamReport
    // since we can't serialize a YamReport (and use it for a key), just use the attachment id
    NSArray *publishedReports = [DataManager arrayForEntity:NSStringFromClass([YammerPublishedReport class]) sortDescriptorsOrNil:nil];
    for (YammerPublishedReport *yamReport in publishedReports) {
        NSUInteger ct = 0;
        for (YammerPublishedThread *thread in yamReport.threads) {
            NSNumber *ctr = [counts objectForKey:thread.threadStarterId];
            ct += ctr ? ctr.intValue : 0;
        }
        
        [self.unreadCts setObject:[NSNumber numberWithInt:ct] forKey:yamReport.attachmentId];
    }
    
    DLog(@"unreadCts: %@", self.unreadCts);
}



@end
