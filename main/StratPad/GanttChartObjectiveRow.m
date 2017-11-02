//
//  GanttChartObjectiveRow.m
//  StratPad
//
//  Created by Eric Rogers on 11-12-10.
//  Copyright (c) 2011 Glassey Strategy. All rights reserved.
//

#import "GanttChartObjectiveRow.h"
#import "MBDrawableLabel.h"
#import "ObjectiveGanttTimeline.h"
#import "Metric.h"
#import "MBDiamond.h"

#define rowHeaderInsets_ UIEdgeInsetsMake(0, 8.f, 0, 6.f)

@interface GanttChartObjectiveRow (Private)
- (void)drawContent;
@end

@implementation GanttChartObjectiveRow

#pragma mark - Public

- (id)initWithRect:(CGRect)rect headingFont:(UIFont*)headingFont columnDates:(NSArray*)columnDates 
  andGanttTimeline:(GanttTimeline*)timeline andMediaType:(MediaType)mediaType
{
    CGFloat detailRowHeight = [GanttChartDetailRow heightWithTitle:timeline.title rowWidth:rect.size.width font:headingFont restrictedToHeight:kMaxRowHeight insets:rowHeaderInsets_];
    CGRect detailRowRect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, detailRowHeight);
    if ((self = [super initWithRect:detailRowRect headingFont:headingFont columnDates:columnDates andGanttTimeline:timeline andMediaType:mediaType])) {

    }
    return self;
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
    // draw the row heading for an objective timeline
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
    
    // for R9 Gantt only, if an objective has a metric which has a date, show the diamond
    // we don't want to show blank lines - overriding principle
    if ([(ObjectiveGanttTimeline*)timeline_ shouldDrawMetricMilestones]) {

        Objective *objective = [(ObjectiveGanttTimeline*)timeline_ objective];        
        if (objective.metrics.count) {
            
            // look for target dates in metrics - grab the greatest date
            NSDate *metricDate = [NSDate distantPast];
            // we want to draw diamonds for objectives which have a metric with a targetdate, irrespective of targetvalue
            // use the latest date
            for (Metric *metric in objective.metrics) {
                if ([metricDate compare:metric.targetDate] == NSOrderedAscending) {
                    metricDate = metric.targetDate;
                }
            }
     
            if (![metricDate isEqualToDate:[NSDate distantPast]]) {
                // draw the diamond
                CGFloat diamondDiameter = 16.f;
                
                // center the diamond vertically in the rect.
                CGRect diamondRect = CGRectMake([self xCoordinateForDate:metricDate] - diamondDiameter/2, 
                                                rect_.origin.y + (rect_.size.height - diamondDiameter)/2, 
                                                diamondDiameter, 
                                                diamondDiameter);
                
                MBDiamond *diamond = [[MBDiamond alloc] initWithRect:diamondRect];
                diamond.color = [[SkinManager sharedManager] colorForProperty:kSkinSection3DiamondColor forMediaType:mediaType_];
                [diamond draw];
                [diamond release];
                
            }
        }
    }
    
}

@end
