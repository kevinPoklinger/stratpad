//
//  ReachTheseGoalsChartBuilder.h
//  StratPad
//
//  Created by Eric on 11-09-29.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//
//  Builds a Reach These Goals chart that will be included
//  in a single page.

#import "ReachTheseGoalsChart.h"
#import "StratFile.h"

@interface ReachTheseGoalsChartBuilder : NSObject {
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
    
    // font size for the chart
    CGFloat fontSize_;
    
    // font colors for the chart
    UIColor *headingFontColor_;
    UIColor *fontColor_;
    
    // line color for the chart.
    UIColor *lineColor_;
    
    // color for alternating rows in the chart.
    UIColor *alternatingRowColor_;
    
    // color of diamonds in the chart.
    UIColor *diamondColor_;
}

@property(nonatomic, assign) CGRect rect;
@property(nonatomic, retain) StratFile *stratFile;

@property(nonatomic, copy) NSString *fontName;
@property(nonatomic, copy) NSString *boldFontName;

@property(nonatomic, assign) CGFloat fontSize;
@property(nonatomic, retain) UIColor *headingFontColor;
@property(nonatomic, retain) UIColor *fontColor;
@property(nonatomic, retain) UIColor *lineColor;
@property(nonatomic, retain) UIColor *alternatingRowColor;
@property(nonatomic, retain) UIColor *diamondColor;

- (ReachTheseGoalsChart*)build;

@end
