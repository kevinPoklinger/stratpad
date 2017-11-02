//
//  ChartReportSection.h
//  StratPad
//
//  Created by Julian Wood on 12-05-12.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChartReportSection : NSObject

- (id)initWithDrawables:(NSMutableArray*)drawables;
- (BOOL)hasDrawables;
- (BOOL)fitsInRect:(CGRect)bodyRect atOrigin:(CGPoint)chartReportOrigin;
- (BOOL)readyForPrint;

@property (nonatomic,assign) CGRect rect;
@property (nonatomic,assign) NSUInteger pageNum; // 0-based
@property (nonatomic,assign) NSUInteger col; // 0-based
@property (nonatomic,assign) NSMutableArray *drawables;

@end
