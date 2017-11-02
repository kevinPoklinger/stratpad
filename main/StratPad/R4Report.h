//
//  R4Report.h
//  StratPad
//
//  Created by Eric on 11-09-15.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//
//  For every theme, show a page of calculations for each year or portion thereof. Themes have independent start dates.
//  See R2 for a more detailed description of the architecture.

#import "AbstractReportDelegate.h"
#import "ThemeFinancialAnalysisCalculationStrategy.h"

@interface R4Report : AbstractReportDelegate<ScreenReportDelegate,PrintReportDelegate> {
@private
    ThemeFinancialAnalysisCalculationStrategy *calculationStrategy_;
    NSString *themeTitle_;
    NSString *reportInfo_;
    
    // provides the starting x-position and width of the section in the table
    // containing the row headings.
    CGFloat rowHeadingSectionStartX_;
    CGFloat rowHeadingSectionWidth_;
    
    // provides the starting x-position and width of the section of the table 
    // containing the calculations
    CGFloat valuesSectionStartX_;
    CGFloat valuesSectionWidth_;
    
    // width of each value column, i.e., month, 1st year total, subs years.
    CGFloat valueColumnWidth_;
    
    // tracks the current y-position as we draw
    CGFloat yPosition_;
    
    // font names for the report
    NSString *fontName_;
    NSString *boldFontName_;
    NSString *obliqueFontName_;
    
    // font size for the report
    CGFloat fontSize_;
    
    // font color for the report
    UIColor *fontColor_;
    
    // line color for the report.
    UIColor *lineColor_;
    
    // proportion of the first column, and the rest of the chart compared to the width of the report.
    CGFloat rowHeadingSectionRelativeSize_;
    CGFloat valueSectionRelativeSize_;
    
    BOOL isPrint_;
    
    BOOL hasMorePages_;
    
    NSUInteger year_;
}

@property(nonatomic, retain) ThemeFinancialAnalysisCalculationStrategy *calculationStrategy;
@property(nonatomic, copy) NSString *themeTitle;
@property(nonatomic, copy) NSString *reportInfo;
@property(nonatomic, assign) NSUInteger year;

@end
