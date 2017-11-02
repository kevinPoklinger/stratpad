//
//  BalanceSheetSummaryViewController.m
//  StratPad
//
//  Created by Julian Wood on 2013-05-06.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//

#import "BalanceSheetSummaryViewController.h"

#define LOAD_TABLE_METHOD @"loadBalanceSheetSummary"
#define REPORT_URL_PATH @"/reports/balancesheet/summary"

@interface BalanceSheetSummaryViewController ()

@end

@implementation BalanceSheetSummaryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.headerView setTextInsetLeft:20];
    [self.headerView setReportTitle:LocalizedString(@"BalanceSheetSummaryTitle", nil)];
    
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
    return LocalizedString(@"BalanceSheetReportTitle", nil);
}

-(NSString*)fullReportName
{
    return [LocalizedString(@"BalanceSheetSummaryTitle", nil) stringByReplacingOccurrencesOfString:@"\n" withString:@" - "];
}

@end
