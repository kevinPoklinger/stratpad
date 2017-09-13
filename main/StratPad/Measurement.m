//
//  Measurement.m
//  StratPad
//
//  Created by Julian Wood on 12-02-24.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "Measurement.h"
#import "Metric.h"


@implementation Measurement

@dynamic comment;
@dynamic date;
@dynamic value;
@dynamic metric;

- (NSString*)comment
{
    NSString *comment = [self primitiveValueForKey:@"comment"];
    return [comment substringToIndex:MIN(maxCommentLength, comment.length)];
}


@end
