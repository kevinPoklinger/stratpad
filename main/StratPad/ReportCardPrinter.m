//
//  ReportCardPrinter.m
//  StratPad
//
//  Created by Julian Wood on 12-05-10.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "ReportCardPrinter.h"
#import "NSDate-StratPad.h"
#import "MBDrawableLabel.h"
#import "PageSpooler.h"
#import "Chart.h"
#import "StratFileManager.h"
#import "MainChartView.h"
#import "Measurement.h"
#import "Metric.h"
#import "NSNumber-StratPad.h"
#import "NSCalendar+Expanded.h"
#import "LinearRegression.h"
#import "ChartReportHeader.h"
#import "DataManager.h"
#import "ChartReport.h"
#import "ChartReportSection.h"
#import "ReportCardHeader.h"
#import "ThemeKey.h"
#import "ColorWell.h"
#import "NSUserDefaults+StratPad.h"

#pragma mark - Extensions

@interface NSNumber (ReportCardPrinter)
- (NSString*)formattedNumberForReportCard;
@end

@implementation NSNumber (ReportCardPrinter)
- (NSString*)formattedNumberForReportCard
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setMaximumFractionDigits:2];
    
    NSString *formattedNumber = [NSString stringWithFormat:@"%@", [formatter stringFromNumber:self]];
    [formatter release];
    
    return formattedNumber;

}
@end

@interface NSDate (ReportCardPrinter)
- (NSString*)formattedDateForTarget;
@end

@implementation NSDate (ReportCardPrinter)
- (NSString*)formattedDateForTarget
{
    // locale independent, tz-sensitive
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];        
    [formatter setDateFormat:@"MMM yyyy"];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    NSString *formattedDate = [formatter stringFromDate:self];
    [formatter release];
    return formattedDate;
}
@end


#pragma mark - ReportCard Printer

@implementation ReportCardPrinter

- (id)init
{
    self = [super init];
    if (self) {
        skinMan_ = [SkinManager sharedManager];
        reportHelper_ = [[ReportHelper alloc] init];
        numPages_ = 0;
        hasMorePages_ = YES;
        
        regularFont_ = [UIFont fontWithName:reportCardFontName size:reportCardFontSize];
        boldFont_ = [UIFont fontWithName:reportCardFontNameBold size:reportCardFontSize];
        italicFont_ = [UIFont fontWithName:reportCardFontNameItalic size:reportCardFontSize];
        
        pagedDrawables_ = [[NSMutableDictionary alloc] init];
        chartsPerTheme_ = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [chartsPerTheme_ release];
    [reportHelper_ release];
    [pagedDrawables_ release];
    [super dealloc];
}

#pragma mark - PrintReportDelegate

- (BOOL)hasMorePages
{
    // always have at least one page    
    return hasMorePages_;
}

- (void)drawPage:(NSInteger)pageIndex inRect:(CGRect)rect
{    
    pageRect_ = rect;
        
    UIEdgeInsets printInsets_ = reportHelper_.printInsets;
    CGRect printInsetRect = CGRectMake(rect.origin.x + printInsets_.left, 
                                       rect.origin.y + printInsets_.top, 
                                       rect.size.width - printInsets_.left - printInsets_.right, 
                                       rect.size.height - printInsets_.top - printInsets_.bottom);
    
    // header rect
    CGFloat footerHeight = 1.5*reportCardFontSize;
    headerRect_ = CGRectMake(printInsetRect.origin.x, 
                             printInsetRect.origin.y, 
                             printInsetRect.size.width, 
                             printInsetRect.size.height - footerHeight); // maxHeight
    
    // footer is for page number; footer can go inside the printInsets (ie outside of bodyrect)
    CGRect footerRect = CGRectMake(printInsetRect.origin.x, 
                                   CGRectGetMaxY(printInsetRect),
                                   printInsetRect.size.width, 
                                   footerHeight);  
    
    // determine headerHeight
    ReportCardHeader *reportCardHeader = [[ReportCardHeader alloc] initWithThemeKey:nil rect:headerRect_];
    CGFloat headerHeight = reportCardHeader.rect.size.height;        
    headerRect_.size.height = headerHeight;
    [reportCardHeader release];
    
    // draw the chart into contentRect_, which for printing does not equal our context rect
    bodyRect_ = CGRectMake(printInsetRect.origin.x, printInsetRect.origin.y + headerHeight, 
                           printInsetRect.size.width, printInsetRect.size.height - headerHeight);
    
    column1LeftEdge_ = bodyRect_.origin.x;
    column1RightEdge_ = bodyRect_.origin.x + bodyRect_.size.width/2 - columnSpacerX/2;
    column2LeftEdge_ = column1RightEdge_ + columnSpacerX;
    column2RightEdge_ = bodyRect_.origin.x + bodyRect_.size.width;
        
    // figure out numPages by laying out charts and comments; note that this number is cached, as is the layout
    NSInteger numPages = [self numPages];
    hasMorePages_ = pageIndex < numPages-1;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    // don't let the ChartReportHeader vert line go below bodyRect
    CGContextClipToRect(context, CGRectUnion(headerRect_, bodyRect_));
    
    // now draw them
    NSArray *pageOfDrawables = [pagedDrawables_ objectForKey:[NSNumber numberWithInt:pageIndex]];
    for (id<Drawable>drawable in pageOfDrawables) {
        [drawable draw];
    }
    
    // remove clipping
    CGContextRestoreGState(context);
    
    
    // now draw the page number in the footer
    NSString *footerText = [NSString stringWithFormat:@"%@ %i", LocalizedString(@"PAGE", nil), 
                            [[PageSpooler sharedManager] cumulativePageNumberForReport]];
    
    MBDrawableLabel *footerLabel = [[MBDrawableLabel alloc] initWithText:footerText 
                                                                    font:regularFont_
                                                                   color:[UIColor blackColor]
                                                           lineBreakMode:UILineBreakModeTailTruncation 
                                                               alignment:UITextAlignmentCenter
                                                                 andRect:footerRect];    
    [footerLabel draw];
    [footerLabel release];
}

#pragma mark - layout

- (NSInteger) numPages
{    
    // numPages_ is at 0 until we go figure it out
    if (numPages_ == 0) {
        numPages_ = 1;
        
        // layout the page to figure out
        [self layoutChartReports];
    }
    
    return numPages_;
}

- (void)layoutChartReports
{
    // nb this is only executed once per draw
    
    // 2 column layout
    // inverted N-pattern flow
    // variable amount of text at the top of each chart
    // chart is always same size
    // need different sized text than main charts
    // for any chart with a comments overlay, we have a variable amount of text underneath the chart
    // comments should flow separately from the chart
    // there is a grey left border which groups the charts, and is of variable length
    
    // occurance rules per chartReport
    // -------------------------------
    // ChartReportHeader 1
    //  SummarySection
    //   MBDrawableLabel   >=0
    //  ChartSection 
    //    MainChartView      1
    //  Comments 
    //    MBDrawableLabel >= 0
    
    // splitting rules
    // ---------------
    // - can split after chart
    // - can split after any individual comment
    

    // we have to group charts under a single theme; always start a new page for a new theme
    NSArray *chartList = [Chart chartsSortedByOrderForStratFile:[[StratFileManager sharedManager] currentStratFile]];
    NSDictionary *chartPrintingDict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:keyChartPrinting];
    for (Chart *chart in chartList) {
        
        // check to see if we should print this chart; default if not set is YES
        if (chartPrintingDict) {
            if (! [[chartPrintingDict objectForKey:chart.uuid] boolValue]) {
                continue;
            }
        }
                
        ThemeKey *themeKey = [[ThemeKey alloc] initWithTheme:chart.metric.objective.theme];
    
        // chartReports are organized by theme
        NSMutableArray *chartReports = [chartsPerTheme_ objectForKey:themeKey];
        if (!chartReports) {
            chartReports = [NSMutableArray array];
            [chartsPerTheme_ setObject:chartReports forKey:themeKey];
        }
        [themeKey release];
        
        // each ChartReport has a ChartReportHeader, and 3 ChartReportSections
        ChartReport *chartReport = [self newChartReport:chart chartReportOrigin:CGPointZero];
        [chartReports addObject:chartReport];
        [chartReport release];
    }
        
    // this is the unchanging origin that we start with on every page for drawing chart reports
    topLeftOrigin_ = CGPointMake(column1LeftEdge_, bodyRect_.origin.y + sectionSpacerY);
    
    // keep track of our next origin for drawing
    CGPoint originOnPage = topLeftOrigin_;

    // organize chartReports into pages and columns, splitting where necessary and possible
    int col = 0, pageNum = 0;
    
    NSArray *sortedThemeKeys = [[chartsPerTheme_ allKeys] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES]]];
    for (ThemeKey *themeKey in sortedThemeKeys) {
        
        BOOL drawHeader = YES;
        
        // layout chart reports and their "children", each relative to a chartReportOrigin of 0,0
        NSArray *chartReports = [chartsPerTheme_ objectForKey:themeKey];
        for (int i=0, ct=chartReports.count; i<ct; ++i) {
            
            ChartReport *chartReport = [chartReports objectAtIndex:i];
        
            if (drawHeader) {
                // header is included on all pages, and is theme-specific
                ReportCardHeader *reportCardHeader = [[ReportCardHeader alloc] initWithThemeKey:themeKey rect:headerRect_];
                NSMutableArray *pagedDrawables = [pagedDrawables_ objectForKey:[NSNumber numberWithInt:pageNum]];
                if (!pagedDrawables) {
                    pagedDrawables = [NSMutableArray array];
                    [pagedDrawables_ setObject:pagedDrawables forKey:[NSNumber numberWithInt:pageNum]];
                }
                [pagedDrawables addObject:reportCardHeader];
                [reportCardHeader release];
                drawHeader = NO;
            }
            
            if ([chartReport fitsInRect:bodyRect_ atOrigin:originOnPage]) {            
                // make sure all drawables reflect this origin
                [chartReport updateAllDrawableOrigins:originOnPage];
                
                // add to current page - this will be all of them
                [self addPrintReadyDrawablesToPage:pageNum chartReport:chartReport];
                
                // add lines for comments
                if (chartReport.commentSection.rect.size.height > 0) {
                    CGPoint commentBottom = CGPointMake(0, CGRectGetMaxY(chartReport.commentSection.rect));
                    [chartReport.chartReportHeader addPointToBoundingLinePoints:commentBottom];                    
                }
                
                // move next origin just below this chart report in same col
                originOnPage = CGPointMake(originOnPage.x, CGRectGetMaxY(chartReport.rect) + chartReportSpacerY);
                
            } else {
                // see which sections will fit and record
                // move other sections to other columns or pages
                if ([chartReport partiallyFitsInRect:bodyRect_ atOrigin:originOnPage]) {
                    // so we know that at least one section will fit in the current col
                    
                    // so place the header and the section(s) on this page and col, place the rest 
                    [chartReport fitSectionsIntoColumn:col page:pageNum atOrigin:originOnPage bodyRect:bodyRect_];
                    
                    // add to current page
                    [self addPrintReadyDrawablesToPage:pageNum chartReport:chartReport];
                    
                    while (![chartReport readyForPrint]) {
                        
                        // now the next origin is either the next col or the next page
                        if (col==0) {
                            col=1;
                            originOnPage = CGPointMake(column2LeftEdge_, topLeftOrigin_.y);
                        } else {
                            col=0;
                            pageNum++;
                            drawHeader = YES;
                            originOnPage = topLeftOrigin_;
                        }
                        [chartReport fitSectionsIntoColumn:col page:pageNum atOrigin:originOnPage bodyRect:bodyRect_];
                        
                        // add to current page
                        [self addPrintReadyDrawablesToPage:pageNum chartReport:chartReport];
                        
                    }
                    
                    // move next origin just below this chart in same col, remembering that it has been split and chartReport.rect is unreliable now
                    originOnPage = CGPointMake(originOnPage.x, [chartReport getMaxY] + chartReportSpacerY);
                    
                } else {
                    // move it to the next column or page
                    if (col==0) {
                        col=1;
                        originOnPage = CGPointMake(column2LeftEdge_, topLeftOrigin_.y);
                    } else {
                        col=0;
                        pageNum++;
                        drawHeader = YES;
                        originOnPage = topLeftOrigin_;
                    }
                    // have to make sure we draw it!
                    i--;
                }
                
            }
            
        }
        
        // new page for every theme
        col=0;
        originOnPage = topLeftOrigin_;
        pageNum++;
        
    }
    
    numPages_ = pageNum;
}

// we're keeping a dict of page -> drawables
-(void)addPrintReadyDrawablesToPage:(NSUInteger)pageNum chartReport:(ChartReport*)chartReport
{
    NSMutableArray *pagedDrawables = [pagedDrawables_ objectForKey:[NSNumber numberWithInt:pageNum]];
    if (!pagedDrawables) {
        pagedDrawables = [NSMutableArray array];
        [pagedDrawables_ setObject:pagedDrawables forKey:[NSNumber numberWithInt:pageNum]];
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"readyForPrint=YES"];
    NSArray *printDrawables = [chartReport.drawables filteredArrayUsingPredicate:predicate];

    // if any of these drawables exist on a previous page, don't want to add them again
    if (pageNum > 0) {
        NSArray *prevPageDrawables = [pagedDrawables_ objectForKey:[NSNumber numberWithInt:pageNum-1]];
        
        // subtract the prev set from current set
        NSMutableSet *prevSet = [NSMutableSet setWithArray:prevPageDrawables];
        NSMutableSet *currSet = [NSMutableSet setWithArray:printDrawables];
        [currSet intersectSet:prevSet];
        
        // now remove the intersecting drawables from printDrawables
        if (currSet.count) {
            NSMutableArray *printDrawablesForPage = [NSMutableArray arrayWithCapacity:printDrawables.count];
            [printDrawablesForPage addObjectsFromArray:printDrawables];
            for (id obj in currSet) {
                [printDrawablesForPage removeObject:obj];
            }
            
            // add remaining objects to page
            [pagedDrawables addObjectsFromArray:printDrawablesForPage];
            return;
        }
    }
    
    [pagedDrawables addObjectsFromArray:printDrawables];
}

-(ChartReport*)newChartReport:(Chart*)chart chartReportOrigin:(CGPoint)chartReportOrigin
{
    ChartReport *chartReport = [[ChartReport alloc] init];
    
    CGFloat chartReportWidth = column1RightEdge_-column1LeftEdge_;
    
    // summary section
    CGPoint sectionOrigin = CGPointMake(chartReportOrigin.x + sectionMarginLeft, chartReportOrigin.y + chartReportHeaderHeight + sectionSpacerY);
    NSMutableArray *summaryDrawables = [self summarySectionForChart:chart sectionOrigin:sectionOrigin];
    ChartReportSection *summarySection = [[ChartReportSection alloc] initWithDrawables:summaryDrawables];
    chartReport.summarySection = summarySection;
    [summarySection release];
    
    
    // calculate new origin for chart
    CGFloat sectionY = 0;
    if (summaryDrawables.count) {
        id<Drawable> drawable = [summaryDrawables lastObject];
        sectionY += [drawable rect].origin.y + [drawable rect].size.height;
    }
    sectionOrigin = CGPointMake(sectionOrigin.x, sectionY + sectionSpacerY);
    
    
    // chart section
    CGFloat chartWidth = chartReportWidth - sectionMarginLeft;
    CGFloat chartHeight = chartWidth*0.75;
    CGRect chartRect = CGRectMake(sectionOrigin.x, sectionOrigin.y, chartWidth, chartHeight);
    
    MainChartView *chartView = [[MainChartView alloc] initWithFrame:chartRect chart:chart];
    chartView.mediaType = MediaTypePrint;
    chartView.scale = 0.5;
    chartView.padding = UIEdgeInsetsMake(0, 30, 20, 30); // allow axis labels to be drawn
    
    ChartReportSection *chartSection = [[ChartReportSection alloc] initWithDrawables:[NSMutableArray arrayWithObject:chartView]];
    chartReport.chartSection = chartSection;
    [chartSection release];
    [chartView release];
    
    
    // comments section
    sectionY = chartRect.origin.y + chartRect.size.height + sectionSpacerY;
    sectionOrigin = CGPointMake(sectionOrigin.x, sectionY);
    NSMutableArray *commentDrawables = [self commentSectionForChart:chart sectionOrigin:sectionOrigin];
    ChartReportSection *commentSection = [[ChartReportSection alloc] initWithDrawables:commentDrawables];
    chartReport.commentSection = commentSection;
    [commentSection release];
    
    
    // chart report header
    id<Drawable> lastDrawable = commentDrawables.count ? [commentDrawables lastObject] : chartView;
    CGFloat chartReportHeight = CGRectGetMaxY(lastDrawable.rect) - chartReportOrigin.y;
    CGRect chartReportRect = CGRectMake(chartReportOrigin.x, chartReportOrigin.y, chartReportWidth, chartReportHeight);
    ChartReportHeader *header = [[ChartReportHeader alloc] initWithText:chart.title
                                                                           font:boldFont_
                                                                          color:[UIColor blackColor]
                                                                  lineBreakMode:UILineBreakModeTailTruncation
                                                                      alignment:UITextAlignmentLeft
                                                                        andRect:chartReportRect];
    // only draw line to the bottom of the chart for now
    [header addPointToBoundingLinePoints:CGPointMake(header.rect.origin.x, CGRectGetMaxY(chartView.rect))];
    chartReport.chartReportHeader = header;
    [header release];
    
    chartReport.rect = chartReportRect;
    return chartReport;
}

// NB there may be no drawables returned
-(NSMutableArray*)summarySectionForChart:(Chart*)chart sectionOrigin:(CGPoint)sectionOrigin
{
    NSMutableArray *drawables = [NSMutableArray array];
    CGFloat sectionWidth = column1RightEdge_ - column1LeftEdge_ - sectionMarginLeft;
    CGFloat y = sectionOrigin.y;
    
    // metric
    CGRect rect = CGRectMake(sectionOrigin.x, y, sectionWidth, 999);
    MBDrawableLabel *lbl = [[MBDrawableLabel alloc] initWithText:chart.metric.summary
                                                            font:boldFont_
                                                           color:[UIColor blackColor]
                                                   lineBreakMode:UILineBreakModeWordWrap 
                                                       alignment:UITextAlignmentLeft
                                                         andRect:rect];
    [lbl sizeToFit];

    // colorwell, now that we know the size of the metric
    rect = CGRectMake(sectionOrigin.x, y+1, lbl.rect.size.height-2, lbl.rect.size.height-2);
    ColorWell *colorWell = [[ColorWell alloc] initWithRect:rect color:[chart colorForGradientStart]];
    [drawables addObject:colorWell];
    [colorWell release];
    
    // separate metric from colorwell
    lbl.rect = CGRectMake(lbl.rect.origin.x + rect.size.width + 3, lbl.rect.origin.y,
                          lbl.rect.size.width, lbl.rect.size.height);
    
    // now add metric
    [drawables addObject:lbl];
    [lbl release];
    y += lbl.rect.size.height + bulletSpacerY;

    // recent value
    NSArray *measurements = [chart.metric.measurements sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]]];
    if (measurements.count > 0) {
        Measurement *m = [measurements lastObject];
        if (m.value) {
            NSString *s = [NSString stringWithFormat:LocalizedString(@"RECENT_VALUE", nil), [m.value formattedNumberForReportCard]];
            CGRect rect = CGRectMake(sectionOrigin.x + bulletMarginLeft, y, sectionWidth, 999);
            MBDrawableLabel *lbl = [[MBDrawableLabel alloc] initWithText:s
                                                                    font:regularFont_
                                                                   color:[UIColor blackColor]
                                                           lineBreakMode:UILineBreakModeWordWrap 
                                                               alignment:UITextAlignmentLeft
                                                                 andRect:rect];
            [lbl sizeToFit];
            [drawables addObject:lbl];
            [lbl release];
            y += lbl.rect.size.height + bulletSpacerY;            
        }
    }
    
    // target value and date    
    NSString *targetString = [self targetStringForChart:chart];
    if (targetString.length) {
        CGRect rect = CGRectMake(sectionOrigin.x + bulletMarginLeft, y, sectionWidth, 999);
        MBDrawableLabel *lbl = [[MBDrawableLabel alloc] initWithText:targetString
                                                                      font:regularFont_
                                                                     color:[UIColor blackColor]
                                                             lineBreakMode:UILineBreakModeWordWrap 
                                                                 alignment:UITextAlignmentLeft
                                                                   andRect:rect];
        [lbl sizeToFit];
        [drawables addObject:lbl];
        [lbl release];
        y += lbl.rect.size.height + bulletSpacerY;
    }
    
    // On target
    NSNumber *isOnTarget = [self isOnTarget:chart];
    if (isOnTarget) {
        NSString *boolString = isOnTarget.boolValue ? LocalizedString(@"YES", nil) : LocalizedString(@"NO", nil);
        NSString *onTargetString = [NSString stringWithFormat:LocalizedString(@"ON_TARGET", nil), boolString];
    
        CGRect rect = CGRectMake(sectionOrigin.x + bulletMarginLeft, y, sectionWidth, 999);
        MBDrawableLabel *lbl = [[MBDrawableLabel alloc] initWithText:onTargetString
                                                                      font:regularFont_
                                                                     color:[UIColor blackColor]
                                                             lineBreakMode:UILineBreakModeWordWrap 
                                                                 alignment:UITextAlignmentLeft
                                                                   andRect:rect];
        [lbl sizeToFit];
        [drawables addObject:lbl];
        [lbl release];
        y += lbl.rect.size.height + bulletSpacerY;
    }
    
    // overlay
    if ([chart shouldDrawOverlay]) {
        Chart *overlay = [Chart chartWithUUID:chart.overlay];
        if (overlay.chartType.intValue != ChartTypeComments) {
            
            // metric
            CGRect rect = CGRectMake(sectionOrigin.x, y, sectionWidth, 999);
            MBDrawableLabel *lbl = [[MBDrawableLabel alloc] initWithText:overlay.metric.summary
                                                                    font:boldFont_
                                                                   color:[UIColor blackColor]
                                                           lineBreakMode:UILineBreakModeWordWrap 
                                                               alignment:UITextAlignmentLeft
                                                                 andRect:rect];
            [lbl sizeToFit];
            
            // colorwell, now that we know the size of the metric
            rect = CGRectMake(sectionOrigin.x, y+1, lbl.rect.size.height-2, lbl.rect.size.height-2);
            ColorWell *colorWell = [[ColorWell alloc] initWithRect:rect color:[overlay colorForGradientStart]];
            [drawables addObject:colorWell];
            [colorWell release];
            
            // separate metric from colorwell
            lbl.rect = CGRectMake(lbl.rect.origin.x + rect.size.width + 3, lbl.rect.origin.y,
                                  lbl.rect.size.width, lbl.rect.size.height);
            
            // now add metric
            [drawables addObject:lbl];
            [lbl release];
            
            y += lbl.rect.size.height + bulletSpacerY;
            
            // most recent
            NSArray *measurements = [overlay.metric.measurements sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]]];
            if (measurements.count > 0) {
                Measurement *m = [measurements lastObject];
                NSString *s = [NSString stringWithFormat:LocalizedString(@"RECENT_VALUE", nil), [m.value formattedNumberForReportCard]];
                CGRect rect = CGRectMake(sectionOrigin.x + bulletMarginLeft, y, sectionWidth, 999);
                MBDrawableLabel *lbl = [[MBDrawableLabel alloc] initWithText:s
                                                                        font:regularFont_
                                                                       color:[UIColor blackColor]
                                                               lineBreakMode:UILineBreakModeWordWrap 
                                                                   alignment:UITextAlignmentLeft
                                                                     andRect:rect];
                [lbl sizeToFit];
                [drawables addObject:lbl];
                [lbl release];
                y += lbl.rect.size.height + bulletSpacerY;
            }


            // target value and date    
            NSString *targetString = [self targetStringForChart:overlay];
            if (targetString.length) {
                CGRect rect = CGRectMake(sectionOrigin.x + bulletMarginLeft, y, sectionWidth, 999);
                MBDrawableLabel *lbl = [[MBDrawableLabel alloc] initWithText:targetString
                                                                        font:regularFont_
                                                                       color:[UIColor blackColor]
                                                               lineBreakMode:UILineBreakModeWordWrap 
                                                                   alignment:UITextAlignmentLeft
                                                                     andRect:rect];
                [lbl sizeToFit];
                [drawables addObject:lbl];
                [lbl release];
                y += lbl.rect.size.height + bulletSpacerY;
            }
            
            // On target
            NSNumber *isOnTarget = [self isOnTarget:overlay];
            if (isOnTarget) {
                NSString *boolString = isOnTarget.boolValue ? LocalizedString(@"YES", nil) : LocalizedString(@"NO", nil);
                NSString *onTargetString = [NSString stringWithFormat:LocalizedString(@"ON_TARGET", nil), boolString];
                
                CGRect rect = CGRectMake(sectionOrigin.x + bulletMarginLeft, y, sectionWidth, 999);
                MBDrawableLabel *lbl = [[MBDrawableLabel alloc] initWithText:onTargetString
                                                                        font:regularFont_
                                                                       color:[UIColor blackColor]
                                                               lineBreakMode:UILineBreakModeWordWrap 
                                                                   alignment:UITextAlignmentLeft
                                                                     andRect:rect];
                [lbl sizeToFit];
                [drawables addObject:lbl];
                [lbl release];
//                y += lbl.rect.size.height + bulletSpacerY;
            }

        }
        
    }
    
    
    return drawables;
}

-(NSMutableArray*)commentSectionForChart:(Chart*)chart sectionOrigin:(CGPoint)sectionOrigin
{            
    NSMutableArray *drawables = [NSMutableArray array];
    
    // only if we have an overlay which is comments-based do we add drawables
    Chart *overlayChart = [Chart chartWithUUID:chart.overlay];
    if (!(overlayChart && overlayChart.chartType.intValue == ChartTypeComments)) {
        return drawables;
    }

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"metric=%@ && comment!=nil && comment!=''", chart.metric];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
    NSArray *commentMeasurements =  [DataManager arrayForEntity:NSStringFromClass([Measurement class])
                                           sortDescriptorsOrNil:[NSArray arrayWithObject:sortDescriptor]
                                                 predicateOrNil:predicate];
    
    int commentNum = 0;
    CGFloat offsetY = 0, marginTop = 2, bulletWidth, bulletSpacerX = 2;
    CGFloat sectionWidth = column1RightEdge_ - column1LeftEdge_ - sectionMarginLeft;
    for (Measurement *measurement in commentMeasurements) {
        
        // because we need the comments to wrap with a tab stop, separate bullet from comment
        NSString *alpha = [ChartView abbreviationForComment:commentNum++];
        bulletWidth = alpha.length*10 + 2;
        NSString *alphaBullet = [NSString stringWithFormat:@"%@.", alpha];
        CGRect alphaRect = CGRectMake(sectionOrigin.x, sectionOrigin.y + offsetY + marginTop, bulletWidth, 999);
        MBDrawableLabel *alphaLabel = [[MBDrawableLabel alloc] initWithText:alphaBullet 
                                                                       font:regularFont_ 
                                                                      color:[UIColor blackColor]
                                                              lineBreakMode:UILineBreakModeClip
                                                                  alignment:UITextAlignmentLeft
                                                                    andRect:alphaRect];
        
        // comment
        NSString *commentString = [NSString stringWithFormat:@"%@: %@", 
                                   [measurement.date formattedDate1],
                                   measurement.comment
                                   ];
        CGRect commentRect = CGRectMake(sectionOrigin.x+bulletWidth+bulletSpacerX, sectionOrigin.y + offsetY + marginTop, 
                                        sectionWidth-alphaLabel.rect.size.width-bulletSpacerX, 999);
        MBDrawableLabel *commentLabel = [[MBDrawableLabel alloc] initWithText:commentString 
                                                                         font:regularFont_ 
                                                                        color:[UIColor blackColor]
                                                                lineBreakMode:UILineBreakModeWordWrap
                                                                    alignment:UITextAlignmentLeft
                                                                      andRect:commentRect];
        [commentLabel sizeToFit];        
        [drawables addObject:commentLabel];
        [commentLabel release];
        
        // need to make the alphaBullet the same height as the comment, so they end up on the same page
        alphaLabel.rect = CGRectMake(alphaLabel.rect.origin.x, alphaLabel.rect.origin.y, alphaLabel.rect.size.width, commentLabel.rect.size.height);
        [drawables addObject:alphaLabel];
        [alphaLabel release];
        
        // prepare for next
        offsetY += commentLabel.rect.size.height + bulletSpacerY;
    }
    return drawables;
}



#pragma mark - utility

-(NSNumber*)isOnTarget:(Chart*)chart
{
    // figure out if the trendline will exceed the target (or in some cases it is supposed to be less)
    NSNumber *isOnTarget;
    NSDateComponents *components;
    NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];    
    NSDate *chartStartDate = [chart startDate];
    LinearRegression *lr = [[LinearRegression alloc] initWithChart:chart chartStartDate:chartStartDate];
    if (chart.metric.targetDate && [chart.metric isNumeric]) {
        
        // need the number of days since the starting month (ie Jan 1, 2011 in our example) of this measurement        
        components = [gregorian components:NSDayCalendarUnit
                                  fromDate:chartStartDate
                                    toDate:chart.metric.targetDate options:0];
        NSInteger dayOfYear = [components day];
        CGFloat trendVal = [lr yVal:(CGFloat)dayOfYear];
        CGFloat targetVal = chart.metric.parseNumberFromTargetValue.floatValue;
        
        if (chart.metric.successIndicator.intValue == SuccessIndicatorMeetOrExceed) {
            isOnTarget = [NSNumber numberWithBool:trendVal >= targetVal];            
            
        } else { // SuccessIndicatorMeetOrSubcede
            isOnTarget = [NSNumber numberWithBool:trendVal <= targetVal];
            
        }
        
    } else {
        isOnTarget = nil;
    }
    [lr release];
    return isOnTarget;
}

-(NSString*)targetStringForChart:(Chart*)chart
{
    // target value and date
    NSMutableString *targetString = [[NSMutableString alloc] init];
    if (chart.metric.targetValue) {
        NSString *target;
        if ([chart.metric isNumeric]) {
            target = [[chart.metric parseNumberFromTargetValue] formattedNumberForReportCard];
        } else {
            target = chart.metric.targetValue;
        }
        [targetString appendFormat:LocalizedString(@"STRAT_TARGET", nil), target];
    }
    
    if (chart.metric.targetDate) {
        [targetString appendFormat:LocalizedString(@"STRAT_TARGET_BY", nil), [chart.metric.targetDate formattedDateForTarget]];
    }

    return [targetString autorelease];
}

#pragma mark - Report

- (NSString*)companyName
{
    return [reportHelper_ companyName];
}

- (NSString*)stratFileName
{
    return [reportHelper_ stratFileName];
}

- (NSString*)reportTitle
{
    return LocalizedString(@"REPORT_CARD", nil);
}



@end
