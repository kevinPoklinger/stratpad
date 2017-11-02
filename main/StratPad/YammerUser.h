//
//  YammerUser.h
//  StratPad
//
//  Created by Julian Wood on 12-07-25.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YammerNetwork.h"

@interface YammerUser : NSObject

@property (nonatomic, retain) NSString* fullname;
@property (nonatomic, retain) YammerNetwork* authenticatedNetwork;
@property (nonatomic, retain) NSString* mugshotURL;

+ (YammerUser*)yammerUserFromJSON:(NSString*)jsonString;
+ (YammerUser*)yammerUserFromDict:(NSDictionary*)dict;

@end
