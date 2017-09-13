//
//  YammerGroup.h
//  StratPad
//
//  Created by Julian Wood on 12-07-11.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YammerGroup : NSObject

- (id)initWithGroupId:(NSUInteger)groupId groupName:(NSString*)groupName;

@property (nonatomic, assign) NSUInteger groupId;
@property (nonatomic, retain) NSString *groupName;

+ (NSArray*)yammerGroupsFromJSON:(NSString*)jsonString;
+(YammerGroup*) yammerGroupFromDict:(NSDictionary*)groupDict;

@end
