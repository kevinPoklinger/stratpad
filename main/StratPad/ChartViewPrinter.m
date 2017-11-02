//
//  ChartViewPrinter.m
//  StratPad
//
//  Created by Julian Wood on 12-05-10.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "ChartViewPrinter.h"
#import "MBDrawableReportHeader.h"
#import "NSDate-StratPad.h"
#import "MainChartView.h"
#import "DataManager.h"
#import "Measurement.h"
#import "MBDrawableLabel.h"
#import "PageSpooler.h"

@implementation ChartViewPrinter

- (id)initWithChart:(Chart*)chart
{
    self = [super init];
    if (self) {
        chart_ = [chart retain];
        skinMan_ = [SkinManager sharedManager];
        reportHelper_ = [[ReportHelper alloc] init];
        numPages_ = 0;
        hasMorePages_ = YES;
    }
    return self;
}

- (void)dealloc
{
    [chart_ release];
    [reportHelper_ release];
    [super dealloc];
}

#pragma mark - PrintReportDelegate

- (BOOL)hasMorePages
{
    // always have at least one page
    // if we have a comment overlay with >= 1 comment, then we have at least two pages
    // we don't know how many comment pages until we have a rect to draw to, and we've done a layout
    
    return hasMorePages_;
}

- (void)drawPage:(NSInteger)pageIndex inRect:(CGRect)rect
{    
    pageRect_ = rect;
        
    CGFloat textFontSizeForPrint = [skinMan_ fontSizeForProperty:kSkinSection4FontSize forMediaType:MediaTypePrint];
    UIFont *boldFont = [UIFont fontWithName:[skinMan_ stringForProperty:kSkinSection3BoldFontName forMediaType:MediaTypePrint] 
                                       size:textFontSizeForPrint];
    UIFont *regularFont = [UIFont fontWithName:[skinMan_ stringForProperty:kSkinSection3FontName forMediaType:MediaTypePrint] 
                                          size:textFontSizeForPrint];
    UIFont *italicFont = [UIFont fontWithName:[skinMan_ stringForProperty:kSkinSection3ItalicFontName forMediaType:MediaTypePrint] 
                                         size:textFontSizeForPrint];
    
    UIEdgeInsets printInsets_ = reportHelper_.printInsets;
    CGRect printInsetRect = CGRectMake(rect.origin.x + printInsets_.left, 
                                       rect.origin.y + printInsets_.top, 
                                       rect.size.width - printInsets_.left - printInsets_.right, 
                                       rect.size.height - printInsets_.top - printInsets_.bottom);
    
    // for print we shift the header to the left slightly, but keep the text aligned with the rest of the page.
    CGFloat headerLeftShift = 5.f;
    CGFloat footerHeight = 1.5*textFontSizeForPrint;
    CGRect headerRect = CGRectMake(printInsetRect.origin.x - headerLeftShift, 
                                   printInsetRect.origin.y, 
                                   printInsetRect.size.width + headerLeftShift, 
                                   printInsetRect.size.height - footerHeight);
    
    // footer is for page number
    CGRect footerRect = CGRectMake(printInsetRect.origin.x, 
                                   printInsetRect.origin.y + printInsetRect.size.height - footerHeight,
                                   printInsetRect.size.width, 
                                   footerHeight);  
    
    // header is included on all pages
    MBDrawableReportHeader *reportHeader = [[MBDrawableReportHeader alloc] initWithRect:headerRect textInsetLeft:headerLeftShift andReportTitle:[self reportTitle]];
    [reportHeader addTitleItemWithText:[self companyName] font:boldFont andColor:[UIColor blackColor]];
    [reportHeader addTitleItemWithText:[self stratFileName] font:regularFont andColor:[UIColor blackColor]];
    [reportHeader addTitleItemWithText:[[NSDate date] formattedDate2] font:italicFont andColor:[UIColor blackColor]];
    [reportHeader sizeToFit];
    
    CGFloat headerHeight = reportHeader.rect.size.height;        
    [reportHeader draw];    
    [reportHeader release];
    
    
    // draw the chart into contentRect_, which for printing does not equal our context rect
    bodyRect_ = CGRectMake(printInsetRect.origin.x, printInsetRect.origin.y + headerHeight, 
                              printInsetRect.size.width, printInsetRect.size.height - headerHeight - footerHeight);
    
    // figure out numPages by laying out comments
    NSInteger numPages = [self numPages];
    hasMorePages_ = pageIndex < numPages-1;
    
    BOOL isCommentsPage = pageIndex > 0;
    if (isCommentsPage) {
        // draw a page of comments
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, [[UIColor blackColor] CGColor]);
        
        NSNumber *commentPageNum = [NSNumber numberWithInt:pageIndex-1];
        NSArray *drawableComments = [pagedDrawableComments_ objectForKey:commentPageNum];
        for (id<Drawable> drawable in drawableComments) {
            [drawable draw];
        }
        
    } else {
        MainChartView *chartView = [[MainChartView alloc] initWithFrame:bodyRect_ chart:chart_];
        chartView.mediaType = MediaTypePrint;
        [chartView draw];
        [chartView release];
    }
    
    // now draw the page number in the footer
    NSString *footerText = [NSString stringWithFormat:@"%@ %i", LocalizedString(@"PAGE", nil), 
                            [[PageSpooler sharedManager] cumulativePageNumberForReport]];
    
    MBDrawableLabel *footerLabel = [[MBDrawableLabel alloc] initWithText:footerText 
                                                                    font:regularFont
                                                                   color:[UIColor blackColor]
                                                           lineBreakMode:UILineBreakModeTailTruncation 
                                                               alignment:UITextAlignmentCenter
                                                                 andRect:footerRect];    
    [footerLabel draw];
    [footerLabel release];

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
    return LocalizedString(@"STRATBOARD", nil);
}

#pragma mark - Utility

- (NSInteger) numPages
{    
    // numPages_ is at 0 until we go figure it out
    if (numPages_ == 0) {
        numPages_ = 1;
        
        // only overlays can be comment charts
        if (chart_.shouldDrawOverlay) {
            
            // grab the overlay and see if it has any comments
            Chart *overlay = [Chart chartWithUUID:chart_.overlay];
            if (overlay.chartType.intValue == ChartTypeComments) {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"metric=%@ && comment!=nil", overlay.metric];
                NSUInteger numComments = [DataManager countForEntity:NSStringFromClass([Measurement class]) predicateOrNil:predicate];
                if (numComments > 0) {
                    numPages_ += [self numCommentPages];
                }
            }
        }                
    }
    
    return numPages_;
}

- (NSInteger)numCommentPages 
{
    // only layout once
    if (!pagedDrawableComments_) {
        [self layoutComments];
    }
    
    return [pagedDrawableComments_ count];
}

-(void)layoutComments
{    
    pagedDrawableComments_ = [[NSMutableDictionary dictionary] retain];
    
    UIFont *regularFont = [UIFont fontWithName:[skinMan_ stringForProperty:kSkinSection3FontName forMediaType:MediaTypePrint] size:12.f];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"metric=%@ && comment!=nil", chart_.metric];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
    NSArray *commentMeasurements =  [DataManager arrayForEntity:NSStringFromClass([Measurement class])
                                           sortDescriptorsOrNil:[NSArray arrayWithObject:sortDescriptor]
                                                 predicateOrNil:predicate];
    
    int pageCtr = 0;
    CGFloat offsetY = 0, marginTop = 10;
    for (uint i=0, ct=commentMeasurements.count; i<ct; ++i) {
        Measurement *measurement = [commentMeasurements objectAtIndex:i];
        
        NSString *measurementString = [NSString stringWithFormat:@"%@. %@: %@", 
                                       [ChartView abbreviationForComment:i],
                                       [measurement.date formattedDate2],
                                       measurement.comment
                                       ];
        
        CGRect commentRect = CGRectMake(bodyRect_.origin.x, bodyRect_.origin.y + offsetY + marginTop, bodyRect_.size.width, 999);
        MBDrawableLabel *commentLabel = [[MBDrawableLabel alloc] initWithText:measurementString 
                                                                         font:regularFont 
                                                                        color:[UIColor blackColor]
                                                                lineBreakMode:UILineBreakModeWordWrap
                                                                    alignment:UITextAlignmentLeft
                                                                      andRect:commentRect];
        [commentLabel sizeToFit];
        
        if (CGRectContainsRect(bodyRect_, commentLabel.rect)) {
            // this page
            offsetY += commentLabel.rect.size.height + 5;
            
            // add to pagedDrawableComments
            NSNumber *pageNum = [NSNumber numberWithInt:pageCtr];
            NSMutableArray *drawables = [pagedDrawableComments_ objectForKey:pageNum];
            if (!drawables) {
                drawables = [NSMutableArray array];
                [pagedDrawableComments_ setObject:drawables forKey:pageNum];
            }
            [drawables addObject:commentLabel];
            [commentLabel release];

        } else {
            // goes on next page
            [commentLabel release];
            offsetY = 0;
            pageCtr++;
            i--;
            continue;
        }
        
    }
}

@end
