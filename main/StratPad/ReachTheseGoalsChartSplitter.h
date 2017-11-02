//
//  ReachTheseGoalsChartSplitter.h
//  StratPad
//
//  Created by Eric on 11-10-11.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "DrawableSplitter.h"

@interface ReachTheseGoalsChartSplitter : NSObject<DrawableSplitter> {
@private
    CGRect firstRect_;
    CGRect subsequentRect_;
}

@end
