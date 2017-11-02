//
//  GanttReport.h
//  StratPad
//
//  Created by Eric Rogers on September 16, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//
//  Overall structure for Screen
//  - use (SinglePage)ReportBuilder to assemble Drawables
//  - 1 page of Drawables, which are scrollable
//  - MBDrawableHeader and MBDrawableGanttChart
//  - use GanttChartBuilder to build the MBDrawableGanttChart
//  - the builder makes GanttTimeline objects and quarterly dates
//      - ThemeGanttTimeline
//      - ObjectiveGanttTimeline
//      - ActivityGanttTimeline
//      - MetricGanttTimeline
//  - and places them in GanttDataSource
//  - for each GanttTimeline in the data source, we draw a GanttChartDetailRow:GanttChartRow
//      - GanttChartThemeRow
//      - GanttChartObjectiveRow
//      - GanttChartActivityRow
//      - GanttChartMetricRow
//


// For print, we use a MultiPageReportBuilder
// - we only divide up what is seen in the UIScrollView, not how wide the GanttChart could be

// For both, we always use the same chart with 8 divisions, but the timescale changes depending on the strategy duration
// - For 1-8 mo, use months. 
// - For 9-24 mo, use quarters. 
// - For 25-48 mo, use semi-annual. 
// - For 49-60 mo, use annual. 


#import "AbstractReportDelegate.h"
#import "MBDrawableGanttChart.h"
#import "StratFile.h"


@interface GanttReport : AbstractReportDelegate<ScreenReportDelegate, PrintReportDelegate> {
@protected        
    StratFile *stratFile_;
        
    // contains arrays corresponding to a page, each containing drawables for that page.
    NSArray *pagedDrawables_;
    
    NSString *reportSubTitle_;
    
    // font names for the chart
    NSString *fontName_;
    NSString *boldFontName_;
    NSString *obliqueFontName_;
    
    // font size for the chart
    CGFloat fontSize_;
    
    // font colors for the chart
    UIColor *headingFontColor_;
    UIColor *fontColor_;
    
    // line color for the chart.
    UIColor *lineColor_;
    
    // color for alternating rows in the chart.
    UIColor *alternatingRowColor_;
        
    BOOL hasMorePages_;
}

- (id)initWithStratFile:(StratFile*)stratFile;

@end
