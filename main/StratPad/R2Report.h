//
//  R2Report.h
//  StratPad
//
//  Created by Eric Rogers on September 14, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//
//  For every year of the duration of a strategy, show the effect of the combination of theme costs and expenses.
//  Each page is represented by a VC, which represents a year in the strategy.
//  Each VC has a print and screen delegate, which reuse the same calculation strategy and basic drawing routines (per row).
//  We start with R2CalculationStrategy, which will host an array of ThemeFinancialAnalysisCalculationStrategy's
//  Each ThemeFinancialAnalysisCalculationStrategy has an array of Calculator
//  - ThemeRevenueCalculator
//  - ThemeCOGSCalculator
//  - ThemeExpenseCalculator
//  - ThemeCostCalculator
//  Each Calculator holds an array of monthly, quarterly, annual and one time values, for the duration of its lifetime

#import "AbstractReportDelegate.h"
#import "R2CalculationStrategy.h"


@interface R2Report : AbstractReportDelegate<ScreenReportDelegate,PrintReportDelegate> {
@private
    R2CalculationStrategy *calculationStrategy_;
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
        
    // proportion of the first column, and the rest of the chart compared to the width of the report.
    CGFloat rowHeadingSectionRelativeSize_;
    CGFloat valueSectionRelativeSize_;

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
    
    BOOL isPrint_;
    
    BOOL hasMorePages_;
    
    NSUInteger pageNumber_;
}

@property(nonatomic, retain) R2CalculationStrategy *calculationStrategy;
@property(nonatomic, copy) NSString *reportInfo;
@property(nonatomic, assign) NSUInteger pageNumber;

@end
