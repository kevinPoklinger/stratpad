//
//  PdfHelper.h
//  StratPad
//
//  Created by Julian Wood on 2012-10-30.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Chapter.h"
#import <MessageUI/MessageUI.h>

typedef enum {
    ReportSizeCurrentChapter   = 0, // all pages within a chapter
    ReportSizeAllChapters      = 1, // all chapters within a section
    ReportSizeCurrentPage      = 2  // all pages needed to print a current screen page
} ReportSize;

typedef enum {
    ReportActionEmail,
    ReportActionPrint,
    ReportActionYammer,
    
    // we auto update pdf's from the Yammer comments
    ReportActionYammerUpdate
} ReportAction;

typedef void (^AllTasksCompletedBlock)(NSString *pdfPath);

@interface PdfHelper : NSObject<MFMailComposeViewControllerDelegate,UIPrintInteractionControllerDelegate>

// the block to run when all tasks are completed
@property (nonatomic, copy) AllTasksCompletedBlock allTasksCompletedBlock;

// if we're anywhere in the S1 chapter
@property (nonatomic, assign) BOOL isStratBoard;

// if we're on page 0 of S1
@property (nonatomic, assign) BOOL isStratCard;

// include a reportAction, so that we can invoke the appropriate block (print or email) when all tasks have finished
- (id)initWithReportName:(NSString*)reportName
                 chapter:(Chapter*)chapter
              pageNumber:(NSInteger)pageNumber
              reportSize:(ReportSize)reportSize
            reportAction:(ReportAction)reportAction;

// gets us a path with a normalized filename
- (NSString *)pdfPathWithFileName:(NSString*)filename;

// will save us a pdf and then perform reportAction
-(void)generatePdf;

@end
