//
//  ThemeFinancialAnalysisMonthViewController.h
//  StratPad
//
//  Created by Eric Rogers on August 30, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "ReportViewController.h"
#import "Theme.h"
#import "MBPDFView.h"

@interface ThemeFinancialAnalysisMonthViewController : ReportViewController {
@private
    Theme *theme_;    
    
    // 0-based year, within a theme; eg the first year of three for the lifespan of this theme
    NSUInteger year_;
    
    MBPDFView *pdfView_;  
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andThemeOrNil:(Theme*)theme andYear:(NSInteger)year;

// total number of pages for all themes, and all pages within a theme
+ (NSUInteger)numberOfPages:(StratFile*)stratFile;

@property(nonatomic, retain) IBOutlet MBPDFView *pdfView;

@end
