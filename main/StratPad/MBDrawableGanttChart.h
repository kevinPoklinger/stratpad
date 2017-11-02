//
//  MBDrawableGanttChart.h
//  StratPad
//
//  Created by Eric Rogers on September 30, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "Drawable.h"
#import "GanttDataSource.h"
#import "ThemeGanttTimeline.h"
#import "ObjectiveGanttTimeline.h"
#import "ActivityGanttTimeline.h"
#import "MetricGanttTimeline.h"
#import "SkinManager.h"

@interface MBDrawableGanttChart : NSObject<Drawable> {
@private
    CGRect rect_;
    
    // data source for the chart
    GanttDataSource *dataSource_;
            
    // fonts for the chart
    UIFont *font_;
    UIFont *boldFont_;
    UIFont *obliqueFont_;
            
    // font colors for the chart
    UIColor *headingFontColor_;
    UIColor *fontColor_;
    
    // line color for the chart.
    UIColor *lineColor_;
    
    // color for alternating rows in the chart.
    UIColor *alternatingRowColor_;
    
    MediaType mediaType_;    
}

@property(nonatomic, assign) CGRect rect;
@property(nonatomic, readonly) GanttDataSource *dataSource;

@property(nonatomic, readonly) UIFont *font;
@property(nonatomic, readonly) UIFont *boldFont;
@property(nonatomic, readonly) UIFont *obliqueFont;

@property(nonatomic, retain) UIColor *headingFontColor;
@property(nonatomic, retain) UIColor *fontColor;
@property(nonatomic, retain) UIColor *lineColor;
@property(nonatomic, retain) UIColor *alternatingRowColor;
@property(nonatomic, assign) MediaType mediaType;

- (id)initWithRect:(CGRect)rect 
              font:(UIFont*)font 
          boldFont:(UIFont*)boldFont 
       obliqueFont:(UIFont*)obliqueFont
andGanttDataSource:(GanttDataSource*)dataSource;

+ (CGFloat)heightWithDataSource:(GanttDataSource*)dataSource rowHeadingFont:(UIFont*)font andRowWidth:(CGFloat)rowWidth;

@end
