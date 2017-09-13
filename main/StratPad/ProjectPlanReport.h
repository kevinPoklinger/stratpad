//
//  ProjectPlanReport.h
//  StratPad
//
//  Created by Julian Wood on 9/13/11.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "AbstractReportDelegate.h"

@interface ProjectPlanReport : AbstractReportDelegate<ScreenReportDelegate, PrintReportDelegate> {    
@private    
    // contains arrays corresponding to a page, each containing drawables for that page.
    NSArray *pagedDrawables_;
    
    NSUInteger row_;
    CGFloat rowHeight_;
    NSArray *colWidths_;
    UIEdgeInsets contentInsets_;
        
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
}

@end
