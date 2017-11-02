//
//  StrategyFinancialAnalysisThemeViewController.h
//  StratPad
//
//  Created by Eric Rogers on August 29, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "ReportViewController.h"
#import "MBPDFView.h"

@interface StrategyFinancialAnalysisThemeViewController : ReportViewController {
@private
    MBPDFView *pdfView_;
    
    // this is the 0-based, local page number within all the pages of a year
    NSUInteger pageNumber_; 
    
    // the first (0), second, etc year we are looking at; each year has a number of pages
    NSUInteger year_;
}

@property(nonatomic, retain) IBOutlet MBPDFView *pdfView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
              andYear:(NSUInteger)year
        andPageNumber:(NSUInteger)pageNumber;

+ (NSUInteger)numberOfPages:(StratFile*)stratFile;
+ (NSIndexPath*)yearAndPageForPageIndex:(NSUInteger)pageIndex stratFile:(StratFile*)stratFile;
@end
