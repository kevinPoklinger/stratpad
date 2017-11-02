//
//  ReportCardPrinter.h
//  StratPad
//
//  Created by Julian Wood on 12-05-10.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//
//  Also known as the StratCard. Invoked when printing the StratBoard page.

#import <UIKit/UIKit.h>
#import "Report.h"
#import "ReportHelper.h"
#import "SkinManager.h"

#define sectionMarginLeft           10.f
#define sectionSpacerY              8.f
#define chartReportSpacerY          20.f
#define chartReportHeaderHeight     17.f
#define columnSpacerX               20.f
#define bulletSpacerY               1.5f
#define bulletMarginLeft            8.f

#define reportCardFontSize          10.f
#define reportCardFontName          @"Helvetica"
#define reportCardFontNameBold      @"Helvetica-Bold"
#define reportCardFontNameItalic    @"Helvetica-Oblique"

@interface ReportCardPrinter : NSObject<PrintReportDelegate> {
    // the entire rect available for drawing - set by drawPage:inRect:
    CGRect pageRect_;
    
    // rect for the header on each page
    CGRect headerRect_;
    
    // excludes the page insets, the header and the footer - the rectangle inbetween header and footer
    CGRect bodyRect_;
    
    // for printing, true if there are more pages to print
    BOOL hasMorePages_;
    
    // total number of pages to print
    NSInteger numPages_;
        
    // pageNumber -> array of Drawables
    NSMutableDictionary *pagedDrawables_;
    
    // ThemeKey -> array of Charts
    NSMutableDictionary *chartsPerTheme_;
    
    SkinManager *skinMan_;
    ReportHelper *reportHelper_;

    // column help
    CGFloat column1LeftEdge_;
    CGFloat column1RightEdge_;
    CGFloat column2LeftEdge_;
    CGFloat column2RightEdge_;
    
    CGPoint topLeftOrigin_;
    
    
    // fonts
    UIFont *regularFont_;
    UIFont *boldFont_;
    UIFont *italicFont_;

}

@end
