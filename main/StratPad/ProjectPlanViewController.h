//
//  ProjectPlanViewController.h
//  StratPad
//
//  Created by Julian Wood on 9/13/11.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "ReportViewController.h"
#import "MBPDFView.h"

@interface ProjectPlanViewController : ReportViewController {
@private
    UIScrollView *scrollView_;
    
    MBPDFView *pdfView_;
}

@property(nonatomic,retain) IBOutlet UIScrollView *scrollView;
@property(nonatomic,retain) IBOutlet MBPDFView *pdfView;

@end
