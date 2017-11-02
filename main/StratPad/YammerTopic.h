//
//  YammerTopic.h
//  StratPad
//
//  Created by Julian Wood on 12-07-11.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YammerTopic : NSObject

- (id)initWithTopicId:(NSUInteger)topicId topicName:(NSString*)topicName;

@property (nonatomic, assign) NSUInteger topicId;
@property (nonatomic, retain) NSString *topicName;

@end
