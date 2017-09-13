//
//  BalanceSheetDetailViewController.m
//  StratPad
//
//  Created by Julian Wood on 2013-05-06.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//

#import "BalanceSheetDetailViewController.h"

#define LOAD_TABLE_METHOD @"loadBalanceSheetDetails"
#define REPORT_URL_PATH @"/reports/balancesheet/details"

@interface BalanceSheetDetailViewController ()

@end

@implementation BalanceSheetDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.headerView setTextInsetLeft:20];
    [self.headerView setReportTitle:LocalizedString(@"BalanceSheetDetailTitle", nil)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [super dealloc];
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
    return [LocalizedString(@"BalanceSheetDetailTitle", nil) stringByReplacingOccurrencesOfString:@"\n" withString:@" - "];
}


@end
