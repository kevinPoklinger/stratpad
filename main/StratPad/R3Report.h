//
//  R3Report.h
//  StratPad
//
//  Created by Eric on 11-09-15.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "AbstractReportDelegate.h"
#import "R3CalculationStrategy.h"

// maximum number of columns per page, including themes, and the
// first year and subs year columns.
extern uint const kMaxColumnsPerPage;

@interface R3Report : AbstractReportDelegate<ScreenReportDelegate, PrintReportDelegate> {
@private
    R3CalculationStrategy *calculationStrategy_;
    NSString *reportInfo_;
    NSArray *themesToRender_;
        
    // 0-based page number of the report, within a year
    NSUInteger pageNumber_;
    
    // 0-based year of the report
    NSUInteger year_;
    
    // starting index from calculation strategy themes array.
    NSUInteger themeStartIndex_;
    
    // 0-based page number that first year total goes on
    NSUInteger nthYearPageNumber_;
    
    // 0-based page number that subs years total goes on.
    NSUInteger subsYearsPageNumber_;
    
    // left and right padding to apply to value columns
    CGFloat valueHorizontalPadding_;
    
    // provides the starting x-position and width of the section in the table
    // containing the row headings.
    CGFloat rowHeadingSectionStartX_;
    CGFloat rowHeadingSectionWidth_;
    
    // provides the starting x-position and width of the section of the table 
    // containing the calculations
    CGFloat valuesSectionStartX_;
    CGFloat valuesSectionWidth_;
    
    // width of each value column, i.e., month.
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
}

@property(nonatomic, retain) R3CalculationStrategy *calculationStrategy;
@property(nonatomic, copy) NSString *reportInfo;
@property(nonatomic, assign) NSUInteger pageNumber;
@property(nonatomic, assign) NSUInteger year;

@end
