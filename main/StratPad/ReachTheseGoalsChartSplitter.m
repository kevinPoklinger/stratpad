//
//  ReachTheseGoalsChartSplitter.m
//  StratPad
//
//  Created by Eric on 11-10-11.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "ReachTheseGoalsChartSplitter.h"
#import "ReachTheseGoalsChart.h"
#import "ReachTheseGoalsDataSource.h"
#import "Goal.h"


@implementation ReachTheseGoalsChartSplitter

- (id)initWithFirstRect:(CGRect)firstRect andSubsequentRect:(CGRect)subsequentRect
{
    if ((self = [super init])) {
        firstRect_ = firstRect;
        subsequentRect_ = subsequentRect;
    }
    return self;
}

- (NSArray*)splitDrawable:(id<Drawable>)drawable
{
    ReachTheseGoalsChart *chartToSplit = ((ReachTheseGoalsChart*)drawable);
    ReachTheseGoalsDataSource *dataSource = chartToSplit.dataSource;
    NSDate *startDate = [dataSource.columnDates objectAtIndex:0];

    NSMutableArray *charts = [NSMutableArray array];
    CGRect splitRect = firstRect_;

    ReachTheseGoalsDataSource *splitDataSource = [[ReachTheseGoalsDataSource alloc] initWithStartDate:startDate forIntervalInMonths:dataSource.intervalInMonths];
    ReachTheseGoalsChart *chart = nil;

    NSArray *keys = [dataSource.goals allKeys];
    NSArray *goals;
    
    for (NSString *key in keys) {
        goals = [dataSource.goals valueForKey:key];
        
        [splitDataSource.goals setValue:goals forKey:key];
        
        if ([ReachTheseGoalsChart heightWithDataSource:splitDataSource font:chartToSplit.font andRowWidth:splitRect.size.width] > splitRect.size.height) {
            
            [splitDataSource.goals removeObjectForKey:key];            
            chart = [[ReachTheseGoalsChart alloc] initWithRect:splitRect 
                                                          font:chartToSplit.font 
                                                      boldFont:chartToSplit.boldFont 
                                                  andDataSource:splitDataSource];            
            chart.headingFontColor = chartToSplit.headingFontColor;
            chart.fontColor = chartToSplit.fontColor;    
            chart.lineColor = chartToSplit.lineColor;
            chart.alternatingRowColor = chartToSplit.alternatingRowColor;
            chart.diamondColor = chartToSplit.diamondColor;    
            [chart sizeToFit];
            [charts addObject:chart];
            [chart release];
            [splitDataSource release];
            
            splitRect = subsequentRect_;
            splitDataSource = [[ReachTheseGoalsDataSource alloc] initWithStartDate:startDate forIntervalInMonths:dataSource.intervalInMonths];
            [splitDataSource.goals setValue:goals forKey:key];
        }
    }
    
    if (splitDataSource.goals.count > 0) {
        chart = [[ReachTheseGoalsChart alloc] initWithRect:splitRect 
                                                      font:chartToSplit.font 
                                                  boldFont:chartToSplit.boldFont 
                                             andDataSource:splitDataSource];            
        chart.headingFontColor = chartToSplit.headingFontColor;
        chart.fontColor = chartToSplit.fontColor;    
        chart.lineColor = chartToSplit.lineColor;
        chart.alternatingRowColor = chartToSplit.alternatingRowColor;
        chart.diamondColor = chartToSplit.diamondColor;    
        [chart sizeToFit];
        [charts addObject:chart];
        [chart release];        
    }
    
    [splitDataSource release];
    return charts;
}

+ (CGFloat)minimumSplitHeightForDrawable:(id<Drawable>)drawable
{
    ReachTheseGoalsChart *chart = (ReachTheseGoalsChart*)drawable;
    ReachTheseGoalsDataSource *dataSource = [[ReachTheseGoalsDataSource alloc] init];
    CGFloat minHeight = [ReachTheseGoalsChart heightWithDataSource:dataSource font:chart.font andRowWidth:chart.rect.size.width];
    [dataSource release];
    return minHeight;
}

@end
