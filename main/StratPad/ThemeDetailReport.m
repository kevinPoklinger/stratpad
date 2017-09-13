//
//  ThemeDetailReport.m
//  StratPad
//
//  Created by Eric Rogers on September 11, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "ThemeDetailReport.h"
#import "UIColor-Expanded.h"
#import "MBDrawableLabel.h"
#import "MBDrawableHorizontalLine.h"
#import "MBDrawableTextBox.h"
#import "Objective.h"
#import "Activity.h"
#import "NSDate-StratPad.h"
#import "NSNumber-StratPad.h"
#import "SinglePageReportBuilder.h"
#import "MultiPageReportBuilder.h"
#import "MBDrawableReportHeader.h"
#import "Metric.h"
#import "ReportPrintFonts.h"
#import "ApplicationSkin.h"
#import "MBReportHeader.h"

@interface ThemeDetailReport (Private)

- (void)layoutDrawablesInContentRect:(CGRect)contentRect withPageBuilder:(id<ReportPageBuilder>)pageBuilder;
- (void)layoutColumnHeadingDrawablesInRect:(CGRect)rect withPageBuilder:(id<ReportPageBuilder>)pageBuilder;
- (void)layoutScorecardSubHeadingDrawablesWithFont:(UIFont*)font rowHeight:(CGFloat)rowHeight andPageBuilder:(id<ReportPageBuilder>)pageBuilder;
- (void)layoutActivitySubHeadingDrawablesWithFont:(UIFont*)font rowHeight:(CGFloat)rowHeight andPageBuilder:(id<ReportPageBuilder>)pageBuilder;
- (void)layoutObjectiveDrawablesInRect:(CGRect)rect withPageBuilder:(id<ReportPageBuilder>)pageBuilder;
- (void)layoutObjectiveSectionDrawablesWithObjectives:(NSArray*)objectives 
                                                title:(NSString*)title
                               renderSectionSeparator:(BOOL)renderSeparator
                                               inRect:(CGRect)rect 
                                      withPageBuilder:(id<ReportPageBuilder>)pageBuilder;                  
- (void)layoutObjectiveDrawablesWithObjectives:(NSArray*)objectives inRect:(CGRect)rect withFont:(UIFont*)font andPageBuilder:(id<ReportPageBuilder>)pageBuilder;
@end


@implementation ThemeDetailReport

@synthesize theme = theme_;
@synthesize responsibleDescription = responsibleDescription_;
@synthesize themeDescription = themeDescription_;

- (id)init
{
    if ((self = [super init])) {
        hasMorePages_ = YES;
    }
    return self;
}


#pragma mark - Memory Management

- (void)dealloc
{
    [lineColor_ release];
    [fontColor_ release];
    [headingBoxColor_ release];
    [headingBoxFontColor_ release];
    [pagedDrawables_ release];
    
    [super dealloc];
}


#pragma mark - Overrides

- (NSString*)reportTitle
{
    return LocalizedString(@"THEME_DETAIL_REPORT_TITLE", nil);
}

- (NSString*)reportSubTitle
{
    return nil;
}


#pragma mark - ScreenReportDelegate

- (CGFloat)heightToDisplayContentForBounds:(CGRect)viewBounds
{    
    CGRect screenInsetRect = CGRectMake(viewBounds.origin.x + screenInsets_.left, 
                                        viewBounds.origin.y + screenInsets_.top, 
                                        viewBounds.size.width - screenInsets_.left - screenInsets_.right, 
                                        viewBounds.size.height - screenInsets_.top - screenInsets_.bottom);
    
    ApplicationSkin *skin = [ApplicationSkin currentSkin];
    
    // define the table font sizes and layout percentages for screen.
    fontName_ = skin.section3FontName;    
    boldFontName_ = skin.section3BoldFontName;
    obliqueFontName_ = skin.section3ItalicFontName;
    fontSize_ = [skin.section3FinancialAnalysisFontSize floatValue];
    fontColor_ = [[UIColor colorWithHexString:skin.section3ChartFontColor] retain];
    sectionHeadingFontColor_ = [[UIColor colorWithHexString:skin.section3SectionHeadingFontColor] retain];
    lineColor_ = [[UIColor colorWithHexString:skin.section3ChartLineColor] retain];
    headingBoxColor_ = [[UIColor colorWithHexString:skin.section3HeadingBoxColor] retain];
    headingBoxFontColor_  = [[UIColor colorWithHexString:skin.section3HeadingBoxFontColor] retain];
    
    if (!pagedDrawables_) {
        // we only need to perform the layout once
        SinglePageReportBuilder *pageBuilder = [[SinglePageReportBuilder alloc] initWithPageRect:screenInsetRect];
        
        MBReportHeader *reportHeader = [[MBReportHeader alloc] initWithRect:viewBounds textInsetLeft:screenInsets_.left andReportTitle:[self reportTitle]];
        reportHeader.headerImageName = skin.section3HeaderImage;
        reportHeader.reportTitleFontName = boldFontName_;
        reportHeader.reportTitleFontSize = [skin.section3ReportTitleFontSize floatValue];
        reportHeader.reportTitleFontColor = [UIColor colorWithHexString:skin.section3ReportTitleFontColor];
        
        if (self.theme) {
            // only include the theme title, responsible description, and theme descriptions if we have a theme.        
            NSString *themeTitleText = [NSString stringWithFormat:@"%@: %@", LocalizedString(@"THEME", nil), theme_.title];
            
            [reportHeader addDescriptionItemWithText:themeTitleText 
                                                font:[UIFont fontWithName:boldFontName_ size:[skin.section3ReportDescriptionFontSize floatValue]] 
                                            andColor:[UIColor colorWithHexString:skin.section3ReportDescriptionFontColor]];
            
            [reportHeader addDescriptionItemWithText:self.responsibleDescription 
                                                font:[UIFont fontWithName:boldFontName_ size:[skin.section3ReportDescriptionFontSize floatValue]] 
                                            andColor:[UIColor colorWithHexString:skin.section3ReportDescriptionFontColor]];
            
            [reportHeader addDescriptionItemWithText:self.themeDescription 
                                                font:[UIFont fontWithName:boldFontName_ size:[skin.section3ReportDescriptionFontSize floatValue]] 
                                            andColor:[UIColor colorWithHexString:skin.section3ReportDescriptionFontColor]];
        }                    
        
        [reportHeader sizeToFit];
        
        CGFloat headerHeight = [reportHeader rect].size.height;        
        [pageBuilder addDrawable:reportHeader];
        [reportHeader release];
        
        CGFloat contentRectTopMargin = 10.f;
        CGRect contentRect = CGRectMake(screenInsetRect.origin.x, 
                                        screenInsetRect.origin.y + headerHeight + contentRectTopMargin, 
                                        screenInsetRect.size.width, 
                                        screenInsetRect.size.height - headerHeight - contentRectTopMargin);    
        
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
    
    // define the table font sizes and layout percentages for print.
    fontName_ = fontNameForPrint;
    boldFontName_ = boldFontNameForPrint;
    obliqueFontName_ = obliqueFontNameForPrint;
    fontSize_ = financialAnalysisFontSizeForPrint;
    fontColor_ = [chartFontColorForPrint retain];
    sectionHeadingFontColor_ = [sectionHeadingFontColorForPrint retain];
    lineColor_ = [chartLineColorForPrint retain];
    headingBoxColor_ = [themeDetailHeadingBoxColorForPrint retain];
    headingBoxFontColor_ = [themeDetailHeadingFontColorForPrint retain];
    
    if (!pagedDrawables_) {
        // we only need to perform the layout once
        fontSize_ = financialAnalysisFontSizeForPrint;
        
        MultiPageReportBuilder *pageBuilder = [[MultiPageReportBuilder alloc] initWithPageRect:printInsetRect];
        pageBuilder.mediaType = MediaTypePrint;
        
        MBDrawableReportHeader *reportHeader = [[MBDrawableReportHeader alloc] initWithRect:headerRect textInsetLeft:headerLeftShift andReportTitle:[self reportTitle]];
        [reportHeader addTitleItemWithText:[self companyName] font:[UIFont fontWithName:boldFontName_ size:reportHeaderSubTitleFontSizeForPrint] andColor:reportHeaderFontColorForPrint];
        [reportHeader addTitleItemWithText:[self stratFileName] font:[UIFont fontWithName:fontName_ size:reportHeaderSubTitleFontSizeForPrint] andColor:reportHeaderFontColorForPrint];
        [reportHeader addTitleItemWithText:[[NSDate date] formattedDate2] font:[UIFont fontWithName:obliqueFontName_ size:reportHeaderSubTitleFontSizeForPrint] andColor:reportHeaderFontColorForPrint];
        
        if (self.theme) {
            // only include the theme title, responsible description, and theme descriptions if we have a theme.        
            NSString *themeTitleText = [NSString stringWithFormat:@"%@: %@", LocalizedString(@"THEME", nil), theme_.title];
            [reportHeader addDescriptionItemWithText:themeTitleText font:[UIFont fontWithName:boldFontName_ size:reportHeaderDescriptionFontSizeForPrint] andColor:reportHeaderFontColorForPrint];
            [reportHeader addDescriptionItemWithText:self.responsibleDescription font:[UIFont fontWithName:boldFontName_ size:reportHeaderDescriptionFontSizeForPrint] andColor:reportHeaderFontColorForPrint];
            [reportHeader addDescriptionItemWithText:self.themeDescription font:[UIFont fontWithName:boldFontName_ size:reportHeaderDescriptionFontSizeForPrint] andColor:reportHeaderFontColorForPrint];            
        }                    
        
        [reportHeader sizeToFit];
        
        CGFloat headerHeight = reportHeader.rect.size.height;        
        [pageBuilder addDrawable:reportHeader];    
        [reportHeader release];
        
        CGFloat contentRectTopMargin = 20.f;
        CGRect contentRect = CGRectMake(printInsetRect.origin.x, 
                                        printInsetRect.origin.y + headerHeight + contentRectTopMargin, 
                                        printInsetRect.size.width, 
                                        printInsetRect.size.height - headerHeight - contentRectTopMargin);    
        
        [self layoutDrawablesInContentRect:contentRect withPageBuilder:pageBuilder];
        
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

- (void)layoutDrawablesInContentRect:(CGRect)contentRect withPageBuilder:(id<ReportPageBuilder>)pageBuilder
{        
    yPosition_ = contentRect.origin.y;
    
    [self layoutColumnHeadingDrawablesInRect:contentRect withPageBuilder:pageBuilder];
    
    [self layoutObjectiveDrawablesInRect:contentRect withPageBuilder:pageBuilder];    
}

- (void)layoutColumnHeadingDrawablesInRect:(CGRect)rect withPageBuilder:(id<ReportPageBuilder>)pageBuilder
{
    UIFont *headingFont = [UIFont fontWithName:boldFontName_ size:fontSize_];
    CGFloat headingRowHeight = 20.f;
    
    // add the three main column headings: OBJECTIVE, SCORECARD, and ACTIVITY
    objectiveColumnWidth_ = rect.size.width * 0.2f;
    scorecardColumnWidth_ = rect.size.width * 0.3f;
    activityColumnWidth_ = rect.size.width * 0.45f;    
    CGFloat columnSpacer = rect.size.width * 0.025f;
    
    // objectives heading box
    objectiveColumnStartX_ = rect.origin.x;
    CGRect columnHeadingRect = CGRectMake(objectiveColumnStartX_, yPosition_, objectiveColumnWidth_, headingRowHeight);    
    
    MBDrawableTextBox *boxObjectives = [[MBDrawableTextBox alloc] initWithText:[LocalizedString(@"OBJECTIVES", nil) uppercaseString]
                                                                          font:headingFont
                                                                         color:headingBoxFontColor_
                                                               backgroundColor:headingBoxColor_
                                                                       andRect:columnHeadingRect];
    [pageBuilder addDrawable:boxObjectives];
    [boxObjectives release];    
    
    
    // scorecard heading box    
    scorecardColumnStartX_ = boxObjectives.rect.origin.x + boxObjectives.rect.size.width + columnSpacer;
    columnHeadingRect = CGRectMake(scorecardColumnStartX_, yPosition_, scorecardColumnWidth_, headingRowHeight);
    
    MBDrawableTextBox *boxScorecard = [[MBDrawableTextBox alloc] initWithText:[LocalizedString(@"SCORECARD", nil) uppercaseString]
                                                                         font:headingFont
                                                                        color:headingBoxFontColor_
                                                              backgroundColor:headingBoxColor_
                                                                      andRect:columnHeadingRect];
    [pageBuilder addDrawable:boxScorecard];
    [boxScorecard release];    
    
    
    // activity heading box    
    activityColumnStartX_ = boxScorecard.rect.origin.x + boxScorecard.rect.size.width + columnSpacer;
    columnHeadingRect = CGRectMake(activityColumnStartX_, yPosition_, activityColumnWidth_, headingRowHeight);
    
    MBDrawableTextBox *boxActivity = [[MBDrawableTextBox alloc] initWithText:[LocalizedString(@"ACTIVITY", nil) uppercaseString]
                                                                        font:headingFont
                                                                       color:headingBoxFontColor_
                                                             backgroundColor:headingBoxColor_
                                                                     andRect:columnHeadingRect];
    [pageBuilder addDrawable:boxActivity];
    [boxActivity release];    
    
    yPosition_ += headingRowHeight;
    
    
    // now add the sub-headings for each column...
    UIFont *subHeadingFont = [UIFont fontWithName:boldFontName_ size:fontSize_];
    [self layoutScorecardSubHeadingDrawablesWithFont:subHeadingFont rowHeight:headingRowHeight andPageBuilder:pageBuilder];
    [self layoutActivitySubHeadingDrawablesWithFont:subHeadingFont rowHeight:headingRowHeight andPageBuilder:pageBuilder];
    yPosition_ += headingRowHeight;
    
    
    // draw a line under the sub headings.
    yPosition_ += 5.f; // add a bit of a top margin for the line...
    
    MBDrawableHorizontalLine *bottomLine = [[MBDrawableHorizontalLine alloc] initWithOrigin:CGPointMake(rect.origin.x, yPosition_) width:rect.size.width thickness:3.f andColor:lineColor_];
    [pageBuilder addDrawable:bottomLine];
    [bottomLine release];
    yPosition_ += bottomLine.rect.size.height;
}

- (void)layoutScorecardSubHeadingDrawablesWithFont:(UIFont*)font rowHeight:(CGFloat)rowHeight andPageBuilder:(id<ReportPageBuilder>)pageBuilder
{        
    CGRect scorecardSubHeadingRect = CGRectMake(scorecardColumnStartX_, yPosition_, scorecardColumnWidth_, rowHeight);
    
    // define the spacing between the sub columns in the scorecard column
    CGFloat scorecardColumnSpacer = scorecardSubHeadingRect.size.width * 0.05f;
    
    
    // measure label
    measureColumnStartX_ = scorecardSubHeadingRect.origin.x;
    measureColumnWidth_ = scorecardSubHeadingRect.size.width * 0.3f;
    NSString *measureText = LocalizedString(@"MEASURE", nil);
    
    // measure rect has a specific width, but we need to figure out how tall the text will be so we can vertically align it properly.
    CGSize sizeThatFits = [MBDrawableLabel sizeThatFits:scorecardSubHeadingRect.size withText:measureText andFont:font lineBreakMode:UILineBreakModeTailTruncation];
    CGRect measureRect = CGRectMake(measureColumnStartX_, scorecardSubHeadingRect.origin.y, measureColumnWidth_, sizeThatFits.height);
    
    MBDrawableLabel *lblMeasure = [[MBDrawableLabel alloc] initWithText:measureText
                                                                   font:font
                                                                  color:sectionHeadingFontColor_
                                                          lineBreakMode:UILineBreakModeTailTruncation 
                                                              alignment:UITextAlignmentLeft 
                                                                andRect:measureRect];
    [AbstractReportDelegate verticallyAlignDrawable:lblMeasure inRect:scorecardSubHeadingRect withAlignment:VerticalTextAlignmentMiddle];
    [pageBuilder addDrawable:lblMeasure];
    [lblMeasure release];    
    
    
    // target label
    targetColumnStartX_ = measureRect.origin.x + measureRect.size.width + scorecardColumnSpacer;
    targetColumnWidth_ = scorecardSubHeadingRect.size.width * 0.3f;
    NSString *targetText = LocalizedString(@"TARGET", nil);
    
    // target rect has a specific width, but we need to figure out how tall the text will be so we can vertically align it properly.
    sizeThatFits = [MBDrawableLabel sizeThatFits:scorecardSubHeadingRect.size withText:targetText andFont:font lineBreakMode:UILineBreakModeTailTruncation];
    CGRect targetRect = CGRectMake(targetColumnStartX_, scorecardSubHeadingRect.origin.y, targetColumnWidth_, sizeThatFits.height);
    
    MBDrawableLabel *lblTarget = [[MBDrawableLabel alloc] initWithText:targetText
                                                                  font:font
                                                                 color:sectionHeadingFontColor_ 
                                                         lineBreakMode:UILineBreakModeTailTruncation 
                                                             alignment:UITextAlignmentLeft 
                                                               andRect:targetRect];
    [AbstractReportDelegate verticallyAlignDrawable:lblTarget inRect:scorecardSubHeadingRect withAlignment:VerticalTextAlignmentMiddle];
    [pageBuilder addDrawable:lblTarget];
    [lblTarget release];    
    
    
    // date label
    dateColumnStartX_ = targetRect.origin.x + targetRect.size.width + scorecardColumnSpacer;
    dateColumnWidth_ = scorecardSubHeadingRect.size.width * 0.3f;
    NSString *dateText = LocalizedString(@"DATE", nil);
    
    // date rect has a specific width, but we need to figure out how tall the text will be so we can vertically align it properly.
    sizeThatFits = [MBDrawableLabel sizeThatFits:scorecardSubHeadingRect.size withText:dateText andFont:font lineBreakMode:UILineBreakModeTailTruncation];
    CGRect dateRect = CGRectMake(dateColumnStartX_, scorecardSubHeadingRect.origin.y, dateColumnWidth_, sizeThatFits.height);
    
    MBDrawableLabel *lblDate = [[MBDrawableLabel alloc] initWithText:dateText
                                                                font:font
                                                               color:sectionHeadingFontColor_ 
                                                       lineBreakMode:UILineBreakModeTailTruncation 
                                                           alignment:UITextAlignmentLeft 
                                                             andRect:dateRect];
    [AbstractReportDelegate verticallyAlignDrawable:lblDate inRect:scorecardSubHeadingRect withAlignment:VerticalTextAlignmentMiddle];
    [pageBuilder addDrawable:lblDate];
    [lblDate release];    
}

- (void)layoutActivitySubHeadingDrawablesWithFont:(UIFont*)font rowHeight:(CGFloat)rowHeight andPageBuilder:(id<ReportPageBuilder>)pageBuilder
{
    CGRect activitySubHeadingRect = CGRectMake(activityColumnStartX_, yPosition_, activityColumnWidth_, rowHeight);
    
    // define the spacing between the sub columns in the activity column    
    CGFloat activityColumnSpacer = activitySubHeadingRect.size.width * 0.02f;
    
    // action label
    actionColumnStartX_ = activitySubHeadingRect.origin.x;
    actionColumnWidth_ = activitySubHeadingRect.size.width * 0.3f;
    NSString *actionText = LocalizedString(@"ACTION", nil);
    
    // action rect has a specific width, but we need to figure out how tall the text will be so we can vertically align it properly.
    CGSize sizeThatFits = [MBDrawableLabel sizeThatFits:activitySubHeadingRect.size withText:actionText andFont:font lineBreakMode:UILineBreakModeTailTruncation];    
    CGRect actionRect = CGRectMake(actionColumnStartX_, activitySubHeadingRect.origin.y, actionColumnWidth_, sizeThatFits.height);
    
    MBDrawableLabel *lblAction = [[MBDrawableLabel alloc] initWithText:actionText
                                                                  font:font
                                                                 color:sectionHeadingFontColor_ 
                                                         lineBreakMode:UILineBreakModeTailTruncation 
                                                             alignment:UITextAlignmentLeft 
                                                               andRect:actionRect];
    [AbstractReportDelegate verticallyAlignDrawable:lblAction inRect:activitySubHeadingRect withAlignment:VerticalTextAlignmentMiddle];
    [pageBuilder addDrawable:lblAction];
    [lblAction release];    
    
    
    // first year cost label
    firstYearCostColumnStartX_ = actionRect.origin.x + actionRect.size.width + activityColumnSpacer;
    firstYearCostColumnWidth_ = activitySubHeadingRect.size.width * 0.3f;    
    NSString *firstYearCostText = LocalizedString(@"FIRST_YEAR_COST", nil);
    
    // first year rect has a specific width, but we need to figure out how tall the text will be so we can vertically align it properly.
    sizeThatFits = [MBDrawableLabel sizeThatFits:activitySubHeadingRect.size withText:firstYearCostText andFont:font lineBreakMode:UILineBreakModeTailTruncation];    
    CGRect firstYearCostRect = CGRectMake(firstYearCostColumnStartX_, activitySubHeadingRect.origin.y, firstYearCostColumnWidth_, sizeThatFits.height);
    
    MBDrawableLabel *lblFirstYearCost = [[MBDrawableLabel alloc] initWithText:firstYearCostText
                                                                         font:font
                                                                        color:sectionHeadingFontColor_ 
                                                                lineBreakMode:UILineBreakModeTailTruncation 
                                                                    alignment:UITextAlignmentRight 
                                                                      andRect:firstYearCostRect];
    [AbstractReportDelegate verticallyAlignDrawable:lblFirstYearCost inRect:activitySubHeadingRect withAlignment:VerticalTextAlignmentMiddle];
    [pageBuilder addDrawable:lblFirstYearCost];
    [lblFirstYearCost release];    
    
    
    // draw start label
    startDateColumnStartX_ = firstYearCostRect.origin.x + firstYearCostRect.size.width + activityColumnSpacer;
    startDateColumnWidth_ = activitySubHeadingRect.size.width * 0.17f;
    NSString *startText = LocalizedString(@"START", nil);
    
    // start rect has a specific width, but we need to figure out how tall the text will be so we can vertically align it properly.
    sizeThatFits = [MBDrawableLabel sizeThatFits:activitySubHeadingRect.size withText:startText andFont:font lineBreakMode:UILineBreakModeTailTruncation];    
    CGRect startRect = CGRectMake(startDateColumnStartX_, activitySubHeadingRect.origin.y, startDateColumnWidth_, sizeThatFits.height);
    
    MBDrawableLabel *lblStart = [[MBDrawableLabel alloc] initWithText:startText
                                                                 font:font
                                                                color:sectionHeadingFontColor_ 
                                                        lineBreakMode:UILineBreakModeTailTruncation 
                                                            alignment:UITextAlignmentLeft 
                                                              andRect:startRect];
    [AbstractReportDelegate verticallyAlignDrawable:lblStart inRect:activitySubHeadingRect withAlignment:VerticalTextAlignmentMiddle];
    [pageBuilder addDrawable:lblStart];
    [lblStart release];    
    
    // draw end date label
    endDateColumnStartX_ = startRect.origin.x + startRect.size.width + activityColumnSpacer;
    endDateColumnWidth_ = activitySubHeadingRect.size.width * 0.17f;
    NSString *endText = LocalizedString(@"END", nil);
    
    // start rect has a specific width, but we need to figure out how tall the text will be so we can vertically align it properly.
    sizeThatFits = [MBDrawableLabel sizeThatFits:activitySubHeadingRect.size withText:endText andFont:font lineBreakMode:UILineBreakModeTailTruncation];    
    CGRect endRect = CGRectMake(endDateColumnStartX_, activitySubHeadingRect.origin.y, endDateColumnWidth_, sizeThatFits.height);
    
    MBDrawableLabel *lblEnd = [[MBDrawableLabel alloc] initWithText:endText
                                                               font:font
                                                              color:sectionHeadingFontColor_ 
                                                      lineBreakMode:UILineBreakModeTailTruncation 
                                                          alignment:UITextAlignmentLeft 
                                                            andRect:endRect];
    [AbstractReportDelegate verticallyAlignDrawable:lblEnd inRect:activitySubHeadingRect withAlignment:VerticalTextAlignmentMiddle];
    [pageBuilder addDrawable:lblEnd];
    [lblEnd release];    
}


- (void)layoutObjectiveDrawablesInRect:(CGRect)rect withPageBuilder:(id<ReportPageBuilder>)pageBuilder
{           
    NSArray *objectives = [theme_.objectives allObjects];
    BOOL objectiveSectionRendered = NO;    
    
    NSArray *financialObjectives = [Theme objectivesFilteredByCategory:ObjectiveCategoryFinancial objectives:objectives];        
    [self layoutObjectiveSectionDrawablesWithObjectives:financialObjectives 
                                                  title:[LocalizedString(@"OBJECTIVE_TYPE_FINANCIAL", nil) uppercaseString] 
                                 renderSectionSeparator:NO
                                                 inRect:rect
                                        withPageBuilder:pageBuilder];
    objectiveSectionRendered = financialObjectives.count > 0;
    
    
    NSArray *customerObjectives = [Theme objectivesFilteredByCategory:ObjectiveCategoryCustomer objectives:objectives];        
    [self layoutObjectiveSectionDrawablesWithObjectives:customerObjectives 
                                                  title:[LocalizedString(@"OBJECTIVE_TYPE_CUSTOMER", nil) uppercaseString] 
                                 renderSectionSeparator:objectiveSectionRendered
                                                 inRect:rect 
                                        withPageBuilder:pageBuilder];
    objectiveSectionRendered |= customerObjectives.count > 0;
    
    
    NSArray *processObjectives = [Theme objectivesFilteredByCategory:ObjectiveCategoryProcess objectives:objectives];        
    [self layoutObjectiveSectionDrawablesWithObjectives:processObjectives 
                                                  title:[LocalizedString(@"OBJECTIVE_TYPE_PROCESS", nil) uppercaseString] 
                                 renderSectionSeparator:objectiveSectionRendered
                                                 inRect:rect 
                                        withPageBuilder:pageBuilder];
    objectiveSectionRendered |= processObjectives.count > 0;
    
    
    NSArray *staffObjectives = [Theme objectivesFilteredByCategory:ObjectiveCategoryStaff objectives:objectives];        
    [self layoutObjectiveSectionDrawablesWithObjectives:staffObjectives 
                                                  title:[LocalizedString(@"OBJECTIVE_TYPE_STAFF", nil) uppercaseString] 
                                 renderSectionSeparator:objectiveSectionRendered
                                                 inRect:rect 
                                        withPageBuilder:pageBuilder];
    
}

- (void)layoutObjectiveSectionDrawablesWithObjectives:(NSArray*)objectives 

                                                title:(NSString*)title
                               renderSectionSeparator:(BOOL)renderSeparator
                                               inRect:(CGRect)rect  
                                      withPageBuilder:pageBuilder
{
    CGFloat sectionPaddingTop = 5.f;
    CGFloat sectionPaddingBottom = 25.f;
    
    if (objectives.count > 0) {        
        if (renderSeparator) {
            MBDrawableHorizontalLine *separator = [[MBDrawableHorizontalLine alloc] initWithOrigin:CGPointMake(rect.origin.x, yPosition_ + sectionPaddingBottom) width:rect.size.width  thickness:1.f andColor:lineColor_];
            [pageBuilder addDrawable:separator];
            [separator release];
            yPosition_ += sectionPaddingBottom + separator.rect.size.height + sectionPaddingTop;
        }
        
        CGRect sectionTitleRect = CGRectMake(rect.origin.x, yPosition_, rect.size.width, 14.f);        
        
        MBDrawableLabel *lblSectionTitle = [[MBDrawableLabel alloc] initWithText:title font:[UIFont fontWithName:boldFontName_ size:fontSize_] color:fontColor_ lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentLeft andRect:sectionTitleRect];
        [pageBuilder addDrawable:lblSectionTitle];
        [lblSectionTitle release];
        
        yPosition_ += lblSectionTitle.rect.size.height;        
        
        CGRect objectivesRect = CGRectMake(rect.origin.x, yPosition_, rect.size.width, rect.size.height);        
        UIFont *objectiveFont = [UIFont fontWithName:fontName_ size:fontSize_];
        [self layoutObjectiveDrawablesWithObjectives:objectives 
                                              inRect:objectivesRect 
                                            withFont:objectiveFont
                                      andPageBuilder:pageBuilder];
    }
}

- (void)layoutObjectiveDrawablesWithObjectives:(NSArray*)objectives 
                                        inRect:(CGRect)rect 
                                      withFont:(UIFont*)font 
                                andPageBuilder:(id<ReportPageBuilder>)pageBuilder
{
    CGFloat rowSpacing = 10.f;
    CGRect detailRect;
    
    for (Objective *objective in objectives) {
        
        // we are showing objectives, metrics and activities
        // might have several metrics or activities per objective
        // their labels can also wrap
        // have to make sure the columns reflect this spacing
        // eg. the next objective description is below the level of all the metrics and activities
        
        // objective summary
        detailRect = CGRectMake(objectiveColumnStartX_, yPosition_ + rowSpacing, objectiveColumnWidth_, 0);        
        MBDrawableLabel *lblSummary = [[MBDrawableLabel alloc] initWithText:objective.summary font:font color:fontColor_ lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentLeft andRect:detailRect];
        [lblSummary sizeToFit];
        [pageBuilder addDrawable:lblSummary];
        [lblSummary release];        
        
        // increase the height of the current row to that of the label, if necessary.
        CGFloat objectiveCellHeight = lblSummary.rect.size.height;
        
        
        // metric
        CGFloat metricPositionY = yPosition_;
        for (Metric *metric in objective.metrics) {
            
            // reset
            CGFloat metricRowHeight = 0;
            
            detailRect = CGRectMake(measureColumnStartX_, metricPositionY + rowSpacing, measureColumnWidth_, 0);        
            MBDrawableLabel *lblMetric = [[MBDrawableLabel alloc] initWithText:metric.summary font:font color:fontColor_ lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentLeft andRect:detailRect];
            [lblMetric sizeToFit];
            [pageBuilder addDrawable:lblMetric];
            [lblMetric release];        
            
            // increase the height of the current row to that of the label, if necessary.
            metricRowHeight = lblMetric.rect.size.height > metricRowHeight ? lblMetric.rect.size.height : metricRowHeight;
            
            
            // target value
            detailRect = CGRectMake(targetColumnStartX_, metricPositionY + rowSpacing, targetColumnWidth_, 0); 
            
            MBDrawableLabel *lblTargetValue = [[MBDrawableLabel alloc] initWithText:metric.targetValue font:font color:fontColor_ lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentLeft andRect:detailRect];
            [lblTargetValue sizeToFit];
            [pageBuilder addDrawable:lblTargetValue];
            [lblTargetValue release];                
            
            // increase the height of the current row to that of the label, if necessary.
            metricRowHeight = lblTargetValue.rect.size.height > metricRowHeight ? lblTargetValue.rect.size.height : metricRowHeight;
            
            
            // target date
            detailRect = CGRectMake(dateColumnStartX_, metricPositionY + rowSpacing, dateColumnWidth_, 0);
            MBDrawableLabel *lblTargetDate = [[MBDrawableLabel alloc] initWithText:[metric.targetDate formattedDate1] font:font color:fontColor_ lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentLeft andRect:detailRect];
            [lblTargetDate sizeToFit];
            [pageBuilder addDrawable:lblTargetDate];
            [lblTargetDate release];                
            
            // increase the height of the current row to that of the label, if necessary.
            metricRowHeight = lblTargetDate.rect.size.height > metricRowHeight ? lblTargetDate.rect.size.height : metricRowHeight;
            
            metricPositionY += metricRowHeight + rowSpacing;
            
        }
        CGFloat metricsCellHeight = metricPositionY - yPosition_;
        
        
        // activities
        NSArray *activities = [objective activitiesSortedByDate];
        CGFloat activityPositionY = yPosition_;
        for (Activity *activity in activities) {
            
            // reset
            CGFloat activityRowHeight = 0;
            
            // action
            detailRect = CGRectMake(actionColumnStartX_, activityPositionY + rowSpacing, actionColumnWidth_, 0);
            MBDrawableLabel *lblAction = [[MBDrawableLabel alloc] initWithText:activity.action font:font color:fontColor_ lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentLeft andRect:detailRect];
            [lblAction sizeToFit];
            [pageBuilder addDrawable:lblAction];
            [lblAction release];                
            
            // increase the height of the current row to that of the label, if necessary.
            activityRowHeight = lblAction.rect.size.height > activityRowHeight ? lblAction.rect.size.height : activityRowHeight;
            
            
            // first year cost
            detailRect = CGRectMake(firstYearCostColumnStartX_, activityPositionY + rowSpacing, firstYearCostColumnWidth_, 0);
            MBDrawableLabel *lblFirstYearCost = [[MBDrawableLabel alloc] initWithText:[activity.upfrontCost formattedNumberForReports] font:font color:fontColor_ lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentRight andRect:detailRect];
//            [lblFirstYearCost sizeToFit]; // will ruin UITextALignmentRight
            [pageBuilder addDrawable:lblFirstYearCost];
            [lblFirstYearCost release];                
            
            // increase the height of the current row to that of the label, if necessary.
            activityRowHeight = lblFirstYearCost.rect.size.height > activityRowHeight ? lblFirstYearCost.rect.size.height : activityRowHeight;
            
            
            // activity start date
            detailRect = CGRectMake(startDateColumnStartX_, activityPositionY + rowSpacing, startDateColumnWidth_, 0);                
            MBDrawableLabel *lblStartDate = [[MBDrawableLabel alloc] initWithText:[activity.startDate formattedDate1] font:font color:fontColor_ lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentLeft andRect:detailRect];
            [lblStartDate sizeToFit];
            [pageBuilder addDrawable:lblStartDate];
            [lblStartDate release];                
            
            // increase the height of the current row to that of the label, if necessary.
            activityRowHeight = lblStartDate.rect.size.height > activityRowHeight ? lblStartDate.rect.size.height : activityRowHeight;
            
            
            // activity end date
            detailRect = CGRectMake(endDateColumnStartX_, activityPositionY + rowSpacing, endDateColumnWidth_, 0);
            MBDrawableLabel *lblEndDate = [[MBDrawableLabel alloc] initWithText:[activity.endDate formattedDate1] font:font color:fontColor_ lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentLeft andRect:detailRect];
            [lblEndDate sizeToFit];
            [pageBuilder addDrawable:lblEndDate];
            [lblEndDate release];                
            
            // increase the height of the current row to that of the label, if necessary.
            activityRowHeight = lblEndDate.rect.size.height > activityRowHeight ? lblEndDate.rect.size.height : activityRowHeight;            
            
            // add the height of the current row to the y-position.
            activityPositionY += activityRowHeight + rowSpacing;
        }
        CGFloat activitiesCellHeight = activityPositionY - yPosition_;
        
        yPosition_ += MAX(objectiveCellHeight, MAX(metricsCellHeight, activitiesCellHeight));
                
    }
    
}

@end

