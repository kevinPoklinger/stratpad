//
//  BusinessPlanReport.m
//  StratPad
//
//  Created by Julian Wood on 9/15/11.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "BusinessPlanReport.h"
#import "StratFileManager.h"
#import "NSDate-StratPad.h"
#import "NSCalendar+Expanded.h"
#import "SinglePageReportBuilder.h"
#import "MultiPageReportBuilder.h"
#import "MBDrawableLabel.h"
#import "GanttChartBuilder.h"
#import "ReachTheseGoalsChartBuilder.h"
#import "AllowingUsToProgressDataSource.h"
#import "UIColor-Expanded.h"
#import "MBDrawableReportHeader.h"
#import "ReportPrintFonts.h"
#import "MBReportHeader.h"
#import "SkinManager.h"


@interface BusinessPlanReport ()

// the bottom margin to use between sections and paragraphs.
@property(nonatomic,assign) CGFloat sectionMarginBottom;

// the margin between a heading and the text
@property(nonatomic,assign) CGFloat headingMarginBottom;


@end

@implementation BusinessPlanReport

- (id)init
{
    if ((self = [super init])) {
        hasMorePages_ = YES;        
    }
    return self;
}


#pragma mark - Memory Management

-(void)dealloc
{
    [pagedDrawables_ release];

    [_businessPlanSkin release];
    
    [_sectionAContent release];
    [_sectionBContent release];
    
    [super dealloc];
}


#pragma mark - Overrides

- (NSString*)reportTitle
{
    return LocalizedString(@"R9_REPORT_TITLE", nil);
}


#pragma mark - ScreenReportDelegate

- (CGFloat)heightToDisplayContentForBounds:(CGRect)viewBounds
{
    CGRect screenInsetRect = CGRectMake(viewBounds.origin.x + screenInsets_.left, 
                                        viewBounds.origin.y + screenInsets_.top, 
                                        viewBounds.size.width - screenInsets_.left - screenInsets_.right, 
                                        viewBounds.size.height - screenInsets_.top - screenInsets_.bottom);
    
    // determine drawables, so that we can determine height
    if (!pagedDrawables_) {
        // we only need to perform the layout once
        SkinManager *skinMan = [SkinManager sharedManager];
        
        // define the table font sizes and layout percentages for screen.
        BusinessPlanSkin *skin = [[BusinessPlanSkin alloc] init];
        skin.fontName = [skinMan stringForProperty:kSkinSection3FontName];
        skin.boldFontName = [skinMan stringForProperty:kSkinSection3BoldFontName];
        skin.obliqueFontName = [skinMan stringForProperty:kSkinSection3ItalicFontName];
        skin.fontSize = [skinMan fontSizeForProperty:kSkinSection3FontSize];
        skin.chartFontSize = [skinMan fontSizeForProperty:kSkinSection3FontSize];
        skin.chartHeadingFontColor = [skinMan colorForProperty:kSkinSection3ChartHeadingFontColor];
        skin.chartFontColor = [skinMan colorForProperty:kSkinSection3ChartFontColor];
        skin.textFontColor = [skinMan colorForProperty:kSkinSection3FontColor];
        skin.sectionHeadingFontColor = [skinMan colorForProperty:kSkinSection3SectionHeadingFontColor];
        skin.lineColor = [skinMan colorForProperty:kSkinSection3ChartLineColor];
        skin.alternatingRowColor = [skinMan colorForProperty:kSkinSection3ChartAlternatingRowColor];
        skin.largeArrowColor = [skinMan colorForProperty:kSkinSection3LargeArrowColor];
        skin.smallArrowColor = [skinMan colorForProperty:kSkinSection3SmallArrowColor];
        skin.diamondColor = [skinMan colorForProperty:kSkinSection3DiamondColor];
        self.businessPlanSkin = skin;
        [skin release];
                
        _sectionMarginBottom = 30.f;
        _headingMarginBottom = 10.f;
        
        SinglePageReportBuilder *pageBuilder = [[SinglePageReportBuilder alloc] initWithPageRect:screenInsetRect];

        MBReportHeader *reportHeader = [[MBReportHeader alloc] initWithRect:viewBounds textInsetLeft:screenInsets_.left andReportTitle:[self reportTitle]];
        reportHeader.headerImageName = [skinMan stringForProperty:kSkinSection3HeaderImage];
        reportHeader.reportTitleFontName = _businessPlanSkin.boldFontName;
        reportHeader.reportTitleFontSize = [skinMan fontSizeForProperty:kSkinSection3ReportTitleFontSize];
        reportHeader.reportTitleFontColor = [skinMan colorForProperty:kSkinSection3ReportTitleFontColor];        
        [reportHeader addTitleItemWithText:LocalizedString(@"PROPRIETARY_AND_CONFIDENTIAL", nil)
                                      font:[skinMan fontWithName:_businessPlanSkin.obliqueFontName andSize:kSkinSection3ReportSubTitleFontSize]
                                  andColor:[skinMan colorForProperty:kSkinSection3ReportSubTitleFontColor]];
        [reportHeader sizeToFit];
        
        CGFloat headerHeight = [reportHeader rect].size.height;        
        [pageBuilder addDrawable:reportHeader];
        [reportHeader release];
        
        CGFloat contentRectTopMargin = 10.f;
        CGRect contentRect = CGRectMake(screenInsetRect.origin.x, screenInsetRect.origin.y + headerHeight + contentRectTopMargin, screenInsetRect.size.width, screenInsetRect.size.height - headerHeight - contentRectTopMargin);    
        
        [self layoutDrawablesInContentRect:contentRect withPageBuilder:pageBuilder];
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
        SkinManager *skinMan = [SkinManager sharedManager];
        BusinessPlanSkin *skin = [[BusinessPlanSkin alloc] init];
        skin.fontName = [skinMan stringForProperty:kSkinSection3FontName forMediaType:MediaTypePrint];
        skin.boldFontName = [skinMan stringForProperty:kSkinSection3BoldFontName forMediaType:MediaTypePrint];
        skin.obliqueFontName = [skinMan stringForProperty:kSkinSection3ItalicFontName forMediaType:MediaTypePrint];
        skin.fontSize = [skinMan fontSizeForProperty:kSkinSection3FontSize forMediaType:MediaTypePrint];
        skin.chartFontSize = 7.5f;
        skin.chartHeadingFontColor = [skinMan colorForProperty:kSkinSection3ChartHeadingFontColor forMediaType:MediaTypePrint];
        skin.chartFontColor = [skinMan colorForProperty:kSkinSection3ChartFontColor forMediaType:MediaTypePrint];
        skin.textFontColor = [skinMan colorForProperty:kSkinSection3FontColor forMediaType:MediaTypePrint];
        skin.sectionHeadingFontColor = [skinMan colorForProperty:kSkinSection3SectionHeadingFontColor forMediaType:MediaTypePrint];
        skin.lineColor = [skinMan colorForProperty:kSkinSection3ChartLineColor forMediaType:MediaTypePrint];
        skin.alternatingRowColor = [skinMan colorForProperty:kSkinSection3ChartAlternatingRowColor forMediaType:MediaTypePrint];
        skin.largeArrowColor = [skinMan colorForProperty:kSkinSection3LargeArrowColor forMediaType:MediaTypePrint];
        skin.smallArrowColor = [skinMan colorForProperty:kSkinSection3SmallArrowColor forMediaType:MediaTypePrint];
        skin.diamondColor = [skinMan colorForProperty:kSkinSection3DiamondColor forMediaType:MediaTypePrint];
        self.businessPlanSkin = skin;
        [skin release];
        
        _sectionMarginBottom = 20.f;
        _headingMarginBottom = 10.f;
        
        MultiPageReportBuilder *pageBuilder = [[MultiPageReportBuilder alloc] initWithPageRect:printInsetRect];
        pageBuilder.mediaType = MediaTypePrint;

        MBDrawableReportHeader *reportHeader = [[MBDrawableReportHeader alloc] initWithRect:headerRect textInsetLeft:headerLeftShift andReportTitle:[self reportTitle]];
        [reportHeader addTitleItemWithText:[self companyName] font:[UIFont fontWithName:_businessPlanSkin.boldFontName size:reportHeaderSubTitleFontSizeForPrint] andColor:reportHeaderFontColorForPrint];
        [reportHeader addTitleItemWithText:[self stratFileName] font:[UIFont fontWithName:_businessPlanSkin.fontName size:reportHeaderSubTitleFontSizeForPrint] andColor:reportHeaderFontColorForPrint];
        [reportHeader addTitleItemWithText:[[NSDate date] formattedDate2] font:[UIFont fontWithName:_businessPlanSkin.obliqueFontName size:reportHeaderSubTitleFontSizeForPrint] andColor:reportHeaderFontColorForPrint];
        [reportHeader addTitleItemWithText:LocalizedString(@"PROPRIETARY_AND_CONFIDENTIAL", nil) font:[UIFont fontWithName:_businessPlanSkin.obliqueFontName size:reportHeaderSubTitleFontSizeForPrint] andColor:reportHeaderFontColorForPrint];
        [reportHeader sizeToFit];
        
        CGFloat headerHeight = reportHeader.rect.size.height;        
        [pageBuilder addDrawable:reportHeader];    
        [reportHeader release];
        
        CGFloat contentRectTopMargin = 20.f;
        CGRect contentRect = CGRectMake(printInsetRect.origin.x, printInsetRect.origin.y + headerHeight + contentRectTopMargin, printInsetRect.size.width, printInsetRect.size.height - headerHeight - contentRectTopMargin);    

        [self layoutDrawablesInContentRect:contentRect withPageBuilder:pageBuilder];
        pagedDrawables_ = [[pageBuilder build] retain];
        [pageBuilder release];
    }
    
    NSArray *drawablesForPage = [pagedDrawables_ objectAtIndex:pageIndex];    
    for (id<Drawable> drawable in drawablesForPage) {
        DLog(@"page: %i, rect: %@", pageIndex, NSStringFromCGRect(drawable.rect));
        [drawable draw];
    }
    
    hasMorePages_ = !(pageIndex == pagedDrawables_.count - 1);
}


#pragma mark - Drawing
    
- (void)layoutDrawablesInContentRect:(CGRect)contentRect withPageBuilder:(id<ReportPageBuilder>)pageBuilder
{    
    yPosition_ = contentRect.origin.y;
    
    contentStartX_ = contentRect.origin.x;
    contentWidth_ = 1.0f * contentRect.size.width;
    
    [self layoutDrawablesForSectionAInRect:contentRect withPageBuilder:pageBuilder];
    [self layoutDrawablesForSectionBInRect:contentRect withPageBuilder:pageBuilder];
    [self layoutDrawablesForSectionCInRect:contentRect withPageBuilder:pageBuilder];
    [self layoutDrawablesForSectionDInRect:contentRect withPageBuilder:pageBuilder];
    [self layoutDrawablesForSectionEInRect:contentRect withPageBuilder:pageBuilder];
    [self layoutDrawablesForFooterInRect:contentRect withPageBuilder:pageBuilder];
}

- (void)layoutDrawablesForSectionAInRect:(CGRect)rect withPageBuilder:(id<ReportPageBuilder>)pageBuilder
{
    MBDrawableLabel *sectionAHeading = [[MBDrawableLabel alloc] initWithText:LocalizedString(@"R9_SECTION_A_HEADING", nil)
                                                                        font:[UIFont fontWithName:_businessPlanSkin.boldFontName size:_businessPlanSkin.fontSize]
                                                                       color:_businessPlanSkin.sectionHeadingFontColor
                                                               lineBreakMode:UILineBreakModeWordWrap
                                                                   alignment:UITextAlignmentLeft
                                                                     andRect:CGRectMake(contentStartX_, yPosition_, contentWidth_, 999)];
    [sectionAHeading sizeToFit];
    [pageBuilder addDrawable:sectionAHeading];
    [sectionAHeading release];

    yPosition_ += sectionAHeading.rect.size.height;
    yPosition_ += _headingMarginBottom;

    MBDrawableLabel *lblSectionAContent = [[MBDrawableLabel alloc] initWithText:_sectionAContent
                                                                        font:[UIFont fontWithName:_businessPlanSkin.fontName size:_businessPlanSkin.fontSize]
                                                                       color:_businessPlanSkin.textFontColor
                                                               lineBreakMode:UILineBreakModeWordWrap
                                                                   alignment:UITextAlignmentLeft
                                                                     andRect:CGRectMake(contentStartX_, yPosition_, contentWidth_, 9999)];
    [lblSectionAContent sizeToFit];
    [pageBuilder addDrawable:lblSectionAContent];
    [lblSectionAContent release];
    yPosition_ += lblSectionAContent.rect.size.height;
    yPosition_ += _sectionMarginBottom;
}

- (void)layoutDrawablesForSectionBInRect:(CGRect)rect withPageBuilder:(id<ReportPageBuilder>)pageBuilder
{
    // Layout Section B
    MBDrawableLabel *sectionBHeading = [[MBDrawableLabel alloc] initWithText:LocalizedString(@"R9_SECTION_B_HEADING", nil)
                                                                        font:[UIFont fontWithName:_businessPlanSkin.boldFontName    size:_businessPlanSkin.fontSize]
                                                                       color:_businessPlanSkin.sectionHeadingFontColor
                                                               lineBreakMode:UILineBreakModeWordWrap
                                                                   alignment:UITextAlignmentLeft
                                                                     andRect:CGRectMake(contentStartX_, yPosition_, contentWidth_, 999)];
    [sectionBHeading sizeToFit];
    [pageBuilder addDrawable:sectionBHeading];
    [sectionBHeading release];
    
    yPosition_ += sectionBHeading.rect.size.height;
    yPosition_ += _headingMarginBottom;
    
    MBDrawableLabel *lblSectionBContent = [[MBDrawableLabel alloc] initWithText:_sectionBContent
                                                                        font:[UIFont fontWithName:_businessPlanSkin.fontName size:_businessPlanSkin.fontSize]
                                                                       color:_businessPlanSkin.textFontColor
                                                               lineBreakMode:UILineBreakModeWordWrap
                                                                   alignment:UITextAlignmentLeft
                                                                     andRect:CGRectMake(contentStartX_, yPosition_, contentWidth_, 9999)];
    [lblSectionBContent sizeToFit];
    [pageBuilder addDrawable:lblSectionBContent];
    [lblSectionBContent release];
    
    yPosition_ += lblSectionBContent.rect.size.height;
    yPosition_ += _sectionMarginBottom;        
}

- (void)layoutDrawablesForSectionCInRect:(CGRect)rect withPageBuilder:(id<ReportPageBuilder>)pageBuilder
{    
    // Layout Section C
    MBDrawableLabel *sectionCHeading = [[MBDrawableLabel alloc] initWithText:LocalizedString(@"R9_SECTION_C_HEADING", nil)
                                                                        font:[UIFont fontWithName:_businessPlanSkin.boldFontName size:_businessPlanSkin.fontSize]
                                                                       color:_businessPlanSkin.sectionHeadingFontColor
                                                               lineBreakMode:UILineBreakModeWordWrap
                                                                   alignment:UITextAlignmentLeft
                                                                     andRect:CGRectMake(contentStartX_, yPosition_, contentWidth_, 999)];
    [sectionCHeading sizeToFit];
    [pageBuilder addDrawable:sectionCHeading];
    [sectionCHeading release];
    
    yPosition_ += sectionCHeading.rect.size.height;
    yPosition_ += _headingMarginBottom;
        
    CGRect ganttRect = CGRectMake(contentStartX_, yPosition_, contentWidth_, 9999);
    MBDrawableGanttChart *ganttChart = [self ganttChart:ganttRect];
    [pageBuilder addDrawable:ganttChart];

    yPosition_ += ganttChart.rect.size.height;
    yPosition_ += _sectionMarginBottom;    
}

- (MBDrawableGanttChart*)ganttChart:(CGRect)rect
{
    StratFile *stratFile = [[StratFileManager sharedManager] currentStratFile];

    GanttChartBuilder *ganttBuilder = [[GanttChartBuilder alloc] init];
    ganttBuilder.fontSize = _businessPlanSkin.chartFontSize;
    ganttBuilder.fontName = _businessPlanSkin.fontName;
    ganttBuilder.boldFontName = _businessPlanSkin.boldFontName;
    ganttBuilder.obliqueFontName = _businessPlanSkin.obliqueFontName;
    ganttBuilder.headingFontColor = _businessPlanSkin.chartHeadingFontColor;
    ganttBuilder.fontColor = _businessPlanSkin.chartFontColor;
    ganttBuilder.lineColor = _businessPlanSkin.lineColor;
    ganttBuilder.alternatingRowColor = _businessPlanSkin.alternatingRowColor;
    ganttBuilder.rect = rect;
    ganttBuilder.stratFile = stratFile;
    
    // we don't include metrics in the Gantt Chart in this report.  We do so in R6 however.
    ganttBuilder.hideMetricsRow = YES;
    
    // we want to show the metric diamond, if appropriate, in the objective row
    ganttBuilder.showMetricMilestoneForObjective = YES;
    
    // we want to hide the objective if its metrics have numeric target values and dates
    ganttBuilder.shouldFilterBlankObjectives = YES;

    MBDrawableGanttChart *ganttChart = (MBDrawableGanttChart*)[ganttBuilder build];
    [ganttBuilder release];

    return ganttChart;
}

- (void)layoutDrawablesForSectionDInRect:(CGRect)rect withPageBuilder:(id<ReportPageBuilder>)pageBuilder
{
    // Layout Section D
    MBDrawableLabel *sectionDHeading = [[MBDrawableLabel alloc] initWithText:LocalizedString(@"R9_SECTION_D_HEADING", nil)
                                                                        font:[UIFont fontWithName:_businessPlanSkin.boldFontName size:_businessPlanSkin.fontSize]
                                                                       color:_businessPlanSkin.sectionHeadingFontColor
                                                               lineBreakMode:UILineBreakModeWordWrap
                                                                   alignment:UITextAlignmentLeft
                                                                     andRect:CGRectMake(contentStartX_, yPosition_, contentWidth_, 999)];
    [sectionDHeading sizeToFit];
    [pageBuilder addDrawable:sectionDHeading];
    [sectionDHeading release];
    
    yPosition_ += sectionDHeading.rect.size.height;
    yPosition_ += _headingMarginBottom;
        
    CGRect chartRect = CGRectMake(contentStartX_, yPosition_, contentWidth_, 9999);
    ReachTheseGoalsChart *reachTheseGoalsChart = [self reachTheseGoalsChart:chartRect];
    [pageBuilder addDrawable:reachTheseGoalsChart];
    
    yPosition_ += reachTheseGoalsChart.rect.size.height;
    yPosition_ += _sectionMarginBottom;    
}

-(ReachTheseGoalsChart*)reachTheseGoalsChart:(CGRect)rect
{
    ReachTheseGoalsChartBuilder *chartBuilder = [[ReachTheseGoalsChartBuilder alloc] init];
    chartBuilder.fontName = _businessPlanSkin.fontName;
    chartBuilder.boldFontName = _businessPlanSkin.boldFontName;
    chartBuilder.fontSize = _businessPlanSkin.chartFontSize;
    chartBuilder.headingFontColor = _businessPlanSkin.chartHeadingFontColor;
    chartBuilder.fontColor = _businessPlanSkin.chartFontColor;
    chartBuilder.lineColor = _businessPlanSkin.lineColor;
    chartBuilder.alternatingRowColor = _businessPlanSkin.alternatingRowColor;
    chartBuilder.diamondColor = _businessPlanSkin.diamondColor;
    chartBuilder.rect = rect;
    chartBuilder.stratFile = [[StratFileManager sharedManager] currentStratFile];
    ReachTheseGoalsChart *reachTheseGoalsChart = [chartBuilder build];
    [chartBuilder release];
    
    return reachTheseGoalsChart;
}

- (void)layoutDrawablesForSectionEInRect:(CGRect)rect withPageBuilder:(id<ReportPageBuilder>)pageBuilder
{
    // Layout Section E
    MBDrawableLabel *sectionEHeading = [[MBDrawableLabel alloc] initWithText:LocalizedString(@"R9_SECTION_E_HEADING", nil)
                                                                        font:[UIFont fontWithName:_businessPlanSkin.boldFontName size:_businessPlanSkin.fontSize]
                                                                       color:sectionHeadingFontColorForPrint
                                                               lineBreakMode:UILineBreakModeWordWrap
                                                                   alignment:UITextAlignmentLeft andRect:CGRectMake(contentStartX_, yPosition_, contentWidth_, 999)];
    [sectionEHeading sizeToFit];
    [pageBuilder addDrawable:sectionEHeading];
    [sectionEHeading release];
    
    yPosition_ += sectionEHeading.rect.size.height;
    yPosition_ += _headingMarginBottom;
 
    CGRect chartRect = CGRectMake(contentStartX_, yPosition_, contentWidth_, 9999);
    AllowingUsToProgressChart *allowingUsToProgressChart = [self allowingUsToProgressChart:chartRect];
    [pageBuilder addDrawable:allowingUsToProgressChart];
    
    yPosition_ += allowingUsToProgressChart.rect.size.height;
    yPosition_ += _sectionMarginBottom;    
}

-(AllowingUsToProgressChart*)allowingUsToProgressChart:(CGRect)rect
{
    UIFont *font = [UIFont fontWithName:_businessPlanSkin.fontName size:_businessPlanSkin.chartFontSize];
    UIFont *boldFont = [UIFont fontWithName:_businessPlanSkin.boldFontName size:_businessPlanSkin.chartFontSize];
    
    AllowingUsToProgressDataSource *dataSource = [[AllowingUsToProgressDataSource alloc] initWithStratFile:[[StratFileManager sharedManager] currentStratFile]];
    AllowingUsToProgressChart *allowingUsToProgressChart = [[AllowingUsToProgressChart alloc]
                                                            initWithRect:rect
                                                            font:font
                                                            boldFont:boldFont
                                                            andAllowingUsToProgressDataSource:dataSource];
    [dataSource release];
    allowingUsToProgressChart.headingFontColor = _businessPlanSkin.chartHeadingFontColor;
    allowingUsToProgressChart.fontColor = _businessPlanSkin.chartFontColor;
    allowingUsToProgressChart.lineColor = _businessPlanSkin.lineColor;
    allowingUsToProgressChart.alternatingRowColor = _businessPlanSkin.alternatingRowColor;
    [allowingUsToProgressChart sizeToFit];
    return [allowingUsToProgressChart autorelease];
}

- (void)layoutDrawablesForFooterInRect:(CGRect)rect withPageBuilder:(id<ReportPageBuilder>)pageBuilder
{
    // draw copyright
    CGRect footerRect = CGRectMake(rect.origin.x, yPosition_, rect.size.width, 21.f);        
    MBDrawableLabel *lblFooter = [[MBDrawableLabel alloc] initWithText:[self footerText] 
                                                                  font:[UIFont fontWithName:_businessPlanSkin.fontName size:_businessPlanSkin.fontSize]
                                                                 color:_businessPlanSkin.textFontColor
                                                         lineBreakMode:UILineBreakModeWordWrap 
                                                             alignment:UITextAlignmentCenter 
                                                               andRect:footerRect];    
    // center the footer label horizontally
    [lblFooter sizeToFit];
    lblFooter.rect = CGRectMake(rect.origin.x + (rect.size.width - lblFooter.rect.size.width)/2, 
                                lblFooter.rect.origin.y, 
                                lblFooter.rect.size.width, 
                                lblFooter.rect.size.height);
    [pageBuilder addDrawable:lblFooter];
    [lblFooter release];
    yPosition_ += lblFooter.rect.size.height;
}

- (NSString*)footerText
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];        
    [formatter setDateFormat:@"yyyy"];
    NSString *year = [formatter stringFromDate:[NSDate date]];
    [formatter release];
    
    NSString *companyName = [self companyName] == nil ? [NSString stringWithFormat:@"[%@]", LocalizedString(@"COMPANY_NAME", nil)] : [self companyName];
  
    NSString *copyrightText = [NSString stringWithFormat:LocalizedString(@"R9_COPYRIGHT_TEMPLATE", nil), year, companyName];
    
    // if the copyright text doesn't end with a period, then ensure we add one before continuing.
    if (![copyrightText hasSuffix:@"."]) {
        copyrightText = [copyrightText stringByAppendingString:@"."];
    }
    
    return [NSString stringWithFormat:@"%@ %@", copyrightText, LocalizedString(@"R9_ALL_RIGHTS_RESERVED", nil)];
}

@end
