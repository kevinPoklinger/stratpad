//
//  BusinessPlanSkin.h
//  StratPad
//
//  Created by Julian Wood on 2013-06-21.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BusinessPlanSkin : NSObject

// font names for the report
@property(nonatomic,retain) NSString *fontName;
@property(nonatomic,retain) NSString *boldFontName;
@property(nonatomic,retain) NSString *obliqueFontName;

// font sizes for the report
@property(nonatomic,assign) CGFloat fontSize;
@property(nonatomic,assign) CGFloat chartFontSize;

// font colors for charts
@property(nonatomic,retain) UIColor *chartHeadingFontColor;
@property(nonatomic,retain) UIColor *chartFontColor;

// font colors for the report
@property(nonatomic,retain) UIColor *sectionHeadingFontColor;
@property(nonatomic,retain) UIColor *textFontColor;

// line color for charts in the report.
@property(nonatomic,retain) UIColor *lineColor;

// color for alternating rows in the charts.
@property(nonatomic,retain) UIColor *alternatingRowColor;

// color of large arrows in the Gantt chart.
@property(nonatomic,retain) UIColor *largeArrowColor;

// color of small arrows in the Gantt chart.
@property(nonatomic,retain) UIColor *smallArrowColor;

// color of diamonds in the Gantt chart.
@property(nonatomic,retain) UIColor *diamondColor;


+(BusinessPlanSkin*)skinForDocx;

@end
