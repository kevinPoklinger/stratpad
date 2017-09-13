//
//  ReportHelper.m
//  StratPad
//
//  Created by Julian Wood on 12-04-09.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "ReportHelper.h"
#import "StratFileManager.h"

@implementation ReportHelper

@synthesize screenInsets = screenInsets_;
@synthesize printInsets = printInsets_;

- (id)init
{
    if ((self = [super init])) {
        screenInsets_ = UIEdgeInsetsMake(20, 20, 20, 20);
        printInsets_ = UIEdgeInsetsMake(0.5*72, 0.75*72, 0.5*72, 0.75*72);
    }
    return self;
}

- (NSString*)companyName
{
    NSString *companyName = [[[StratFileManager sharedManager] currentStratFile] companyName];
    return companyName ? companyName : LocalizedString(@"UNNAMED_COMPANY", nil);
}

- (NSString*)stratFileName
{
    NSString *stratFileName = [[[StratFileManager sharedManager] currentStratFile] name];
    return stratFileName ? stratFileName : LocalizedString(@"UNNAMED_STRATFILE_TITLE", nil);
}

- (NSString*)reportTitle
{
    ELog(@"All reports must have a title.");
    return nil;
}


@end
