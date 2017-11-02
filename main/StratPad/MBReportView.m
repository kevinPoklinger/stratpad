//
//  MBReportView.m
//  StratPad
//
//  Created by Julian Wood on 11-09-30.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "MBReportView.h"


@implementation MBReportView

@synthesize screenDelegate = screenDelegate_;
@synthesize printDelegate = printDelegate_;

- (void)dealloc
{
    [screenDelegate_ release], screenDelegate_ = nil;
    [printDelegate_ release], printDelegate_ = nil;
    [super dealloc];
}

- (void)drawPDFPagesWithOrientation:(PageOrientation)orientation
{
    CGRect paperRect;
    if (orientation == PageOrientationLandscape) {
        paperRect = CGRectMake(0, 0, 72*11, 72*8.5);
    } else {
        paperRect = CGRectMake(0, 0, 72*8.5, 72*11);
    }
    
    NSUInteger pageNumber = 0;
    while([printDelegate_ hasMorePages]) {
        // Mark the beginning of a new page.                
        UIGraphicsBeginPDFPageWithInfo(paperRect, nil);
        [printDelegate_ drawPage:pageNumber inRect:paperRect];
        pageNumber++;
    }    
}


@end
