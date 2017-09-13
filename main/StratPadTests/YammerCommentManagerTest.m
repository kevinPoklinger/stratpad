//
//  YammerCommentManagerTest.m
//  StratPad
//
//  Created by Julian Wood on 12-09-24.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "TestSupport.h"
#import "CoreDataTestCase.h"
#import "YammerCommentManager.h"
#import "SBJson.h"
#import "DataManager.h"

@interface YammerCommentManagerTest : CoreDataTestCase

@end


@implementation YammerCommentManagerTest

-(void)testUnreadCommentHandling
{
    NSString *path = [[NSBundle bundleForClass:[YammerCommentManagerTest class]]
                      pathForResource:@"messages2" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSString *permalink = @"externalstratpaddiscussion";
    
    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
    NSDictionary *json = [jsonParser objectWithData:data];
    [jsonParser release];
    
    // make sure our threads of interest are published somewhere
    NSArray *stratFiles = [DataManager arrayForEntity:NSStringFromClass([StratFile class]) sortDescriptorsOrNil:nil];
    for (StratFile *stratfile in stratFiles) {
        [DataManager deleteManagedInstance:stratfile];
    }
    StratFile *stratfile = [TestSupport createEmptyStratFile];
    
    // has 1 thread represented in our update
    YammerPublishedReport *yammerReport1 = (YammerPublishedReport*)[DataManager createManagedInstance:NSStringFromClass([YammerPublishedReport class])];
    yammerReport1.stratFile = stratfile;
    yammerReport1.attachmentId = [NSNumber numberWithInt:6914837];
    yammerReport1.chapterNumber = @"R1";
    yammerReport1.permalink = permalink;
    
    // attID: 6914837; 1 message total (the root)
    YammerPublishedThread *thread1 = (YammerPublishedThread*)[DataManager createManagedInstance:NSStringFromClass([YammerPublishedThread class])];
    thread1.threadStarterId = [NSNumber numberWithInt:216913159];
    thread1.creationDate = [NSDate dateTimeFromYammer:@"2012/09/27 22:47:23 +0000"];
    [yammerReport1 addThreadsObject:thread1];
    
    
    // has 2 threads represented in this update
    YammerPublishedReport *yammerReport2 = (YammerPublishedReport*)[DataManager createManagedInstance:NSStringFromClass([YammerPublishedReport class])];
    yammerReport2.stratFile = stratfile;
    yammerReport2.attachmentId = [NSNumber numberWithInt:6840629];
    yammerReport2.chapterNumber = @"R1";
    yammerReport2.permalink = permalink;

    // attID: 6840629; there are just 2 replies in our json - thread starter isn't there
    YammerPublishedThread *thread2 = (YammerPublishedThread*)[DataManager createManagedInstance:NSStringFromClass([YammerPublishedThread class])];
    thread2.threadStarterId = [NSNumber numberWithInt:215327975];
    thread2.creationDate = [NSDate dateTimeFromYammer:@"2012/09/24 07:23:09 +0000"];
    [yammerReport2 addThreadsObject:thread2];

    // attID: 6840629; 4 replies in our json (though there is actually 1 more intervening message, the thread starter is in the references)
    YammerPublishedThread *thread3 = (YammerPublishedThread*)[DataManager createManagedInstance:NSStringFromClass([YammerPublishedThread class])];
    thread3.threadStarterId = [NSNumber numberWithInt:215322919];
    thread3.creationDate = [NSDate dateTimeFromYammer:@"2012/09/24 07:06:20 +0000"];
    [yammerReport2 addThreadsObject:thread3];

    
    // for reference
    for (NSDictionary *msgDict in [json objectForKey:@"messages"]) {
        DLog(@"id: %@: t_id: %@, %@", [msgDict objectForKey:@"id"], [msgDict objectForKey:@"thread_id"], [msgDict objectForKey:@"created_at"]);
    }

//    id: 218821758: t_id: 218736526, 2012/10/03 21:02:11 +0000
//    id: 218812047: t_id: 218737065, 2012/10/03 20:26:27 +0000
//    id: 218799245: t_id: 218736526, 2012/10/03 19:41:58 +0000
//    id: 218738094: t_id: 218738094, 2012/10/03 16:34:07 +0000
//    id: 218737065: t_id: 218737065, 2012/10/03 16:30:59 +0000
//    id: 218736688: t_id: 218736526, 2012/10/03 16:29:56 +0000
//    id: 218736526: t_id: 218736526, 2012/10/03 16:29:34 +0000
//    id: 218734979: t_id: 218734979, 2012/10/03 16:25:39 +0000
//    id: 218725041: t_id: 218724631, 2012/10/03 15:58:22 +0000
//    id: 218724631: t_id: 218724631, 2012/10/03 15:57:32 +0000
//    id: 218468359: t_id: 218468140, 2012/10/03 01:23:15 +0000
//    id: 218468140: t_id: 218468140, 2012/10/03 01:22:21 +0000
//    id: 218440444: t_id: 215322919, 2012/10/02 23:07:36 +0000 -- rep2, thread3
//    id: 218387922: t_id: 215322919, 2012/10/02 19:54:16 +0000 -- rep2, thread3
//    id: 218380190: t_id: 215327975, 2012/10/02 19:29:37 +0000 -- rep2, thread2
//    id: 218375265: t_id: 216038557, 2012/10/02 19:15:46 +0000
//    id: 218363352: t_id: 215322919, 2012/10/02 18:36:44 +0000 -- rep2, thread3
//    id: 218362168: t_id: 215322919, 2012/10/02 18:32:31 +0000 -- rep2, thread3
//    id: 218336122: t_id: 215327975, 2012/10/02 17:12:26 +0000 -- rep2, thread2
//    id: 216913159: t_id: 216913159, 2012/09/27 22:47:23 +0000 -- rep1, thread1, root
        
    
    YammerCommentManager *yamMan = [YammerCommentManager sharedManager];
    NSArray *messages = [json objectForKey:@"messages"];
    [yamMan mergeCommentsForNetwork:permalink messages:messages];
    
    // filtered messages (ie referenced by YammerPublishedReport)
    STAssertEquals([yamMan unreadMessageCount], (uint)7, @"Oops");
    

    NSDictionary *prefsDict = [[NSUserDefaults standardUserDefaults] objectForKey:permalink];
    DLog(@"externalstratpaddiscussion prefs: %@", prefsDict);
        
    // mark a couple as read
    YammerComment *c1 = [[YammerComment alloc] init];
    c1.commentId = 218362168;
    YammerComment *c2 = [[YammerComment alloc] init];
    c2.commentId = 218363352;
    
    [[YammerCommentManager sharedManager] markAsRead:[NSArray arrayWithObjects:c1, c2, nil] forNetwork:permalink];

    STAssertEquals([yamMan unreadMessageCount], (uint)5, @"Oops");
}

@end
