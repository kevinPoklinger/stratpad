//
//  YammerTest.m
//  StratPad
//
//  Created by Julian Wood on 7/25/12.
//  Copyright 2012 Glassey Strategy. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "TestSupport.h"
#import "CoreDataTestCase.h"
#import "YammerUser.h"
#import "YammerGroup.h"
#import "YammerManager.h"
#import "YammerComment.h"
#import "SBJson.h"
#import "DataManager.h"

@interface YammerTest : CoreDataTestCase 
    
@end


static NSString *userJSON = @" \
{ \"activated_at\" : \"2012/06/01 04:28:13 +0000\", \
    \"admin\" : \"false\", \
    \"birth_date\" : \"\", \
    \"can_broadcast\" : \"false\", \
    \"canonical_network_name\" : \"mobilesce.com\", \
    \"contact\" : { \"email_addresses\" : [ { \"address\" : \"julian-guest+yammerdevelopersnetwork@users.yammer.com\", \
    \"type\" : \"other\" \
    } ], \
    \"im\" : { \"provider\" : \"\", \
    \"username\" : \"\" \
    }, \
    \"phone_numbers\" : [  ] \
    }, \
    \"department\" : null, \
    \"expertise\" : \"\", \
    \"external_urls\" : [  ], \
    \"first_name\" : \"Julian\", \
    \"follow_general_messages\" : false, \
    \"full_name\" : \"Julian Wood\", \
    \"guid\" : null, \
    \"hire_date\" : null, \
    \"id\" : 1487386865, \
    \"interests\" : [  ], \
    \"job_title\" : \"CTO\", \
    \"kids_names\" : \"\", \
    \"last_name\" : \"Wood\", \
    \"location\" : null, \
    \"mugshot_url\" : \"https://www.yammer.com/mugshot/48x48/12802507\", \
    \"mugshot_url_template\" : \"https://www.yammer.com/mugshot/{width}x{height}/12802507\", \
    \"name\" : \"julian-guest\", \
    \"network_domains\" : [ \"yammer-inc.com\" ], \
    \"network_id\" : 54605, \
    \"network_name\" : \"Yammer Developers Network\", \
    \"previous_companies\" : [  ], \
    \"schools\" : [  ], \
    \"settings\" : { \"xdr_proxy\" : \"https://xdrproxy.yammer.com\" }, \
    \"show_ask_for_photo\" : false, \
    \"significant_other\" : \"\", \
    \"state\" : \"active\", \
    \"stats\" : { \"followers\" : 2, \
    \"following\" : 1, \
    \"updates\" : 5 \
    }, \
    \"summary\" : null, \
    \"timezone\" : \"Mountain Time (US & Canada)\", \
    \"type\" : \"user\", \
    \"url\" : \"https://www.yammer.com/api/v1/users/1487386865\", \
    \"verified_admin\" : \"false\", \
    \"web_preferences\" : {}, \
    \"web_url\" : \"https://www.yammer.com/yammerdevelopersnetwork/users/julian-guest\" \
    } \
";

static NSString *networksJSON = @" \
[ \
{ \"community\" : true, \
\"created_at\" : \"2012/04/12 16:45:54 +0000\", \
\"header_background_color\" : \"#75150d\", \
\"header_text_color\" : \"#FFFFFF\", \
\"id\" : 354446, \
\"is_chat_enabled\" : true, \
\"is_group_enabled\" : true, \
\"is_org_chart_enabled\" : false, \
\"is_primary\" : false, \
\"name\" : \"External StratPad Discussion\", \
\"navigation_background_color\" : \"#38699F\", \
\"navigation_text_color\" : \"#FFFFFF\", \
\"paid\" : false, \
\"permalink\" : \"externalstratpaddiscussion\", \
\"preferred_unseen_message_count\" : 0, \
\"private_unseen_thread_count\" : 0, \
\"profile_fields_config\" : { \"enable_job_title\" : true, \
\"enable_mobile_phone\" : false, \
\"enable_work_phone\" : false \
}, \
\"show_upgrade_banner\" : false, \
\"type\" : \"network\", \
\"unseen_message_count\" : 0, \
\"unseen_notification_count\" : 0, \
\"web_url\" : \"https://www.yammer.com/externalstratpaddiscussion\" \
} \
] \
";

static NSString *groupsJSON = @" \
[ \
{ \"created_at\" : \"2012/06/01 21:55:57 +0000\", \
\"creator_id\" : 10341207, \
\"creator_type\" : \"user\", \
\"description\" : \"Programmers, architects, designers and managers working on StratPad\", \
\"full_name\" : \"StratPad Team\", \
\"id\" : 664795, \
\"mugshot_url\" : \"https://c64.assets-yammer.com/images/group_profile_small.gif\", \
\"name\" : \"stratpadteam\", \
\"privacy\" : \"public\", \
\"show_in_directory\" : \"true\", \
\"state\" : \"active\", \
\"stats\" : { \"last_message_at\" : \"2012/06/07 16:49:25 +0000\", \
\"last_message_id\" : 181092956, \
\"members\" : 2, \
\"updates\" : 4 \
}, \
\"type\" : \"group\", \
\"url\" : \"https://www.yammer.com/api/v1/groups/664795\", \
\"web_url\" : \"https://www.yammer.com/mobilesce.com/groups/stratpadteam\" \
} \
] \
";

static NSString *tokensJSON = @"[{\"token\":\"HuL5LCJXJ5M2ddDqXKI6nw\",\"modify_messages\":true,\"network_id\":352770,\"authorized_at\":\"2012/07/23 04:12:05 +0000\",\"view_groups\":true,\"created_at\":\"2012/07/23 04:12:05 +0000\",\"network_permalink\":\"mobilesce.com\",\"network_name\":\"mobilesce.com\",\"view_tags\":true,\"expires_at\":null,\"user_id\":10341207,\"modify_subscriptions\":true,\"secret\":\"5d1Gu3ayjcS6YS7smKma8T2sYei4ZzrrJyx9PYdhyno\",\"view_messages\":true,\"view_members\":true,\"view_subscriptions\":true},{\"token\":\"sRjtBQ9TS90OP4U7ih0Q\",\"modify_messages\":true,\"network_id\":54605,\"authorized_at\":\"2012/07/23 04:29:36 +0000\",\"view_groups\":true,\"created_at\":\"2012/07/23 04:29:36 +0000\",\"network_permalink\":\"yammerdevelopersnetwork\",\"network_name\":\"Yammer Developers Network\",\"view_tags\":true,\"expires_at\":null,\"user_id\":1487386865,\"modify_subscriptions\":true,\"secret\":\"QBFAPlE9idAiBoTNyQr0jC9HGPFeGucZIu7gD1NBw2I\",\"view_messages\":true,\"view_members\":true,\"view_subscriptions\":true},{\"token\":\"9JpwvVnUav2kXVPwY36VwQ\",\"modify_messages\":true,\"network_id\":378908,\"authorized_at\":\"2012/07/23 04:15:42 +0000\",\"view_groups\":true,\"created_at\":\"2012/07/23 04:15:42 +0000\",\"network_permalink\":\"whippetaccounting\",\"network_name\":\"Whippet Accounting\",\"view_tags\":true,\"expires_at\":null,\"user_id\":1487488017,\"modify_subscriptions\":true,\"secret\":\"DlEqwADSfbH8g5wmNIWzjFkLqmdeRB0u5fgfJ4Rr6WA\",\"view_messages\":true,\"view_members\":true,\"view_subscriptions\":true},{\"token\":\"3zURxf66dg7v3vmoYXyBOg\",\"modify_messages\":true,\"network_id\":354446,\"authorized_at\":\"2012/07/23 03:30:12 +0000\",\"view_groups\":true,\"created_at\":\"2012/07/23 03:30:12 +0000\",\"network_permalink\":\"externalstratpaddiscussion\",\"network_name\":\"External StratPad Discussion\",\"view_tags\":true,\"expires_at\":null,\"user_id\":1487504215,\"modify_subscriptions\":true,\"secret\":\"ac48rudr0YNz82FZNRWIkmiahrrTRo7939s3nkw3tw\",\"view_messages\":true,\"view_members\":true,\"view_subscriptions\":true}]";

@implementation YammerTest

- (void)testYammerUserFromJSON 
{
    YammerUser *user = [YammerUser yammerUserFromJSON:userJSON];
        
    STAssertEqualObjects(user.fullname, @"Julian Wood", @"Oops");
    STAssertEqualObjects(user.authenticatedNetwork.permalink, @"yammerdevelopersnetwork", @"Oops");
    STAssertEqualObjects(user.authenticatedNetwork.name, @"Yammer Developers Network", @"Oops");
    STAssertEquals(user.authenticatedNetwork.networkId, (uint)54605, @"Oops");
    STAssertEqualObjects(user.mugshotURL, @"https://www.yammer.com/mugshot/48x48/12802507", @"Oops");
}

- (void)testYammerNetworkFromJSON 
{
    YammerNetwork *network = [[YammerNetwork yammerNetworksFromJSON:networksJSON] lastObject];

    STAssertEqualObjects(network.permalink, @"externalstratpaddiscussion", @"Oops");
    STAssertEqualObjects(network.name, @"External StratPad Discussion", @"Oops");
    STAssertEquals(network.networkId, (uint)354446, @"Oops");

}

- (void)testYammerNetworkFromTokensJSON
{
    YammerNetwork *network = [[YammerNetwork yammerNetworksFromJSON:tokensJSON] lastObject];
    
    STAssertEqualObjects(network.permalink, @"externalstratpaddiscussion", @"Oops");
    STAssertEqualObjects(network.name, @"External StratPad Discussion", @"Oops");
    STAssertEquals(network.networkId, (uint)354446, @"Oops");
    
}

- (void)testYammerGroupFromJSON 
{
    YammerGroup *group = [[YammerGroup yammerGroupsFromJSON:groupsJSON] lastObject];
    
    STAssertEqualObjects(group.groupName, @"StratPad Team", @"Oops");
    STAssertEquals(group.groupId, (uint)664795, @"Oops");
    
}

-(void)testYammerURLs
{
    NSURL *url = [[YammerManager sharedManager] urlForAPI:YammerApiCallGroups];
    STAssertTrue([url.absoluteString hasPrefix:@"https://www.yammer.com/api/v1/groups.json?"] , @"Oops");

    url = [[YammerManager sharedManager] urlForAPI:YammerApiCallGroups params:[NSDictionary dictionaryWithObjectsAndKeys:@"bar", @"foo", nil]];
    STAssertTrue([url.absoluteString hasPrefix:@"https://www.yammer.com/api/v1/groups.json?"] , @"Oops");
    STAssertTrue([url.absoluteString hasSuffix:@"&foo=bar"] , @"Oops");
    
    DLog(@"url: %@", url);

}

- (void)testYammerCommentFromJSON
{
    NSString *path = [[NSBundle bundleForClass:[YammerTest class]]
                      pathForResource:@"messages" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    
    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
    NSDictionary *json = [jsonParser objectWithData:data];
    [jsonParser release];
    
    // store the refs
    NSMutableDictionary *refs = [NSMutableDictionary dictionaryWithCapacity:10];
    NSArray *refsArray = [json objectForKey:@"references"];
    for (NSDictionary *refDict in refsArray) {
        [refs setObject:refDict forKey:[refDict objectForKey:@"id"]];
    }
    
    
    YammerComment *cmt = [YammerComment commentFromDict:[[json objectForKey:@"messages"] lastObject]];
    STAssertEquals(cmt.commentId, (uint)212680428, @"OOps");
    STAssertEquals(cmt.threadId, (uint)212680358, @"OOps");
    STAssertEqualObjects(cmt.text, @"I agree.", @"OOps");

    

}





@end