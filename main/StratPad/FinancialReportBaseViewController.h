//
//  FinancialReportBaseViewController.h
//  StratPad
//
//  Created by Julian Wood on 2013-05-09.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBReportHeaderView.h"
#import "ReportViewController.h"
#import "RemoteReport.h"
#import "CSVFileWriter.h"

#define MBReportServerApiToken @"b4354c901f71614a2dc36687698cfc6c"

@interface FinancialReportBaseViewController : ReportViewController<UIWebViewDelegate,RemoteReport>

@property (retain, nonatomic) IBOutlet MBReportHeaderView *headerView;
@property (retain, nonatomic) IBOutlet UIWebView *webView;

@property(nonatomic,retain) NSDictionary *localizedStringsAndKeys;

-(void)loadReport;

- (void)exportToPDF:(void (^)(NSString* pdfPath))completionBlock;


@end
