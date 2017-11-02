//
//  ChartReportHeader.h
//  StratPad
//
//  Created by Julian Wood on 12-05-11.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//
//  Draws a label with a gradient background and a long vertical line down the left edge of the rect

#import <UIKit/UIKit.h>
#import "MBDrawableLabel.h"

#define boundingLineColor   @"939393"

@interface ChartReportHeader : MBDrawableLabel {
    // points are all relative to the ChartReportHeader origin (same as ChartReport origin)
    NSMutableArray *boundingLinePoints_;
}

// used to extend the bounding line for comments
// only covers comments in the same column
// use a separate BoundingLine for drawing lines for comments on separate columns or pages
- (void)addPointToBoundingLinePoints:(CGPoint)point;

@end
