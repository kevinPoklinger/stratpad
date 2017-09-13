//
//  GanttChartActivityRow.m
//  StratPad
//
//  Created by Eric Rogers on 11-12-10.
//  Copyright (c) 2011 Glassey Strategy. All rights reserved.
//

#import "GanttChartActivityRow.h"
#import "ActivityGanttTimeline.h"
#import "MBDrawableLabel.h"
#import "MBHorizontalArrow.h"
#import "MBDrawableHorizontalLine.h"
#import "NSDate-StratPad.h"
#import "MBDiamond.h"
#import "SkinManager.h"

#define rowHeaderInsets_ UIEdgeInsetsMake(0, 14.f, 0, 6.f)

@interface GanttChartActivityRow (Private)
- (void)drawContent;
@end

@implementation GanttChartActivityRow

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
    
    
    // draw the timeline itself
    ActivityGanttTimeline *activityTimeline = (ActivityGanttTimeline*)timeline_;
    
    if (!activityTimeline.startDate && !activityTimeline.endDate) {
        // no start date or end date; don't draw anything else in this case...
        return;
    }    

    uint startX, endX;

    if ((activityTimeline.startDate && activityTimeline.endDate) || !activityTimeline.endDate) {
        startX = [self xCoordinateForDate:activityTimeline.startDate];
        endX = [self xCoordinateForDate:activityTimeline.endDate];
        
        CGFloat lineWidth = 4.f;
        UIColor *arrowColor = [[SkinManager sharedManager] colorForProperty:kSkinSection3SmallArrowColor forMediaType:mediaType_];
        if (!activityTimeline.endDate || [activityTimeline.endDate compareDayMonthAndYearTo:[columnDates_ lastObject]] != NSOrderedAscending) {
            
            //just have a start date, or the end date is after the last date in the graph, so draw a horizontal arrow
            CGSize arrowHeadSize = CGSizeMake(4*lineWidth, 3*lineWidth);
            
            uint startX = activityTimeline.startDate ? [self xCoordinateForDate:activityTimeline.startDate] : startingXForValueColumns_;                
            CGRect arrowRect = CGRectMake(startX, rect_.origin.y, endX - startX, rowHeight_);
            
            MBHorizontalArrow *horizontalArrow = [[MBHorizontalArrow alloc] initWithRect:arrowRect arrowHeadSize:arrowHeadSize andLineWidth:lineWidth];
            horizontalArrow.color = arrowColor;
            [horizontalArrow draw];
            [horizontalArrow release];        
            
        } else {
            // just draw a horizontal line
            
            CGPoint origin = CGPointMake(startX, rect_.origin.y + (rowHeight_ - lineWidth)/2);
            MBDrawableHorizontalLine *themeLine = [[MBDrawableHorizontalLine alloc] initWithOrigin:origin 
                                                                                             width:endX - startX 
                                                                                         thickness:lineWidth
                                                                                          andColor:arrowColor];
            [themeLine draw];
            [themeLine release];        
        }        
        
    }  else {
        // only an end date - diamond
        
        CGFloat diamondDiameter = 16.f;
        
        // center the diamond vertically in the rect.
        CGRect diamondRect = CGRectMake([self xCoordinateForDate:activityTimeline.endDate] - diamondDiameter/2, 
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
