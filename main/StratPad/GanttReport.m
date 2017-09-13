//
//  GanttReport.m
//  StratPad
//
//  Created by Eric Rogers on September 16, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "GanttReport.h"
#import "GanttChartBuilder.h"
#import "SinglePageReportBuilder.h"
#import "MultiPageReportBuilder.h"
#import "MBDrawableReportHeader.h"
#import "NSDate-StratPad.h"
#import "ReportPrintFonts.h"
#import "MBReportHeader.h"

@interface GanttReport (Private)
- (void)addGanttChartInContentRect:(CGRect)contentRect andPageBuilder:(id<ReportPageBuilder>)pageBuilder;
@end


@implementation GanttReport

- (id)initWithStratFile:(StratFile*)stratFile
{
    if ((self = [super init])) {
        stratFile_ = [stratFile retain];
        hasMorePages_ = YES;
    }
    return self;
}


#pragma mark - Memory Management

- (void)dealloc
{
    [stratFile_ release];
    [pagedDrawables_ release];
    [lineColor_ release];
    [headingFontColor_ release];
    [fontColor_ release];
    [alternatingRowColor_ release];
    [super dealloc];
}


#pragma mark - Overrides

- (NSString*)reportTitle
{
    return LocalizedString(@"GANTT", nil);
}


#pragma mark - ScreenReportDelegate

- (CGFloat)heightToDisplayContentForBounds:(CGRect)viewBounds
{
    CGRect screenInsetRect = CGRectMake(viewBounds.origin.x + screenInsets_.left, 
                                        viewBounds.origin.y + screenInsets_.top, 
                                        viewBounds.size.width - screenInsets_.left - screenInsets_.right, 
                                        viewBounds.size.height - screenInsets_.top - screenInsets_.bottom);
    
    if (!pagedDrawables_) {
        SkinManager *skinMan = [SkinManager sharedManager];
        
        // define the table font sizes and layout percentages for screen.        
        fontName_ = [skinMan stringForProperty:kSkinSection3FontName forMediaType:MediaTypeScreen];
        boldFontName_ = [skinMan stringForProperty:kSkinSection3BoldFontName forMediaType:MediaTypeScreen];
        obliqueFontName_ = [skinMan stringForProperty:kSkinSection3ItalicFontName forMediaType:MediaTypeScreen];
        fontSize_ = [skinMan fontSizeForProperty:kSkinSection3FinancialAnalysisFontSize forMediaType:MediaTypeScreen];
        headingFontColor_ = [[skinMan colorForProperty:kSkinSection3ChartHeadingFontColor forMediaType:MediaTypeScreen] retain];
        fontColor_ = [[skinMan colorForProperty:kSkinSection3ChartFontColor forMediaType:MediaTypeScreen] retain];
        lineColor_ = [[skinMan colorForProperty:kSkinSection3ChartLineColor forMediaType:MediaTypeScreen] retain];
        alternatingRowColor_ = [[skinMan colorForProperty:kSkinSection3ChartAlternatingRowColor forMediaType:MediaTypeScreen] retain];

        // we only need to perform the layout once
        SinglePageReportBuilder *pageBuilder = [[SinglePageReportBuilder alloc] initWithPageRect:screenInsetRect];
        pageBuilder.mediaType = MediaTypeScreen;
        
        MBReportHeader *reportHeader = [[MBReportHeader alloc] initWithRect:viewBounds textInsetLeft:screenInsets_.left andReportTitle:[self reportTitle]];
        reportHeader.headerImageName = [skinMan stringForProperty:kSkinSection3HeaderImage forMediaType:MediaTypeScreen];
        reportHeader.reportTitleFontName = boldFontName_;
        reportHeader.reportTitleFontSize = [skinMan fontSizeForProperty:kSkinSection3ReportTitleFontSize forMediaType:MediaTypeScreen];
        reportHeader.reportTitleFontColor = [skinMan colorForProperty:kSkinSection3ReportTitleFontColor forMediaType:MediaTypeScreen];
        [reportHeader sizeToFit];
        
        CGFloat headerHeight = [reportHeader rect].size.height;        
        [pageBuilder addDrawable:reportHeader];
        [reportHeader release];
        
        CGFloat contentRectTopMargin = 10.f;
        CGRect contentRect = CGRectMake(screenInsetRect.origin.x, headerHeight + contentRectTopMargin, screenInsetRect.size.width, screenInsetRect.size.height - headerHeight - contentRectTopMargin);    

        [self addGanttChartInContentRect:contentRect andPageBuilder:pageBuilder];
        pagedDrawables_ = [[pageBuilder build] retain];
        [pageBuilder release];
    }
    
    CGFloat height = 0;
    CGRect drawableRect;
    
    // should only be a single page of drawables
    NSArray *drawables = [pagedDrawables_ objectAtIndex:0];
    
    for (id<Drawable> drawable in drawables) {
        drawableRect = drawable.rect;
        
        if (drawableRect.origin.y + drawableRect.size.height > height) {
            height = drawableRect.origin.y + drawableRect.size.height;
        }
    }
    
    return screenInsets_.top + height + screenInsets_.bottom;
}

- (void)drawRect:(CGRect)rect
{    
    // should only be a single page of drawables
    NSArray *drawables = [pagedDrawables_ objectAtIndex:0];
    
    for (id<Drawable> drawable in drawables) {
        [drawable draw];
    }
}


#pragma mark - PrintReportDelegate

- (BOOL)hasMorePages
{
    return hasMorePages_;
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

    if (!pagedDrawables_) {
        // we only need to perform the layout once
        fontName_ = fontNameForPrint;
        boldFontName_ = boldFontNameForPrint;
        obliqueFontName_ = obliqueFontNameForPrint;
        fontSize_ = textFontSizeForPrint;
        headingFontColor_ = [chartHeadingFontColorForPrint retain];
        fontColor_ = [chartFontColorForPrint retain];
        lineColor_ = [chartLineColorForPrint retain];
        alternatingRowColor_ = [chartAlternatingRowColorForPrint retain];


        MBDrawableReportHeader *reportHeader = [[MBDrawableReportHeader alloc] initWithRect:headerRect textInsetLeft:headerLeftShift andReportTitle:[self reportTitle]];
        [reportHeader addTitleItemWithText:[self companyName] font:[UIFont fontWithName:boldFontNameForPrint size:reportHeaderSubTitleFontSizeForPrint] andColor:reportHeaderFontColorForPrint];
        [reportHeader addTitleItemWithText:[self stratFileName] font:[UIFont fontWithName:fontNameForPrint size:reportHeaderSubTitleFontSizeForPrint] andColor:reportHeaderFontColorForPrint];
        [reportHeader addTitleItemWithText:[[NSDate date] formattedDate2] font:[UIFont fontWithName:obliqueFontNameForPrint size:reportHeaderSubTitleFontSizeForPrint] andColor:reportHeaderFontColorForPrint];
        [reportHeader sizeToFit];
 
        MultiPageReportBuilder *pageBuilder = [[MultiPageReportBuilder alloc] initWithPageRect:printInsetRect andHeader:reportHeader];
        pageBuilder.mediaType = MediaTypePrint;
        [reportHeader release];
    
        [self addGanttChartInContentRect:printInsetRect andPageBuilder:pageBuilder];
        pagedDrawables_ = [[pageBuilder build] retain];
        [pageBuilder release];
    }
    
    NSArray *drawablesForPage = [pagedDrawables_ objectAtIndex:pageIndex];    
    for (id<Drawable> drawable in drawablesForPage) {
        [drawable draw];
    }
    
    hasMorePages_ = !(pageIndex == pagedDrawables_.count - 1);
}


#pragma mark - Drawing

- (void)addGanttChartInContentRect:(CGRect)contentRect andPageBuilder:(id<ReportPageBuilder>)pageBuilder
{
    GanttChartBuilder *chartBuilder = [[GanttChartBuilder alloc] init];
    chartBuilder.fontName = fontName_;
    chartBuilder.boldFontName = boldFontName_;
    chartBuilder.obliqueFontName = obliqueFontName_;
    chartBuilder.fontSize = fontSize_;
    chartBuilder.headingFontColor = headingFontColor_;
    chartBuilder.fontColor = fontColor_;
    chartBuilder.lineColor = lineColor_;
    chartBuilder.alternatingRowColor = alternatingRowColor_;
    chartBuilder.mediaType = pageBuilder.mediaType;
    chartBuilder.rect = CGRectMake(contentRect.origin.x, contentRect.origin.y, contentRect.size.width, 9999);
    chartBuilder.stratFile = stratFile_;
    
    MBDrawableGanttChart *chart = [chartBuilder build];
    [pageBuilder addDrawable:chart];
    [chartBuilder release];
}

@end
