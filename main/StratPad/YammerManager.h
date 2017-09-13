//
//  YammerManager.h
//  StratPad
//
//  Created by Julian Wood on 12-07-20.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "YammerGroup.h"
#import "YammerNetwork.h"
#import "YammerUser.h"
#import "UAKeychainUtils+StratPad.h"

// for our StratPad (Yammer) app
#define yammerAppKey  @"9gxKBIH79EXOnTS8g9V33w"
#define yammerAppSecret  @"roqTRu9qZbFRLHklLbQoUu3IvPnvHNOpY7sNiwlKjt8"

typedef enum {
    YammerApiCallGroups,
    YammerApiCallNetworks,
    YammerApiCallCurrentUser,
    YammerApiCallPostMessage,
    YammerApiCallSignIn,
    YammerApiCallAllNewMessages,
    YammerApiCallFileMessage,
    YammerApiCallThread,
} YammerApiCall;

@interface YammerManager : NSObject {
    // this is the network against which you are authenticated
    YammerNetwork *defaultNetwork_;
            
}

// this is the network you have chosen to use
@property (nonatomic,retain) YammerNetwork *preferredNetwork;

// this is the user that was authenticated when we fetched the current user; NB. we also have the auth. network in here
@property (nonatomic,retain) YammerUser *authenticatedUser;

// this is the group within a particular network that you would like to use
@property (nonatomic,retain) YammerGroup *preferredGroup;

// list of YammerNetwork
@property (nonatomic,retain) NSArray *networks;


// init
+ (YammerManager *)sharedManager;

// suitable for sending to remote services
-(NSString*)userAgent;

// if you use urlForApi:params: to generate this URL, then the "permalink" param can be propagated to the auth headers
- (ASIHTTPRequest*)requestWithURL:(NSURL*)url;
- (void)addAuthToRequest:(ASIHTTPRequest*)request;

-(void)resetAuthentication;
-(void)saveAuthentication:(NSString*)permalink token:(NSString*)token;

-(void)savePreferredGroup:(YammerGroup*)group;
-(void)savePreferredNetwork:(YammerNetwork *)network;

// get the appropriate URL for the correct version of the API, for the currently chosen network
// this version will not automatically figure out the correct network, or do any arg substitution, and so will use the network last chosen by the authenticated user when posting
-(NSURL*) urlForAPI:(YammerApiCall)yammerApiCall;
// note that if you include the key "args" in the params, those will be used for substition
// if you include the key "permalink", then we will look for the token for that network and use it when adding auth headers
-(NSURL*) urlForAPI:(YammerApiCall)yammerApiCall params:(NSDictionary*)params;


-(void)fetchUserForTarget:(id)target action:(SEL)action;
-(void)fetchNetworks:(id)target action:(SEL)action;
-(void)fetchGroups:(id)target action:(SEL)action;
-(void)signInWithUsername:(NSString*)username password:(NSString*)password target:(id)target action:(SEL)action;

// check the saved authentication to see if it is valid (a full yammer api call)
-(void)checkAuthentication:(id)target action:(SEL)action;

-(YammerNetwork*)networkForNetworkId:(NSUInteger)networkId;

@end
