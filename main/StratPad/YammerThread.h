//
//  YammerThread.h
//  StratPad
//
//  Created by Julian Wood on 12-10-05.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YammerThread : NSObject

// transient property to hold YammerComments, in order; first message is the root message or thread starter
@property (nonatomic, retain) NSMutableArray *comments;

// let's us know if there are more than the 2 latest messages in this thread; determined by comparing with totalComments
@property (nonatomic, assign) BOOL hasMoreComments;

// how many comments in total? - provided directly by Yammer in json
@property (nonatomic, assign) NSUInteger totalComments;

// attachment for this thread?


@end
