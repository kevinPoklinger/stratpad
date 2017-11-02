//
//  BoundingLine.h
//  StratPad
//
//  Created by Julian Wood on 12-05-25.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Drawable.h"

@interface BoundingLine : NSObject<Drawable> {
    // origins are all relative to origin of 0,0
    NSMutableArray *boundingLineRects_;
}

// used to extend the bounding line for comments
// only covers comments in the same column
// use a separate BoundingLine object for drawing lines for comments on separate columns or pages
- (void)addRectForBounding:(CGRect)boundingRect;

@property (nonatomic,assign) CGRect rect;
@property(nonatomic, assign) BOOL readyForPrint;

@end
