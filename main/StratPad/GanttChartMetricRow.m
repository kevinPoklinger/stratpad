//
//  GanttChartMetricRow.m
//  StratPad
//
//  Created by Eric Rogers on 11-12-10.
//  Copyright (c) 2011 Glassey Strategy. All rights reserved.
//

#import "GanttChartMetricRow.h"
#import "MetricGanttTimeline.h"
#import "MBDiamond.h"
#import "MBDrawableLabel.h"
#import "SkinManager.h"

#define rowHeaderInsets_ UIEdgeInsetsMake(0, 14.f, 0, 6.f)

@interface GanttChartMetricRow (Private)
- (void)drawContent;
@end

@implementation GanttChartMetricRow

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
    [self calculateLayoutForRow:rowHeaderInsets_];
    
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
    // draw the heading
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
    
    // now draw a diamond for the metric, only if it has a date
    MetricGanttTimeline *metricTimeline = (MetricGanttTimeline*)timeline_;

    if (metricTimeline.date) {
        
        CGFloat diamondDiameter = 16.f;
        
        // center the diamond vertically in the rect.
        CGRect diamondRect = CGRectMake([self xCoordinateForDate:metricTimeline.date] - diamondDiameter/2, 
                                        rect_.origin.y + (rect_.size.height - diamondDiameter)/2, 
                                        diamondDiameter, 
                                        diamondDiameter);
        
        MBDiamond *diamond = [[MBDiamond alloc] initWithRect:diamondRect];
        diamond.color = [[SkinManager sharedManager] colorForProperty:kSkinSection3DiamondColor forMediaType:mediaType_];
        [diamond draw];
        [diamond release];
    }        
}

@end
