//
//  BusinessPlanViewControllerTest.m
//  StratPad
//
//  Created by Eric on 11-09-20.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "BusinessPlanViewController.h"
#import "DataManager.h"
#import "StratFile.h"
#import "TestSupport.h"

@interface BusinessPlanViewControllerTest : SenTestCase {    
}
@end


@implementation BusinessPlanViewControllerTest


#pragma mark - generateSectorDescriptionForStratFile

/*
 * Test the generateSectorDescriptionForStratFile method in the situation where
 * a StratFile has no sector defined.
 */
- (void)testGenerateSectorDescriptionForStratFile1
{
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    
    BusinessPlanViewController *controller = [[BusinessPlanViewController alloc] init];
    NSString *result = [controller generateSectorDescriptionForStratFile:stratFile];
    
    STAssertEqualObjects(@"", result, @"Sector description should have been an empty string, but was %@", result);
    
    [controller release];        
}

/*
 * Test the generateSectorDescriptionForStratFile method in the situation where
 * a StratFile has a sector defined.
 */
- (void)testGenerateSectorDescriptionForStratFile2
{
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    stratFile.industry = @"Manufacturing";
    
    BusinessPlanViewController *controller = [[BusinessPlanViewController alloc] init];
    NSString *result = [controller generateSectorDescriptionForStratFile:stratFile];
    
    STAssertEqualObjects(@"operates in the Manufacturing sector", result, @"Sector description was not as expected, it was %@.", result);
    
    [controller release];        
}


#pragma mark - generateLocationDescriptionForStratFile

/*
 * Test the generateLocationDescriptionForStratFile method in the situation where
 * a StratFile has no city, province, or country defined.
 */
- (void)testGenerateLocationDescriptionForStratFile1
{
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    
    BusinessPlanViewController *controller = [[BusinessPlanViewController alloc] init];
    NSString *result = [controller generateLocationDescriptionForStratFile:stratFile];
    
    STAssertEqualObjects(@"", result, @"Location description should have been an empty string, but was %@", result);
    
    [controller release];        
}

/*
 * Test the generateLocationDescriptionForStratFile method in the situation where
 * a StratFile has no city, or country defined but has a province defined.
 */
- (void)testGenerateLocationDescriptionForStratFile2
{
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    stratFile.provinceState = @"AB";
    
    BusinessPlanViewController *controller = [[BusinessPlanViewController alloc] init];
    NSString *result = [controller generateLocationDescriptionForStratFile:stratFile];
    
    STAssertEqualObjects(@"", result, @"Location description should have been an empty string, but was %@", result);
    
    [controller release];        
}

/*
 * Test the generateLocationDescriptionForStratFile method in the situation where
 * a StratFile has no city, or province defined but has a country defined.
 */
- (void)testGenerateLocationDescriptionForStratFile3
{
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    stratFile.country = @"Canada";
    
    BusinessPlanViewController *controller = [[BusinessPlanViewController alloc] init];
    NSString *result = [controller generateLocationDescriptionForStratFile:stratFile];
    
    STAssertEqualObjects(@"", result, @"Location description should have been an empty string, but was %@", result);
    
    [controller release];        
}

/*
 * Test the generateLocationDescriptionForStratFile method in the situation where
 * a StratFile has a city defined, but no province or country.
 */
- (void)testGenerateLocationDescriptionForStratFile4
{
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    stratFile.city = @"Calgary";
    
    BusinessPlanViewController *controller = [[BusinessPlanViewController alloc] init];
    NSString *result = [controller generateLocationDescriptionForStratFile:stratFile];
    
    STAssertEqualObjects(@"is based in Calgary", result, @"Location description was not as expected, it was %@", result);
    
    [controller release];        
}

/*
 * Test the generateLocationDescriptionForStratFile method in the situation where
 * a StratFile has a city, and a province defined, but no country.
 */
- (void)testGenerateLocationDescriptionForStratFile5
{
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    stratFile.city = @"Calgary";
    stratFile.provinceState = @"AB";
    
    BusinessPlanViewController *controller = [[BusinessPlanViewController alloc] init];
    NSString *result = [controller generateLocationDescriptionForStratFile:stratFile];
    
    STAssertEqualObjects(@"is based in Calgary, AB", result, @"Location description was not as expected, it was %@", result);
    
    [controller release];        
}

/*
 * Test the generateLocationDescriptionForStratFile method in the situation where
 * a StratFile has a city, and a country defined, but no province.
 */
- (void)testGenerateLocationDescriptionForStratFile6
{
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    stratFile.city = @"Calgary";
    stratFile.country = @"Canada";
    
    BusinessPlanViewController *controller = [[BusinessPlanViewController alloc] init];
    NSString *result = [controller generateLocationDescriptionForStratFile:stratFile];
    
    STAssertEqualObjects(@"is based in Calgary, Canada", result, @"Location description was not as expected, it was %@", result);
    
    [controller release];        
}

/*
 * Test the generateLocationDescriptionForStratFile method in the situation where
 * a StratFile has a city, province, and a country defined.
 */
- (void)testGenerateLocationDescriptionForStratFile7
{
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    stratFile.city = @"Calgary";
    stratFile.provinceState = @"AB";
    stratFile.country = @"Canada";
    
    BusinessPlanViewController *controller = [[BusinessPlanViewController alloc] init];
    NSString *result = [controller generateLocationDescriptionForStratFile:stratFile];
    
    STAssertEqualObjects(@"is based in Calgary, AB, Canada", result, @"Location description was not as expected, it was %@", result);
    
    [controller release];        
}


#pragma mark - generateCompanyBasicsDescriptionForStratFile

/*
 * Test the generateCompanyBasicsDescriptionForStratFile method in the situation where
 * a StratFile has no company, location, or sector defined.
 */
- (void)testGenerateCompanyBasicsDescriptionForStratFile1
{
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    
    BusinessPlanViewController *controller = [[BusinessPlanViewController alloc] init];
    NSString *result = [controller generateCompanyBasicsDescriptionForStratFile:stratFile];
    
    STAssertEqualObjects(@"", result, @"Company basics description should have been blank, but was %@", result);
    
    [controller release];        
}

/*
 * Test the generateCompanyBasicsDescriptionForStratFile method in the situation where
 * a StratFile has no company, or location defined, but has a sector defined.
 */
- (void)testGenerateCompanyBasicsDescriptionForStratFile2
{
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    stratFile.industry = @"Manufacturing";
    stratFile.companyName = nil;
    
    BusinessPlanViewController *controller = [[BusinessPlanViewController alloc] init];
    NSString *result = [controller generateCompanyBasicsDescriptionForStratFile:stratFile];
    
    STAssertEqualObjects(@"", result, @"Company basics description should have been blank, but was %@", result);
    
    [controller release];        
}

/*
 * Test the generateCompanyBasicsDescriptionForStratFile method in the situation where
 * a StratFile has no company, or sector defined, but has a location defined.
 */
- (void)testGenerateCompanyBasicsDescriptionForStratFile3
{
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    stratFile.city = @"Calgary";
    stratFile.companyName = nil;
    
    BusinessPlanViewController *controller = [[BusinessPlanViewController alloc] init];
    NSString *result = [controller generateCompanyBasicsDescriptionForStratFile:stratFile];
    
    STAssertEqualObjects(@"", result, @"Company basics description should have been blank, but was %@", result);
    
    [controller release];        
}

/*
 * Test the generateCompanyBasicsDescriptionForStratFile method in the situation where
 * a StratFile has no company defined, but has a location and sector.
 */
- (void)testGenerateCompanyBasicsDescriptionForStratFile4
{
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    stratFile.city = @"Calgary";
    stratFile.industry = @"Manufacturing";
    stratFile.companyName = nil;
    
    BusinessPlanViewController *controller = [[BusinessPlanViewController alloc] init];
    NSString *result = [controller generateCompanyBasicsDescriptionForStratFile:stratFile];
    
    STAssertEqualObjects(@"", result, @"Company basics description should have been blank, but was %@", result);
    
    [controller release];        
}

/*
 * Test the generateCompanyBasicsDescriptionForStratFile method in the situation where
 * a StratFile has a company defined, but no location or sector defined.
 */
- (void)testGenerateCompanyBasicsDescriptionForStratFile5
{
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    stratFile.companyName = @"Acme Inc.";
    
    BusinessPlanViewController *controller = [[BusinessPlanViewController alloc] init];
    NSString *result = [controller generateCompanyBasicsDescriptionForStratFile:stratFile];
    
    STAssertEqualObjects(@"", result, @"Company basics description should have been blank, but was %@", result);
    
    [controller release];        
}

/*
 * Test the generateCompanyBasicsDescriptionForStratFile method in the situation where
 * a StratFile has a company and location defined, but no sector.
 */
- (void)testGenerateCompanyBasicsDescriptionForStratFile6
{
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    stratFile.companyName = @"Acme Inc.";
    stratFile.city = @"Calgary";
    
    BusinessPlanViewController *controller = [[BusinessPlanViewController alloc] init];
    NSString *result = [controller generateCompanyBasicsDescriptionForStratFile:stratFile];
    
    STAssertEqualObjects(@"Acme Inc. is based in Calgary.", result, @"Company basics was not as expected, it was %@", result);
    
    [controller release];        
}

/*
 * Test the generateCompanyBasicsDescriptionForStratFile method in the situation where
 * a StratFile has a company and sector defined, but no location.
 */
- (void)testGenerateCompanyBasicsDescriptionForStratFile7
{
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    stratFile.companyName = @"Acme Inc.";
    stratFile.industry = @"Manufacturing";
    
    BusinessPlanViewController *controller = [[BusinessPlanViewController alloc] init];
    NSString *result = [controller generateCompanyBasicsDescriptionForStratFile:stratFile];
    
    STAssertEqualObjects(@"Acme Inc. operates in the Manufacturing sector.", result, @"Company basics was not as expected, it was %@", result);
    
    [controller release];        
}

/*
 * Test the generateCompanyBasicsDescriptionForStratFile method in the situation where
 * a StratFile has a company, location, and sector defined.
 */
- (void)testGenerateCompanyBasicsDescriptionForStratFile8
{
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    stratFile.companyName = @"Acme Inc.";
    stratFile.city = @"Calgary";
    stratFile.industry = @"Manufacturing";
    
    BusinessPlanViewController *controller = [[BusinessPlanViewController alloc] init];
    NSString *result = [controller generateCompanyBasicsDescriptionForStratFile:stratFile];
    
    STAssertEqualObjects(@"Acme Inc. is based in Calgary and operates in the Manufacturing sector.", result, @"Company basics was not as expected, it was %@", result);
    
    [controller release];        
}


#pragma mark - generateSectionAContentForStratFile

/*
 * Test the generateSectionAContentForStratFile method in the situation where
 * a StratFile has no content for section A.
 */
- (void)testGenerateSectionADescriptionForStratFile1
{
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    
    BusinessPlanViewController *controller = [[BusinessPlanViewController alloc] init];
    NSString *result = [controller generateSectionAContentForStratFile:stratFile];
    
    STAssertEqualObjects(@"", result, @"Section A description should have been blank, but was %@", result);
    
    [controller release];        
}

/*
 * Test the generateSectionAContentForStratFile method in the situation where
 * a StratFile only has company basics content.
 */
- (void)testGenerateSectionADescriptionForStratFile2
{
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    stratFile.companyName = @"Acme Inc.";
    stratFile.city = @"Calgary";
    stratFile.industry = @"Manufacturing";
    
    BusinessPlanViewController *controller = [[BusinessPlanViewController alloc] init];
    NSString *result = [controller generateSectionAContentForStratFile:stratFile];
    
    STAssertEqualObjects(@"Acme Inc. is based in Calgary and operates in the Manufacturing sector.", result, @"Section A description was not as expected, it was %@", result);
    
    [controller release];        
}

/*
 * Test the generateSectionAContentForStratFile method in the situation where
 * a StratFile has company basics content and ultimateAspiration content.
 */
- (void)testGenerateSectionADescriptionForStratFile3
{
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    stratFile.companyName = @"Acme Inc.";
    stratFile.city = @"Calgary";
    stratFile.industry = @"Manufacturing";
    stratFile.ultimateAspiration = @"We aspire to succeed.";
    
    BusinessPlanViewController *controller = [[BusinessPlanViewController alloc] init];
    NSString *result = [controller generateSectionAContentForStratFile:stratFile];
    
    STAssertEqualObjects(@"Acme Inc. is based in Calgary and operates in the Manufacturing sector.\n\nWe aspire to succeed.", result, @"Section A description was not as expected, it was %@", result);
    
    [controller release];        
}

/*
 * Test the generateSectionAContentForStratFile method in the situation where
 * a StratFile has no company basics content but has ultimateAspiration and mediumTermStrategicGoal content.
 */
- (void)testGenerateSectionADescriptionForStratFile4
{
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    stratFile.ultimateAspiration = @"We aspire to succeed.";
    stratFile.mediumTermStrategicGoal = @"In the medium term we want to take over the world.";
    
    BusinessPlanViewController *controller = [[BusinessPlanViewController alloc] init];
    NSString *result = [controller generateSectionAContentForStratFile:stratFile];
    
    STAssertEqualObjects(@"We aspire to succeed.\n\nIn the medium term we want to take over the world.", result, @"Section A description was not as expected, it was %@", result);
    
    [controller release];        
}


#pragma mark - generateSectionBContentForStratFile

/*
 * Test the generateSectionBContentForStratFile method in the situation where
 * a StratFile has no content for section B.
 */
- (void)testGenerateSectionBDescriptionForStratFile1
{
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    
    BusinessPlanViewController *controller = [[BusinessPlanViewController alloc] init];
    NSString *result = [controller generateSectionBContentForStratFile:stratFile];
    
    STAssertEqualObjects(@"", result, @"Section B description should have been blank, but was %@", result);
    
    [controller release];        
}

/*
 * Test the generateSectionBContentForStratFile method in the situation where
 * a StratFile has customersDescription content.
 */
- (void)testGenerateSectionBDescriptionForStratFile2
{
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    stratFile.customersDescription = @"Our customers are awesome.";
    
    BusinessPlanViewController *controller = [[BusinessPlanViewController alloc] init];
    NSString *result = [controller generateSectionBContentForStratFile:stratFile];
    
    STAssertEqualObjects(@"Our customers are awesome.", result, @"Section B description was not as expected, it was %@", result);
    
    [controller release];        
}

/*
 * Test the generateSectionBContentForStratFile method in the situation where
 * a StratFile has all section B content.
 */
- (void)testGenerateSectionBDescriptionForStratFile3
{
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    stratFile.customersDescription = @"Our customers are awesome.";
    stratFile.keyProblems = @"Here are some key problems.";
    stratFile.addressProblems = @"We address problems by throwing more money at them.";
    stratFile.competitorsDescription = @"Our competitors are efficient.";
    stratFile.businessModelDescription = @"Business model description.";
    stratFile.expansionOptionsDescription = @"Expansion is a goal.";
    
    BusinessPlanViewController *controller = [[BusinessPlanViewController alloc] init];
    NSString *result = [controller generateSectionBContentForStratFile:stratFile];
    
    STAssertEqualObjects(@"Our customers are awesome.\n\nHere are some key problems.\n\nWe address problems by throwing more money at them.\n\nOur competitors are efficient.\n\nBusiness model description.\n\nExpansion is a goal.", result, @"Section B description was not as expected, it was %@", result);
    
    [controller release];        
}

@end
