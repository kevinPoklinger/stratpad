//
//  MBDrawableGanttChart.m
//  StratPad
//
//  Created by Eric Rogers on September 30, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "MBDrawableGanttChart.h"
#import "GanttChartHeadingRow.h"
#import "GanttChartThemeRow.h"
#import "GanttChartObjectiveRow.h"
#import "GanttChartActivityRow.h"
#import "GanttChartMetricRow.h"


@interface MBDrawableGanttChart (Private)
+ (Class)detailRowClassForTimeline:(GanttTimeline*)timeline;
@end

@implementation MBDrawableGanttChart

@synthesize rect = rect_;
@synthesize dataSource = dataSource_;
@synthesize font = font_;
@synthesize boldFont = boldFont_;
@synthesize obliqueFont = obliqueFont_;

@synthesize headingFontColor = headingFontColor_;
@synthesize fontColor = fontColor_;
@synthesize lineColor = lineColor_;
@synthesize alternatingRowColor = alternatingRowColor_;
@synthesize mediaType = mediaType_;

- (id)initWithRect:(CGRect)rect 
              font:(UIFont*)font 
          boldFont:(UIFont*)boldFont 
       obliqueFont:(UIFont*)obliqueFont
andGanttDataSource:(GanttDataSource*)dataSource
{
    if ((self = [super init])) {        
        rect_ = rect;        
        dataSource_ = [dataSource retain];        
        font_ = [font retain];
        boldFont_ = [boldFont retain];
        obliqueFont_ = [obliqueFont retain];        
    }
    return self;
}

#pragma mark - Memory Management

- (void)dealloc
{
    [dataSource_ release];
    [font_ release];
    [boldFont_ release];
    [obliqueFont_ release];
    [headingFontColor_ release];
    [fontColor_ release];
    [lineColor_ release];
    [alternatingRowColor_ release];
    [super dealloc];
}


#pragma mark - Public

- (void)draw
{
    uint y = rect_.origin.y; //init to the top of the rect    
    
    // draw the heading row first
    CGFloat headerRowHeight = [GanttChartHeadingRow heightWithRowWidth:rect_.size.width 
                                                                            font:font_
                                                              restrictedToHeight:kMaxRowHeight];
    
    CGRect rowRect = CGRectMake(rect_.origin.x, y, rect_.size.width, headerRowHeight);
    
    GanttChartHeadingRow *headingRow = [[GanttChartHeadingRow alloc] initWithRect:rowRect font:boldFont_ andcolumnDates:dataSource_.columnDates];
    headingRow.fontColor = self.headingFontColor;
    headingRow.backgroundColor = self.lineColor;
    [headingRow draw];
    
    y += headingRow.rect.size.height;
    [headingRow release];    
    
    // draw the detail rows, depending on what timelines we have...
    GanttChartDetailRow *detailRow = nil;
    uint detailRowCount = 0;
    
    for (GanttTimeline *timeline in dataSource_.timelines) {
                
        detailRow = [[timeline.ganttChartDetailRowClass alloc] initWithRect:CGRectMake(rect_.origin.x, y, rect_.size.width, 0) 
                                                 headingFont:boldFont_ 
                                              columnDates:dataSource_.columnDates 
                                            andGanttTimeline:timeline
                                                andMediaType:mediaType_];
        
        // the last row should render a full bottom border
        if (detailRowCount == [dataSource_.timelines count] - 1) {
            detailRow.renderFullWidthBottomBorder = YES;
        }
        
        detailRow.lineColor = self.lineColor;
        detailRow.fontColor = self.fontColor;
        detailRow.backgroundColor = detailRowCount % 2 == 0 ? alternatingRowColor_ : nil;  // alternate the background color
        [detailRow draw];
        y += detailRow.rect.size.height;
        [detailRow release];
        detailRow = nil;
        
        detailRowCount++;
    }
}

- (void)sizeToFit
{
    CGFloat height = 0.f;
    
    // height of the heading row
    height += [GanttChartHeadingRow heightWithRowWidth:rect_.size.width 
                                                  font:font_
                                    restrictedToHeight:kMaxRowHeight];

    // heights of each detail row
    Class detailRowClass = nil;
    for (GanttTimeline *timeline in [dataSource_ timelines]) {
        detailRowClass = [MBDrawableGanttChart detailRowClassForTimeline:timeline];
        height += [GanttChartDetailRow heightWithTitle:timeline.title rowWidth:rect_.size.width font:boldFont_ restrictedToHeight:kMaxRowHeight insets:[detailRowClass rowHeaderInsets]];
    }
    
    rect_ = CGRectMake(rect_.origin.x, rect_.origin.y, rect_.size.width, height);    
}

+ (CGFloat)heightWithDataSource:(GanttDataSource*)dataSource rowHeadingFont:(UIFont*)font andRowWidth:(CGFloat)rowWidth
{
    CGFloat height = 0.f;
    
    // height of the heading row
    height += [GanttChartHeadingRow heightWithRowWidth:rowWidth
                                                  font:font
                                    restrictedToHeight:kMaxRowHeight];
    
    // heights of each detail row
    Class detailRowClass = nil;
    for (GanttTimeline *timeline in [dataSource timelines]) {
        detailRowClass = [MBDrawableGanttChart detailRowClassForTimeline:timeline];
        height += [GanttChartDetailRow heightWithTitle:timeline.title rowWidth:rowWidth font:font restrictedToHeight:kMaxRowHeight insets:[detailRowClass rowHeaderInsets]];
    }
    
    return height;
}

+ (Class)detailRowClassForTimeline:(GanttTimeline*)timeline
{
    Class rowClass = nil;
    
    if ([timeline isKindOfClass:[ThemeGanttTimeline class]]) {
        rowClass = [GanttChartThemeRow class];
        
    } else if ([timeline isKindOfClass:[ObjectiveGanttTimeline class]]) {
        rowClass = [GanttChartObjectiveRow class];
        
    } else if ([timeline isKindOfClass:[ActivityGanttTimeline class]]) {            
        rowClass = [GanttChartActivityRow class];
        
    } else if ([timeline isKindOfClass:[MetricGanttTimeline class]]) {
        rowClass = [GanttChartMetricRow class];
        
    } else {
        WLog(@"Unsupported Gantt Timeline of type %@", NSStringFromClass([timeline class]));
    }
    return rowClass;
}

@end
