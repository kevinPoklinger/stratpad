//
//  GanttChartBuilder.h
//  StratPad
//
//  Created by Eric Rogers on September 30, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "StratFile.h"
#import "MBDrawableGanttChart.h"
#import "SkinManager.h"

@interface GanttChartBuilder : NSObject {
@private
        
    // rect that the chart will use, this defines the maximum
    // dimensions for the chart.
    CGRect rect_;
        
    // strat file that will be used to construct the chart's 
    // data source.
    StratFile *stratFile_;    
    
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
        
    MediaType mediaType_;
    
    // flag to disable the inclusion of metrics in the chart.
    // This is NO by default.
    BOOL hideMetricsRow_;
    
    // flag to show what would have been in the metrics row, in the objective row instead
    // NO by default, but true for R9C
    BOOL showMetricMilestoneForObjective_;
    
    // if true, then if an objective has metrics which all have a numeric value and a date, we don't show the objective   
    // NO by default, but true for R9C
    BOOL shouldFilterBlankObjectives_;
}

@property(nonatomic, assign) CGRect rect;
@property(nonatomic, retain) StratFile *stratFile;

@property(nonatomic, copy) NSString *fontName;
@property(nonatomic, copy) NSString *boldFontName;
@property(nonatomic, copy) NSString *obliqueFontName;

@property(nonatomic, assign) CGFloat fontSize;
@property(nonatomic, retain) UIColor *headingFontColor;
@property(nonatomic, retain) UIColor *fontColor;
@property(nonatomic, retain) UIColor *lineColor;
@property(nonatomic, retain) UIColor *alternatingRowColor;

@property(nonatomic,assign) MediaType mediaType;
@property(nonatomic, assign) BOOL hideMetricsRow;
@property(nonatomic, assign) BOOL showMetricMilestoneForObjective;
@property(nonatomic, assign) BOOL shouldFilterBlankObjectives;


- (MBDrawableGanttChart*)build;

@end
