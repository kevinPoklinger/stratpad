//
//  GanttChartRow.m
//  StratPad
//
//  Created by Eric Rogers on 11-12-09.
//  Copyright (c) 2011 Glassey Strategy. All rights reserved.
//

#import "GanttChartRow.h"
#import "NSDate-StratPad.h"
#import "NSCalendar+Expanded.h"

@implementation GanttChartRow

@synthesize backgroundColor;
@synthesize fontColor;

- (id)initWithRect:(CGRect)rect andColumnDates:(NSArray*)columnDates
{
    if ((self = [super init])) {
        rect_ = rect;     
        columnDates_ = [columnDates retain];
        startingXForValueColumns_ = rect_.origin.x + 0.3f * rect_.size.width;        
        endingXForValueColumns_ = rect_.origin.x + rect_.size.width;
    }
    return self;
}

#pragma mark - Memory Management

- (void)dealloc 
{
    [columnDates_ release];
    [backgroundColor release];
    [fontColor release];
    [super dealloc];
}

#pragma mark - Drawable

- (CGRect)rect
{
    return rect_;
}

- (void)setRect:(CGRect)rect
{
    rect_ = rect;
}

- (void)draw
{
    WLog(@"This method should be overridden!");
}

- (CGRect)rectForColumn:(NSUInteger)column
{    
    if (column == 0) { 
        return CGRectMake(rect_.origin.x, rect_.origin.y, startingXForValueColumns_ - rect_.origin.x, rowHeight_);                
    } else {
        uint x = startingXForValueColumns_ + (column - 1) * valueColumnWidth_;
        return CGRectMake(x, rect_.origin.y, valueColumnWidth_, rowHeight_);        
    }
}

- (NSUInteger)xCoordinateForDate:(NSDate*)date
{    
    if (!date || [date compareDayMonthAndYearTo:[columnDates_ lastObject]] == NSOrderedDescending) {
        // no date, or date is greater than the end date of the chart, so return the max x position.
        return endingXForValueColumns_ - 1; //subtract a pixel to account for the right-border.
    }

    if ([date compareDayMonthAndYearTo:[columnDates_ objectAtIndex:0]] == NSOrderedAscending)  {
        // date is earlier than the starting date for the chart.
        return startingXForValueColumns_;
    }
    
    uint x = startingXForValueColumns_;
    NSDate *quarterDate;
    for (uint i = 1; i < columnDates_.count; i++) {
        
        quarterDate = [columnDates_ objectAtIndex:i];
        
        if ([date compareDayMonthAndYearTo:quarterDate] == NSOrderedSame) {
            //date falls on the date for the quarter, so we are done.
            x += valueColumnWidth_;
            break;
            
        } else if ([date compareDayMonthAndYearTo:quarterDate] == NSOrderedDescending) {
            // date is greater than the date of the current quarter, so add the width
            // of a quarter column and keep going...
            x += valueColumnWidth_;
            
        } else {            
            // date is before the current quarter date, so determine
            // how many days after the last quarter it is and map those appropriately.
            
            NSDate *previousQuarterDate = [columnDates_ objectAtIndex:(i - 1)];
            unsigned unitFlags = NSDayCalendarUnit;
            NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];
            NSDateComponents *comps = [gregorian components:unitFlags fromDate:previousQuarterDate toDate:quarterDate options:0];        
            
            NSUInteger numDaysInQuarter = [comps day];
            CGFloat pixelsPerDay = (float)((float)valueColumnWidth_ / (float)numDaysInQuarter);    
            comps = [gregorian components:unitFlags fromDate:previousQuarterDate toDate:date options:0];
            
            NSUInteger numDaysForDate = [comps day];
            
            x += numDaysForDate * pixelsPerDay;
            break;
        }        
    }
    
    return x;
}

@end
