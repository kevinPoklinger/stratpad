//
//  FinancialDetailBaseViewController.m
//  StratPad
//
//  Created by Julian Wood on 2013-05-06.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//

#import "FinancialDetailBaseViewController.h"
#import "MBLoadingView.h"
#import "AFHTTPClient.h"
#import "SkinManager.h"
#import "UIColor-Expanded.h"

@interface FinancialDetailBaseViewController ()
@end

@implementation FinancialDetailBaseViewController

// @override
-(NSString*)pathToHtmlTemplate
{
    return [[NSBundle mainBundle] pathForResource:@"FinancialDetailsReport" ofType:@"html"];
}


@end
