//
//  CashFlowSummaryViewController.m
//  StratPad
//
//  Created by Julian Wood on 2013-05-06.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//

#import "CashFlowSummaryViewController.h"

#define LOAD_TABLE_METHOD @"loadCashFlowSummary"
#define REPORT_URL_PATH @"/reports/cashflow/summary"

@interface CashFlowSummaryViewController ()
@end

@implementation CashFlowSummaryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.headerView setTextInsetLeft:20];
    [self.headerView setReportTitle:LocalizedString(@"CashFlowSummaryTitle", nil)];
    
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
    return LocalizedString(@"CashFlowReportTitle", nil);
}

-(NSString*)fullReportName
{
    return [LocalizedString(@"CashFlowSummaryTitle", nil) stringByReplacingOccurrencesOfString:@"\n" withString:@" - "];
}

@end
