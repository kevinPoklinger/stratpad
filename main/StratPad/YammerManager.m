//
//  YammerManager.m
//  StratPad
//
//  Created by Julian Wood on 12-07-20.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "YammerManager.h"
#import "SynthesizeSingleton.h"
#import "EditionManager.h"
#import "UAKeychainUtils+StratPad.h"
#import "SBJson.h"
#import "YammerUser.h"
#import "ASIFormDataRequest.h"
#import "NSString-Expanded.h"
#import "NSUserDefaults+StratPad.h"

#define YammerApiPath       @"api/v1"
#define YammerHost          @"www.yammer.com"
#define YammerProtocol      @"https://"

@implementation YammerManager

@synthesize preferredNetwork = preferredNetwork_;
@synthesize authenticatedUser = authenticatedUser_;
@synthesize preferredGroup = preferredGroup_;
@synthesize networks = networks_;

SYNTHESIZE_SINGLETON_FOR_CLASS(YammerManager);

#pragma mark - Lifecycle

- (id)init {
    self = [super init];
    if (self) {
        [ASIHTTPRequest setShouldThrottleBandwidthForWWAN:NO];

        NSData *encNetwork = [[NSUserDefaults standardUserDefaults] valueForKey:keyPreferredYammerNetwork];
        YammerNetwork *network = (YammerNetwork *)[NSKeyedUnarchiver unarchiveObjectWithData:encNetwork];
        preferredNetwork_ = [network retain];
        
        NSData *encGroup = [[NSUserDefaults standardUserDefaults] valueForKey:keyPreferredYammerGroup];
        YammerGroup *group = (YammerGroup *)[NSKeyedUnarchiver unarchiveObjectWithData:encGroup];
        preferredGroup_ = [group retain];
    }
    return self;
}

- (void)dealloc
{
    [authenticatedUser_ release];
    [defaultNetwork_ release];
    [preferredNetwork_ release];
    [preferredGroup_ release];
    [super dealloc];
}

#pragma mark - URL and request generation


-(NSURL*) urlForAPI:(YammerApiCall)yammerApiCall params:(NSDictionary*)params
{
    // eg. "api/v1/groups.json"
    NSString *path = [self pathForYammerApiCall:yammerApiCall];
        
    // create a new UUID to defeat any cache
    CFUUIDRef	uuidObj = CFUUIDCreate(nil);
    NSString	*cacheDefeater = (NSString*)CFUUIDCreateString(nil, uuidObj);
    CFRelease(uuidObj);
    
    // add any params that are supposed to go in the query string
    NSMutableString *query = [NSMutableString string];
    for (NSString *key in params.allKeys) {
        if (![key isEqualToString:@"args"] && ![key isEqualToString:@"permalink"]) {
            [query appendFormat:@"&%@=%@", key, [params objectForKey:key]];
        }
    }
    
    // add permalink if available
    NSString *permalink = [params objectForKey:@"permalink"];
    if (permalink) {
        path = [NSString stringWithFormat:@"%@/%@", permalink, path];
    }
    
    // look for substitutions
    NSArray *subs = [params objectForKey:@"args"];
    if (subs) {        
        // allocate a C array with the same number of elements as array
        id args[ [subs count] ];
        NSUInteger index = 0;
        // copy the object pointers from NSArray to C array
        for ( id item in subs ) {
            args[ index++ ] = item;
        }
        
        path = [[[NSString alloc] initWithFormat:path
                                      arguments:args] autorelease];
    }

    NSString *urlString = [NSString stringWithFormat:@"%@%@/%@?%@%@", YammerProtocol, YammerHost, path, cacheDefeater, query];
    [cacheDefeater release];
    return [NSURL URLWithString:urlString];
}

-(NSURL*) urlForAPI:(YammerApiCall)yammerApiCall
{
    return [self urlForAPI:yammerApiCall params:[NSDictionary dictionary]];
}

-(NSString*)pathForYammerApiCall:(YammerApiCall)yammerApiCall
{
    switch (yammerApiCall) {
        case YammerApiCallGroups:
            return @"api/v1/groups.json";
        case YammerApiCallNetworks:
            return @"api/v1/oauth/tokens.json";
        case YammerApiCallCurrentUser:
            return @"api/v1/users/current.json";
        case YammerApiCallPostMessage:
            return @"api/v1/messages.json";
        case YammerApiCallSignIn:
            return @"oauth2/access_token.json";
        case YammerApiCallAllNewMessages:
            return @"api/v1/messages.json";
        case YammerApiCallFileMessage:
            // takes a file id - the id of the attachment
            return @"api/v1/messages/about_file/%@.json";
        case YammerApiCallThread:
            // takes a thread id
            return @"api/v1/messages/in_thread/%@.json";
        default:
            ELog(@"No such YammerApiCall: %i", yammerApiCall);
            return nil;
    }
}

-(NSString*)userAgent
{
    return [NSString stringWithFormat:@"%@ %@", [[EditionManager sharedManager] productDisplayName], [[EditionManager sharedManager] versionNumber]];
}

- (void)addAuthToRequest:(ASIHTTPRequest*)request
{
    // we can actually get the permalink automatically
    // eg. https://www.yammer.com/externalstratpaddiscussion/api/v1/messages.json?limit=20
    
    NSArray *comps = [request.url.absoluteString componentsSeparatedByString:@"/"];
    NSString *permalink = [comps objectAtIndex:3];
    permalink = [permalink isEqualToString:@"api"] ? nil : permalink;
    DLog(@"permalink: %@", permalink);

    // find the token for this permalink - fetchNetworks:action: will cache these tokens
    NSString *token = nil;
    for (YammerNetwork *network in networks_) {
        if ([network.permalink isEqualToString:permalink]) {
            token = network.token;
        }
    }
    
    // if no token, then use the current authorized network
    if (!token) {
        // retrieve token for the current authorized network
        permalink = [UAKeychainUtils getUsername:keyChainYammerKey];
        token = [UAKeychainUtils getPassword:keyChainYammerKey];
    }
    
    // if there is still none, the op will just fail with a 401
    DLog(@"Using authentication for network: %@ with token: '%@'", permalink, token);
    if (token) {        
        // Authorization: Bearer 1muKXyuxWIV99M1XgHA
        [request addRequestHeader:@"Authorization: Bearer" value:token];
    }
    
    [request addRequestHeader:@"User-Agent" value:[self userAgent]];
}

- (ASIHTTPRequest*)requestWithURL:(NSURL*)url
{    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [self addAuthToRequest:request];    
    return request;
}

#pragma mark - KeyChain Management

-(void)resetAuthentication
{
    [UAKeychainUtils deleteKeychainValue:keyChainYammerKey];

    // forget the preferred choices
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:keyPreferredYammerGroup];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:keyPreferredYammerNetwork];
    
    self.authenticatedUser = nil;
    self.networks = nil;
    self.preferredGroup = nil;
    self.preferredNetwork = nil;
}

-(void)saveAuthentication:(NSString*)permalink token:(NSString*)token
{
    [UAKeychainUtils deleteKeychainValue:keyChainYammerKey];
    [UAKeychainUtils createKeychainValueForUsername:permalink
                                       withPassword:token
                                      forIdentifier:keyChainYammerKey];
    DLog(@"Saving authentication for network: %@", permalink);
}

#pragma mark - Preferred Group and Network


-(void)savePreferredGroup:(YammerGroup *)group
{
    NSData *encGroup = [NSKeyedArchiver archivedDataWithRootObject:group];
    [[NSUserDefaults standardUserDefaults] setValue:encGroup forKey:keyPreferredYammerGroup];
    self.preferredGroup = group;
}

-(void)savePreferredNetwork:(YammerNetwork *)network
{
    NSData *encNetwork = [NSKeyedArchiver archivedDataWithRootObject:network];
    [[NSUserDefaults standardUserDefaults] setValue:encNetwork forKey:keyPreferredYammerNetwork];
    self.preferredNetwork = network;
    
    // when we select a new network, we need to store new credentials
    NSAssert(network.token != nil && ![network.token isBlank], @"You must supply a non-blank token when saving credentials to the keychain");
    [self saveAuthentication:network.permalink token:network.token];
}


#pragma mark - networks

// we're going to call action on target with two params: the first is an array of networks or nil, second is an error or nil
-(void)fetchNetworks:(id)target action:(SEL)action
{
    // use the saved auth and network, if available
    NSURL *url = [self urlForAPI:YammerApiCallNetworks];
    ASIHTTPRequest *request = [self requestWithURL:url];
	[request setTimeOutSeconds:10];
	[request setShouldContinueWhenAppEntersBackground:YES];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(networksFetchFinished:)];
	[request setDidFailSelector:@selector(networksFetchFailed:)];

    // we'll want to notify our caller with the result, when the fetch finishes
    [request setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                          target, @"target", 
                          NSStringFromSelector(action), @"action",
                          nil]];
    
	[request startAsynchronous];
}

- (void)networksFetchFinished:(ASIHTTPRequest *)theRequest
{
    id target = [theRequest.userInfo objectForKey:@"target"];
    SEL action = NSSelectorFromString([theRequest.userInfo objectForKey:@"action"]);

    if ([theRequest responseStatusCode] >= 400) {
        
        // problem
        
        // {"body":["Please include a message"]}
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSDictionary *json = [jsonParser objectWithString:[theRequest responseString]];
        [jsonParser release];
        
        NSError *error = [NSError errorWithDomain:@"com.stratpad.error.yammer.networks" 
                                             code:[theRequest responseStatusCode] 
                                         userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                   [[json objectForKey:@"body"] objectAtIndex:0], NSLocalizedDescriptionKey,
                                                   [theRequest responseStatusMessage], NSLocalizedFailureReasonErrorKey,
                                                   nil]];
        ELog(@"Response failure fetching networks: %@", error);
        ELog(@"Request: %@", theRequest.url);
        ELog(@"Info: %@", error.userInfo);
        
        // uncache
        self.networks = nil;
        
        [target performSelector:action withObject:nil withObject:error];
        
    } else {        
        
        // success
                
        self.networks = [YammerNetwork yammerNetworksFromJSON:[theRequest responseString]];
        
        [target performSelector:action withObject:self.networks withObject:nil];         
    }    
}

- (void)networksFetchFailed:(ASIHTTPRequest *)theRequest
{        
    id target = [theRequest.userInfo objectForKey:@"target"];
    SEL action = NSSelectorFromString([theRequest.userInfo objectForKey:@"action"]);
    NSError *error = [NSError errorWithDomain:@"com.stratpad.error.yammer.networks" 
                                         code:[theRequest responseStatusCode] 
                                     userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                               [NSString stringWithFormat:@"Couldn't fetch networks. Problem: %@", [[theRequest error] localizedDescription]], NSLocalizedDescriptionKey,
                                               [theRequest responseStatusMessage], NSLocalizedFailureReasonErrorKey,
                                               nil]];
    ELog(@"Request failed fetching networks: %@", error);
    ELog(@"Request: %@", theRequest.url);
    ELog(@"Info: %@", error.userInfo);

    [target performSelector:action withObject:nil withObject:error];    
}

#pragma mark - user

// we're going to call action on target with two params: the first is a YammerUser or nil, second is an error or nil
-(void)fetchUserForTarget:(id)target action:(SEL)action
{        
    // best way to get the network is to get the current user
    NSURL *url = [self urlForAPI:YammerApiCallCurrentUser];
    ASIHTTPRequest *request = [self requestWithURL:url];
	[request setTimeOutSeconds:10];
	[request setShouldContinueWhenAppEntersBackground:YES];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(userFetchFinished:)];
	[request setDidFailSelector:@selector(userFetchFailed:)];
    
    // we'll want to notify our caller with the result, when the fetch finishes
    [request setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                          target, @"target", 
                          NSStringFromSelector(action), @"action",
                          nil]];
    
	[request startAsynchronous];
}

- (void)userFetchFinished:(ASIHTTPRequest *)theRequest
{
    // parse json
    if ([theRequest responseStatusCode] >= 400) {
        
        // problem
        
        // {"body":["Please include a message"]}
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSDictionary *json = [jsonParser objectWithString:[theRequest responseString]];
        [jsonParser release];
        
        id target = [theRequest.userInfo objectForKey:@"target"];
        SEL action = NSSelectorFromString([theRequest.userInfo objectForKey:@"action"]);
        NSError *error = [NSError errorWithDomain:@"com.stratpad.error.yammer.user" 
                                             code:[theRequest responseStatusCode] 
                                         userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                   [[json objectForKey:@"body"] objectAtIndex:0], NSLocalizedDescriptionKey,
                                                   [theRequest responseStatusMessage], NSLocalizedFailureReasonErrorKey,
                                                   nil]];
        ELog(@"Response failure fetching user: %@", error);
        ELog(@"Request: %@", theRequest.url);
        ELog(@"Info: %@", error.userInfo);

        // uncache
        [defaultNetwork_ release];
        defaultNetwork_ = nil;
        
        [target performSelector:action withObject:nil withObject:error];
        
    } else {        
        
        // success
        
        YammerUser *user = [YammerUser yammerUserFromJSON:[theRequest responseString]];
        
        // cache network        
        defaultNetwork_ = [user.authenticatedNetwork retain];
        
        id target = [theRequest.userInfo objectForKey:@"target"];
        SEL action = NSSelectorFromString([theRequest.userInfo objectForKey:@"action"]);
        
        [target performSelector:action withObject:user withObject:nil];         
    }    
}

- (void)userFetchFailed:(ASIHTTPRequest *)theRequest
{    
    id target = [theRequest.userInfo objectForKey:@"target"];
    SEL action = NSSelectorFromString([theRequest.userInfo objectForKey:@"action"]);
    NSError *error = [NSError errorWithDomain:@"com.stratpad.error.yammer.user" 
                                         code:[theRequest responseStatusCode] 
                                     userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                               [NSString stringWithFormat:@"Couldn't fetch current user. Problem: %@", [[theRequest error] localizedDescription]], NSLocalizedDescriptionKey,
                                               [theRequest responseStatusMessage], NSLocalizedFailureReasonErrorKey,
                                               nil]];
    ELog(@"Request failed fetching user: %@", error);
    ELog(@"Request: %@", theRequest.url);
    ELog(@"Info: %@", error.userInfo);
    
    // uncache
    [defaultNetwork_ release];
    defaultNetwork_ = nil;

    [target performSelector:action withObject:nil withObject:error];    
}


#pragma mark - groups

// we're going to call action on target with two params: the first is an array of networks or nil, second is an error or nil
-(void)fetchGroups:(id)target action:(SEL)action
{        
    // best way to get the network is to get the current user
    NSURL *url = [self urlForAPI:YammerApiCallGroups];
    DLog(@"Fetching groups from: %@", url);
    ASIHTTPRequest *request = [self requestWithURL:url];
	[request setTimeOutSeconds:10];
	[request setShouldContinueWhenAppEntersBackground:YES];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(groupsFetchFinished:)];
	[request setDidFailSelector:@selector(groupsFetchFailed:)];
    
    // we'll want to notify our caller with the result, when the fetch finishes
    [request setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                          target, @"target", 
                          NSStringFromSelector(action), @"action",
                          nil]];
    
	[request startAsynchronous];
}

- (void)groupsFetchFinished:(ASIHTTPRequest *)theRequest
{
    // parse json
    if ([theRequest responseStatusCode] >= 400) {
        
        // problem
        
        // {"body":["Please include a message"]}
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSDictionary *json = [jsonParser objectWithString:[theRequest responseString]];
        [jsonParser release];
        
        id target = [theRequest.userInfo objectForKey:@"target"];
        SEL action = NSSelectorFromString([theRequest.userInfo objectForKey:@"action"]);
        NSError *error = [NSError errorWithDomain:@"com.stratpad.error.yammer.groups" 
                                             code:[theRequest responseStatusCode] 
                                         userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                   [[json objectForKey:@"body"] objectAtIndex:0], NSLocalizedDescriptionKey,
                                                   [theRequest responseStatusMessage], NSLocalizedFailureReasonErrorKey,
                                                   nil]];
        ELog(@"Response failure fetching groups: %@", error);
        ELog(@"Request: %@", theRequest.url);
        ELog(@"Info: %@", error.userInfo);
        
        [target performSelector:action withObject:nil withObject:error];
        
    } else {        
        
        // success
                
        NSArray *groups = [YammerGroup yammerGroupsFromJSON:[theRequest responseString]];
        DLog(@"groups: %@", groups);
        
        id target = [theRequest.userInfo objectForKey:@"target"];
        SEL action = NSSelectorFromString([theRequest.userInfo objectForKey:@"action"]);
        
        [target performSelector:action withObject:groups withObject:nil];         
    }    
}

- (void)groupsFetchFailed:(ASIHTTPRequest *)theRequest
{    
    id target = [theRequest.userInfo objectForKey:@"target"];
    SEL action = NSSelectorFromString([theRequest.userInfo objectForKey:@"action"]);
    NSError *error = [NSError errorWithDomain:@"com.stratpad.error.yammer.groups" 
                                         code:[theRequest responseStatusCode] 
                                     userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                               [NSString stringWithFormat:@"Couldn't fetch groups. Problem: %@", [[theRequest error] localizedDescription]], NSLocalizedDescriptionKey,
                                               [theRequest responseStatusMessage], NSLocalizedFailureReasonErrorKey,
                                               nil]];
    ELog(@"Request failed fetching groups: %@", error);
    ELog(@"Request: %@", theRequest.url);
    ELog(@"Info: %@", error.userInfo);
    
    [target performSelector:action withObject:nil withObject:error];    
}

#pragma mark - signin

// we're going to call action on target with two params: the first is a dict of info or nil, second is an error or nil
-(void)signInWithUsername:(NSString*)username password:(NSString*)password target:(id)target action:(SEL)action
{
    // best way to get the network is to get the current user
    NSURL *url = [self urlForAPI:YammerApiCallSignIn];
    DLog(@"Signing in with url: %@", url);
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostValue:username forKey:@"username"];
    [request setPostValue:password forKey:@"password"];
    [request setPostValue:yammerAppKey forKey:@"client_id"];
    [request setPostValue:yammerAppSecret forKey:@"client_secret"];
    
	[request setTimeOutSeconds:10];
	[request setShouldContinueWhenAppEntersBackground:YES];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(signInFinished:)];
	[request setDidFailSelector:@selector(signInFailed:)];
    
    // we'll want to notify our caller with the result, when the fetch finishes
    [request setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                          target, @"target",
                          NSStringFromSelector(action), @"action",
                          nil]];
    
	[request startAsynchronous];
}

- (void)signInFinished:(ASIHTTPRequest *)theRequest
{
    // parse json
    if ([theRequest responseStatusCode] != 200) {
        
        // problem
                
        id target = [theRequest.userInfo objectForKey:@"target"];
        SEL action = NSSelectorFromString([theRequest.userInfo objectForKey:@"action"]);
        NSError *error = [NSError errorWithDomain:@"com.stratpad.error.yammer.signIn"
                                             code:[theRequest responseStatusCode]
                                         userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                   [theRequest responseString], NSLocalizedDescriptionKey,
                                                   [theRequest responseStatusMessage], NSLocalizedFailureReasonErrorKey,
                                                   nil]];
        ELog(@"Response failure signing in: %@", error);
        ELog(@"Request: %@", theRequest.url);
        ELog(@"Info: %@", error.userInfo);
        
        [target performSelector:action withObject:nil withObject:error];
        
    } else {
        
        // success
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSDictionary *json = [jsonParser objectWithString:[theRequest responseString]];
        [jsonParser release];
        
        // cache authenticated user (and network inside of user)
        [authenticatedUser_ release];
        authenticatedUser_ = [[YammerUser yammerUserFromDict:[json objectForKey:@"user"]] retain];

                
        id target = [theRequest.userInfo objectForKey:@"target"];
        SEL action = NSSelectorFromString([theRequest.userInfo objectForKey:@"action"]);
        
        [target performSelector:action withObject:json withObject:nil];
    }
}

- (void)signInFailed:(ASIHTTPRequest *)theRequest
{
    id target = [theRequest.userInfo objectForKey:@"target"];
    SEL action = NSSelectorFromString([theRequest.userInfo objectForKey:@"action"]);
    NSError *error = [NSError errorWithDomain:@"com.stratpad.error.yammer.signIn"
                                         code:[theRequest responseStatusCode]
                                     userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                               [NSString stringWithFormat:@"Couldn't sign in. Problem: %@", [[theRequest error] localizedDescription]], NSLocalizedDescriptionKey,
                                               [theRequest responseStatusMessage], NSLocalizedFailureReasonErrorKey,
                                               nil]];
    ELog(@"Request failed signing in: %@", error);
    ELog(@"Request: %@", theRequest.url);
    ELog(@"Info: %@", error.userInfo);
    
    [target performSelector:action withObject:nil withObject:error];
}

#pragma mark - check auth

// we're going to call action on target with two params: the first is a dict of info (json for fetching a user) or nil, second is an error or nil
-(void)checkAuthentication:(id)target action:(SEL)action
{
    NSString *token = [UAKeychainUtils getPassword:keyChainYammerKey];
    if (!token) {
        
        NSError *error = [NSError errorWithDomain:@"com.stratpad.error.yammer.authenticate"
                                             code:403
                                         userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                   @"No saved auth", NSLocalizedDescriptionKey,
                                                   @"No saved auth", NSLocalizedFailureReasonErrorKey,
                                                   nil]];
                
        [target performSelector:action withObject:nil withObject:error];
        
    } else {
        
        NSURL *url = [self urlForAPI:YammerApiCallCurrentUser];
        ASIHTTPRequest *request = [self requestWithURL:url];
        [request setTimeOutSeconds:10];
        [request setShouldContinueWhenAppEntersBackground:YES];
        [request setDelegate:self];
        [request setDidFinishSelector:@selector(checkAuthenticationFinished:)];
        [request setDidFailSelector:@selector(checkAuthenticationFailed:)];
        
        // we'll want to notify our caller with the result, when the fetch finishes
        [request setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                              target, @"target",
                              NSStringFromSelector(action), @"action",
                              nil]];
        
        [request startAsynchronous];
        
    }
    
}

- (void)checkAuthenticationFinished:(ASIHTTPRequest *)theRequest
{
    // parse json
    if ([theRequest responseStatusCode] != 200) {
        
        // problem
        
        id target = [theRequest.userInfo objectForKey:@"target"];
        SEL action = NSSelectorFromString([theRequest.userInfo objectForKey:@"action"]);
        NSError *error = [NSError errorWithDomain:@"com.stratpad.error.yammer.authenticate"
                                             code:[theRequest responseStatusCode]
                                         userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                   [theRequest responseString], NSLocalizedDescriptionKey,
                                                   [theRequest responseStatusMessage], NSLocalizedFailureReasonErrorKey,
                                                   nil]];
        ELog(@"Response failure authenticating: %@", error);
        ELog(@"Request: %@", theRequest.url);
        ELog(@"Info: %@", error.userInfo);
        
        [target performSelector:action withObject:nil withObject:error];
        
    } else {
        
        // success
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSDictionary *json = [jsonParser objectWithString:[theRequest responseString]];
        [jsonParser release];
        
        // cache authenticated user (and network inside of user)
        [authenticatedUser_ release];
        authenticatedUser_ = [[YammerUser yammerUserFromDict:json] retain];
        
        id target = [theRequest.userInfo objectForKey:@"target"];
        SEL action = NSSelectorFromString([theRequest.userInfo objectForKey:@"action"]);
        
        [target performSelector:action withObject:json withObject:nil];
    }
}

- (void)checkAuthenticationFailed:(ASIHTTPRequest *)theRequest
{
    id target = [theRequest.userInfo objectForKey:@"target"];
    SEL action = NSSelectorFromString([theRequest.userInfo objectForKey:@"action"]);
    NSError *error = [NSError errorWithDomain:@"com.stratpad.error.yammer.authenticate"
                                         code:[theRequest responseStatusCode]
                                     userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                               [NSString stringWithFormat:@"Couldn't authenticate. Problem: %@", [[theRequest error] localizedDescription]], NSLocalizedDescriptionKey,
                                               [theRequest responseStatusMessage], NSLocalizedFailureReasonErrorKey,
                                               nil]];
    ELog(@"Request failed signing in: %@", error);
    ELog(@"Request: %@", theRequest.url);
    ELog(@"Info: %@", error.userInfo);
    
    [target performSelector:action withObject:nil withObject:error];
}

#pragma mark - Utility

-(YammerNetwork*)networkForNetworkId:(NSUInteger)networkId
{
    for (YammerNetwork *yammerNetwork in networks_) {
        if (yammerNetwork.networkId == networkId) {
            return yammerNetwork;
        }
    }
    WLog(@"No network for %i. Are you sure you fetched networks?", networkId);
    return nil;
}


@end
