//
//  ThemeDetailReportViewControllerTest.m
//  StratPad
//
//  Created by Eric Rogers on August 30, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import "ThemeDetailReportViewController.h"
#import "DataManager.h"
#import "Theme.h"
#import "Responsible.h"
#import "NSDate-StratPad.h"

@interface ThemeDetailReportViewControllerTest : SenTestCase {    
}
@end


@implementation ThemeDetailReportViewControllerTest


#pragma mark - responsibleDescriptionForCurrentTheme tests

- (void)testResponsibleDescriptionForThemeWithNoApplicableData
{
    Theme *theme = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    
    ThemeDetailReportViewController *controller = [[ThemeDetailReportViewController alloc] initWithNibName:nil bundle:nil andThemeOrNil:theme];
    NSString *responsibleDescription = [controller responsibleDescriptionForCurrentTheme];
    [controller release];
    
    STAssertEqualObjects(responsibleDescription,
                         @"Nobody is responsible for this theme which has no start date and has no end date.", 
                         @"responsibleDescription was not as expected, it was %@", responsibleDescription);
}

- (void)testResponsibleDescriptionForThemeWithNoResponsiblePersonAndNoEndDate
{
    Theme *theme = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    theme.startDate = [NSDate date];
    
    ThemeDetailReportViewController *controller = [[ThemeDetailReportViewController alloc] initWithNibName:nil bundle:nil andThemeOrNil:theme];
    NSString *responsibleDescription = [controller responsibleDescriptionForCurrentTheme];
    [controller release];
    
    NSString *expected = [NSString stringWithFormat:@"Nobody is responsible for this theme which starts on %@ and has no end date.", [theme.startDate formattedDate2]];
    STAssertEqualObjects(responsibleDescription,
                         expected, 
                         @"responsibleDescription was not as expected, it was %@", responsibleDescription);
    
}

- (void)testResponsibleDescriptionForThemeWithNoResponsiblePersonAndNoStartDate
{        
    Theme *theme = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    theme.endDate = [NSDate date];
    
    ThemeDetailReportViewController *controller = [[ThemeDetailReportViewController alloc] initWithNibName:nil bundle:nil andThemeOrNil:theme];
    NSString *responsibleDescription = [controller responsibleDescriptionForCurrentTheme];
    [controller release];
    
    NSString *expected = [NSString stringWithFormat:@"Nobody is responsible for this theme which has no start date and ends on %@.", [theme.endDate formattedDate2]];
    STAssertEqualObjects(responsibleDescription,
                         expected, 
                         @"responsibleDescription was not as expected, it was %@", responsibleDescription);
}

- (void)testResponsibleDescriptionForThemeWithNoResponsiblePerson
{
    Theme *theme = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    theme.startDate = [NSDate date];
    theme.endDate = [NSDate date];
    
    ThemeDetailReportViewController *controller = [[ThemeDetailReportViewController alloc] initWithNibName:nil bundle:nil andThemeOrNil:theme];
    NSString *responsibleDescription = [controller responsibleDescriptionForCurrentTheme];
    [controller release];
    
    NSString *expected = [NSString stringWithFormat:@"Nobody is responsible for this theme which starts on %@ and ends on %@.", 
                [theme.startDate formattedDate2], [theme.endDate formattedDate2]];
    STAssertEqualObjects(responsibleDescription,
                         expected, 
                         @"responsibleDescription was not as expected, it was %@", responsibleDescription);
}

- (void)testResponsibleDescriptionForThemeWithResponsiblePerson
{
    Responsible *responsible = (Responsible*)[DataManager createManagedInstance:NSStringFromClass([Responsible class])];
    responsible.summary = @"Homer Simpson";
    
    Theme *theme = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];    
    theme.responsible = responsible;
    
    ThemeDetailReportViewController *controller = [[ThemeDetailReportViewController alloc] initWithNibName:nil bundle:nil andThemeOrNil:theme];
    NSString *responsibleDescription = [controller responsibleDescriptionForCurrentTheme];
    [controller release];
    
    NSString *expected = @"Homer Simpson is responsible for this theme which has no start date and has no end date.";
    STAssertEqualObjects(responsibleDescription,
                         expected, 
                         @"responsibleDescription was not as expected, it was %@", responsibleDescription);
}

- (void)testResponsibleDescriptionForThemeWithResponsiblePersonAndNoEndDate
{
    Responsible *responsible = (Responsible*)[DataManager createManagedInstance:NSStringFromClass([Responsible class])];
    responsible.summary = @"Homer Simpson";

    Theme *theme = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];    
    theme.responsible = responsible;
    theme.startDate = [NSDate date];
    
    ThemeDetailReportViewController *controller = [[ThemeDetailReportViewController alloc] initWithNibName:nil bundle:nil andThemeOrNil:theme];
    NSString *responsibleDescription = [controller responsibleDescriptionForCurrentTheme];
    [controller release];
    
    NSString *expected = [NSString stringWithFormat:@"Homer Simpson is responsible for this theme which starts on %@ and has no end date.",
                          [theme.startDate formattedDate2]];
    STAssertEqualObjects(responsibleDescription,
                         expected, 
                         @"responsibleDescription was not as expected, it was %@", responsibleDescription);
}

- (void)testResponsibleDescriptionForThemeWithResponsiblePersonAndNoStartDate
{
    Responsible *responsible = (Responsible*)[DataManager createManagedInstance:NSStringFromClass([Responsible class])];
    responsible.summary = @"Homer Simpson";

    Theme *theme = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];    
    theme.responsible = responsible;
    theme.endDate = [NSDate date];
    
    ThemeDetailReportViewController *controller = [[ThemeDetailReportViewController alloc] initWithNibName:nil bundle:nil andThemeOrNil:theme];
    NSString *responsibleDescription = [controller responsibleDescriptionForCurrentTheme];
    [controller release];
    
    NSString *expected = [NSString stringWithFormat:@"Homer Simpson is responsible for this theme which has no start date and ends on %@.",
                          [theme.endDate formattedDate2]];
    STAssertEqualObjects(responsibleDescription,
                         expected, 
                         @"responsibleDescription was not as expected, it was %@", responsibleDescription);
}

- (void)testResponsibleDescriptionForThemeWithAllApplicableData
{
    Responsible *responsible = (Responsible*)[DataManager createManagedInstance:NSStringFromClass([Responsible class])];
    responsible.summary = @"Homer Simpson";

    Theme *theme = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];    
    theme.responsible = responsible;
    theme.startDate = [NSDate date];
    theme.endDate = [NSDate date];
    
    ThemeDetailReportViewController *controller = [[ThemeDetailReportViewController alloc] initWithNibName:nil bundle:nil andThemeOrNil:theme];
    NSString *responsibleDescription = [controller responsibleDescriptionForCurrentTheme];
    [controller release];
    
    NSString *expected = [NSString stringWithFormat:@"Homer Simpson is responsible for this theme which starts on %@ and ends on %@.",
                          [theme.startDate formattedDate2], [theme.endDate formattedDate2]];
    STAssertEqualObjects(responsibleDescription,
                         expected, 
                         @"responsibleDescription was not as expected, it was %@", responsibleDescription);
}


#pragma mark - descriptionForCurrentTheme

- (void)testDescriptionForCurrentThemeWithMandatoryEnhancesUniquenessAndImprovesCustomerValue
{    
    Theme *theme = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];    
    theme.mandatory = [NSNumber numberWithBool:YES];
    theme.enhanceUniqueness = [NSNumber numberWithBool:YES];
    theme.enhanceCustomerValue = [NSNumber numberWithBool:YES];

    ThemeDetailReportViewController *controller = [[ThemeDetailReportViewController alloc] initWithNibName:nil bundle:nil andThemeOrNil:theme];
    NSString *themeDescription = [controller descriptionForCurrentTheme];
    [controller release];
    
    NSString *expected = @"This theme is mandatory, enhances uniqueness, and improves customer value.";
    STAssertEqualObjects(themeDescription, expected, @"themeDescription was not as expected, it was %@", themeDescription);    
}

- (void)testDescriptionForCurrentThemeWithNotMandatoryEnhancesUniquenessAndImprovesCustomerValue
{    
    Theme *theme = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];    
    theme.mandatory = [NSNumber numberWithBool:NO];
    theme.enhanceUniqueness = [NSNumber numberWithBool:YES];
    theme.enhanceCustomerValue = [NSNumber numberWithBool:YES];
    
    ThemeDetailReportViewController *controller = [[ThemeDetailReportViewController alloc] initWithNibName:nil bundle:nil andThemeOrNil:theme];
    NSString *themeDescription = [controller descriptionForCurrentTheme];
    [controller release];
    
    NSString *expected = @"This theme is not mandatory, enhances uniqueness, and improves customer value.";
    STAssertEqualObjects(themeDescription, expected, @"themeDescription was not as expected, it was %@", themeDescription);    
}

- (void)testDescriptionForCurrentThemeWithMandatoryDoesNotEnhanceUniquenessAndImprovesCustomerValue
{    
    Theme *theme = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];    
    theme.mandatory = [NSNumber numberWithBool:YES];
    theme.enhanceUniqueness = [NSNumber numberWithBool:NO];
    theme.enhanceCustomerValue = [NSNumber numberWithBool:YES];
    
    ThemeDetailReportViewController *controller = [[ThemeDetailReportViewController alloc] initWithNibName:nil bundle:nil andThemeOrNil:theme];
    NSString *themeDescription = [controller descriptionForCurrentTheme];
    [controller release];
    
    NSString *expected = @"This theme is mandatory, does not enhance uniqueness, and improves customer value.";
    STAssertEqualObjects(themeDescription, expected, @"themeDescription was not as expected, it was %@", themeDescription);    
}

- (void)testDescriptionForCurrentThemeWithNotMandatoryDoesNotEnhanceUniquenessAndImprovesCustomerValue
{    
    Theme *theme = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];    
    theme.mandatory = [NSNumber numberWithBool:NO];
    theme.enhanceUniqueness = [NSNumber numberWithBool:NO];
    theme.enhanceCustomerValue = [NSNumber numberWithBool:YES];
    
    ThemeDetailReportViewController *controller = [[ThemeDetailReportViewController alloc] initWithNibName:nil bundle:nil andThemeOrNil:theme];
    NSString *themeDescription = [controller descriptionForCurrentTheme];
    [controller release];
    
    NSString *expected = @"This theme is not mandatory, does not enhance uniqueness, and improves customer value.";
    STAssertEqualObjects(themeDescription, expected, @"themeDescription was not as expected, it was %@", themeDescription);    
}

- (void)testDescriptionForCurrentThemeWithMandatoryEnhanceUniquenessAndDoesNotImproveCustomerValue
{    
    Theme *theme = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];    
    theme.mandatory = [NSNumber numberWithBool:YES];
    theme.enhanceUniqueness = [NSNumber numberWithBool:YES];
    theme.enhanceCustomerValue = [NSNumber numberWithBool:NO];
    
    ThemeDetailReportViewController *controller = [[ThemeDetailReportViewController alloc] initWithNibName:nil bundle:nil andThemeOrNil:theme];
    NSString *themeDescription = [controller descriptionForCurrentTheme];
    [controller release];
    
    NSString *expected = @"This theme is mandatory, enhances uniqueness, and does not improve customer value.";
    STAssertEqualObjects(themeDescription, expected, @"themeDescription was not as expected, it was %@", themeDescription);    
}

- (void)testDescriptionForCurrentThemeWithNotMandatoryEnhanceUniquenessAndDoesNotImproveCustomerValue
{    
    Theme *theme = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];    
    theme.mandatory = [NSNumber numberWithBool:NO];
    theme.enhanceUniqueness = [NSNumber numberWithBool:YES];
    theme.enhanceCustomerValue = [NSNumber numberWithBool:NO];
    
    ThemeDetailReportViewController *controller = [[ThemeDetailReportViewController alloc] initWithNibName:nil bundle:nil andThemeOrNil:theme];
    NSString *themeDescription = [controller descriptionForCurrentTheme];
    [controller release];
    
    NSString *expected = @"This theme is not mandatory, enhances uniqueness, and does not improve customer value.";
    STAssertEqualObjects(themeDescription, expected, @"themeDescription was not as expected, it was %@", themeDescription);    
}

- (void)testDescriptionForCurrentThemeWithMandatoryDoesNotEnhanceUniquenessAndDoesNotImproveCustomerValue
{    
    Theme *theme = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];    
    theme.mandatory = [NSNumber numberWithBool:YES];
    theme.enhanceUniqueness = [NSNumber numberWithBool:NO];
    theme.enhanceCustomerValue = [NSNumber numberWithBool:NO];
    
    ThemeDetailReportViewController *controller = [[ThemeDetailReportViewController alloc] initWithNibName:nil bundle:nil andThemeOrNil:theme];
    NSString *themeDescription = [controller descriptionForCurrentTheme];
    [controller release];
    
    NSString *expected = @"This theme is mandatory, does not enhance uniqueness, and does not improve customer value.";
    STAssertEqualObjects(themeDescription, expected, @"themeDescription was not as expected, it was %@", themeDescription);    
}

- (void)testDescriptionForCurrentThemeWithNotMandatoryDoesNotEnhanceUniquenessAndDoesNotImproveCustomerValue
{    
    Theme *theme = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];    
    theme.mandatory = [NSNumber numberWithBool:NO];
    theme.enhanceUniqueness = [NSNumber numberWithBool:NO];
    theme.enhanceCustomerValue = [NSNumber numberWithBool:NO];
    
    ThemeDetailReportViewController *controller = [[ThemeDetailReportViewController alloc] initWithNibName:nil bundle:nil andThemeOrNil:theme];
    NSString *themeDescription = [controller descriptionForCurrentTheme];
    [controller release];
    
    NSString *expected = @"This theme is not mandatory, does not enhance uniqueness, and does not improve customer value.";
    STAssertEqualObjects(themeDescription, expected, @"themeDescription was not as expected, it was %@", themeDescription);    
}


@end