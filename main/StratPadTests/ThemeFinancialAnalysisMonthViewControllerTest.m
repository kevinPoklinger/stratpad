//
//  ThemeFinancialAnalysisMonthViewControllerTest.m
//  StratPad
//
//  Created by Julian Wood on 12-01-25.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "StratFile.h"
#import "Theme.h"
#import "ThemeFinancialAnalysisMonthViewController.h"
#import "TestSupport.h"
#import "NSDate-StratPad.h"

@interface ThemeFinancialAnalysisMonthViewControllerTest : SenTestCase
@end

@implementation ThemeFinancialAnalysisMonthViewControllerTest

// R4 shows the same number of years for every theme, corresponding to entire strategy duration
- (void)testNumberOfPages
{
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    
    // for a single theme
    
    Theme *theme1 = [TestSupport createThemeWithTitle:@"Test Theme 1" andFinancialWidth:1 andOrder:0];
    theme1.startDate = [TestSupport dateFromString:@"2011-06-01"];
    [stratFile addThemesObject:theme1];
    
    theme1.endDate = [TestSupport dateFromString:@"2011-11-15"]; // 5.5 mo
    STAssertEquals([ThemeFinancialAnalysisMonthViewController numberOfPages:stratFile], (uint)1, @"Oops");    
    
    theme1.endDate = [TestSupport dateFromString:@"2013-11-15"]; // 2y 5.5 mo   
    STAssertEquals([ThemeFinancialAnalysisMonthViewController numberOfPages:stratFile], (uint)3, @"Oops");
    
    theme1.endDate = [TestSupport dateFromString:@"2014-01-01"]; // 2y 6 mo
    STAssertEquals([ThemeFinancialAnalysisMonthViewController numberOfPages:stratFile], (uint)3, @"Oops");
    
    theme1.endDate = [TestSupport dateFromString:@"2018-01-01"]; // 6y 6 mo
    STAssertEquals([ThemeFinancialAnalysisMonthViewController numberOfPages:stratFile], (uint)5, @"Oops");
    
    // two themes
        
    Theme *theme2 = [TestSupport createThemeWithTitle:@"Test Theme 2" andFinancialWidth:1 andOrder:0];
    theme2.startDate = [TestSupport dateFromString:@"2012-01-01"];
    [stratFile addThemesObject:theme2];
    
    theme1.endDate = [TestSupport dateFromString:@"2013-11-15"]; // 2y 5.5 mo   
    theme2.endDate = [TestSupport dateFromString:@"2013-12-31"]; // 2y
    STAssertEquals([ThemeFinancialAnalysisMonthViewController numberOfPages:stratFile], (uint)6, @"Oops");
    
    // three themes
    
    Theme *theme3 = [TestSupport createThemeWithTitle:@"Test Theme 3" andFinancialWidth:1 andOrder:0];
    theme3.startDate = [TestSupport dateFromString:@"2012-06-01"];
    [stratFile addThemesObject:theme3];

    theme1.endDate = [TestSupport dateFromString:@"2013-11-15"]; // 2y 5.5 mo   
    theme2.endDate = [TestSupport dateFromString:@"2013-12-31"]; // 2y
    theme3.endDate = [TestSupport dateFromString:@"2013-05-30"]; // 1y
    STAssertEquals([ThemeFinancialAnalysisMonthViewController numberOfPages:stratFile], (uint)9, @"Oops");
    
}

@end
