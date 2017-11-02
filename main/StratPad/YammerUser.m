//
//  YammerUser.m
//  StratPad
//
//  Created by Julian Wood on 12-07-25.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "YammerUser.h"
#import "SBJson.h"

@implementation YammerUser

@synthesize fullname=fullname_;
@synthesize authenticatedNetwork=authenticatedNetwork_;
@synthesize mugshotURL=mugshotURL_;

- (void)dealloc
{
    [fullname_ release];
    [authenticatedNetwork_ release];
    [mugshotURL_ release];
    [super dealloc];
}

+ (YammerUser*)yammerUserFromJSON:(NSString*)jsonString
{
    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
    NSDictionary *userJSON = [jsonParser objectWithString:jsonString];
    YammerUser *user = [YammerUser yammerUserFromDict:userJSON];
    [jsonParser release];
    
    return user;
}

+ (YammerUser*)yammerUserFromDict:(NSDictionary*)dict
{
    YammerUser *user = [[YammerUser alloc] init];
    user.fullname = [dict objectForKey:@"full_name"];
    user.mugshotURL = [dict objectForKey:@"mugshot_url"]; // 48x48
    
    YammerNetwork *network = [[YammerNetwork alloc] init];
    network.networkId = [[dict objectForKey:@"network_id"] integerValue];
    network.name = [dict objectForKey:@"network_name"];
    
    // permalink needs to be extracted from web_url
    NSString *webURL = [dict objectForKey:@"web_url"];
    network.permalink = [[webURL pathComponents] objectAtIndex:2];
    
    user.authenticatedNetwork = network;
    [network release];
    
    return [user autorelease];
}


- (NSString*)description
{    
    return [NSString stringWithFormat: @"[fullname: %@, authenticatedNetwork: %@, mugshotURL: %@]", self.fullname, self.authenticatedNetwork, self.mugshotURL];
}


@end
