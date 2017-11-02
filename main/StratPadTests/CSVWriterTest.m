//
//  CSVWriterTest.m
//  StratPad
//
//  Created by Julian Wood on 2/2/12.
//  Copyright 2012 Glassey Strategy. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "StratFile.h"
#import "Responsible.h"
#import "Theme.h"
#import "StratFile.h"
#import "DataManager.h"
#import "TestSupport.h"
#import "CoreDataTestCase.h"
#import "NSDate-StratPad.h"
#import "CSVFileWriter.h"
#import "IncomeStatementSummaryViewController.h"

@interface CSVWriterTest : CoreDataTestCase 
- (NSDate*)dateFromString:(NSString*)dateString;
@end


@implementation CSVWriterTest

- (void)testExportStratFileToCsvAtPath {
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    
    Theme *theme = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    theme.stratFile = stratFile;
    theme.title = @"Test Theme 1";
    theme.startDate = [self dateFromString:@"2011-12-01"];
    theme.endDate = [self dateFromString:@"2012-06-30"];
    theme.revenueMonthly = [NSNumber numberWithInt:1000];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filename = [[theme.title stringByReplacingOccurrencesOfString:@"/" withString:@"_"] stringByAppendingPathExtension:@"csv"];
    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:filename];
        
    CSVFileWriter *csvWriter = [[CSVFileWriter alloc] init];
    BOOL success = [csvWriter exportThemeToCsvAtPath:path theme:theme];
    [csvWriter release];
    
    STAssertTrue(success, @"Should have saved here: %@", path);
    
    DLog(@"Saved theme csv: %@", path);
    
}

-(void)testExportConsolidatedReportToCsvAtPath
{
    // need a stratfile with multiple themes, each with separate dates
    StratFile *stratFile = [TestSupport createTestStratFile];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filename = @"consolidated.csv";
    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:filename];
    
    CSVFileWriter *csvWriter = [[CSVFileWriter alloc] init];
    BOOL success = [csvWriter exportConsolidatedReportToCsvAtPath:path stratFile:stratFile];
    [csvWriter release];

    STAssertTrue(success, @"Should have saved here: %@", path);
    
    DLog(@"Saved consolidated csv: %@", path);
}

-(void)testExportIncomeStatementToCsvAtPath
{
    // target file
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filename = @"incomeStatement.csv";
    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:filename];
    
    // load json, representative of what we get from a service
    NSString *jsonPath = [[NSBundle bundleForClass:[CSVWriterTest class]] pathForResource:@"IncomeStatementSummary" ofType:@"json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:jsonPath];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    
    CSVFileWriter *csvWriter = [[CSVFileWriter alloc] init];
    [csvWriter exportIncomeStatementToCsvAtPath:path json:json];
    [csvWriter release];
        
    DLog(@"Saved income statement csv: %@", path);    
}

- (NSDate*)dateFromString:(NSString*)dateString
{
    // 2011-12-01 ie. yyyy-mm-dd
    return [NSDate dateTimeFromISO8601:[NSString stringWithFormat:@"%@T00:00:00+0000", [dateString stringByReplacingOccurrencesOfString:@"-" withString:@""]]];
}



@end