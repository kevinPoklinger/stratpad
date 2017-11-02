//
//  R3Report.m
//  StratPad
//
//  Created by Eric on 11-09-15.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "R3Report.h"
#import "UIColor-Expanded.h"
#import "NSNumber-StratPad.h"
#import "Theme.h"
#import "MBDrawableReportHeader.h"
#import "NSDate-StratPad.h"
#import "MBDrawableLabel.h"
#import "PageSpooler.h"
#import "ReportPrintFonts.h"
#import "SkinManager.h"
#import "MBReportHeader.h"

uint const kMaxColumnsPerPage = 10;

@interface R3Report (Private)

- (void)drawReportContentInRect:(CGRect)contentRect;
- (void)calculateLayoutForRect:(CGRect)rect;
- (void)drawTableHeadingRowInRect:(CGRect)rect;

- (void)drawRevenueRowInRect:(CGRect)rect;
- (void)drawChangeInRevenueRowInRect:(CGRect)rect;
- (void)drawChangeInCOGSRowInRect:(CGRect)rect;
- (void)drawTotalChangeInGrossMarginRowInRect:(CGRect)rect;

- (void)drawExpensesRowInRect:(CGRect)rect;
- (void)drawChangeInRadRowInRect:(CGRect)rect;
- (void)drawChangeInGaaRowInRect:(CGRect)rect;
- (void)drawChangeInSamRowInRect:(CGRect)rect;
- (void)drawTotalChangeInExpensesRowInRect:(CGRect)rect;

- (void)drawTotalForStrategyRowInRect:(CGRect)rect;
- (void)drawNetContributionRowInRect:(CGRect)rect;
- (void)drawNetCumulativeRowInRect:(CGRect)rect;

- (void)drawTableDetailRowWithHeading:(NSString*)heading andValues:(NSArray*)values;

@end


@implementation R3Report

@synthesize calculationStrategy = calculationStrategy_;
@synthesize reportInfo = reportInfo_;
@synthesize pageNumber = pageNumber_;
@synthesize year = year_;

- (id)init
{
    if ((self = [super init])) {        
        hasMorePages_ = YES;
        
        SkinManager *skinMan = [SkinManager sharedManager];
        fontName_ = [skinMan stringForProperty:kSkinSection3FontName forMediaType:MediaTypeScreen];    
        boldFontName_ = [skinMan stringForProperty:kSkinSection3BoldFontName forMediaType:MediaTypeScreen];
        obliqueFontName_ = [skinMan stringForProperty:kSkinSection3ItalicFontName forMediaType:MediaTypeScreen];
        fontSize_ = [skinMan fontSizeForProperty:kSkinSection3FinancialAnalysisFontSize forMediaType:MediaTypeScreen];
        fontColor_ = [[skinMan colorForProperty:kSkinSection3ChartFontColor forMediaType:MediaTypeScreen] retain];
        lineColor_ = [[skinMan colorForProperty:kSkinSection3ChartLineColor forMediaType:MediaTypeScreen] retain];
    }
    return self;
}

#pragma mark - Memory Management

- (void)dealloc
{
    [calculationStrategy_ release];
    [lineColor_ release];
    [fontColor_ release];
    [super dealloc];
}


#pragma mark - ReportDelegate

- (NSString*)reportTitle
{
    NSString *msg = isPrint_ ? LocalizedString(@"R3_REPORT_TITLE_FOR_PRINT", nil) : LocalizedString(@"R3_REPORT_TITLE_FOR_SCREEN", nil);
    NSString *ordKey = [NSString stringWithFormat:@"ORDINAL_%i", year_];
    NSString *ordinal = LocalizedString(ordKey, nil);
    return [NSString stringWithFormat:msg, ordinal];
}


#pragma mark - ScreenReportDelegate

- (CGFloat)heightToDisplayContentForBounds:(CGRect)viewBounds
{
    return viewBounds.size.height;
}

- (void)drawRect:(CGRect)rect
{
    isPrint_ = NO;
    
    // define the layout percentages for screen.
    rowHeadingSectionRelativeSize_ = 0.10f;
    valueSectionRelativeSize_ = 0.90f;
    
    SkinManager *skinMan = [SkinManager sharedManager];
    
    CGRect screenInsetRect = CGRectMake(rect.origin.x + screenInsets_.left, 
                                        rect.origin.y + screenInsets_.top, 
                                        rect.size.width - screenInsets_.left - screenInsets_.right, 
                                        rect.size.height - screenInsets_.top - screenInsets_.bottom);
    
    
    MBReportHeader *reportHeader = [[MBReportHeader alloc] initWithRect:rect textInsetLeft:screenInsets_.left andReportTitle:[self reportTitle]];
    reportHeader.headerImageName = [skinMan stringForProperty:kSkinSection3HeaderImage forMediaType:MediaTypeScreen];
    reportHeader.reportTitleFontName = boldFontName_;
    reportHeader.reportTitleFontSize = [skinMan fontSizeForProperty:kSkinSection3ReportTitleFontSize forMediaType:MediaTypeScreen];
    reportHeader.reportTitleFontColor = [skinMan colorForProperty:kSkinSection3ReportTitleFontColor forMediaType:MediaTypeScreen];
    [reportHeader addDescriptionItemWithText:self.reportInfo 
                                        font:[UIFont fontWithName:boldFontName_ size:[skinMan fontSizeForProperty:kSkinSection3ReportDescriptionFontSize forMediaType:MediaTypeScreen]] 
                                    andColor:[skinMan colorForProperty:kSkinSection3ReportDescriptionFontColor forMediaType:MediaTypeScreen]];
    [reportHeader addDescriptionItemWithText:LocalizedString(@"ROUNDING_DISCLAIMER", nil)
                                        font:[UIFont fontWithName:boldFontName_ size:[skinMan fontSizeForProperty:kSkinSection3ReportDescriptionFontSize forMediaType:MediaTypeScreen]] 
                                    andColor:[skinMan colorForProperty:kSkinSection3ReportDescriptionFontColor forMediaType:MediaTypeScreen]];
    [reportHeader sizeToFit];
    
    CGFloat headerHeight = [reportHeader rect].size.height;
    
    [reportHeader draw];    
    [reportHeader release];
    
    CGFloat contentMarginTop = 0;
    CGRect contentRect = CGRectMake(screenInsetRect.origin.x, 
                                    screenInsetRect.origin.y + headerHeight + contentMarginTop, 
                                    screenInsetRect.size.width, 
                                    screenInsetRect.size.height - headerHeight);        
    [self drawReportContentInRect:contentRect];
}


#pragma mark - PrintReportDelegate

- (BOOL)hasMorePages
{
    return hasMorePages_;
}

- (void)drawPage:(NSInteger)pageIndex inRect:(CGRect)rect
{
    isPrint_ = YES;
    
    // define the table font sizes and layout percentages for print.
    SkinManager *skinMan = [SkinManager sharedManager];
    fontName_ = [skinMan stringForProperty:kSkinSection3FontName forMediaType:MediaTypePrint];
    boldFontName_ = [skinMan stringForProperty:kSkinSection3BoldFontName forMediaType:MediaTypePrint];
    obliqueFontName_ = [skinMan stringForProperty:kSkinSection3ItalicFontName forMediaType:MediaTypePrint];
    fontSize_ = [skinMan fontSizeForProperty:kSkinSection3FinancialAnalysisFontSize forMediaType:MediaTypePrint];
    [fontColor_ release], [lineColor_ release];
    fontColor_ = [[skinMan colorForProperty:kSkinSection3ChartFontColor forMediaType:MediaTypePrint] retain];    
    lineColor_ = [[skinMan colorForProperty:kSkinSection3ChartLineColor forMediaType:MediaTypePrint] retain];

    rowHeadingSectionRelativeSize_ = 0.09f;
    valueSectionRelativeSize_ = 0.91f;
    
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
                                   printInsetRect.origin.y + printInsetRect.size.height - 2*fontSize_,
                                   printInsetRect.size.width, 
                                   2*fontSize_);        

    MBDrawableReportHeader *reportHeader = [[MBDrawableReportHeader alloc] initWithRect:headerRect textInsetLeft:headerLeftShift andReportTitle:[self reportTitle]];
    [reportHeader addTitleItemWithText:[self companyName] font:[UIFont fontWithName:boldFontName_ size:reportHeaderSubTitleFontSizeForPrint] andColor:reportHeaderFontColorForPrint];
    [reportHeader addTitleItemWithText:[self stratFileName] font:[UIFont fontWithName:fontName_ size:reportHeaderSubTitleFontSizeForPrint] andColor:reportHeaderFontColorForPrint];
    [reportHeader addTitleItemWithText:[[NSDate date] formattedDate2] font:[UIFont fontWithName:obliqueFontName_ size:reportHeaderSubTitleFontSizeForPrint] andColor:reportHeaderFontColorForPrint];
    [reportHeader addDescriptionItemWithText:[NSString stringWithFormat:@"%@ %@", self.reportInfo, LocalizedString(@"ROUNDING_DISCLAIMER_SHORT", nil)] 
                                        font:[UIFont fontWithName:fontName_ size:reportHeaderDescriptionFontSizeForPrint] andColor:reportHeaderFontColorForPrint];    
    [reportHeader sizeToFit];
    
    CGFloat headerHeight = reportHeader.rect.size.height;
    
    [reportHeader draw];    
    [reportHeader release];
    
    CGFloat contentMarginTop = 10.f;
    CGRect contentRect = CGRectMake(printInsetRect.origin.x, 
                                    printInsetRect.origin.y + headerHeight + contentMarginTop, 
                                    printInsetRect.size.width, 
                                    printInsetRect.size.height - headerHeight - footerRect.size.height);        
    [self drawReportContentInRect:contentRect];
    
    // now draw the page number in the footer
    NSString *footerText = [NSString stringWithFormat:@"%@ %i", LocalizedString(@"PAGE", nil), 
                            [[PageSpooler sharedManager] cumulativePageNumberForReport]];
    
    MBDrawableLabel *footerLabel = [[MBDrawableLabel alloc] initWithText:footerText 
                                                                    font:[UIFont fontWithName:fontName_ size:fontSize_] 
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

    hasMorePages_ = NO;
}


#pragma mark - Drawing

- (void)calculateLayoutForRect:(CGRect)rect
{
    themeStartIndex_ = pageNumber_ * kMaxColumnsPerPage;
 
    // we may only be rendering the first year and/or subs year columns on the current page,
    // so if that is the case, then ensure that there are no themes to render.
    if (themeStartIndex_ > self.calculationStrategy.themes.count - 1) {
        themesToRender_ = [NSArray array];
    } else {
        themesToRender_ = [self.calculationStrategy.themes subarrayWithRange:NSMakeRange(themeStartIndex_, MIN(self.calculationStrategy.themes.count - themeStartIndex_, kMaxColumnsPerPage))];        
    }
        
    // calculate the page numbers that the first year and subs year totals go on.
    nthYearPageNumber_ = ((self.calculationStrategy.themes.count + 1) / (kMaxColumnsPerPage + 1));
    subsYearsPageNumber_ = ((self.calculationStrategy.themes.count + 2) / (kMaxColumnsPerPage + 1));
     
    rowHeadingSectionStartX_ = rect.origin.x;
    rowHeadingSectionWidth_ = rowHeadingSectionRelativeSize_ * rect.size.width;
    
    valuesSectionStartX_ = rowHeadingSectionStartX_ + rowHeadingSectionWidth_;
    valuesSectionWidth_ = valueSectionRelativeSize_ * rect.size.width;
    
    valueHorizontalPadding_ = 10.f;
    
    valueColumnWidth_ = valuesSectionWidth_ / kMaxColumnsPerPage;    
    
    yPosition_ = rect.origin.y;
}

- (void)drawReportContentInRect:(CGRect)contentRect
{
    [self calculateLayoutForRect:contentRect];
    [self drawTableHeadingRowInRect:contentRect];
    
    [self drawRevenueRowInRect:contentRect];
    [self drawChangeInRevenueRowInRect:contentRect];    
    [self drawChangeInCOGSRowInRect:contentRect];
    [self drawTotalChangeInGrossMarginRowInRect:contentRect];
    
    [self drawExpensesRowInRect:contentRect];
    [self drawChangeInRadRowInRect:contentRect];
    [self drawChangeInGaaRowInRect:contentRect];
    [self drawChangeInSamRowInRect:contentRect];
    [self drawTotalChangeInExpensesRowInRect:contentRect];
    
    [self drawTotalForStrategyRowInRect:contentRect];
    [self drawNetContributionRowInRect:contentRect];
    [self drawNetCumulativeRowInRect:contentRect];
}

- (void)drawTableHeadingRowInRect:(CGRect)rect
{
    CGFloat headingRowHeight = 26.f;
    UIFont *columnHeadingFont = [UIFont fontWithName:boldFontName_ size:fontSize_];
    CGRect columnHeadingRect;
    NSString *columnHeading;    

    uint i = 0;
    for (Theme* theme in themesToRender_) {
        columnHeadingRect = CGRectMake(valuesSectionStartX_ + valueColumnWidth_ * i + valueHorizontalPadding_, 
                                       yPosition_, 
                                       valueColumnWidth_ - 2*valueHorizontalPadding_, 
                                       headingRowHeight);
        
        [AbstractReportDelegate drawLabelWithText:theme.title inRect:columnHeadingRect withFont:columnHeadingFont color:fontColor_ horizontalAlignment:UITextAlignmentRight andVerticalAlignment:VerticalTextAlignmentBottom];         
        i++;
    }
    
    if (pageNumber_ == nthYearPageNumber_) {
        NSString *ordKey = [NSString stringWithFormat:@"ORDINAL_ABBR_%i", year_];
        NSString *ordinal = LocalizedString(ordKey, nil);
        columnHeading = [NSString stringWithFormat:LocalizedString(@"NTH_YEAR_TOTAL", nil), ordinal];
        columnHeadingRect = CGRectMake(valuesSectionStartX_ + valueColumnWidth_ * i + valueHorizontalPadding_, 
                                       yPosition_, 
                                       valueColumnWidth_ - 2*valueHorizontalPadding_, 
                                       headingRowHeight);
        
        [AbstractReportDelegate drawLabelWithText:columnHeading inRect:columnHeadingRect withFont:columnHeadingFont color:fontColor_ horizontalAlignment:UITextAlignmentRight andVerticalAlignment:VerticalTextAlignmentBottom];                 
        i++;
    }
    
    if (pageNumber_ == subsYearsPageNumber_) {
        columnHeading = LocalizedString(@"SUBS_YEARS", nil);
        columnHeadingRect = CGRectMake(valuesSectionStartX_ + valueColumnWidth_ * i + valueHorizontalPadding_, 
                                       yPosition_, 
                                       valueColumnWidth_ - 2*valueHorizontalPadding_, 
                                       headingRowHeight);
        
        [AbstractReportDelegate drawLabelWithText:columnHeading inRect:columnHeadingRect withFont:columnHeadingFont color:fontColor_ horizontalAlignment:UITextAlignmentRight andVerticalAlignment:VerticalTextAlignmentBottom];         
    }
    
    CGFloat headingRowBottomMargin = 5.f;
    yPosition_ += headingRowHeight + headingRowBottomMargin;    
    
    [AbstractReportDelegate drawHorizontalLineAtPoint:CGPointMake(valuesSectionStartX_, yPosition_) width:valuesSectionWidth_ thickness:3.f color:lineColor_];    
    yPosition_ += 3.f;
}


- (void)drawRevenueRowInRect:(CGRect)rect
{
    UIFont *revenueHeadingFont = [UIFont fontWithName:boldFontName_ size:fontSize_];
    CGRect revenueRect = CGRectMake(rowHeadingSectionStartX_, yPosition_, rowHeadingSectionWidth_, 11.f);
    [AbstractReportDelegate drawWrappedLabelWithText:[LocalizedString(@"REVENUE", nil) uppercaseString] inRect:revenueRect withFont:revenueHeadingFont color:fontColor_ alignment:UITextAlignmentLeft];
    
    yPosition_ += revenueRect.size.height;
}

- (void)drawChangeInRevenueRowInRect:(CGRect)rect
{    
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:14];
    
    for (uint i = 0; i < themesToRender_.count; i++) {
        [values addObject:[calculationStrategy_ changeInRevenueForThemeNumber:themeStartIndex_ + i year:year_]];
    }
    
    if (pageNumber_ == nthYearPageNumber_) {
        [values addObject:[calculationStrategy_ changeInRevenueForYear:year_]];
    }
    
    if (pageNumber_ == subsYearsPageNumber_) {
        [values addObject:[calculationStrategy_ changeInRevenueForYearsAfter:year_]];
    }
    
    [self drawTableDetailRowWithHeading:LocalizedString(@"CHANGE_IN_REVENUE", nil) andValues:values];
}

- (void)drawChangeInCOGSRowInRect:(CGRect)rect
{    
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:14];
    
    for (uint i = 0; i < themesToRender_.count; i++) {
        [values addObject:[calculationStrategy_ changeInCOGSForThemeNumber:themeStartIndex_ + i year:year_]];
    }
    
    if (pageNumber_ == nthYearPageNumber_) {
        [values addObject:[calculationStrategy_ changeInCOGSForYear:year_]];
    } 

    if (pageNumber_ == subsYearsPageNumber_) {
        [values addObject:[calculationStrategy_ changeInCOGSForYearsAfter:year_]];
    }
    
    [self drawTableDetailRowWithHeading:LocalizedString(@"CHANGE_IN_COGS", nil) andValues:values];
    
    // draw the horizontal line under the change in cost of goods sold row...
    yPosition_ += 5.f;
    [AbstractReportDelegate drawHorizontalLineAtPoint:CGPointMake(valuesSectionStartX_, yPosition_) width:valuesSectionWidth_ thickness:1.f color:lineColor_];    
    yPosition_ += 1.f;
}

- (void)drawTotalChangeInGrossMarginRowInRect:(CGRect)rect
{    
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:14];
    
    for (uint i = 0; i < themesToRender_.count; i++) {
        [values addObject:[calculationStrategy_ changeInGrossMarginForThemeNumber:themeStartIndex_ + i year:year_]];
    }
    
    if (pageNumber_ == nthYearPageNumber_) {
        [values addObject:[calculationStrategy_ totalChangeInGrossMarginForYear:year_]];
    }
    
    if (pageNumber_ == subsYearsPageNumber_) {
        [values addObject:[calculationStrategy_ totalChangeInGrossMarginForYearsAfter:year_]];
    }
    
    [self drawTableDetailRowWithHeading:LocalizedString(@"TOTAL_CHANGE_IN_GROSS_PROFIT", nil) andValues:values];
}


- (void)drawExpensesRowInRect:(CGRect)rect
{
    // add a top margin to this row...
    CGFloat marginTop = 20.f;
    yPosition_ += marginTop;
    
    UIFont *headingFont = [UIFont fontWithName:boldFontName_ size:fontSize_];
    CGRect headingRect = CGRectMake(rowHeadingSectionStartX_, yPosition_, rowHeadingSectionWidth_, 11.f);
    [AbstractReportDelegate drawWrappedLabelWithText:[LocalizedString(@"EXPENSES", nil) uppercaseString] inRect:headingRect withFont:headingFont color:fontColor_ alignment:UITextAlignmentLeft];
    
    yPosition_ += headingRect.size.height;
}

- (void)drawChangeInRadRowInRect:(CGRect)rect
{    
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:14];
    
    for (uint i = 0; i < themesToRender_.count; i++) {
        [values addObject:[calculationStrategy_ changeInRadForThemeNumber:themeStartIndex_ + i year:year_]];
    }
    
    if (pageNumber_ == nthYearPageNumber_) {
        [values addObject:[calculationStrategy_ changeInRadForYear:year_]];
    }
    
    if (pageNumber_ == subsYearsPageNumber_) {
        [values addObject:[calculationStrategy_ changeInRadForYearsAfter:year_]];
    }
    
    [self drawTableDetailRowWithHeading:LocalizedString(@"CHANGE_IN_RAD", nil) andValues:values];
}

- (void)drawChangeInGaaRowInRect:(CGRect)rect
{    
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:14];
    
    for (uint i = 0; i < themesToRender_.count; i++) {
        [values addObject:[calculationStrategy_ changeInGaaForThemeNumber:themeStartIndex_ + i year:year_]];
    }
    
    if (pageNumber_ == nthYearPageNumber_) {
        [values addObject:[calculationStrategy_ changeInGaaForYear:year_]];
    }
    
    if (pageNumber_ == subsYearsPageNumber_) {
        [values addObject:[calculationStrategy_ changeInGaaForYearsAfter:year_]];
    }
    
    [self drawTableDetailRowWithHeading:LocalizedString(@"CHANGE_IN_GAA", nil) andValues:values];    
}

- (void)drawChangeInSamRowInRect:(CGRect)rect
{
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:14];
    
    for (uint i = 0; i < themesToRender_.count; i++) {
        [values addObject:[calculationStrategy_ changeInSamForThemeNumber:themeStartIndex_ + i year:year_]];
    }
    
    if (pageNumber_ == nthYearPageNumber_) {
        [values addObject:[calculationStrategy_ changeInSamForYear:year_]];
    }
    
    if (pageNumber_ == subsYearsPageNumber_) {
        [values addObject:[calculationStrategy_ changeInSamForYearsAfter:year_]];
    }
    
    [self drawTableDetailRowWithHeading:LocalizedString(@"CHANGE_IN_SAM", nil) andValues:values];
    
    // draw the horizontal line under the change in implementation costs row...
    yPosition_ += 5.f;
    [AbstractReportDelegate drawHorizontalLineAtPoint:CGPointMake(valuesSectionStartX_, yPosition_) width:valuesSectionWidth_ thickness:1.f color:lineColor_];
    yPosition_ += 1.f;
}

- (void)drawTotalChangeInExpensesRowInRect:(CGRect)rect
{    
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:14];
    
    for (uint i = 0; i < themesToRender_.count; i++) {
        [values addObject:[calculationStrategy_ totalChangeInExpensesForThemeNumber:themeStartIndex_ + i year:year_]];
    }
    
    if (pageNumber_ == nthYearPageNumber_) {
        [values addObject:[calculationStrategy_ totalChangeInExpensesForYear:year_]];
    }
    
    if (pageNumber_ == subsYearsPageNumber_) {
        [values addObject:[calculationStrategy_ totalChangeInExpensesForYearsAfter:year_]];
    }
    
    [self drawTableDetailRowWithHeading:LocalizedString(@"TOTAL_CHANGE_IN_EXPENSES", nil) andValues:values];
    
    // draw the horizontal line under the total change in expenses row...
    yPosition_ += 5.f;
    [AbstractReportDelegate drawHorizontalLineAtPoint:CGPointMake(valuesSectionStartX_, yPosition_) width:valuesSectionWidth_ thickness:1.f color:lineColor_];    
    yPosition_ += 1.f;
}


- (void)drawTotalForStrategyRowInRect:(CGRect)rect
{
    // add a top margin to this row...
    CGFloat marginTop = 20.f;
    yPosition_ += marginTop;
    
    UIFont *headingFont = [UIFont fontWithName:boldFontName_ size:fontSize_];
    CGRect headingRect = CGRectMake(rowHeadingSectionStartX_, yPosition_, rowHeadingSectionWidth_, 22.f);
    [AbstractReportDelegate drawWrappedLabelWithText:[LocalizedString(@"TOTAL_FOR_STRATEGY", nil) uppercaseString] inRect:headingRect withFont:headingFont color:fontColor_ alignment:UITextAlignmentLeft];
    
    yPosition_ += headingRect.size.height;
}

- (void)drawNetContributionRowInRect:(CGRect)rect
{    
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:14];
    
    for (uint i = 0; i < themesToRender_.count; i++) {
        [values addObject:[calculationStrategy_ netContributionForThemeNumber:themeStartIndex_ + i year:year_]];
    }
    
    if (pageNumber_ == nthYearPageNumber_) {
        [values addObject:[calculationStrategy_ netContributionForYear:year_]];
    }
    
    if (pageNumber_ == subsYearsPageNumber_) {
        [values addObject:[calculationStrategy_ netContributionForYearsAfter:year_]];
    }
    
    [self drawTableDetailRowWithHeading:LocalizedString(@"NET_CONTRIBUTION", nil) andValues:values];
}

- (void)drawNetCumulativeRowInRect:(CGRect)rect
{    
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:14];
    
    for (uint i = 0; i < themesToRender_.count; i++) {
        [values addObject:[calculationStrategy_ netCumulativeForThemeNumber:themeStartIndex_ + i year:year_]];
    }
    
    if (pageNumber_ == nthYearPageNumber_) {
        [values addObject:[calculationStrategy_ netCumulativeForYear:year_]];
    }
    
    if (pageNumber_ == subsYearsPageNumber_) {
        [values addObject:[calculationStrategy_ netCumulativeForYearsAfter:year_]];
    }
    
    [self drawTableDetailRowWithHeading:LocalizedString(@"NET_CUMULATIVE_CONTRIBUTION", nil) andValues:values];
    
    // draw the two horizontal lines under the net cumulative row...
    yPosition_ += 5.f;
    [AbstractReportDelegate drawHorizontalLineAtPoint:CGPointMake(valuesSectionStartX_, yPosition_) width:valuesSectionWidth_ thickness:1.f color:lineColor_];    
    yPosition_ += 2.f;
    [AbstractReportDelegate drawHorizontalLineAtPoint:CGPointMake(valuesSectionStartX_, yPosition_) width:valuesSectionWidth_ thickness:1.f color:lineColor_];    
    yPosition_ += 1.f;
}


- (void)drawTableDetailRowWithHeading:(NSString*)heading andValues:(NSArray*)values
{
    CGFloat marginTop = 5.f;
    yPosition_ += marginTop;
    
    NSString *rowHeading = heading;
    UIFont *rowHeadingFont = [UIFont fontWithName:boldFontName_ size:fontSize_];
    CGSize sizeThatFits = [rowHeading sizeWithFont:rowHeadingFont constrainedToSize:CGSizeMake(rowHeadingSectionWidth_, 100) lineBreakMode:UILineBreakModeWordWrap];
    CGFloat rowHeight = sizeThatFits.height;    
    
    CGRect rowHeadingRect = CGRectMake(rowHeadingSectionStartX_, yPosition_, rowHeadingSectionWidth_, rowHeight);
    [AbstractReportDelegate drawWrappedLabelWithText:rowHeading inRect:rowHeadingRect withFont:rowHeadingFont color:fontColor_ alignment:UITextAlignmentLeft];
    
    UIFont *valueFont = [UIFont fontWithName:fontName_ size:fontSize_];
    CGRect valueRect;
    uint i = 0;
    for (NSNumber *value in values) {
        
        valueRect = CGRectMake(valuesSectionStartX_ + valueColumnWidth_ * i + valueHorizontalPadding_, 
                               yPosition_, 
                               valueColumnWidth_ - 2*valueHorizontalPadding_, 
                               rowHeight);    
        
        [AbstractReportDelegate drawLabelWithText:[value formattedNumberForReports]
                              inRect:valueRect 
                            withFont:valueFont 
                               color:fontColor_ 
                 horizontalAlignment:UITextAlignmentRight 
                andVerticalAlignment:VerticalTextAlignmentBottom];                          
        i++;
    } 
    
    yPosition_ += rowHeight;
}

@end
