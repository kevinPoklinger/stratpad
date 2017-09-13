//
//  YammerNetwork.m
//  StratPad
//
//  Created by Julian Wood on 12-07-24.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "YammerNetwork.h"
#import "SBJson.h"

@implementation YammerNetwork

@synthesize networkId, name, permalink, token;

- (void)dealloc
{
    [token release];
    [name release];
    [permalink release];
    [super dealloc];
}

+(YammerNetwork*) yammerNetworkFromJSON:(NSString*)jsonString
{
    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
    NSDictionary *dict = [jsonParser objectWithString:jsonString];
    YammerNetwork *network = [YammerNetwork yammerNetworkFromDict:dict];
    [jsonParser release];
    return network;
}

+(YammerNetwork*) yammerNetworkFromDict:(NSDictionary*)networkDict
{
    YammerNetwork *network = [[YammerNetwork alloc] init];
    network.name = [networkDict objectForKey:@"name"] != nil ? [networkDict objectForKey:@"name"] : [networkDict objectForKey:@"network_name"];
    network.permalink = [networkDict objectForKey:@"permalink"] != nil ? [networkDict objectForKey:@"permalink"] : [networkDict objectForKey:@"network_permalink"];
    network.networkId = [networkDict objectForKey:@"id"] != nil ? [[networkDict objectForKey:@"id"] unsignedIntegerValue] : [[networkDict objectForKey:@"network_id"] unsignedIntegerValue];
    network.token = [networkDict objectForKey:@"token"];
    return [network autorelease];
}

+(NSArray*)yammerNetworksFromJSON:(NSString*)jsonString
{
    NSMutableArray *networks = [NSMutableArray arrayWithCapacity:5];
    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
    NSArray *json = [jsonParser objectWithString:jsonString];
    for (NSDictionary *networkDict in json) {
        YammerNetwork *network = [YammerNetwork yammerNetworkFromDict:networkDict];
        [networks addObject:network];
    }
    [jsonParser release];
    return networks;
}

- (NSString*)description
{    
    return [NSString stringWithFormat: @"[networkId: %i, name: %@, permalink: %@, token: %@]", self.networkId, self.name, self.permalink, self.token];
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:self.permalink forKey:@"permalink"];
    [coder encodeInteger:self.networkId forKey:@"id"];
    // do not store the token - it is taken care of by keychain services
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.name = [coder decodeObjectForKey:@"name"];
        self.permalink = [coder decodeObjectForKey:@"permalink"];
        self.networkId = [coder decodeIntegerForKey:@"id"];
        // do not store the token - it is taken care of by keychain services
    }
    return self;
}


@end
