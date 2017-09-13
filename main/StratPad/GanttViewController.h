//
//  GanttViewController.h
//  StratPad
//
//  Created by Eric Rogers on August 31, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "ReportViewController.h"
#import "MBPDFView.h"

@interface GanttViewController : ReportViewController {
@private    
    UIScrollView *scrollView_;

    MBPDFView *pdfView_;
}

@property(nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property(nonatomic, retain) IBOutlet MBPDFView *pdfView;

@end
