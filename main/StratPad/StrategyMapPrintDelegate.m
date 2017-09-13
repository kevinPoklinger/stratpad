//
//  StrategyMapPrintDelegate.m
//  StratPad
//
//  Created by Julian Wood on 11-09-30.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "StrategyMapPrintDelegate.h"
#import "StrategyMapViewController.h"
#import "StratFileManager.h"
#import "MBDrawableLabel.h"
#import "SinglePageReportBuilder.h"
#import "MBDrawableReportHeader.h"
#import "NSDate-StratPad.h"
#import "PageSpooler.h"
#import "ReportPrintFonts.h"

@implementation StrategyMapPrintDelegate

@synthesize strategyMapView = strategyMapView_;

-(id) init
{
    self = [super init];
    if (self) {
        pageCounter_ = 0;
        numPages_ = 1;
    }
    return self;
}

- (BOOL)hasMorePages
{
    return (pageCounter_++ < numPages_);
}

- (void)drawPage:(NSInteger)pageIndex inRect:(CGRect)rect
{
    CGRect printInsetRect = CGRectMake(rect.origin.x + printInsets_.left, 
                                       rect.origin.y + printInsets_.top, 
                                       rect.size.width - printInsets_.left - printInsets_.right, 
                                       rect.size.height - printInsets_.top - printInsets_.bottom);
    
    // for print we shift the header to the left slightly, but keep the text aligned with the rest of the page.
    CGFloat headerLeftShift = 5.f;
    CGRect headerRect = CGRectMake(printInsetRect.origin.x - headerLeftShift, 
                                   printInsetRect.origin.y, 
                                   printInsetRect.size.width + headerLeftShift, 
                                   printInsetRect.size.height);
    
    CGRect footerRect = CGRectMake(printInsetRect.origin.x, 
                                   printInsetRect.origin.y + printInsetRect.size.height - 2*textFontSizeForPrint,
                                   printInsetRect.size.width, 
                                   2*textFontSizeForPrint);        
    
    // header is included on all pages
    MBDrawableReportHeader *reportHeader = [[MBDrawableReportHeader alloc] initWithRect:headerRect textInsetLeft:headerLeftShift andReportTitle:[self reportTitle]];
    [reportHeader addTitleItemWithText:[self companyName] font:[UIFont fontWithName:boldFontNameForPrint size:12.f] andColor:[UIColor blackColor]];
    [reportHeader addTitleItemWithText:[self stratFileName] font:[UIFont fontWithName:fontNameForPrint size:12.f] andColor:[UIColor blackColor]];
    [reportHeader addTitleItemWithText:[[NSDate date] formattedDate2] font:[UIFont fontWithName:obliqueFontNameForPrint size:12.f] andColor:[UIColor blackColor]];
    [reportHeader sizeToFit];
    
    CGFloat headerHeight = reportHeader.rect.size.height;        
    [reportHeader draw];    
    [reportHeader release];
    
    CGFloat contentTopMargin = 10.f;        
    
    CGRect contentRect = CGRectMake(printInsetRect.origin.x, printInsetRect.origin.y + headerHeight + contentTopMargin, 
                             printInsetRect.size.width, printInsetRect.size.height - headerHeight - footerRect.size.height);
    
    CGFloat leftMargin = 150;
    CGFloat rowHeight = 70;

    // draw the row headers
    NSArray *rowHeaders = [NSArray arrayWithObjects:                           
                           LocalizedString(@"STRATEGY_MAP_VIEW_LABEL_STRATEGY", nil),
                           LocalizedString(@"STRATEGY_MAP_VIEW_LABEL_THEMES", nil),

                           LocalizedString(@"OBJECTIVE_TYPE_FINANCIAL", nil),
                           LocalizedString(@"OBJECTIVE_TYPE_CUSTOMER", nil),
                           LocalizedString(@"OBJECTIVE_TYPE_PROCESS", nil),
                           LocalizedString(@"OBJECTIVE_TYPE_STAFF", nil),
                           nil];
    for (int i=0, ct=numStratMapRows; i<ct; ++i) {
        MBDrawableLabel *label = [[MBDrawableLabel alloc] 
                                  initWithText:[rowHeaders objectAtIndex:i]
                                  font:[UIFont fontWithName:boldFontNameForPrint size:12]
                                  color:[UIColor blackColor]
                                  lineBreakMode:UILineBreakModeClip
                                  alignment:UITextAlignmentLeft
                                  andRect:CGRectMake(contentRect.origin.x, contentRect.origin.y + i*rowHeight, 
                                                     leftMargin, 18)];
        [label draw];
        [label release];
    }
    
    // draw row descriptions
    NSArray *rowDescriptions = [NSArray arrayWithObjects:
                                @"",
                                LocalizedString(@"STRATEGY_MAP_VIEW_DESC_THEMES", nil),
                                LocalizedString(@"STRATEGY_MAP_VIEW_DESC_FINANCIAL", nil),
                                LocalizedString(@"STRATEGY_MAP_VIEW_DESC_CUSTOMER", nil),
                                LocalizedString(@"STRATEGY_MAP_VIEW_DESC_PROCESS", nil),
                                LocalizedString(@"STRATEGY_MAP_VIEW_DESC_STAFF", nil),
                                nil];
    for (int i=0, ct=numStratMapRows; i<ct; ++i) {
        MBDrawableLabel *label = [[MBDrawableLabel alloc] 
                                  initWithText:[rowDescriptions objectAtIndex:i]
                                  font:[UIFont fontWithName:fontNameForPrint size:11]
                                  color:[UIColor blackColor]
                                  lineBreakMode:UILineBreakModeWordWrap
                                  alignment:UITextAlignmentLeft
                                  andRect:CGRectMake(contentRect.origin.x, contentRect.origin.y + i*rowHeight + 18, 
                                                     leftMargin-5, rowHeight-18)];
        [label draw];
        [label release];
    }

    // which page to draw
    strategyMapView_.pageNumber = pageIndex;
    
    // now draw the strategy map into this rect
    CGRect strategyMapViewRect = CGRectMake(contentRect.origin.x + leftMargin, contentRect.origin.y, contentRect.size.width-leftMargin, numRows*rowHeight);
    [strategyMapView_ drawRect:strategyMapViewRect];

    // now draw the page number in the footer
    NSString *footerText = [NSString stringWithFormat:@"%@ %i", LocalizedString(@"PAGE", nil), 
                  [[PageSpooler sharedManager] cumulativePageNumberForReport]];
    
    MBDrawableLabel *footerLabel = [[MBDrawableLabel alloc] initWithText:footerText 
                                                       font:[UIFont fontWithName:fontNameForPrint size:textFontSizeForPrint] 
                                                      color:textFontColorForPrint
                                              lineBreakMode:UILineBreakModeTailTruncation 
                                                  alignment:UITextAlignmentCenter
                                                    andRect:footerRect];
    [footerLabel sizeToFit];
        
    // center the footer label horizontally and align it with the bottom of the footer rect.
    footerLabel.rect = CGRectMake(footerRect.origin.x + (footerRect.size.width - footerLabel.rect.size.width)/2, 
                                  footerRect.origin.y + (footerRect.size.height - footerLabel.rect.size.height), 
                                  footerLabel.rect.size.width, 
                                  footerLabel.rect.size.height);
        
    [footerLabel draw];
    [footerLabel release];
}


#pragma mark - Overrides

- (NSString*)reportTitle
{
    return LocalizedString(@"STRATEGY_MAP_REPORT_TITLE", nil);
}

@end
