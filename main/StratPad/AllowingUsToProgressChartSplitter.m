//
//  AllowingUsToProgressChartSplitter.m
//  StratPad
//
//  Created by Eric on 11-10-11.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "AllowingUsToProgressChartSplitter.h"
#import "AllowingUsToProgressChart.h"
#import "AllowingUsToProgressDataSource.h"

@implementation AllowingUsToProgressChartSplitter

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
    AllowingUsToProgressChart *chartToSplit = ((AllowingUsToProgressChart*)drawable);
    AllowingUsToProgressDataSource *dataSource = chartToSplit.dataSource;
    UIFont *chartFont = chartToSplit.font;
    UIFont *chartBoldFont = chartToSplit.boldFont;
    
    NSMutableArray *charts = [NSMutableArray array];
    CGRect splitRect = firstRect_;
    
    AllowingUsToProgressDataSource *splitDataSource = [[AllowingUsToProgressDataSource alloc] init];
    splitDataSource.orderedFinancialHeadings = dataSource.orderedFinancialHeadings;
    splitDataSource.columnDates = dataSource.columnDates;
    
    AllowingUsToProgressChart *chart = nil;
    
    // the idea here is to add one set of values (ie 1 row) at a time to the splitDataSource, and figure out when it exceeds available space
    // then back off one row, create a chart from that splitDataSource, add it to our drawables to be returned
    // then proceed on finishing off all the necessary rows

    splitDataSource.revenueValues = dataSource.revenueValues;    
    CGFloat height = [AllowingUsToProgressChart heightWithDataSource:splitDataSource font:chartFont andRowWidth:splitRect.size.width];
    if (height > splitRect.size.height) {
        
        splitDataSource.revenueValues = nil;
                
        chart = [[AllowingUsToProgressChart alloc] initWithRect:CGRectMake(splitRect.origin.x, splitRect.origin.y, splitRect.size.width, height)
                                                           font:chartFont 
                                                       boldFont:chartBoldFont
                                                  andAllowingUsToProgressDataSource:splitDataSource];
        chart.headingFontColor = chartToSplit.headingFontColor;
        chart.fontColor = chartToSplit.fontColor;
        chart.lineColor = chartToSplit.lineColor;
        chart.alternatingRowColor = chartToSplit.alternatingRowColor;
        [chart sizeToFit];
        [charts addObject:chart];        
        [chart release];
        [splitDataSource release];
        
        splitRect = subsequentRect_;
        splitDataSource = [[AllowingUsToProgressDataSource alloc] init];
        splitDataSource.orderedFinancialHeadings = dataSource.orderedFinancialHeadings;
        splitDataSource.columnDates = dataSource.columnDates;
        splitDataSource.revenueValues = dataSource.revenueValues;
    }

    splitDataSource.cogsValues = dataSource.cogsValues;    
    height = [AllowingUsToProgressChart heightWithDataSource:splitDataSource font:chartFont andRowWidth:splitRect.size.width];
    if (height > splitRect.size.height) {
        
        splitDataSource.cogsValues = nil;
        chart = [[AllowingUsToProgressChart alloc] initWithRect:CGRectMake(splitRect.origin.x, splitRect.origin.y, splitRect.size.width, height)
                                                           font:chartFont 
                                                       boldFont:chartBoldFont
                                                  andAllowingUsToProgressDataSource:splitDataSource];
        chart.headingFontColor = chartToSplit.headingFontColor;
        chart.fontColor = chartToSplit.fontColor;
        chart.lineColor = chartToSplit.lineColor;
        chart.alternatingRowColor = chartToSplit.alternatingRowColor;
        [chart sizeToFit];
        [charts addObject:chart];
        [chart release];
        [splitDataSource release];
        
        splitRect = subsequentRect_;
        splitDataSource = [[AllowingUsToProgressDataSource alloc] init];
        splitDataSource.orderedFinancialHeadings = dataSource.orderedFinancialHeadings;
        splitDataSource.columnDates = dataSource.columnDates;
        splitDataSource.cogsValues = dataSource.cogsValues;
    }

    splitDataSource.grossMarginValues = dataSource.grossMarginValues;    
    height = [AllowingUsToProgressChart heightWithDataSource:splitDataSource font:chartFont andRowWidth:splitRect.size.width];
    if (height > splitRect.size.height) {
        
        splitDataSource.grossMarginValues = nil;
        chart = [[AllowingUsToProgressChart alloc] initWithRect:CGRectMake(splitRect.origin.x, splitRect.origin.y, splitRect.size.width, height)
                                                           font:chartFont 
                                                       boldFont:chartBoldFont
                                                  andAllowingUsToProgressDataSource:splitDataSource];
        chart.headingFontColor = chartToSplit.headingFontColor;
        chart.fontColor = chartToSplit.fontColor;
        chart.lineColor = chartToSplit.lineColor;
        chart.alternatingRowColor = chartToSplit.alternatingRowColor;
        [chart sizeToFit];
        [charts addObject:chart];
        [chart release];
        [splitDataSource release];
        
        splitRect = subsequentRect_;
        splitDataSource = [[AllowingUsToProgressDataSource alloc] init];
        splitDataSource.orderedFinancialHeadings = dataSource.orderedFinancialHeadings;
        splitDataSource.columnDates = dataSource.columnDates;
        splitDataSource.grossMarginValues = dataSource.grossMarginValues;
    }

    splitDataSource.radValues = dataSource.radValues;
    height = [AllowingUsToProgressChart heightWithDataSource:splitDataSource font:chartFont andRowWidth:splitRect.size.width];
    if (height > splitRect.size.height) {
        
        splitDataSource.radValues = nil;
        chart = [[AllowingUsToProgressChart alloc] initWithRect:CGRectMake(splitRect.origin.x, splitRect.origin.y, splitRect.size.width, height)
                                                           font:chartFont 
                                                       boldFont:chartBoldFont
                                                  andAllowingUsToProgressDataSource:splitDataSource];
        chart.headingFontColor = chartToSplit.headingFontColor;
        chart.fontColor = chartToSplit.fontColor;
        chart.lineColor = chartToSplit.lineColor;
        chart.alternatingRowColor = chartToSplit.alternatingRowColor;
        [chart sizeToFit];
        [charts addObject:chart];
        [chart release];
        [splitDataSource release];
        
        splitRect = subsequentRect_;
        splitDataSource = [[AllowingUsToProgressDataSource alloc] init];
        splitDataSource.orderedFinancialHeadings = dataSource.orderedFinancialHeadings;
        splitDataSource.columnDates = dataSource.columnDates;
        splitDataSource.radValues = dataSource.radValues;
    }

    splitDataSource.gaaValues = dataSource.gaaValues;
    height = [AllowingUsToProgressChart heightWithDataSource:splitDataSource font:chartFont andRowWidth:splitRect.size.width];
    if (height > splitRect.size.height) {
        
        splitDataSource.gaaValues = nil;
        chart = [[AllowingUsToProgressChart alloc] initWithRect:CGRectMake(splitRect.origin.x, splitRect.origin.y, splitRect.size.width, height)
                                                           font:chartFont 
                                                       boldFont:chartBoldFont
                                                  andAllowingUsToProgressDataSource:splitDataSource];
        chart.headingFontColor = chartToSplit.headingFontColor;
        chart.fontColor = chartToSplit.fontColor;
        chart.lineColor = chartToSplit.lineColor;
        chart.alternatingRowColor = chartToSplit.alternatingRowColor;
        [chart sizeToFit];
        [charts addObject:chart];
        [chart release];
        [splitDataSource release];
        
        splitRect = subsequentRect_;
        splitDataSource = [[AllowingUsToProgressDataSource alloc] init];
        splitDataSource.orderedFinancialHeadings = dataSource.orderedFinancialHeadings;
        splitDataSource.columnDates = dataSource.columnDates;
        splitDataSource.gaaValues = dataSource.gaaValues;
    }
    
    splitDataSource.samValues = dataSource.samValues;
    height = [AllowingUsToProgressChart heightWithDataSource:splitDataSource font:chartFont andRowWidth:splitRect.size.width];
    if (height > splitRect.size.height) {
        
        splitDataSource.samValues = nil;
        chart = [[AllowingUsToProgressChart alloc] initWithRect:CGRectMake(splitRect.origin.x, splitRect.origin.y, splitRect.size.width, height)
                                                           font:chartFont
                                                       boldFont:chartBoldFont
                              andAllowingUsToProgressDataSource:splitDataSource];
        chart.headingFontColor = chartToSplit.headingFontColor;
        chart.fontColor = chartToSplit.fontColor;
        chart.lineColor = chartToSplit.lineColor;
        chart.alternatingRowColor = chartToSplit.alternatingRowColor;
        [chart sizeToFit];
        [charts addObject:chart];
        [chart release];
        [splitDataSource release];
        
        splitRect = subsequentRect_;
        splitDataSource = [[AllowingUsToProgressDataSource alloc] init];
        splitDataSource.orderedFinancialHeadings = dataSource.orderedFinancialHeadings;
        splitDataSource.columnDates = dataSource.columnDates;
        splitDataSource.samValues = dataSource.samValues;
    }

    splitDataSource.totalExpenseValues = dataSource.totalExpenseValues;
    height = [AllowingUsToProgressChart heightWithDataSource:splitDataSource font:chartFont andRowWidth:splitRect.size.width];
    if (height > splitRect.size.height) {
        
        splitDataSource.totalExpenseValues = nil;
        chart = [[AllowingUsToProgressChart alloc] initWithRect:CGRectMake(splitRect.origin.x, splitRect.origin.y, splitRect.size.width, height)
                                                           font:chartFont 
                                                       boldFont:chartBoldFont
                                                  andAllowingUsToProgressDataSource:splitDataSource];
        chart.headingFontColor = chartToSplit.headingFontColor;
        chart.fontColor = chartToSplit.fontColor;
        chart.lineColor = chartToSplit.lineColor;
        chart.alternatingRowColor = chartToSplit.alternatingRowColor;
        [chart sizeToFit];
        [charts addObject:chart];
        [chart release];
        [splitDataSource release];
        
        splitRect = subsequentRect_;
        splitDataSource = [[AllowingUsToProgressDataSource alloc] init];
        splitDataSource.orderedFinancialHeadings = dataSource.orderedFinancialHeadings;
        splitDataSource.columnDates = dataSource.columnDates;
        splitDataSource.totalExpenseValues = dataSource.totalExpenseValues;
    }

    splitDataSource.contributionValues = dataSource.contributionValues;    
    height = [AllowingUsToProgressChart heightWithDataSource:splitDataSource font:chartFont andRowWidth:splitRect.size.width];
    if (height > splitRect.size.height) {
        
        splitDataSource.contributionValues = nil;
        chart = [[AllowingUsToProgressChart alloc] initWithRect:CGRectMake(splitRect.origin.x, splitRect.origin.y, splitRect.size.width, height)
                                                           font:chartFont 
                                                       boldFont:chartBoldFont
                                                  andAllowingUsToProgressDataSource:splitDataSource];
        chart.headingFontColor = chartToSplit.headingFontColor;
        chart.fontColor = chartToSplit.fontColor;
        chart.lineColor = chartToSplit.lineColor;
        chart.alternatingRowColor = chartToSplit.alternatingRowColor;
        [chart sizeToFit];
        [charts addObject:chart];
        [chart release];
        [splitDataSource release];
        
        splitRect = subsequentRect_;
        splitDataSource = [[AllowingUsToProgressDataSource alloc] init];
        splitDataSource.orderedFinancialHeadings = dataSource.orderedFinancialHeadings;
        splitDataSource.columnDates = dataSource.columnDates;

        splitDataSource.contributionValues = dataSource.contributionValues;
    }

    splitDataSource.cumulativeContributionValues = dataSource.cumulativeContributionValues;    
    height = [AllowingUsToProgressChart heightWithDataSource:splitDataSource font:chartFont andRowWidth:splitRect.size.width];
    chart = [[AllowingUsToProgressChart alloc] initWithRect:CGRectMake(splitRect.origin.x, splitRect.origin.y, splitRect.size.width, height)
                                                       font:chartFont 
                                                   boldFont:chartBoldFont
                                              andAllowingUsToProgressDataSource:splitDataSource];
    chart.headingFontColor = chartToSplit.headingFontColor;
    chart.fontColor = chartToSplit.fontColor;
    chart.lineColor = chartToSplit.lineColor;
    chart.alternatingRowColor = chartToSplit.alternatingRowColor;
    [chart sizeToFit];
    [charts addObject:chart];
    [chart release];
    [splitDataSource release];

    return charts;
}

+ (CGFloat)minimumSplitHeightForDrawable:(id<Drawable>)drawable
{
    CGFloat header = 28;
    AllowingUsToProgressChart *chart = (AllowingUsToProgressChart*)drawable;
    return header + chart.font.pointSize * 3;
}

@end
