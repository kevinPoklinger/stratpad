//
//  StratFileManagerTest.m
//  StratPad
//
//  Created by Julian Wood on 9/8/11.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "StratFileManager.h"
#import "StratFile.h"
#import "AppDelegate.h"
#import "Responsible.h"
#import "Theme.h"
#import "Objective.h"
#import "Activity.h"
#import "Frequency.h"
#import "StratFile.h"
#import "Metric.h"
#import "DataManager.h"
#import "TestSupport.h"
#import "EditionManager.h"
#import "CoreDataTestCase.h"
#import "NSDate-StratPad.h"
#import "Measurement.h"
#import "Chart.h"
#import "NSString-Expanded.h"

@interface StratFileManagerTest : CoreDataTestCase 
- (NSDate*)dateFromString:(NSString*)dateString;
@end


@implementation StratFileManagerTest

- (void)testExportStratFileToXmlAtPath {
    StratFile *stratFile = [TestSupport createTestStratFile];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filename = [[stratFile.name stringByReplacingOccurrencesOfString:@"/" withString:@"_"] stringByAppendingPathExtension:@"xml"];
    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:filename];
    
    BOOL success = [[StratFileManager sharedManager] exportStratFileToXmlAtPath:path stratFile:stratFile];
    
    STAssertTrue(success, @"Should have saved here: %@", path);
    
    DLog(@"Saved xml: %@", path);
    
}

- (void)testStratFileFromXmlAtPath
{
    // create a stratfile for import
    StratFile *stratFile = [TestSupport createTestStratFile];
    
    // override permissions so we don't see the default
    stratFile.permissions = @"0400";
    
    // check all the adjustments
    Theme *theme = [stratFile.themesSortedByOrder objectAtIndex:0];
    theme.revenueMonthly = [NSNumber numberWithInt:1];
    theme.revenueMonthlyAdjustment = [NSDecimalNumber decimalNumberWithString:@"5.1"];
    theme.revenueQuarterly = [NSNumber numberWithInt:2];
    theme.revenueQuarterlyAdjustment = [NSDecimalNumber decimalNumberWithString:@"5.2"];
    theme.revenueAnnually = [NSNumber numberWithInt:3];
    theme.revenueAnnuallyAdjustment = [NSDecimalNumber decimalNumberWithString:@"5.3"];

    theme.generalAndAdminMonthly = [NSNumber numberWithInt:4];
    theme.generalAndAdminMonthlyAdjustment = [NSDecimalNumber decimalNumberWithString:@"5.4"];
    theme.generalAndAdminQuarterly = [NSNumber numberWithInt:5];
    theme.generalAndAdminQuarterlyAdjustment = [NSDecimalNumber decimalNumberWithString:@"5.5"];
    theme.generalAndAdminAnnually = [NSNumber numberWithInt:6];
    theme.generalAndAdminAnnuallyAdjustment = [NSDecimalNumber decimalNumberWithString:@"5.6"];

    theme.cogsMonthly = [NSNumber numberWithInt:7];
    theme.cogsMonthlyAdjustment = [NSDecimalNumber decimalNumberWithString:@"5.7"];
    theme.cogsQuarterly = [NSNumber numberWithInt:8];
    theme.cogsQuarterlyAdjustment = [NSDecimalNumber decimalNumberWithString:@"5.8"];
    theme.cogsAnnually = [NSNumber numberWithInt:9];
    theme.cogsAnnuallyAdjustment = [NSDecimalNumber decimalNumberWithString:@"5.9"];

    theme.researchAndDevelopmentMonthly = [NSNumber numberWithInt:10];
    theme.researchAndDevelopmentMonthlyAdjustment = [NSDecimalNumber decimalNumberWithString:@"6.1"];
    theme.researchAndDevelopmentQuarterly = [NSNumber numberWithInt:11];
    theme.researchAndDevelopmentQuarterlyAdjustment = [NSDecimalNumber decimalNumberWithString:@"6.2"];
    theme.researchAndDevelopmentAnnually = [NSNumber numberWithInt:12];
    theme.researchAndDevelopmentAnnuallyAdjustment = [NSDecimalNumber decimalNumberWithString:@"6.3"];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filename = [[stratFile.name stringByReplacingOccurrencesOfString:@"/" withString:@"_"] stringByAppendingPathExtension:@"xml"];
    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:filename];
    
    BOOL success = [[StratFileManager sharedManager] exportStratFileToXmlAtPath:path stratFile:stratFile];
    STAssertTrue(success, @"Should have saved here: %@", path);
    
    // import the stratfile xml
    StratFile *importedStratFile = [[StratFileManager sharedManager] stratFileFromXmlAtPath:path];

    STAssertTrue([importedStratFile.dateCreated compare:stratFile.dateCreated], @"Wrong created date");
    STAssertTrue([importedStratFile.dateModified compare:stratFile.dateModified], @"Wrong modified date");
    STAssertTrue([importedStratFile.dateLastAccessed compare:stratFile.dateLastAccessed], @"Wrong last accessed date");

    STAssertEqualObjects(importedStratFile.name, @"Business Plan", @"Wrong name");
    STAssertEqualObjects(importedStratFile.companyName, @"ACME Cool Co.", @"Wrong name");
    STAssertNil(importedStratFile.city, @"Oops");
    STAssertNil(importedStratFile.country, @"Oops");
    STAssertNil(importedStratFile.provinceState, @"Oops");
    STAssertNil(importedStratFile.industry, @"Oops");
    
    STAssertEqualObjects(importedStratFile.permissions, @"0400", @"Wrong permissions: %@", importedStratFile.permissions);
    
    // check adjustments
    Theme *importedTheme = [importedStratFile.themesSortedByOrder objectAtIndex:0];
    STAssertEquals(importedTheme.revenueMonthly.intValue, (int)1, @"Oops");
    STAssertTrue([importedTheme.revenueMonthlyAdjustment compare:[NSDecimalNumber decimalNumberWithString:@"5.1"]] == NSOrderedSame, @"Oops");
    STAssertEquals(importedTheme.revenueQuarterly.intValue, (int)2, @"Oops");
    STAssertTrue([importedTheme.revenueQuarterlyAdjustment compare:[NSDecimalNumber decimalNumberWithString:@"5.2"]] == NSOrderedSame, @"Oops");
    STAssertEquals(importedTheme.revenueAnnually.intValue, (int)3, @"Oops");
    STAssertTrue([importedTheme.revenueAnnuallyAdjustment compare:[NSDecimalNumber decimalNumberWithString:@"5.3"]] == NSOrderedSame, @"Oops");
    
    STAssertEquals(importedTheme.generalAndAdminMonthly.intValue, (int)4, @"Oops");
    STAssertTrue([importedTheme.generalAndAdminMonthlyAdjustment compare:[NSDecimalNumber decimalNumberWithString:@"5.4"]] == NSOrderedSame, @"Oops");
    STAssertEquals(importedTheme.generalAndAdminQuarterly.intValue, (int)5, @"Oops");
    STAssertTrue([importedTheme.generalAndAdminQuarterlyAdjustment compare:[NSDecimalNumber decimalNumberWithString:@"5.5"]] == NSOrderedSame, @"Oops");
    STAssertEquals(importedTheme.generalAndAdminAnnually.intValue, (int)6, @"Oops");
    STAssertTrue([importedTheme.generalAndAdminAnnuallyAdjustment compare:[NSDecimalNumber decimalNumberWithString:@"5.6"]] == NSOrderedSame, @"Oops");
    
    STAssertEquals(importedTheme.cogsMonthly.intValue, (int)7, @"Oops");
    STAssertTrue([importedTheme.cogsMonthlyAdjustment compare:[NSDecimalNumber decimalNumberWithString:@"5.7"]] == NSOrderedSame, @"Oops");
    STAssertEquals(importedTheme.cogsQuarterly.intValue, (int)8, @"Oops");
    STAssertTrue([importedTheme.cogsQuarterlyAdjustment compare:[NSDecimalNumber decimalNumberWithString:@"5.8"]] == NSOrderedSame, @"Oops");
    STAssertEquals(importedTheme.cogsAnnually.intValue, (int)9, @"Oops");
    STAssertTrue([importedTheme.cogsAnnuallyAdjustment compare:[NSDecimalNumber decimalNumberWithString:@"5.9"]] == NSOrderedSame, @"Oops");
    
    STAssertEquals(importedTheme.researchAndDevelopmentMonthly.intValue, (int)10, @"Oops");
    STAssertTrue([importedTheme.researchAndDevelopmentMonthlyAdjustment compare:[NSDecimalNumber decimalNumberWithString:@"6.1"]] == NSOrderedSame, @"Oops");
    STAssertEquals(importedTheme.researchAndDevelopmentQuarterly.intValue, (int)11, @"Oops");
    STAssertTrue([importedTheme.researchAndDevelopmentQuarterlyAdjustment compare:[NSDecimalNumber decimalNumberWithString:@"6.2"]] == NSOrderedSame, @"Oops");
    STAssertEquals(importedTheme.researchAndDevelopmentAnnually.intValue, (int)12, @"Oops");
    STAssertTrue([importedTheme.researchAndDevelopmentAnnuallyAdjustment compare:[NSDecimalNumber decimalNumberWithString:@"6.3"]] == NSOrderedSame, @"Oops");

    // check measurements
    Objective *obj = [[importedTheme objectivesSortedByOrder] objectAtIndex:0];
    Metric *metric = [[obj metrics] anyObject];
    STAssertEqualObjects(metric.summary, @"Revenue", @"Oops");
    STAssertEqualObjects(metric.successIndicator, [NSNumber numberWithInt:SuccessIndicatorMeetOrExceed], @"Oops");
    
    NSArray *measurements = [metric.measurements sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]]];
    Measurement *measurement = [measurements objectAtIndex:0];
    STAssertEqualObjects(measurement.value, [NSNumber numberWithInt:100], @"Oops");
    
    // check charts
    Chart *chart = [[metric charts] anyObject];
    STAssertEqualObjects(chart.title, @"Revenue Chart", @"Oops");
    STAssertEqualObjects(chart.zLayer, primaryChartLayer, @"Oops");
    STAssertEqualObjects(chart.chartType, [NSNumber numberWithInt:ChartTypeBar], @"Oops");
    STAssertEqualObjects(chart.showTrend, [NSNumber numberWithBool:NO], @"Oops");
    STAssertEqualObjects(chart.colorScheme, [NSNumber numberWithInt:7], @"Oops");
    STAssertEqualObjects(chart.showTarget, [NSNumber numberWithBool:NO], @"Oops");
    STAssertNotNil(chart.uuid, @"Oops");
    STAssertEquals(chart.uuid.length, (uint)36, @"Oops");
    STAssertEquals(chart.yAxisMax.intValue, (int)200, @"Oops");
    
    // write it back out so that we can see it
    NSString *rewriteFilename = [[[stratFile.name stringByReplacingOccurrencesOfString:@"/" withString:@"_"] stringByAppendingString:@"_rewrite"] stringByAppendingPathExtension:@"xml"];
    NSString *rewritePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:rewriteFilename];
    success = [[StratFileManager sharedManager] exportStratFileToXmlAtPath:rewritePath stratFile:importedStratFile];
    STAssertTrue(success, @"Should have saved here: %@", rewritePath);
    DLog(@"Saved rewrite xml: %@", rewritePath);

    // make sure input and output files are identical (though they may have elements in different orders)
    NSDictionary *pathAttrs = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:NULL];
    NSDictionary *rewritePathAttrs = [[NSFileManager defaultManager] attributesOfItemAtPath:rewritePath error:NULL];
    
    STAssertEquals([pathAttrs fileSize], [rewritePathAttrs fileSize], @"Oops: %@ != %@", [path lastPathComponent], [rewritePath lastPathComponent]);
    
}

-(void)testDataStoreChanged
{    
    NSManagedObjectModel *managedObjectModel = [(AppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectModel];
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [(AppDelegate*)[[UIApplication sharedApplication] delegate] persistentStoreCoordinator];
    NSDictionary *metadata = [persistentStoreCoordinator metadataForPersistentStore:[[persistentStoreCoordinator persistentStores] objectAtIndex:0]];
    STAssertTrue([managedObjectModel isConfiguration:nil compatibleWithStoreMetadata:metadata], @"Oops the datastore is not compatible!!");
    
    NSDictionary *referenceHashes = [NSDictionary dictionaryWithObjectsAndKeys:
                                     @"<daa6704f a239b722 4965003a 2f01c5a5 44c6f3ed d66f2fad f03fca95 862e361f>", @"Activity",
                                     @"<1428e2c5 f426f7db 94153e83 efabef4c 84a9674a 540c9e90 a65c7408 e69d17df>", @"Chart",
                                     @"<85463d06 f5568603 e18f561c 91a6b042 c6ea0f99 2a5f1c57 f676f316 75a6c550>", @"Frequency",
                                     @"<3fd99803 f7c73a8d 3b8d84a6 b1b837b5 894dc372 666e7ccd 9ab7341e ff30c628>", @"Objective",
                                     @"<26b006d0 c259f7c5 e1985371 c357f45c 7e68b438 1120fa70 3dc4d93f 5456eb31>", @"Measurement",
                                     @"<1e9b0ec6 6661f451 9e1075db 02313334 2645e55d e767b841 944ad7ed 1eb7b21c>", @"Metric",
                                     @"<8f8c232b 99d8a015 98a4c60b 3686f8b7 e091bc89 d409015f 956f8ef3 3ad09021>", @"ObjectiveType",
                                     @"<836bc6fc d058f490 bf64acdc f3ce5041 1a655e9c 3fa2cfcb f8225caf f61f8f4b>", @"Responsible",
                                     @"<4aed60cb 0fdf0a10 b0a37496 38c0810a ec918929 fea225d4 149fab98 3802e913>", @"Settings",
                                     @"<a0f1f654 c9e8f6f7 cb26041e c9ba8d5b b32fefeb c80dddc9 a66a50ae de94107d>", @"StratFile",
                                     @"<160c27d3 a8fb05c6 ce002524 a6d358ac 9b301c8a d98f51fb 50b35527 16159fe2>", @"Theme",
                                     @"<82ded5ef dcd34ce8 2407005c f70654f3 d189d979 246daec5 092ad63f 37b02f2c>", @"YammerPublishedReport",
                                     @"<c97b9921 73426b2e 54ddce96 0df6604c cc99712e be3ee642 9388c7dc e23cd6f3>", @"YammerPublishedThread",
                                     @"<e546ba99 c56055df 78f4e6a2 27231841 710e624b 92671766 e92a1ab6 34f7db85>", @"YammerStoredComment",
                                     
                                     @"<1c1565e2 2b527bd9 20e3f944 b5ce6bee 0a7b12a8 788c4b5b a6b2bf54 fd67245f>", @"Asset",
                                     @"<aea23e12 77e3e797 30904f58 e4917cc8 09cd05f1 853d87c4 c2341a0a f220ea05>", @"EmployeeDeductions",
                                     @"<8abb4309 64c161a3 470178e0 742a8776 e8ddd7a6 9a922974 9c7fc740 6c5b7b65>", @"Equity",
                                     @"<c89a69cf a819b50e ba1c0dca 1961e2e5 d7cb8ddc 682b6934 b0d6485f e4ce2c4c>", @"Financials",
                                     @"<64e924cc 8bf79479 9b9d2f18 2863d057 af8bff46 023ad727 a8088dc7 ac65f4ef>", @"IncomeTax",
                                     @"<23ac2b3f ea6c5349 04c87d43 af0fb34e c050fd6b 5835adf5 8ab3c6e1 f9254b4a>", @"Loan",
                                     @"<211ecc03 112f9fb8 5e16c2c8 dd93fd44 cbbfffad a5b959cf 950fbeea 3afeeeed>", @"OpeningBalances",
                                     @"<b243737c 0f361463 1760721b b0ad50e0 b0da86b3 564fd845 e7d7ce56 53804186>", @"SalesTax",

                                     nil];

    NSDictionary *entityHashes = [managedObjectModel entityVersionHashesByName];
    
    DLog(@"Entity hashes %@", entityHashes);
        
    STAssertEquals([[referenceHashes allKeys] count], [[entityHashes allKeys] count], @"Oops - different number of entities. Make sure marshalling and unmarshalling to XML works.");
    
    for (NSString *entityName in [referenceHashes allKeys]) {
        NSString *refHash = [[referenceHashes objectForKey:entityName] description];
        NSString *hash = [[entityHashes objectForKey:entityName] description];
                
        STAssertEqualObjects(refHash, hash, @"Oops. Entities have changed: %@. Make sure marshalling and unmarshalling to XML works.", entityName);
    }
    
    // if you look in StratPad.xcdatamodeld, you will see all the core data model versions
    // this is the current one eg. StratPad 1.1.2 (622) ( major.minor.revision (build) )
    // compare against the app version to see if we have a matching model (ignoring rev number)
    // if it doesn't match, we have likely increased the major or minor version number and should thus create a matching cd model
    NSString *modelVersion = [[EditionManager sharedManager] modelVersion]; 
    NSError *error = NULL;
    
    // we only care about major and minor parts of the app version eg. 1.2
    NSArray *versionParts = [[[EditionManager sharedManager] versionNumber] componentsSeparatedByString:@"."];
    NSString *versionNumber = [NSString stringWithFormat:@"%@.%@", [versionParts objectAtIndex:0], [versionParts objectAtIndex:1]];
    
    // now look to see if eg 1.2 is in the modelVersion eg. StratPad 1.2.1 (738)
    NSString *pattern = [NSString stringWithFormat:@"StratPad %@\\.?\\d? \\(\\d+\\)", versionNumber];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:modelVersion
                                                        options:0
                                                          range:NSMakeRange(0, [modelVersion length])];
    
    STAssertEquals(numberOfMatches, (uint)1, @"Oops. Have you upgraded the core data model: %@ to match the app version: %@", modelVersion, [[EditionManager sharedManager] versionString]);

}

- (NSDate*)dateFromString:(NSString*)dateString
{
    // 2011-12-01 ie. yyyy-mm-dd
    return [NSDate dateTimeFromISO8601:[NSString stringWithFormat:@"%@T00:00:00+0000", [dateString stringByReplacingOccurrencesOfString:@"-" withString:@""]]];
}

-(void)testWriteXHTML
{
    XMLWriter *writer = [[XMLWriter alloc] init];
    [writer write:@"<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">"];

    [writer writeStartElement:@"html"];
    [writer writeAttribute:@"xmlns" value:@"http://www.w3.org/1999/xhtml"];

    [writer writeStartElement:@"head"];

    [writer writeStartElement:@"title"];
    [writer writeCharacters:@"Test"];
    [writer writeEndElement];
    
    [writer writeEndElement];

    [writer writeStartElement:@"body"];
    
    // adds the rest of the end elements
    [writer writeEndDocument];
    
    DLog(@"html: %@", writer.toString);
    
    [writer release];
    
    
    
}



@end