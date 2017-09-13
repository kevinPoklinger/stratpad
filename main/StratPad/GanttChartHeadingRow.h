//
//  GanttChartHeadingRow.h
//  StratPad
//
//  Created by Eric Rogers on 11-12-09.
//  Copyright (c) 2011 Glassey Strategy. All rights reserved.
//

#import "GanttChartRow.h"

@interface GanttChartHeadingRow : GanttChartRow {
@private
    // font used for the row
    UIFont *font_;        
}

- (id)initWithRect:(CGRect)rect font:(UIFont*)font andcolumnDates:(NSArray*)columnDates;

// returns the height required by the row to display the row when it has a given width and font size.
+ (CGFloat)heightWithRowWidth:(CGFloat)rowWidth font:(UIFont*)font restrictedToHeight:(CGFloat)maxHeight;

@end
