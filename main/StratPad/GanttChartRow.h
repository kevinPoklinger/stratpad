//
//  GanttChartRow.h
//  StratPad
//
//  Created by Eric Rogers on 11-12-09.
//  Copyright (c) 2011 Glassey Strategy. All rights reserved.
//
//  Abstract superclass for all rows in a Gantt Chart.

#import "Drawable.h"

// padding for the top and bottom of each cell in a row
static const CGFloat kCellYPadding = 5.f;

// maximum possible row height
static const CGFloat kMaxRowHeight = 400.f;

@interface GanttChartRow : NSObject<Drawable> {
@protected
    // rect for the row
    CGRect rect_;    
        
    // stores the quarterly dates for the row
    NSArray *columnDates_;

    // define the beginning and end x-coordinates for the value columns in the row
    NSUInteger startingXForValueColumns_;
    NSUInteger endingXForValueColumns_;
    
    // width of each value column
    NSUInteger valueColumnWidth_;
    
    // height of the row
    CGFloat rowHeight_;    
}

// background color for the row
@property(nonatomic, retain) UIColor *backgroundColor;

// color of the font to use in the row
@property(nonatomic, retain) UIColor *fontColor;

- (id)initWithRect:(CGRect)rect andColumnDates:(NSArray*)columnDates;

// returns the rect for the column in the row
- (CGRect)rectForColumn:(NSUInteger)column;

// translates a given date into an x-coordinate in the value portion of the chart.
- (NSUInteger)xCoordinateForDate:(NSDate*)date;

@end
