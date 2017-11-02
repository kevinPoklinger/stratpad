//
//  StrategyFinancialAnalysisMonthViewController.h
//  StratPad
//
//  Created by Eric Rogers on August 25, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "ReportViewController.h"
#import "MBPDFView.h"

@interface StrategyFinancialAnalysisMonthViewController : ReportViewController {
@private
    MBPDFView *pdfView_; 
    
    NSUInteger pageNumber_;    
}

@property(nonatomic, retain) IBOutlet MBPDFView *pdfView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andPageNumber:(NSUInteger)pageNumber;

+ (NSUInteger)numberOfPages:(StratFile*)stratFile;

@end
