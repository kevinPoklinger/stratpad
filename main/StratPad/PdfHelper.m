//
//  PdfHelper.m
//  StratPad
//
//  Created by Julian Wood on 2012-10-30.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "PdfHelper.h"
#import "NavigationConfig.h"
#import "StratFileManager.h"
#import "Chart.h"
#import "NSDate-StratPad.h"
#import "NSUserDefaults+StratPad.h"
#import "Page.h"
#import "PageSpooler.h"
#import "EditionManager.h"
#import "ReportPage.h"
#import "ContentViewController.h"
#import "YammerManager.h"
#import "FinancialReportBaseViewController.h"
#import "IncomeStatementSummaryViewController.h"
#import "CashFlowSummaryViewController.h"
#import "BalanceSheetSummaryViewController.h"
#import "PdfService.h"
#import "RootViewController.h"
#import "Tracking.h"
#import "MBProgressHUD.h"

@interface PdfHelper ()

// the base name of the report, initially decided by RootViewController -> title of current chapter
@property (nonatomic,retain) NSString *reportName;

// 0-based index of the page in the chapter to be printed
@property (nonatomic,assign) NSInteger pageNumber;

// the chapter to be printed
@property (nonatomic, assign) Chapter *printChapter;

// single page, current chapter or all chapters
@property (nonatomic, assign) ReportSize reportSize;

// progress
@property (nonatomic, retain) MBProgressHUD *hud;
@property (nonatomic, assign) float progress;

@end

@implementation PdfHelper

- (id)initWithReportName:(NSString*)reportName
                 chapter:(Chapter*)chapter
              pageNumber:(NSInteger)pageNumber
              reportSize:(ReportSize)reportSize
            reportAction:(ReportAction)reportAction
{
    self = [super init];
    if (self) {
        self.reportName = reportName;
        self.printChapter = chapter;
        self.pageNumber = pageNumber;
        self.reportSize = reportSize;
        
        self.isStratBoard = self.printChapter.chapterIndex == ChapterIndexStratBoard;
        self.isStratCard = self.isStratBoard && self.pageNumber == 0;
        
        RootViewController *rootViewController = (RootViewController*)[[[UIApplication sharedApplication] keyWindow] rootViewController];
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:rootViewController.view];
        self.hud = hud;
        [hud release];
        
        [rootViewController.view addSubview:_hud];

        
        // the completionBlock is just going to create an email and attach the pdf at path
        PdfHelper *pdfHelper = self;
        
        
        switch (reportAction) {
            case ReportActionEmail:
                self.allTasksCompletedBlock = ^(NSString *path) {
                    
                    // email as an attachment
                    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
                    picker.mailComposeDelegate = pdfHelper;
                    
                    StratFile *stratFile = [[StratFileManager sharedManager] currentStratFile];
                    
                    // subject and body text
                    NSString *subject;
                    NSString *emailBody;
                    switch (reportSize) {
                        case ReportSizeCurrentChapter:
                            subject = [NSString stringWithFormat:LocalizedString(@"EMAIL_ONE_REPORT_SUBJECT", nil), _reportName];
                            emailBody = [NSString stringWithFormat:LocalizedString(@"EMAIL_ONE_REPORT_BODY", nil), _reportName, [stratFile name]];
                            break;
                            
                        case ReportSizeAllChapters:
                            subject = [NSString stringWithFormat:LocalizedString(@"EMAIL_ALL_REPORTS_SUBJECT", nil), [stratFile name]];
                            emailBody = [NSString stringWithFormat:LocalizedString(@"EMAIL_ALL_REPORTS_BODY", nil), [stratFile name]];
                            break;
                            
                        case ReportSizeCurrentPage:
                            if (_isStratBoard) {
                                subject = [NSString stringWithFormat:LocalizedString(@"EMAIL_ONE_CHART_SUBJECT", nil), _reportName];
                                emailBody = [NSString stringWithFormat:LocalizedString(@"EMAIL_ONE_CHART_BODY", nil), _reportName, [stratFile name]];
                            }
                            else {
                                subject = [NSString stringWithFormat:LocalizedString(@"EMAIL_ONE_FINANCIAL_REPORT_SUBJECT", nil), _reportName];
                                emailBody = [NSString stringWithFormat:LocalizedString(@"EMAIL_ONE_FINANCIAL_REPORT_BODY", nil), _reportName, [stratFile name]];
                            }
                            break;
                            
                        default:
                            break;
                    }
                    
                    [picker setSubject:subject];
                    [picker setMessageBody:emailBody isHTML:NO];
                    
                    // Attach pdf to the email
                    DLog(@"Attaching pdf: %@", path);
                    NSData *pdfData = [NSData dataWithContentsOfFile:path];
                    [picker addAttachmentData:pdfData mimeType:@"application/pdf" fileName:[path lastPathComponent]];
                    
#if EMAIL_STRATFILE
                    // add an xml version of the stratfile, for adhoc
                    NSString *filename = [[[stratFile name] stringByReplacingOccurrencesOfString:@"/" withString:@"_"] stringByAppendingPathExtension:@"xml"];
                    NSString *xmlPath = [[path stringByDeletingLastPathComponent] stringByAppendingPathComponent:filename];
                    [[StratFileManager sharedManager] exportStratFileToXmlAtPath:xmlPath stratFile:stratFile];
                    
                    NSData *xmlData = [NSData dataWithContentsOfFile:xmlPath];
                    [picker addAttachmentData:xmlData mimeType:@"text/xml" fileName:filename];
#endif
                    
                    // show the email view
                    RootViewController *rootViewController = (RootViewController*)[[[UIApplication sharedApplication] keyWindow] rootViewController];
                    [rootViewController dismissAllMenus];
                    [rootViewController presentModalViewController:picker animated:YES];
                    [picker release];
                    
                    [Tracking logEvent:kTrackingEventReportEmailed];
                    
                };
                
                break;
                
            case ReportActionYammer:
                
                // block is provided elsewhere

                break;
                
            case ReportActionYammerUpdate:
                // completion block is provided elsewhere
                
                // make sure we have the right reportSize
                if (_isStratBoard) {
                    self.reportSize = ReportSizeCurrentPage;
                } else {
                    self.reportSize = ReportSizeCurrentChapter;
                }

                break;
            case ReportActionPrint:
                self.allTasksCompletedBlock = ^(NSString* path) {
                    NSData *dataFromPath = [NSData dataWithContentsOfFile:path];
                    
                    UIPrintInteractionController *printController = [UIPrintInteractionController sharedPrintController];
                    
                    if(printController && [UIPrintInteractionController canPrintData:dataFromPath]) {
                        
                        printController.delegate = pdfHelper;
                        
                        UIPrintInfo *printInfo = [UIPrintInfo printInfo];
                        printInfo.outputType = UIPrintInfoOutputGeneral;
                        printInfo.jobName = [path lastPathComponent];
                        printInfo.duplex = UIPrintInfoDuplexLongEdge;
                        printController.printInfo = printInfo;
                        printController.showsPageRange = YES;
                        printController.printingItem = dataFromPath;
                        
                        void (^completionHandler)(UIPrintInteractionController *, BOOL, NSError *) = ^(UIPrintInteractionController *printController, BOOL completed, NSError *error) {
                            if (!completed && error) {
                                ELog(@"FAILED! due to error in domain %@ with error code %u", error.domain, error.code);
                            }
                            [printController dismissAnimated:YES];
                        };
                        
                        [Tracking logEvent:kTrackingEventReportPrinted];
                        
                        // show the print menu
                        RootViewController *rootViewController = (RootViewController*)[[[UIApplication sharedApplication] keyWindow] rootViewController];
                        [rootViewController dismissAllMenus];
                        [printController presentFromBarButtonItem:rootViewController.actionsItem animated:YES completionHandler:completionHandler];
                        
                    } else {
                        WLog(@"Can't print data at: %@", path);
                    }
                    
                };
                
                break;
                
            default:
                WLog(@"Unsupported ReportAction: %i", reportAction);
                break;
        }

    }
    return self;
}

- (void)dealloc
{
    [_hud release];
    [_allTasksCompletedBlock release];
    [_reportName release];
    [super dealloc];
}

#pragma mark - pdf generation

// will download json, create html, and then convert to pdf, before combining into a final pdf and then performing reportAction
-(void)generatePdfForFinancialReports
{    
    [_hud show:YES];
    self.progress = 0;
    
    NSArray *controllers;
    if (_printChapter.chapterIndex == ChapterIndexFinancialStatementDetail) {
        // todo: the detailed pdfs
        controllers = [NSArray arrayWithObjects:[IncomeStatementSummaryViewController class],[CashFlowSummaryViewController class], [BalanceSheetSummaryViewController class], nil];
    } else {
        controllers = [NSArray arrayWithObjects:[IncomeStatementSummaryViewController class],[CashFlowSummaryViewController class], [BalanceSheetSummaryViewController class], nil];
    }
    
    NSString *filename = [self filenameWithBasename:LocalizedString(@"SUMMARY_FINACIAL_REPORTS_FILENAME", nil)];
    NSString *targetPath = [self pdfPathWithFileName:filename];
    
    // all the downloading happens on background threads
    // we will quickly have to switch to the main thread to do the json processing, but that's it
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self saveFinancialReportsToPDF:controllers additionalChapters:[NSArray array] toPath:targetPath];
    });
}

-(void)generatePdfForAllReports
{
    [_hud show:YES];
    self.progress = 0;
    
    // todo: the detailed finances
    NSArray *controllers = [NSArray arrayWithObjects:[IncomeStatementSummaryViewController class],[CashFlowSummaryViewController class], [BalanceSheetSummaryViewController class], nil];

    // assemble chapters
    NSArray *chapters = [[NavigationConfig sharedManager] chapters];
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        Chapter *chapter = (Chapter*)evaluatedObject;
        return [chapter isPrintable] && chapter.chapterIndex != ChapterIndexFinancialStatementDetail && chapter.chapterIndex != ChapterIndexFinancialStatementSummary;
    }];
    NSArray *printableChapters = [chapters filteredArrayUsingPredicate:predicate];
    
    NSString *filename = [self filenameWithBasename:LocalizedString(@"STRATPAD_REPORTS_NAME", nil)];
    NSString *targetPath = [self pdfPathWithFileName:filename];
    
    // all the downloading happens on background threads
    // we will quickly have to switch to the main thread to do the json processing, but that's it
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self saveFinancialReportsToPDF:controllers additionalChapters:printableChapters toPath:targetPath];
    });

}

// if path is nil, then we create a new context and file; if non-nil, we expect an open pdf context and existing file!
-(void)saveFinancialReportsToPDF:(NSArray*)controllers additionalChapters:(NSArray*)chapters toPath:(NSString*)targetPath
{
    // NB we expect to be on a background thread here
    
    // reset the page numbering - can still have multiple print pages
    [[PageSpooler sharedManager] resetCumulativePageNumber];
    
    NSMutableDictionary *pdfs = [NSMutableDictionary dictionaryWithCapacity:5];
    
    // we have to move on to yet another thread, because we are going to block this background thread, waiting for tasks to finish
    NSUInteger numKeys = controllers.count;
    
    NSUInteger maxProgress = numKeys + chapters.count;
    
    // back on the main thread
    dispatch_async(dispatch_get_main_queue(), ^{
        RootViewController *rootViewController = (RootViewController*)[[[UIApplication sharedApplication] keyWindow] rootViewController];
        [rootViewController dismissAllMenus];

        [_hud setMode:MBProgressHUDModeDeterminate];
        [_hud setProgress:_progress]; // 0
        _hud.labelText = LocalizedString(@"FINANCIAL_PROGRESS_PREPARING", nil);
    });
    
    // place our financial downloads on a separate background queue, and then block this background thread until finished
    NSConditionLock *conditionLock = [[NSConditionLock alloc] initWithCondition:numKeys];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    for (NSUInteger i = 0; i < numKeys; i++) {
        dispatch_async(queue, ^{
            FinancialReportBaseViewController *vc = [[[controllers objectAtIndex:i] alloc] initWithNibName:nil bundle:nil];
            [vc exportToPDF:^(NSString *pdfPath) {
                // Basically, nothing more than a obtaining a lock
                // Use this as your synchronization primitive to serialize access
                // to the condition variable and also can double as primitive to replace
                // @synchronize -- if you feel that is still necessary
                [conditionLock lock];
                
                DLog(@"Finished task %i with path:%@", i, pdfPath);
                [pdfs setObject:pdfPath forKey:[NSNumber numberWithUnsignedInteger:i]];
                
                dispatch_async(dispatch_get_main_queue(), ^{
//                    [_hud setMode:MBProgressHUDModeDeterminate];
                    self.progress = _progress + 1.f/maxProgress;
                    [_hud setProgress:_progress];
                });
                
                // When unlocking, decrement the condition counter
                [conditionLock unlockWithCondition:[conditionLock condition]-1];
                
            }];
            [vc release];

        });
    }
    
    // This call will get the lock when the condition variable is equal to 0
    [conditionLock lockWhenCondition:0];
    // You have mutex access to the shared stuff... but you are the only one
    // running, so can just immediately release...
    [conditionLock unlock];
    [conditionLock release];
    
    DLog(@"Finished all download and processing tasks");
    
    
    // create final pdf
    dispatch_async(dispatch_get_main_queue(), ^{
        if (UIGraphicsBeginPDFContextToFile(targetPath, CGRectZero, [self pdfContextDictionary]) == NO) {
            ELog(@"Couldn't create a PDF Context.");
            return;
        }
    });
    
    // draw any of the chapters we're supposed to
    for (Chapter *chapter in chapters) {
        
        dispatch_async(dispatch_get_main_queue(), ^{

            // reset the page numbering for each chapter, so that the
            // pages for the chapter begin at 1.
            [[PageSpooler sharedManager] resetCumulativePageNumber];

            DLog(@"Preparing report: %@", chapter.title);
            _hud.labelText = chapter.title;

            for (Page *page in [chapter pages]) {
                if ([page isKindOfClass:[ReportPage class]]) {
                    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
                    ContentViewController *vc = [[NavigationConfig sharedManager] newViewControllerForPage:page];
                    [vc exportToPDF];
                    [vc release];
                    [pool release];
                }
            }

            self.progress = _progress + 1.f/maxProgress;
            [_hud setProgress:_progress];

            // give the progress hud some breathing room to update
            NSDate* futureDate = [NSDate dateWithTimeInterval:0.001 sinceDate:[NSDate date]];
            [[NSRunLoop currentRunLoop] runUntilDate:futureDate];
        });
        
    }
    
    
    // financial reports
    dispatch_async(dispatch_get_main_queue(), ^{
        _hud.mode = MBProgressHUDModeIndeterminate;
        _hud.labelText = LocalizedString(@"FINANCIAL_PROGRESS_FINALIZING", nil);
        
        // now we have to draw each of our downloaded (financial) pdf's into the current context (which will save it to file)
        CGRect paperRect = CGRectMake(0, 0, 72*11, 72*8.5);
        CGContextRef context = UIGraphicsGetCurrentContext();
        for (uint i=0, ct=pdfs.count; i<ct; ++i) {
            NSURL *pdfURL = [NSURL fileURLWithPath:[pdfs objectForKey:[NSNumber numberWithUnsignedInt:i]]];
            
            // create a quartz pdf doc with our pdf file
            CGPDFDocumentRef pdfDoc = CGPDFDocumentCreateWithURL((CFURLRef)pdfURL);
            
            // our summary financials are a single page
            CGPDFPageRef pdfPage = CGPDFDocumentGetPage(pdfDoc, 1);
            
            // save state for restoration later
            CGContextSaveGState(context);
            
            UIGraphicsBeginPDFPageWithInfo(paperRect, nil);
            
            CGContextTranslateCTM(context, paperRect.size.width, paperRect.size.height);
            CGContextRotateCTM(context, degreesToRadians(-90));
            CGContextScaleCTM(context, 1.0, -1.0);
            
            // draw our pdf page into our current pdf file context
            CGContextDrawPDFPage(context, pdfPage);
            
            // restore state
            CGContextRestoreGState(context);
            
            // release
            CGPDFDocumentRelease(pdfDoc);
        }
        
        UIGraphicsEndPDFContext();
        DLog(@"Created: %@", targetPath);
        
        [_hud hide:YES];
        
        // email or print dialog
        _allTasksCompletedBlock(targetPath);

    });
    
}

-(void)generatePdf
{
    NSString *path, *filename;
    switch (_reportSize) {
        case ReportSizeAllChapters:
            DLog(@"All chapters");
            
            [self generatePdfForAllReports];
            
            // completion block is called internally, so it's safe to return
            return;
            
            break;
        case ReportSizeCurrentChapter:
            DLog(@"Current chapter");
            
            if (_printChapter.chapterIndex == ChapterIndexFinancialStatementSummary ||
                _printChapter.chapterIndex == ChapterIndexFinancialStatementDetail) {
                [self generatePdfForFinancialReports];
                
                // completion block is called internally, so it's safe to return
                return;
            }
            else {
                // report names can contain $/ (ie $/month), so we need to replace them...
                NSString *escapedReportName = [self.reportName stringByReplacingOccurrencesOfString:@"$/" withString:LocalizedString(@"DOLLARS_PER", nil)];
                
                // render current chapter to pdf
                filename = [self filenameWithBasename:escapedReportName];
                path = [self pdfPathWithFileName:filename];
                [self saveToPdf:path chapters:[NSArray arrayWithObject:self.printChapter]];
            }
            
            break;
            
        case ReportSizeCurrentPage:
            DLog(@"Current page: %i", self.pageNumber);
            
            NSString *reportNameForFile;
            if (_isStratBoard) {
                if (self.pageNumber == 0) {
                    // ReportCard
                    reportNameForFile = LocalizedString(@"REPORT_CARD", nil);
                    [self setReportName:reportNameForFile];
                    
                } else {
                    // use the name of the chart
                    NSArray *chartList = [Chart chartsSortedByOrderForStratFile:[[StratFileManager sharedManager] currentStratFile]];
                    
                    // first chart is on 2nd page, after ReportCard
                    Chart *chart = [chartList objectAtIndex:self.pageNumber-1];
                    
                    // normally at this point it would be "StratBoard"
                    [self setReportName:chart.title];
                    
                    reportNameForFile = [NSString stringWithFormat:@"%@ - %@", LocalizedString(@"STRATBOARD", nil), chart.title];
                    
                }
            }
            else {
                WLog(@"Trying to print a single page that is not supported. Chapter: %@ Page: %i", _printChapter.chapterNumber, _pageNumber);
                path = nil;
                break;
            }
            
            
            filename = [self filenameWithBasename:reportNameForFile];
            
            path = [self pdfPathWithFileName:filename];
            
            [self saveToPdf:path chapter:self.printChapter pageNumber:self.pageNumber];
            
            break;
            
        default:
            ELog(@"No report size for: %i", _reportSize);
            path = nil;
            break;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        // email or print dialog
        _allTasksCompletedBlock(path);
    });

}

- (NSString*)filenameWithBasename:(NSString*)baseName
{
    // stratfile - basename - date
    NSString *filename = [[NSString stringWithFormat:@"%@ - %@ - %@",
                           [[StratFileManager sharedManager] currentStratFile].name,
                           baseName,
                           [[NSDate date] mediumFormattedDateForLocalTimeZone]
                           ] stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
    return filename;
}

// filename with no extension (it will be deleted and replaced)
- (NSString *)pdfPathWithFileName:(NSString*)filename
{
    filename = [filename stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    
    // some of our filenames come with a period in them (ie an abbreviation), but have no extension
    // extensions should have no spaces in them
    
    NSString *ext = [filename pathExtension];
    if ([ext rangeOfString:@" "].length == 0) {
        // this is a real extension, so get rid of it
        filename = [filename stringByDeletingPathExtension];
    }
    
    filename = [filename stringByAppendingPathExtension:@"pdf"];
    return [NSTemporaryDirectory() stringByAppendingPathComponent:filename];
}

// gives the pdf a title, author, etc
- (NSDictionary *)pdfContextDictionary
{
    NSString *email = [[NSUserDefaults standardUserDefaults] stringForKey:keyEmail];
    
    return [NSDictionary dictionaryWithObjectsAndKeys:
            email, kCGPDFContextAuthor,
            [[EditionManager sharedManager] productDisplayName], kCGPDFContextCreator,
            [[[StratFileManager sharedManager] currentStratFile] name], kCGPDFContextTitle,
            nil];
}

- (void)saveToPdf:(NSString*)path chapters:(NSArray*)chapters
{
    if (UIGraphicsBeginPDFContextToFile(path, CGRectZero, [self pdfContextDictionary]) == NO) {
        ELog(@"Couldn't create a PDF Context.");
        return;
    }
    
    for (Chapter *chapter in chapters) {

        // deal with the financial statements separately
        if (chapter.chapterIndex != ChapterIndexFinancialStatementDetail && chapter.chapterIndex != ChapterIndexFinancialStatementSummary) {
         
            // reset the page numbering for each chapter, so that the
            // pages for the chapter begin at 1.
            [[PageSpooler sharedManager] resetCumulativePageNumber];
            
            for (Page *page in [chapter pages]) {
                if ([page isKindOfClass:[ReportPage class]]) {
                    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
                    ContentViewController *vc = [[NavigationConfig sharedManager] newViewControllerForPage:page];
                    [vc exportToPDF];
                    [vc release];
                    [pool release];
                }
            }
        }
        
    }
    
    UIGraphicsEndPDFContext();
    DLog(@"Created: %@", path);
}

- (void)saveToPdf:(NSString*)path chapter:(Chapter*)chapter pageNumber:(NSInteger)pageNumber
{

    if (UIGraphicsBeginPDFContextToFile(path, CGRectZero, [self pdfContextDictionary]) == NO) {
        ELog(@"Couldn't create a PDF Context.");
        return;
    }
    
    // reset the page numbering - can still have multiple print pages
    [[PageSpooler sharedManager] resetCumulativePageNumber];
    
    Page *page = [[chapter pages] objectAtIndex:pageNumber];
    
    ContentViewController *vc = [[NavigationConfig sharedManager] newViewControllerForPage:page];
    [vc exportToPDF];
    [vc release];
    
    
    UIGraphicsEndPDFContext();
    DLog(@"Created: %@", path);
    

}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    ILog("Email result: %i; error: %@", result, error);
    [controller dismissModalViewControllerAnimated:YES];
}

#pragma mark - UIPrintInteractionControllerDelegate & printing

- (void)printInteractionControllerDidFinishJob:(UIPrintInteractionController *)printInteractionController
{
    printInteractionController.delegate = nil;
    [printInteractionController dismissAnimated:YES];
}

@end
