//
//  ReportCardPrinterTest.m
//  StratPad
//
//  Created by Julian Wood on 12-05-13.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "NSNumber-StratPad.h"
#import "StratFileManager.h"
#import "ChartReport.h"
#import "ChartReportSection.h"
#import "ChartReportHeader.h"
#import "ReportCardPrinter.h"
#import "StratBoardViewController.h"
#import "MBTestDrawable.h"

@interface ReportCardPrinterTest : SenTestCase
@end

@implementation ReportCardPrinterTest

-(void)testReportCard
{
    NSString *path = [[NSBundle bundleForClass:[ReportCardPrinterTest class]] 
                      pathForResource:@"ReportCardStratfile" ofType:@"xml"];
    
    // we're ignoring the returned stratfile, but this places the stratfile into the db
    StratFile *stratFile = [[StratFileManager sharedManager] stratFileFromXmlAtPath:path];
    
    STAssertEqualObjects(stratFile.name, @"V-Soft Strategy", @"Oops");
    
    [[StratFileManager sharedManager] loadStratFile:stratFile withChapterIndex:0];    
    STAssertEqualObjects([StratFileManager sharedManager].currentStratFile.name, @"V-Soft Strategy", @"Oops");


    
}

-(void)testFitsInRect
{
    
    ChartReport *chartReport = [[ChartReport alloc] init];
    chartReport.rect = CGRectMake(0, 0, 150, 200); 
    
    // does the chartReportRect fit in bodyRect, if the chart report rect has an origin of 100,100?
    CGRect bodyRect = CGRectMake(50, 50, 200, 200);
    
    STAssertFalse([chartReport fitsInRect:bodyRect atOrigin:CGPointMake(100, 100)], @"Oops");
    STAssertTrue([chartReport fitsInRect:bodyRect atOrigin:CGPointMake(50, 50)], @"Oops");
    STAssertTrue([chartReport fitsInRect:bodyRect atOrigin:CGPointMake(75, 50)], @"Oops");
    
}

-(void)testPartiallyFitsInRect
{
    ChartReport *chartReport = [[ChartReport alloc] init];
    chartReport.rect = CGRectMake(0, 0, 200, 400);

    MBTestDrawable *dia1 = [[MBTestDrawable alloc] initWithRect:CGRectMake(20, 100, 50, 50)];
    MBTestDrawable *dia2 = [[MBTestDrawable alloc] initWithRect:CGRectMake(20, 160, 50, 50)];
    MBTestDrawable *dia3 = [[MBTestDrawable alloc] initWithRect:CGRectMake(20, 220, 50, 50)];
    NSMutableArray *drawables = [NSMutableArray arrayWithObjects:dia1, dia2, dia3, nil];
    ChartReportSection *summarySection = [[ChartReportSection alloc] initWithDrawables:drawables];
    chartReport.summarySection = summarySection;
    [summarySection release];
    
    STAssertEquals(summarySection.rect, CGRectMake(20, 100, 50, 170), @"Oops");
    
    MBTestDrawable *dia4 = [[MBTestDrawable alloc] initWithRect:CGRectMake(20, 300, 80, 100)];
    ChartReportSection *chartSection = [[ChartReportSection alloc] initWithDrawables:[NSMutableArray arrayWithObject:dia4]];
    chartReport.chartSection = chartSection;
    [chartSection release];

    STAssertEquals(chartSection.rect, CGRectMake(20, 300, 80, 100), @"Oops");

    
    // check if we are the first chartReport in the left column
    CGRect bodyRect = CGRectMake(50, 50, 600, 500);

    STAssertTrue([chartReport fitsInRect:bodyRect atOrigin:CGPointMake(50, 50)], @"Oops");
    STAssertFalse([chartReport fitsInRect:bodyRect atOrigin:CGPointMake(50, 300)], @"Oops");

    // put a chartReport of 200x400 at 50,300 and see if it partially fits in 50,50,600,500
    // --> has 300 height available, summary uses up 270 px
    STAssertTrue([chartReport partiallyFitsInRect:bodyRect atOrigin:CGPointMake(50, 150)], @"Oops");
    STAssertFalse([chartReport partiallyFitsInRect:bodyRect atOrigin:CGPointMake(50, 300)], @"Oops");

}

-(void)testDrawPage
{
    
    StratBoardViewController *sbvc = [[StratBoardViewController alloc] initWithNibName:nil bundle:nil];
    
    [sbvc exportToPDF];
    

}



@end
