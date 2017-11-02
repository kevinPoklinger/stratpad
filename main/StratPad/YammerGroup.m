//
//  YammerGroup.m
//  StratPad
//
//  Created by Julian Wood on 12-07-11.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "YammerGroup.h"
#import "SBJson.h"

@implementation YammerGroup

@synthesize groupId = groupId_, groupName = groupName_;

+ (YammerGroup*)yammerGroupFromJSON:(NSString*)jsonString
{
    YammerGroup *group = [[YammerGroup alloc] init];
    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
    NSDictionary *groupJSON = [jsonParser objectWithString:jsonString];
    group.groupName = [groupJSON objectForKey:@"full_name"];
    group.groupId = [[groupJSON objectForKey:@"id"] unsignedIntegerValue];
    [jsonParser release];
    return [group autorelease];
}

+(YammerGroup*) yammerGroupFromDict:(NSDictionary*)groupDict
{
    YammerGroup *group = [[YammerGroup alloc] init];
    group.groupName = [groupDict objectForKey:@"full_name"];
    group.groupId = [[groupDict objectForKey:@"id"] unsignedIntegerValue];
    return [group autorelease];
}

+(NSArray*)yammerGroupsFromJSON:(NSString*)jsonString
{
    NSMutableArray *groups = [NSMutableArray arrayWithCapacity:5];
    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
    NSArray *json = [jsonParser objectWithString:jsonString];
    for (NSDictionary *groupDict in json) {
        YammerGroup *group = [YammerGroup yammerGroupFromDict:groupDict];
        [groups addObject:group];
    }
    [jsonParser release];
    return groups;
}



- (id)initWithGroupId:(NSUInteger)groupId groupName:(NSString*)groupName
{
    self = [super init];
    if (self) {
        groupId_ = groupId;
        groupName_ = [groupName retain];
    }
    return self;
}

- (void)dealloc
{
    [groupName_ release];
    [super dealloc];
}

- (NSString*)description
{    
    return [NSString stringWithFormat: @"[groupId: %i, groupName:%@]", self.groupId, self.groupName];
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.groupName forKey:@"name"];
    [coder encodeInteger:self.groupId forKey:@"id"];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.groupName = [coder decodeObjectForKey:@"name"];
        self.groupId = [coder decodeIntegerForKey:@"id"];
    }
    return self;
}



@end
