//
//  BusinessPlanViewController.h
//  StratPad
//
//  Created by Julian Wood on 9/15/11.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "ReportViewController.h"
#import "MBPDFView.h"


@interface BusinessPlanViewController : ReportViewController {
@private
    UIScrollView *scrollView_;
    MBPDFView *pdfView_;
}

@property(nonatomic,retain) IBOutlet UIScrollView *scrollView;
@property(nonatomic,retain) IBOutlet MBPDFView *pdfView;


- (NSString*)prepareContentText:(NSString*)contentText;

@end

@interface BusinessPlanViewController (Testable)
- (NSString*)generateSectionAContentForStratFile:(StratFile*)stratFile;
- (NSString*)generateCompanyBasicsDescriptionForStratFile:(StratFile*)stratFile;
- (NSString*)generateLocationDescriptionForStratFile:(StratFile*)stratFile;
- (NSString*)generateSectorDescriptionForStratFile:(StratFile*)stratFile;
- (NSString*)generateSectionBContentForStratFile:(StratFile*)stratFile;
@end