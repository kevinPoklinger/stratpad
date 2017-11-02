//
//  GanttChartSplitter.m
//  StratPad
//
//  Created by Eric on 11-10-07.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "GanttChartSplitter.h"
#import "MBDrawableGanttChart.h"
#import "GanttDataSource.h"
#import "GanttTimeline.h"

@implementation GanttChartSplitter

- (id)initWithFirstRect:(CGRect)firstRect andSubsequentRect:(CGRect)subsequentRect
{
    if ((self = [super init])) {
        firstRect_ = firstRect;
        subsequentRect_ = subsequentRect;
    }
    return self;
}

- (NSArray*)splitDrawable:(id<Drawable>)drawable
{
    MBDrawableGanttChart *ganttToSplit = ((MBDrawableGanttChart*)drawable);
    GanttDataSource *dataSource = ganttToSplit.dataSource;
    NSDate *ganttStartDate = [dataSource.columnDates objectAtIndex:0];
    
    NSMutableArray *ganttCharts = [NSMutableArray array];
    CGRect splitRect = firstRect_;

    GanttDataSource *splitDataSource = [[GanttDataSource alloc] initWithStartDate:ganttStartDate forIntervalInMonths:dataSource.intervalInMonths];
    
    for (GanttTimeline *timeline in dataSource.timelines) {

        [splitDataSource.timelines addObject:timeline];
        
        if ([MBDrawableGanttChart heightWithDataSource:splitDataSource 
                                                  rowHeadingFont:ganttToSplit.boldFont 
                                           andRowWidth:splitRect.size.width] > splitRect.size.height) {
            
            [splitDataSource.timelines removeObject:timeline];            
            MBDrawableGanttChart *chart = [[MBDrawableGanttChart alloc] initWithRect:splitRect
                                                                                font:ganttToSplit.font
                                                                            boldFont:ganttToSplit.boldFont
                                                                         obliqueFont:ganttToSplit.obliqueFont
                                                                  andGanttDataSource:splitDataSource];
            chart.lineColor = ganttToSplit.lineColor;
            chart.headingFontColor = ganttToSplit.headingFontColor;
            chart.fontColor = ganttToSplit.fontColor;
            chart.alternatingRowColor = ganttToSplit.alternatingRowColor;
            
            [chart sizeToFit];
            [ganttCharts addObject:chart];
            [chart release];
            [splitDataSource release];
            
            splitRect = subsequentRect_;
            splitDataSource = [[GanttDataSource alloc] initWithStartDate:ganttStartDate forIntervalInMonths:dataSource.intervalInMonths];
            [splitDataSource.timelines addObject:timeline];
        }
    }
    
    if (splitDataSource.timelines.count > 0) {
        MBDrawableGanttChart *chart = [[MBDrawableGanttChart alloc] initWithRect:splitRect
                                                                            font:ganttToSplit.font
                                                                        boldFont:ganttToSplit.boldFont
                                                                     obliqueFont:ganttToSplit.obliqueFont
                                                              andGanttDataSource:splitDataSource];
        chart.lineColor = ganttToSplit.lineColor;
        chart.headingFontColor = ganttToSplit.headingFontColor;
        chart.fontColor = ganttToSplit.fontColor;
        chart.alternatingRowColor = ganttToSplit.alternatingRowColor;
        [chart sizeToFit];
        [ganttCharts addObject:chart];
        [chart release];        
    }
    [splitDataSource release];
    
    return ganttCharts;
}

+ (CGFloat)minimumSplitHeightForDrawable:(id<Drawable>)drawable
{
    MBDrawableGanttChart *chart = (MBDrawableGanttChart*)drawable;
    GanttDataSource *dataSource = [[GanttDataSource alloc] init];
    CGFloat minHeight = [MBDrawableGanttChart heightWithDataSource:dataSource rowHeadingFont:chart.boldFont andRowWidth:chart.rect.size.width];
    [dataSource release];
    return minHeight;
}

@end
