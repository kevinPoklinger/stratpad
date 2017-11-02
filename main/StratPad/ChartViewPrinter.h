//
//  ChartViewPrinter.h
//  StratPad
//
//  Created by Julian Wood on 12-05-10.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Report.h"
#import "SkinManager.h"
#import "ReportHelper.h"
#import "Chart.h"

@interface ChartViewPrinter : NSObject<PrintReportDelegate> {

    // the entire rect available for drawing - set by drawPage:inRect:
    CGRect pageRect_;
    
    // excludes the page insets, the header and the footer - the rectangle inbetween header and footer
    CGRect bodyRect_;
    
    // for printing, true if there are more pages to print
    BOOL hasMorePages_;
    
    // total number of pages to print
    NSInteger numPages_;
        
    // pageNumber -> array of Drawables
    NSMutableDictionary *pagedDrawableComments_;
    
    SkinManager *skinMan_;
    ReportHelper *reportHelper_;
    Chart *chart_;
}

- (id)initWithChart:(Chart*)chart;

@end
