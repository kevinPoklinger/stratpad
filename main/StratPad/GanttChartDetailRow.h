//
//  GanttChartDetailRow.h
//  StratPad
//
//  Created by Eric Rogers on 11-12-10.
//  Copyright (c) 2011 Glassey Strategy. All rights reserved.
//
//  Abstract superclass for detail rows for the Gantt Chart
//  e.g., GanttChartThemeRow.

#import "GanttChartRow.h"
#import "GanttTimeline.h"
#import "SkinManager.h"

@interface GanttChartDetailRow : GanttChartRow {
@protected
    // font used for the row heading
    UIFont *headingFont_;
    
    GanttTimeline *timeline_;
    
    MediaType mediaType_;
}


- (void)calculateLayoutForRow:(UIEdgeInsets)insets;

// color of the lines in the row
@property(nonatomic, retain) UIColor *lineColor;

// controls the renering fo a full-width bottom border for the row
@property(nonatomic, assign) BOOL renderFullWidthBottomBorder;

- (id)initWithRect:(CGRect)rect headingFont:(UIFont*)headingFont columnDates:(NSArray*)columnDates 
  andGanttTimeline:(GanttTimeline*)timeline andMediaType:(MediaType)mediaType;

// draws the background for the row
- (void)drawBackground;

// draws the lines in the detail row
- (void)drawLines;

// returns the height required by the row to display its content with the given width and font.
+ (CGFloat)heightWithTitle:(NSString*)title rowWidth:(CGFloat)rowWidth font:(UIFont*)font restrictedToHeight:(CGFloat)maxHeight insets:(UIEdgeInsets)insets;

+(UIEdgeInsets)rowHeaderInsets;

@end
