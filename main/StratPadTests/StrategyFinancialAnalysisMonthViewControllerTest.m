//
//  StrategyFinancialAnalysisMonthViewControllerTest.m
//  StratPad
//
//  Created by Julian Wood on 12-01-24.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "StratFile.h"
#import "Theme.h"
#import "StrategyFinancialAnalysisMonthViewController.h"
#import "TestSupport.h"
#import "NSDate-StratPad.h"

@interface StrategyFinancialAnalysisMonthViewControllerTest : SenTestCase
- (NSDate*)dateFromString:(NSString*)dateString;
@end

@implementation StrategyFinancialAnalysisMonthViewControllerTest

- (void)testNumberOfPages
{
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    
    Theme *theme = [TestSupport createThemeWithTitle:@"Test Theme" andFinancialWidth:1 andOrder:0];
    theme.startDate = [self dateFromString:@"2011-06-01"];
    [stratFile addThemesObject:theme];
    
    theme.endDate = [self dateFromString:@"2011-11-15"]; // 5.5 mo
    STAssertEquals([StrategyFinancialAnalysisMonthViewController numberOfPages:stratFile], (uint)1, @"Oops");    
    
    theme.endDate = [self dateFromString:@"2013-11-15"]; // 2y 5.5 mo   
    STAssertEquals([StrategyFinancialAnalysisMonthViewController numberOfPages:stratFile], (uint)3, @"Oops");
    
    theme.endDate = [self dateFromString:@"2014-01-01"]; // 2y 6 mo
    STAssertEquals([StrategyFinancialAnalysisMonthViewController numberOfPages:stratFile], (uint)3, @"Oops");

    theme.endDate = [self dateFromString:@"2018-01-01"]; // 6y 6 mo
    STAssertEquals([StrategyFinancialAnalysisMonthViewController numberOfPages:stratFile], (uint)5, @"Oops");

}

- (NSDate*)dateFromString:(NSString*)dateString
{
    // 2011-12-01 ie. yyyy-mm-dd
    return [NSDate dateTimeFromISO8601:[NSString stringWithFormat:@"%@T00:00:00+0000", [dateString stringByReplacingOccurrencesOfString:@"-" withString:@""]]];
}

@end
