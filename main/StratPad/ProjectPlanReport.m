//
//  ProjectPlanReport.m
//  StratPad
//
//  Created by Julian Wood on 9/13/11.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "ProjectPlanReport.h"
#import "NSDate-StratPad.h"
#import "StratFileManager.h"
#import "Theme.h"
#import "Objective.h"
#import "Activity.h"
#import "Responsible.h"
#import "MBDrawableLabel.h"
#import "MBDrawableHorizontalLine.h"
#import "UIColor-Expanded.h"
#import "NSString-Expanded.h"
#import "SinglePageReportBuilder.h"
#import "MultiPageReportBuilder.h"
#import "MBDrawableReportHeader.h"
#import "ReportPrintFonts.h"
#import "ApplicationSkin.h"
#import "MBReportHeader.h"
#import "Metric.h"

@interface ProjectPlanReport (Private)
- (void)layoutDrawablesInContentRect:(CGRect)contentRect withPageBuilder:(id<ReportPageBuilder>)pageBuilder;
- (void)layoutDrawablesForHeaderInRect:(CGRect)rect withPageBuilder:(id<ReportPageBuilder>)pageBuilder;
- (void)layoutDrawablesForTheme:(Theme*)theme inRect:(CGRect)rect withPageBuilder:(id<ReportPageBuilder>)pageBuilder;
- (void)layoutDrawableForObjective:(Objective*)objective inRect:(CGRect)rect withPageBuilder:(id<ReportPageBuilder>)pageBuilder;
- (void)layoutDrawablesForActivity:(Activity*)activity inRect:(CGRect)rect withPageBuilder:(id<ReportPageBuilder>)pageBuilder;
@end

@implementation ProjectPlanReport

- (id)init
{
    if ((self = [super init])) {
        hasMorePages_ = YES;
    }
    return self;
}

- (void)dealloc
{
    [colWidths_ release];     
    [fontColor_ release];
    [lineColor_ release];
    [pagedDrawables_ release];
    
    [super dealloc];
}


#pragma mark - ScreenReportDelegate

- (CGFloat)heightToDisplayContentForBounds:(CGRect)viewBounds
{    
    isPrint_ = NO;
    
    CGRect screenInsetRect = CGRectMake(viewBounds.origin.x + screenInsets_.left, 
                                        viewBounds.origin.y + screenInsets_.top, 
                                        viewBounds.size.width - screenInsets_.left - screenInsets_.right, 
                                        viewBounds.size.height - screenInsets_.top - screenInsets_.bottom);
    
    if (!pagedDrawables_) {
        // we only need to perform the layout once
        
        ApplicationSkin *skin = [ApplicationSkin currentSkin];
        
        // define the table font sizes and layout percentages for screen.
        fontName_ = skin.section3FontName;    
        boldFontName_ = skin.section3BoldFontName;
        obliqueFontName_ = skin.section3ItalicFontName;
        fontSize_ = [skin.section3TextFontSize floatValue];
        fontColor_ = [[UIColor colorWithHexString:skin.section3ChartFontColor] retain];
        lineColor_ = [[UIColor colorWithHexString:skin.section3ChartLineColor] retain];

        SinglePageReportBuilder *pageBuilder = [[SinglePageReportBuilder alloc] initWithPageRect:screenInsetRect];
        
        contentInsets_ = UIEdgeInsetsMake(40, 0, 40, 0);                
        CGFloat insetWidth = screenInsetRect.size.width - contentInsets_.left - contentInsets_.right;
        colWidths_ = [[NSArray arrayWithObjects:
                       [NSNumber numberWithFloat:insetWidth * 0.6], 
                       [NSNumber numberWithFloat:insetWidth * 0.2], 
                       [NSNumber numberWithFloat:insetWidth * 0.2], 
                       nil] retain];
        rowHeight_ = 20.f;
        
        MBReportHeader *reportHeader = [[MBReportHeader alloc] initWithRect:viewBounds textInsetLeft:screenInsets_.left andReportTitle:[self reportTitle]];
        reportHeader.headerImageName = skin.section3HeaderImage;
        reportHeader.reportTitleFontName = boldFontName_;
        reportHeader.reportTitleFontSize = [skin.section3ReportTitleFontSize floatValue];
        reportHeader.reportTitleFontColor = [UIColor colorWithHexString:skin.section3ReportTitleFontColor];
        [reportHeader sizeToFit];
        
        CGFloat headerHeight = [reportHeader rect].size.height;        
        [pageBuilder addDrawable:reportHeader];
        [reportHeader release];
        
        CGRect contentRect = CGRectMake(screenInsetRect.origin.x, headerHeight, screenInsetRect.size.width, screenInsetRect.size.height - headerHeight);    
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
    isPrint_ = YES;
    
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
        MultiPageReportBuilder *pageBuilder = [[MultiPageReportBuilder alloc] initWithPageRect:printInsetRect];
        pageBuilder.mediaType = MediaTypePrint;
        
        fontName_ = fontNameForPrint;
        boldFontName_ = boldFontNameForPrint;
        obliqueFontName_ = obliqueFontNameForPrint;
        fontSize_ = textFontSizeForPrint;
        fontColor_ = [chartFontColorForPrint retain];
        lineColor_ = [chartLineColorForPrint retain];

        contentInsets_ = UIEdgeInsetsMake(20, 0, 20, 0);
        CGFloat insetWidth = printInsetRect.size.width - contentInsets_.left - contentInsets_.right;
        colWidths_ = [[NSArray arrayWithObjects:
                       [NSNumber numberWithFloat:insetWidth * 0.6], 
                       [NSNumber numberWithFloat:insetWidth * 0.2], 
                       [NSNumber numberWithFloat:insetWidth * 0.2], 
                       nil] retain];
        rowHeight_ = 18.f;
        
        MBDrawableReportHeader *reportHeader = [[MBDrawableReportHeader alloc] initWithRect:headerRect textInsetLeft:headerLeftShift andReportTitle:[self reportTitle]];
        [reportHeader addTitleItemWithText:[self companyName] font:[UIFont fontWithName:boldFontNameForPrint size:12.f] andColor:[UIColor blackColor]];
        [reportHeader addTitleItemWithText:[self stratFileName] font:[UIFont fontWithName:fontNameForPrint size:12.f] andColor:[UIColor blackColor]];
        [reportHeader addTitleItemWithText:[[NSDate date] formattedDate2] font:[UIFont fontWithName:obliqueFontNameForPrint size:12.f] andColor:[UIColor blackColor]];
        [reportHeader sizeToFit];
        
        CGFloat headerHeight = reportHeader.rect.size.height;        
        [pageBuilder addDrawable:reportHeader];    
        [reportHeader release];
        
        CGRect contentRect = CGRectMake(printInsetRect.origin.x, printInsetRect.origin.y + headerHeight, printInsetRect.size.width, printInsetRect.size.height - headerHeight);            
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


#pragma mark - Overrides

- (NSString*)reportTitle
{
    // default date is today
    NSDate *date = [NSDate date];
    
    NSArray *themes = [[[StratFileManager sharedManager] currentStratFile] themesSortedByStartDate];
    if ([themes count] > 0) {
        for (Theme *theme in themes) {
            if (theme.startDate) {
                date = theme.startDate;
                break;
            }
        }
    }
    
    if (isPrint_) {
        return [NSString stringWithFormat:@"%@: %@",
                LocalizedString(@"PROJECT_PLAN_REPORT_TITLE", nil),
                [NSString stringWithFormat:LocalizedString(@"LABEL_STARTING_FROM", nil), [date formattedDate2]]];        
    } else {
        return [NSString stringWithFormat:@"%@:\n%@",
                LocalizedString(@"PROJECT_PLAN_REPORT_TITLE", nil),
                [NSString stringWithFormat:LocalizedString(@"LABEL_STARTING_FROM", nil), [date formattedDate2]]];
    }    
}


#pragma mark - Drawing

- (void)layoutDrawablesInContentRect:(CGRect)contentRect withPageBuilder:(id<ReportPageBuilder>)pageBuilder
{          
    row_ = 0;
    
    CGRect contentInsetRect = CGRectMake(contentRect.origin.x + contentInsets_.left, 
                                  contentRect.origin.y + contentInsets_.top, 
                                  contentRect.size.width - contentInsets_.left - contentInsets_.right, 
                                  contentRect.size.height - contentInsets_.top - contentInsets_.bottom);
    
    [self layoutDrawablesForHeaderInRect:contentInsetRect withPageBuilder:pageBuilder];
    
    // rows are constant height, columns are constant width
    // always pass the content rect - the methods figure out their offsets
    NSArray *themes = [[[StratFileManager sharedManager] currentStratFile] themesSortedByOrder];
    for (Theme *theme in themes) {
        [self layoutDrawablesForTheme:theme inRect:contentInsetRect withPageBuilder:pageBuilder];
        NSArray *objectives = [theme objectivesSortedByOrder];
        for (Objective *objective in objectives) {
            [self layoutDrawableForObjective:objective inRect:contentInsetRect withPageBuilder:pageBuilder];
            NSArray *activities = [objective activitiesSortedByDate];
            for (Activity *activity in activities) {
                [self layoutDrawablesForActivity:activity inRect:contentInsetRect withPageBuilder:pageBuilder];
            }
        }
    }
}

- (void)layoutDrawablesForHeaderInRect:(CGRect)rect withPageBuilder:(id<ReportPageBuilder>)pageBuilder
{    
    CGFloat xOffset = 0;
    CGFloat colWidth = [[colWidths_ objectAtIndex:0] floatValue];
    CGRect cellRect = CGRectMake(rect.origin.x + xOffset, rect.origin.y + row_*rowHeight_, colWidth, rowHeight_);
    
    // theme heading
    MBDrawableLabel *lblThemeHeading = [[MBDrawableLabel alloc] initWithText:[LocalizedString(@"PPR_HEADING_THEME", nil) uppercaseString]
                                                                        font:[UIFont fontWithName:boldFontName_ size:fontSize_] 
                                                                       color:fontColor_ 
                                                               lineBreakMode:UILineBreakModeTailTruncation 
                                                                   alignment:UITextAlignmentLeft 
                                                                     andRect:cellRect];
    [lblThemeHeading sizeToFit];
    [pageBuilder addDrawable:lblThemeHeading];
    [lblThemeHeading release];
    
    
    // start date heading
    xOffset += colWidth;
    colWidth = [[colWidths_ objectAtIndex:1] floatValue];
    cellRect = CGRectMake(rect.origin.x + xOffset, rect.origin.y + row_*rowHeight_, colWidth, rowHeight_);
    
    MBDrawableLabel *lblStartDateHeading = [[MBDrawableLabel alloc] initWithText:[LocalizedString(@"PPR_HEADING_START_DATE", nil) uppercaseString]
                                                                            font:[UIFont fontWithName:boldFontName_ size:fontSize_] 
                                                                           color:fontColor_
                                                                   lineBreakMode:UILineBreakModeTailTruncation 
                                                                       alignment:UITextAlignmentLeft
                                                                         andRect:cellRect];
    [lblStartDateHeading sizeToFit];
    [pageBuilder addDrawable:lblStartDateHeading];
    [lblStartDateHeading release];
    
    
    // end date heading
    xOffset += colWidth;
    colWidth = [[colWidths_ objectAtIndex:2] floatValue];
    cellRect = CGRectMake(rect.origin.x + xOffset, rect.origin.y + row_*rowHeight_, colWidth, rowHeight_);
    
    
    MBDrawableLabel *lblEndDateHeading = [[MBDrawableLabel alloc] initWithText:[LocalizedString(@"PPR_HEADING_END_DATE", nil) uppercaseString]
                                                                          font:[UIFont fontWithName:boldFontName_ size:fontSize_] 
                                                                         color:fontColor_
                                                                 lineBreakMode:UILineBreakModeTailTruncation 
                                                                     alignment:UITextAlignmentLeft
                                                                       andRect:cellRect];
    [lblEndDateHeading sizeToFit];
    [pageBuilder addDrawable:lblEndDateHeading];
    [lblEndDateHeading release];
    
    
    // bottom line
    MBDrawableHorizontalLine *bottomLine = [[MBDrawableHorizontalLine alloc] initWithOrigin:CGPointMake(rect.origin.x, rect.origin.y+rowHeight_-2.f) 
                                                                                      width:rect.size.width 
                                                                                  thickness:2.f
                                                                                   andColor:lineColor_];
    [pageBuilder addDrawable:bottomLine];
    [bottomLine release];
    
    row_++;
}


- (void)layoutDrawablesForTheme:(Theme*)theme inRect:(CGRect)rect withPageBuilder:(id<ReportPageBuilder>)pageBuilder
{
    // if no start date, use the current date
    // if no end date, don't print the date
    
    CGFloat xOffset = 0;
    CGFloat yOffset = row_*rowHeight_;
    
    // top line
    MBDrawableHorizontalLine *topLine = [[MBDrawableHorizontalLine alloc] initWithOrigin:CGPointMake(rect.origin.x, rect.origin.y+yOffset) 
                                                                                   width:rect.size.width 
                                                                               thickness:1.f
                                                                                andColor:lineColor_];
    [pageBuilder addDrawable:topLine];
    [topLine release];
    
    
    // cell 1
    BOOL isResponsible = theme.responsible.summary != nil && ![theme.responsible.summary isBlank];
    NSString *themeTitle = isResponsible ? [theme.title stringByAppendingFormat:@" [%@]", theme.responsible.summary] : theme.title;
    
    CGFloat colWidth = [[colWidths_ objectAtIndex:0] floatValue];
    CGRect cellRect = CGRectMake(rect.origin.x + xOffset, rect.origin.y + yOffset, colWidth, rowHeight_);
    
    MBDrawableLabel *lblThemeTitle = [[MBDrawableLabel alloc] initWithText:themeTitle
                                                                      font:[UIFont fontWithName:boldFontName_ size:fontSize_] 
                                                                     color:fontColor_
                                                             lineBreakMode:UILineBreakModeTailTruncation 
                                                                 alignment:UITextAlignmentLeft
                                                                   andRect:cellRect];
    [lblThemeTitle sizeToFit];
    [AbstractReportDelegate verticallyAlignDrawable:lblThemeTitle inRect:cellRect withAlignment:VerticalTextAlignmentMiddle];
    [pageBuilder addDrawable:lblThemeTitle];
    [lblThemeTitle release];
    
    
    // cell 2
    xOffset += colWidth;
    colWidth = [[colWidths_ objectAtIndex:1] floatValue];
    cellRect = CGRectMake(rect.origin.x + xOffset, rect.origin.y + yOffset, colWidth, rowHeight_);
    
    MBDrawableLabel *lblStartDate = [[MBDrawableLabel alloc] initWithText:theme.startDate ? [theme.startDate formattedDate2] : [[[NSDate date] dateWithZeroedTime] formattedDate2]
                                                                     font:[UIFont fontWithName:boldFontName_ size:fontSize_] 
                                                                    color:fontColor_
                                                            lineBreakMode:UILineBreakModeTailTruncation 
                                                                alignment:UITextAlignmentLeft
                                                                  andRect:cellRect];
    [lblStartDate sizeToFit];
    [AbstractReportDelegate verticallyAlignDrawable:lblStartDate inRect:cellRect withAlignment:VerticalTextAlignmentMiddle];
    [pageBuilder addDrawable:lblStartDate];
    [lblStartDate release];
    
    
    // cell 3
    xOffset += colWidth;
    colWidth = [[colWidths_ objectAtIndex:2] floatValue];
    cellRect = CGRectMake(rect.origin.x + xOffset, rect.origin.y + yOffset, colWidth, rowHeight_);
    
    MBDrawableLabel *lblEndDate = [[MBDrawableLabel alloc] initWithText:[theme.endDate formattedDate2] 
                                                                   font:[UIFont fontWithName:boldFontName_ size:fontSize_] 
                                                                  color:fontColor_
                                                          lineBreakMode:UILineBreakModeTailTruncation 
                                                              alignment:UITextAlignmentLeft
                                                                andRect:cellRect];
    [lblEndDate sizeToFit];
    [AbstractReportDelegate verticallyAlignDrawable:lblEndDate inRect:cellRect withAlignment:VerticalTextAlignmentMiddle];    
    [pageBuilder addDrawable:lblEndDate];
    [lblEndDate release];
    
    
    // bottom line
    MBDrawableHorizontalLine *bottomLine = [[MBDrawableHorizontalLine alloc] initWithOrigin:CGPointMake(rect.origin.x, rect.origin.y+yOffset+rowHeight_) 
                                                                                      width:rect.size.width 
                                                                                  thickness:1.f
                                                                                   andColor:lineColor_];
    [pageBuilder addDrawable:bottomLine];
    [bottomLine release];
    
    row_++;    
}

-(void)layoutDrawableForObjective:(Objective*)objective inRect:(CGRect)rect withPageBuilder:(id<ReportPageBuilder>)pageBuilder
{
#define indent 10.f
    
    CGFloat colWidth = [[colWidths_ objectAtIndex:0] floatValue];
    CGRect cellRect = CGRectMake(rect.origin.x + indent, rect.origin.y + row_*rowHeight_, colWidth-indent, rowHeight_);
    
    MBDrawableLabel *lblObjective = [[MBDrawableLabel alloc] initWithText:objective.summary
                                                                     font:[UIFont fontWithName:obliqueFontName_ size:fontSize_] 
                                                                    color:fontColor_
                                                            lineBreakMode:UILineBreakModeTailTruncation 
                                                                alignment:UITextAlignmentLeft
                                                                  andRect:cellRect];
    [lblObjective sizeToFit];
    [AbstractReportDelegate verticallyAlignDrawable:lblObjective inRect:cellRect withAlignment:VerticalTextAlignmentMiddle];    
    [pageBuilder addDrawable:lblObjective];
    [lblObjective release];
    
    if (objective.metrics.count) {
        // look for target dates in metrics - show the greatest date
        NSDate *metricDate = [NSDate distantPast];
        // none of the metrics can have a target value
        BOOL hasTargetValue = NO;
        for (Metric *metric in objective.metrics) {
            if ([metricDate compare:metric.targetDate] == NSOrderedAscending) {
                metricDate = metric.targetDate;
            }
            if (metric.targetValue) {
                hasTargetValue = YES;
            }
        }
        
        
        if (![metricDate isEqualToDate:[NSDate distantPast]] && !hasTargetValue) {
            // show this metric date as the date for the objective
            CGFloat xOffset = 0;

            // nothing in cell 2
            xOffset += colWidth;
            colWidth = [[colWidths_ objectAtIndex:1] floatValue];
            
            // cell 3
            xOffset += colWidth;
            colWidth = [[colWidths_ objectAtIndex:2] floatValue];
            cellRect = CGRectMake(rect.origin.x + xOffset, rect.origin.y + row_*rowHeight_, colWidth, rowHeight_);
            
            MBDrawableLabel *lblMetricDate = [[MBDrawableLabel alloc] initWithText:[metricDate formattedDate2]
                                                                           font:[UIFont fontWithName:obliqueFontName_ size:fontSize_] 
                                                                          color:fontColor_
                                                                  lineBreakMode:UILineBreakModeTailTruncation 
                                                                      alignment:UITextAlignmentLeft
                                                                        andRect:cellRect];
            [lblMetricDate sizeToFit];
            [AbstractReportDelegate verticallyAlignDrawable:lblMetricDate inRect:cellRect withAlignment:VerticalTextAlignmentMiddle];      
            [pageBuilder addDrawable:lblMetricDate];
            [lblMetricDate release];
        }        
    }
    
    row_++;
}

- (void)layoutDrawablesForActivity:(Activity*)activity inRect:(CGRect)rect withPageBuilder:(id<ReportPageBuilder>)pageBuilder
{
    CGFloat xOffset = 0;
    CGFloat yOffset = row_*rowHeight_;
    
    BOOL isResponsible = activity.responsible.summary != nil && ![activity.responsible.summary isBlank];
    NSString *activityTitle = isResponsible ? [activity.action stringByAppendingFormat:@" [%@]", activity.responsible.summary] : activity.action;
    
    // cell 1
    CGFloat colWidth = [[colWidths_ objectAtIndex:0] floatValue];
    CGRect cellRect = CGRectMake(rect.origin.x + xOffset + 2*indent, rect.origin.y + yOffset, colWidth-2*indent, rowHeight_);
    
    MBDrawableLabel *lblActivityTitle = [[MBDrawableLabel alloc] initWithText:activityTitle
                                                                         font:[UIFont fontWithName:fontName_ size:fontSize_] 
                                                                        color:fontColor_
                                                                lineBreakMode:UILineBreakModeTailTruncation 
                                                                    alignment:UITextAlignmentLeft
                                                                      andRect:cellRect];
    [lblActivityTitle sizeToFit];
    [AbstractReportDelegate verticallyAlignDrawable:lblActivityTitle inRect:cellRect withAlignment:VerticalTextAlignmentMiddle];    
    [pageBuilder addDrawable:lblActivityTitle];
    [lblActivityTitle release];
    
    
    // cell 2
    xOffset += colWidth;
    colWidth = [[colWidths_ objectAtIndex:1] floatValue];
    cellRect = CGRectMake(rect.origin.x + xOffset, rect.origin.y + yOffset, colWidth, rowHeight_);
    
    MBDrawableLabel *lblStartDate = [[MBDrawableLabel alloc] initWithText:[activity.startDate formattedDate2]
                                                                     font:[UIFont fontWithName:fontName_ size:fontSize_] 
                                                                    color:fontColor_
                                                            lineBreakMode:UILineBreakModeTailTruncation 
                                                                alignment:UITextAlignmentLeft
                                                                  andRect:cellRect];
    [lblStartDate sizeToFit];
    [AbstractReportDelegate verticallyAlignDrawable:lblStartDate inRect:cellRect withAlignment:VerticalTextAlignmentMiddle];    
    [pageBuilder addDrawable:lblStartDate];
    [lblStartDate release];
    
    
    // cell 3
    xOffset += colWidth;
    colWidth = [[colWidths_ objectAtIndex:2] floatValue];
    cellRect = CGRectMake(rect.origin.x + xOffset, rect.origin.y + yOffset, colWidth, rowHeight_);
    
    MBDrawableLabel *lblEndDate = [[MBDrawableLabel alloc] initWithText:[activity.endDate formattedDate2]
                                                                   font:[UIFont fontWithName:fontName_ size:fontSize_] 
                                                                  color:fontColor_
                                                          lineBreakMode:UILineBreakModeTailTruncation 
                                                              alignment:UITextAlignmentLeft
                                                                andRect:cellRect];
    [lblEndDate sizeToFit];
    [AbstractReportDelegate verticallyAlignDrawable:lblEndDate inRect:cellRect withAlignment:VerticalTextAlignmentMiddle];      
    [pageBuilder addDrawable:lblEndDate];
    [lblEndDate release];
    
    row_++;
}

@end
