//
//  ThemeDetailReport.h
//  StratPad
//
//  Created by Eric Rogers on September 11, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "AbstractReportDelegate.h"
#import "Theme.h"


@interface ThemeDetailReport : AbstractReportDelegate<ScreenReportDelegate, PrintReportDelegate> {    
@private
    
    Theme *theme_;    

    // contains arrays corresponding to a page, each containing drawables for that page.
    NSArray *pagedDrawables_;
    
    // store the starting x-coordinates of each subcolumn so it's 
    // easy to determine where to put objective data.
    CGFloat objectiveColumnStartX_;
    CGFloat scorecardColumnStartX_;
    CGFloat activityColumnStartX_;
    
    CGFloat measureColumnStartX_;
    CGFloat targetColumnStartX_;
    CGFloat dateColumnStartX_;
    CGFloat actionColumnStartX_;
    CGFloat firstYearCostColumnStartX_;
    CGFloat startDateColumnStartX_;
    CGFloat endDateColumnStartX_;
    
    // store the widths of each subcolumn so it's easy to 
    // determine where to put objective data.
    CGFloat objectiveColumnWidth_;
    CGFloat scorecardColumnWidth_;
    CGFloat activityColumnWidth_;
    
    CGFloat measureColumnWidth_;
    CGFloat targetColumnWidth_;
    CGFloat dateColumnWidth_;
    CGFloat actionColumnWidth_;
    CGFloat firstYearCostColumnWidth_;
    CGFloat startDateColumnWidth_;
    CGFloat endDateColumnWidth_;
    
    // tracks the current yPosition as we draw, since
    // rows can have a dynamic height.
    CGFloat yPosition_;

    // font names for the report
    NSString *fontName_;
    NSString *boldFontName_;
    NSString *obliqueFontName_;
    
    // font size for the report
    CGFloat fontSize_;
    
    // font color for the report
    UIColor *fontColor_;
    UIColor *sectionHeadingFontColor_;
    
    // line color for the report.
    UIColor *lineColor_;
    
    // color of the heading boxes and their font for the report.
    UIColor *headingBoxColor_;
    UIColor *headingBoxFontColor_;
    
    NSString *responsibleDescription_;  
    NSString *themeDescription_;    
    
    BOOL hasMorePages_;
}

// set by the vc
@property(nonatomic, assign) Theme* theme;

// set by the vc with a custom description
@property(nonatomic, copy) NSString *responsibleDescription;
@property(nonatomic, copy) NSString *themeDescription;

@end

