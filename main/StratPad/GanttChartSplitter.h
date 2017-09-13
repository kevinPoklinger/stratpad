//
//  GanttChartSplitter.h
//  StratPad
//
//  Created by Eric on 11-10-07.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "DrawableSplitter.h"


@interface GanttChartSplitter : NSObject<DrawableSplitter> {
@private
    CGRect firstRect_;
    CGRect subsequentRect_;
}

@end
