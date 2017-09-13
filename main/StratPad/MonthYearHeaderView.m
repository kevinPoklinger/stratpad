//
//  MonthYearHeaderView.m
//  StratPad
//
//  Created by Julian Wood on 12-04-20.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "MonthYearHeaderView.h"
#import "NSDate-StratPad.h"
#import "Chart.h"
#import "NSCalendar+Expanded.h"
#import "DataManager.h"
#import "Measurement.h"
#import "StratFileManager.h"
#import "MiniChartView.h"

@implementation MonthYearHeaderView

-(void)setup
{
    // grab all charts (which must have metric.measurements)
    // grab the last measurement by date
    // from that determine start date
    
    startDate_ = [[MiniChartView startDate] retain];
    TLog(@"start: %@", startDate_);
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
    
    // determine the labels for the x-axis from the start-date
    uint duration = 24; // months
    uint timeInterval = 1; // month
    
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];
    int numColumns = duration/timeInterval;
    CGFloat interval = rect.size.width/numColumns;
    for (int i=0; i<numColumns; i++) {
        
        // add a month to date
        [offsetComponents setMonth:i];
        NSDate *lblDate = [gregorian dateByAddingComponents:offsetComponents
                                                     toDate:startDate_
                                                    options:0
                           ];
        
        // draw the month abbrev
        [[lblDate monthNameChar] drawInRect:CGRectMake(i*interval, CGRectGetMaxY(rect)-20, interval, 17) 
                                    withFont:[UIFont boldSystemFontOfSize:15]
                               lineBreakMode:UILineBreakModeClip
                                   alignment:UITextAlignmentCenter];
        
        // draw the year over all January's
        NSDateComponents *monthYearComponent = [gregorian components:(NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:lblDate];
        if ([monthYearComponent month] == 1) {
            NSString *year = [NSString stringWithFormat:@"%i", [monthYearComponent year]];
            CGRect frame = CGRectMake(i*interval+3, 3, 50, 14);
            if (CGRectContainsRect(self.bounds, frame)) {                
                [year drawInRect:frame
                        withFont:[UIFont boldSystemFontOfSize:15]
                   lineBreakMode:UILineBreakModeClip
                       alignment:UITextAlignmentLeft];            
            }
        }
        
    }
    [offsetComponents release];

}

-(void)dealloc
{
    [startDate_ release];
    [super dealloc];
}

@end
