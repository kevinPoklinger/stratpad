//
//  ChartView.h
//  StratPad
//
//  Created by Julian Wood on 12-03-29.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Chart.h"
#import "SkinManager.h"

@interface ChartView : UIView {
@protected
    
    // normalized start date for the chart, including overlay
    NSDate *chartStartDate_;
    
    // normalized duration in months of the chart -> 12, 24, 36 etc
    NSUInteger chartDuration_; 
    
    // this is the number of days between the start of the chart grid and the end of its grid
    NSInteger xMax_;
    
    // this is the max y value + a suitable percentage
    CGFloat yMax_;
    
    // we draw things at a smaller scale for the Report Card, 1.0 on screen
    CGFloat scale_;
    
    // allows us to look for points in rects to find comments (matching abbrevs)
    NSMutableArray *commentBoxen_;
    
    // print or screen?
    MediaType mediaType_;
}

-(void)drawAreaChart:(CGRect)rect chart:(Chart*)chart;
-(void)drawBarChart:(CGRect)rect chart:(Chart*)chart;
-(void)drawLineChart:(CGRect)rect chart:(Chart*)chart;
-(void)drawCommentsChart:(CGRect)gridRect chart:(Chart*)chart;

-(void)drawColorWellWithGradientColorStart:(UIColor*)gradientColorStart gradientColorEnd:(UIColor*)gradientColorEnd inRect:(CGRect)rect;

+(NSString*)abbreviationForComment:(NSUInteger)index;

// get measurements with non-nil values, sorted by date, for chart
+(NSArray*)measurementsForChart:(Chart*)chart;

@property (nonatomic,assign) CGFloat scale;

@property (nonatomic,assign) MediaType mediaType;


@end
