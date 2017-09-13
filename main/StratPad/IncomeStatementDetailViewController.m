//
//  IncomeStatementDetailViewController.m
//  StratPad
//
//  Created by Julian Wood on 2013-05-06.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//

#import "IncomeStatementDetailViewController.h"

#define LOAD_TABLE_METHOD @"loadIncomeStatementDetails"
#define REPORT_URL_PATH @"/reports/incomestatement/details"

@interface IncomeStatementDetailViewController ()

@end

@implementation IncomeStatementDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.headerView setTextInsetLeft:20];
    [self.headerView setReportTitle:LocalizedString(@"IncomeStatementDetailTitle", nil)];
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
    return [LocalizedString(@"IncomeStatementDetailTitle", nil) stringByReplacingOccurrencesOfString:@"\n" withString:@" - "];
}

@end
