//
//  YammerNetwork.h
//  StratPad
//
//  Created by Julian Wood on 12-07-24.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YammerNetwork : NSObject<NSCoding>

@property (nonatomic,retain) NSString *name;
@property (nonatomic,retain) NSString *permalink;
@property (nonatomic,assign) NSUInteger networkId;

// note that we cannot store this token
@property (nonatomic,retain) NSString *token;

+(NSArray*)yammerNetworksFromJSON:(NSString*)jsonString;


@end
