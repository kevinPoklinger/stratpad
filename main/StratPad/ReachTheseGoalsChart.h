//
//  ReachTheseGoalsChart.h
//  StratPad
//
//  Created by Eric Rogers on September 24, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//
//  Chart that displays goals to be reached, per quarter, based on the 
//  metrics, target dates, and target values of objectives in a StratFile.

#import "Drawable.h"
#import "ReachTheseGoalsDataSource.h"


@interface ReachTheseGoalsChart : NSObject<Drawable> {
@private
    // data source for the chart.
    ReachTheseGoalsDataSource *dataSource_;

    // rect to draw the chart in.
    CGRect rect_;
        
    // fonts for the chart
    UIFont *font_;
    UIFont *boldFont_;
            
    // font color for the chart
    UIColor *headingFontColor_;
    UIColor *fontColor_;
    
    // line color for the chart.
    UIColor *lineColor_;
    
    // color for alternating rows in the chart.
    UIColor *alternatingRowColor_;
    
    // color of diamonds in the chart.
    UIColor *diamondColor_;
}

@property(nonatomic, readonly) ReachTheseGoalsDataSource *dataSource;
@property(nonatomic, assign) CGRect rect;

@property(nonatomic, readonly) UIFont *font;
@property(nonatomic, readonly) UIFont *boldFont;
@property(nonatomic, retain) UIColor *headingFontColor;
@property(nonatomic, retain) UIColor *fontColor;
@property(nonatomic, retain) UIColor *lineColor;
@property(nonatomic, retain) UIColor *alternatingRowColor;
@property(nonatomic, retain) UIColor *diamondColor;

- (id)initWithRect:(CGRect)rect font:(UIFont*)font boldFont:(UIFont*)boldFont andDataSource:(ReachTheseGoalsDataSource*)dataSource;

+ (CGFloat)heightWithDataSource:(ReachTheseGoalsDataSource*)dataSource font:(UIFont*)font andRowWidth:(CGFloat)rowWidth;

@end
