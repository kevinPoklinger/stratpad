//
//  MultiPageReportBuilder.m
//  StratPad
//
//  Created by Eric Rogers on October 6, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//
//  Any report, which is scrolling on screen, will need to be broken into multiple pages for print. This
//  helps with that task. It's not about whether a single report has several pages (each of which may be 
//  scrolling and thus have several pages itself). So we use this for print tasks only.

#import "MultiPageReportBuilder.h"
#import "MBDrawableLabel.h"
#import "PageSpooler.h"
#import "ReportPrintFonts.h"
#import "MBDrawableLabelSplitter.h"
#import "MBDrawableGanttChart.h"
#import "ReachTheseGoalsChart.h"
#import "AllowingUsToProgressChart.h"
#import "GanttChartSplitter.h"
#import "ReachTheseGoalsChartSplitter.h"
#import "AllowingUsToProgressChartSplitter.h"
#import <math.h>

@interface MultiPageReportBuilder (Private)
- (void)addDrawable:(id<Drawable>)drawable toPagedDrawables:(NSMutableArray*)pagedDrawables atPageIndex:(uint)pageIndex;
- (void)addPageNumbersToPagedDrawables:(NSMutableArray*)pagedDrawables;
- (void)addReportHeaderToPagedDrawables:(NSMutableArray*)pagedDrawables;
- (Class<DrawableSplitter>)splitterClassForDrawable:(id<Drawable>)drawable;
@end

@implementation MultiPageReportBuilder

@synthesize mediaType = mediaType_;

- (id)initWithPageRect:(CGRect)rect
{
    if ((self = [super init])) {
        headerRect_ = CGRectZero;
        footerRect_ = CGRectMake(rect.origin.x, rect.origin.y + rect.size.height - 2*textFontSizeForPrint, rect.size.width, 2*textFontSizeForPrint);        
        drawablesRect_ = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height - footerRect_.size.height);        
        drawables_ = [[NSMutableArray array] retain];
    }
    return self;
}

- (id)initWithPageRect:(CGRect)rect andHeader:(MBDrawableReportHeader*)header
{
    if (self = [super init]) {
        reportHeader_ = [header retain];
        CGFloat headerRectPaddingBottom = 10.f;
        headerRect_ = CGRectMake(rect.origin.x, 
                                 rect.origin.y, 
                                 reportHeader_.rect.size.width, 
                                 reportHeader_.rect.size.height + headerRectPaddingBottom);
        footerRect_ = CGRectMake(rect.origin.x, rect.origin.y + rect.size.height - 2*textFontSizeForPrint, rect.size.width, 2*textFontSizeForPrint);        
        drawablesRect_ = CGRectMake(rect.origin.x, 
                                    rect.origin.y + headerRect_.size.height, 
                                    rect.size.width, 
                                    rect.size.height - footerRect_.size.height - headerRect_.size.height);        
        drawables_ = [[NSMutableArray array] retain];        
    }
    return self;
}

- (void)dealloc
{
    [reportHeader_ release];
    [drawables_ release];    
    [super dealloc];
}

- (void)addDrawable:(id<Drawable>)drawable
{
    [drawables_ addObject:drawable];
}

- (NSArray*)build
{
    NSMutableArray *pagedDrawables = [NSMutableArray array];
    
    // this is the position of the origin of the next drawable, on the page
    CGFloat yPage = drawablesRect_.origin.y;
    
    NSUInteger pageIndex = 0;
    
    // drawable rects at this stage are set in a single long page, one after the other, in order
    // we need to place them on pages and adjust their rects as necessary
    // that means their y-origins, and if necessary we split them, so that their heights also change
    for (uint i=0; i<drawables_.count; ++i) {
        id<Drawable> drawable = [drawables_ objectAtIndex:i];
        DLog(@"rect: %@", NSStringFromCGRect(drawable.rect));
        
        if (drawable.rect.size.width == 0 || drawable.rect.size.height == 0) {
            // don't include drawables with a width or height of 0.
            continue;
        }
        
        // figure out bottom margin (typically 10 or 20)
        CGFloat bottomMargin = 10;
        if (i+1 < drawables_.count) {
            bottomMargin = [[drawables_ objectAtIndex:i+1] rect].origin.y - (drawable.rect.origin.y + drawable.rect.size.height);
        }
        
        // now we can resize if needed
        if ([drawable respondsToSelector:@selector(sizeToFit)]) {
            [drawable sizeToFit];
        }
        
        // ignore the origin.x and width of the drawable - only interested in origin.y and height
        CGRect newRect = CGRectMake(drawablesRect_.origin.x, yPage, drawablesRect_.size.width, drawable.rect.size.height);
        if (CGRectContainsRect(drawablesRect_, newRect)) {
            // ok, it fits on the page
            newRect = CGRectMake(drawable.rect.origin.x, yPage, drawable.rect.size.width, drawable.rect.size.height);
            [drawable setRect:newRect];
            
            // add drawable to page
            [self addDrawable:drawable toPagedDrawables:pagedDrawables atPageIndex:pageIndex];
            
            // the origin for the next drawable
            yPage += drawable.rect.size.height + bottomMargin;
        }
        else {
            // need to split
            Class splitterClass = [self splitterClassForDrawable:drawable];
            
            // determine the minimum height of the first drawable so we know whether or not
            // it will fit on the remainder of the current page.
            CGFloat minHeight = [splitterClass minimumSplitHeightForDrawable:drawable];

            CGRect firstRect;
            if (yPage + minHeight < drawablesRect_.size.height) {
                // the first split drawable will fit on the remainder of the current page.
                firstRect = CGRectMake(drawable.rect.origin.x,
                                       yPage,
                                       drawable.rect.size.width,
                                       CGRectGetMaxY(drawablesRect_) - yPage);
            } else {
                // the first split drawable will not fit on the remainder of the current page,
                // so begin it on a new page, and adjust pageIndex and yOffset accordingly.
                yPage = drawablesRect_.origin.y;
                firstRect = CGRectMake(drawable.rect.origin.x,
                                       yPage,
                                       drawable.rect.size.width,
                                       drawablesRect_.size.height);
                pageIndex++;
            }
            
            // now split it
            id<DrawableSplitter> splitter = [[splitterClass alloc] initWithFirstRect:firstRect andSubsequentRect:drawablesRect_];
            NSArray *splitDrawables = [splitter splitDrawable:drawable];
            [splitter release];

            // finally go and add the split drawables to the document, starting at pageIndex and continuing
            // on successive pages until we have no split drawables left to add.
            for (uint i=0; i<splitDrawables.count; ++i) {
                id<Drawable> splitDrawable = [splitDrawables objectAtIndex:i];
                [self addDrawable:splitDrawable toPagedDrawables:pagedDrawables atPageIndex:pageIndex];
                
                // only augment pageIndex on the last page, if it was a full page drawable (odds are the last piece leaves some room on the page)
                if (i+1 < splitDrawables.count) {
                    pageIndex++;
                }
                
                yPage = CGRectGetMaxY(splitDrawable.rect) + bottomMargin;
            }
            
        }
        
    }
    
    // if applicable, add the report header to each page (eg in Gantt, we add a header to each page)
    [self addReportHeaderToPagedDrawables:pagedDrawables];
    
    // finally add page numbers to each page of drawables - ie one more drawable per page in the bottom margin
    [self addPageNumbersToPagedDrawables:pagedDrawables];
    
    return pagedDrawables;
}


#pragma mark - Private

- (void)addDrawable:(id<Drawable>)drawable toPagedDrawables:(NSMutableArray*)pagedDrawables atPageIndex:(uint)pageIndex
{
    if (pageIndex >= pagedDrawables.count) {
        // create pages until we can add the drawable to one.
        for (uint i = pagedDrawables.count; i <= pageIndex; i++) {
            [pagedDrawables addObject:[NSMutableArray array]];
        }
    }
    
    NSMutableArray *pageArray = [pagedDrawables objectAtIndex:pageIndex];
    TLog(@"Adding drawable with rect %@, to page %i", NSStringFromCGRect(drawable.rect), pageIndex);
    [pageArray addObject:drawable];    
}

- (void)addReportHeaderToPagedDrawables:(NSMutableArray*)pagedDrawables
{
    // only proceed if there is a report header to print (eg on the Gantt chart, which goes on every page)
    if (!reportHeader_) {
        return;
    }
    
    for (NSMutableArray *page in pagedDrawables) {
        reportHeader_.rect = headerRect_;
        [page addObject:reportHeader_];
    }
}

- (void)addPageNumbersToPagedDrawables:(NSMutableArray*)pagedDrawables
{
    MBDrawableLabel *footerLabel;
    NSString *footerText; 
    
    for (NSMutableArray *page in pagedDrawables) {
        footerText = [NSString stringWithFormat:@"%@ %i", LocalizedString(@"PAGE", nil), 
                      [[PageSpooler sharedManager] cumulativePageNumberForReport]];
        
        footerLabel = [[MBDrawableLabel alloc] initWithText:footerText
                                                       font:[UIFont fontWithName:fontNameForPrint size:textFontSizeForPrint] 
                                                      color:textFontColorForPrint
                                              lineBreakMode:UILineBreakModeTailTruncation 
                                                  alignment:UITextAlignmentCenter
                                                    andRect:footerRect_];
        [footerLabel sizeToFit];
        
        // center the footer label horizontally and align it with the bottom of the footer rect.
        footerLabel.rect = CGRectMake(footerRect_.origin.x + (footerRect_.size.width - footerLabel.rect.size.width)/2, 
                                      footerRect_.origin.y + (footerRect_.size.height - footerLabel.rect.size.height), 
                                      footerLabel.rect.size.width, 
                                      footerLabel.rect.size.height);
        
        [page addObject:footerLabel];        
        [footerLabel release];
    }    
}

- (Class<DrawableSplitter>)splitterClassForDrawable:(id<Drawable>)drawable
{
    Class<DrawableSplitter> splitterClass = nil;
    
    if ([drawable isKindOfClass:[MBDrawableLabel class]]) {
        splitterClass = [MBDrawableLabelSplitter class];
        
    } else if ([drawable isKindOfClass:[MBDrawableGanttChart class]]) {
        splitterClass = [GanttChartSplitter class];
        
    } else if ([drawable isKindOfClass:[ReachTheseGoalsChart class]]) {
        splitterClass = [ReachTheseGoalsChartSplitter class];
        
    } else if ([drawable isKindOfClass:[AllowingUsToProgressChart class]]) {
        splitterClass = [AllowingUsToProgressChartSplitter class];
        
    } else {
        WLog(@"No drawable splitter has been configured for class %@", NSStringFromClass([drawable class]));
    }
    
    return splitterClass;
}

@end
