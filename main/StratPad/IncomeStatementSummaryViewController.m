//
//  IncomeStatementSummaryViewController.m
//  StratPad
//
//  Created by Julian Wood on 2013-05-02.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//

#import "IncomeStatementSummaryViewController.h"
#import "MBReportHeaderView.h"
#import "MBLoadingView.h"
#import "SkinManager.h"
#import "UIColor-Expanded.h"
#import "AFNetworking.h"
#import "StratFileWriter.h"
#import "StratFile.h"
#import "StratFileManager.h"
#import "PdfService.h"

#define LOAD_TABLE_METHOD @"loadIncomeStatementSummary"
#define REPORT_URL_PATH @"/reports/incomestatement/summary"

@implementation IncomeStatementSummaryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.headerView setTextInsetLeft:20];
    [self.headerView setReportTitle:LocalizedString(@"IncomeStatementSummaryTitle", nil)];
    
}

#pragma mark - RemoteReport

-(NSString*)jsMethodNameToLoadTable
{
    return LOAD_TABLE_METHOD;
}

-(NSString*)reportUrlPath
{
    return REPORT_URL_PATH;
}

-(NSString*)reportName
{
    return LocalizedString(@"IncomeStatementReportTitle", nil);
}

-(NSString*)fullReportName
{
    return [LocalizedString(@"IncomeStatementSummaryTitle", nil) stringByReplacingOccurrencesOfString:@"\n" withString:@" - "];
}




@end
