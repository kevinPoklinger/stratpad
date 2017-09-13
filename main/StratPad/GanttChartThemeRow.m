//
//  GanttChartThemeRow.m
//  StratPad
//
//  Created by Eric Rogers on 11-12-09.
//  Copyright (c) 2011 Glassey Strategy. All rights reserved.
//

#import "GanttChartThemeRow.h"
#import "MBDrawableHorizontalLine.h"
#import "MBDrawableVerticalLine.h"
#import "MBDrawableLabel.h"
#import "MBHorizontalArrow.h"
#import "NSDate-StratPad.h"

#define rowHeaderInsets_ UIEdgeInsetsMake(0, 4.f, 0, 6.f)

@interface GanttChartThemeRow (Private)
- (void)calculateLayoutForRow;
- (void)drawContent;
@end

@implementation GanttChartThemeRow

#pragma mark - Memory Management

- (id)initWithRect:(CGRect)rect headingFont:(UIFont*)headingFont columnDates:(NSArray*)columnDates 
  andGanttTimeline:(GanttTimeline*)timeline andMediaType:(MediaType)mediaType
{
    CGFloat detailRowHeight = [GanttChartDetailRow heightWithTitle:timeline.title rowWidth:rect.size.width font:headingFont restrictedToHeight:kMaxRowHeight insets:rowHeaderInsets_];
    CGRect detailRowRect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, detailRowHeight);
    if ((self = [super initWithRect:detailRowRect headingFont:headingFont columnDates:columnDates andGanttTimeline:timeline andMediaType:mediaType])) {

    }
    return self;
}

- (void)dealloc 
{ 
    [super dealloc];
}

+(UIEdgeInsets)rowHeaderInsets
{
    return rowHeaderInsets_;
}


#pragma mark - Drawable

- (void)draw
{
    [self calculateLayoutForRow: rowHeaderInsets_];
    
    // only draw a background color if one has been set
    if (self.backgroundColor) {
        [self drawBackground];
    }
    
    [self drawLines];    
    [self drawContent];
}

#pragma mark - Private

- (void)drawContent
{
    CGRect headingRect = [self rectForColumn:0];
    headingRect = CGRectMake(headingRect.origin.x + rowHeaderInsets_.left, 
                             headingRect.origin.y + kCellYPadding, 
                             headingRect.size.width - rowHeaderInsets_.left - rowHeaderInsets_.right, 
                             headingRect.size.height - 2*kCellYPadding);
    MBDrawableLabel *headingLabel = [[MBDrawableLabel alloc] initWithText:timeline_.title                                     
                                                                     font:headingFont_ 
                                                                    color:self.fontColor 
                                                            lineBreakMode:UILineBreakModeWordWrap 
                                                                alignment:UITextAlignmentLeft 
                                                                  andRect:headingRect];
    [headingLabel sizeToFit];
    [headingLabel draw];
    [headingLabel release];

    ThemeGanttTimeline *themeTimeline = (ThemeGanttTimeline*)timeline_;
    
    uint startX = themeTimeline.startDate ? [self xCoordinateForDate:themeTimeline.startDate] : startingXForValueColumns_;
    uint endX = [self xCoordinateForDate:themeTimeline.endDate];
    
    CGFloat lineWidth = 8.f;
    if (themeTimeline.endDate && [themeTimeline.endDate compareDayMonthAndYearTo:[columnDates_ lastObject]] != NSOrderedDescending) {
        // end date is earlier than the last date in the chart, so just draw a horizontal line...        
        
        UIColor *arrowColor = [[SkinManager sharedManager] colorForProperty:kSkinSection3LargeArrowColor forMediaType:mediaType_];
        CGPoint origin = CGPointMake(startX, rect_.origin.y + (rowHeight_ - lineWidth)/2);
        MBDrawableHorizontalLine *themeLine = [[MBDrawableHorizontalLine alloc] initWithOrigin:origin 
                                                                                         width:endX - startX 
                                                                                     thickness:lineWidth
                                                                                      andColor:arrowColor];
        [themeLine draw];
        [themeLine release];        
        
    } else {
        // either no end date, or the end date is later than the last day in the chart, so draw a horizontal arrow.
        CGSize arrowHeadSize = CGSizeMake(3*lineWidth, 2*lineWidth);                                
        CGRect arrowRect = CGRectMake(startX, rect_.origin.y, endX - startX, rowHeight_);
        
        UIColor *arrowColor = [[SkinManager sharedManager] colorForProperty:kSkinSection3LargeArrowColor forMediaType:mediaType_];
        MBHorizontalArrow *horizontalArrow = [[MBHorizontalArrow alloc] initWithRect:arrowRect arrowHeadSize:arrowHeadSize andLineWidth:lineWidth];
        horizontalArrow.color = arrowColor;
        [horizontalArrow draw];
        [horizontalArrow release];        
    }
}

@end
