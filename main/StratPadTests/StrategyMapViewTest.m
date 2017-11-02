//
//  StrategyMapViewTest.m
//  StratPad
//
//  Created by Julian Wood on 11-08-22.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "StrategyMapViewController.h"
#import "Objective.h"
#import "Theme.h"
#import "ObjectiveType.h"
#import "DataManager.h"
#import "TestSupport.h"
#import "CoreDataTestCase.h"

@interface StrategyMapViewTest : CoreDataTestCase {    
}
@end

@implementation StrategyMapViewTest

-(void)testFilteredObjectives
{
    Theme *theme3 = [TestSupport createTheme3];
    STAssertEquals((uint)4, [theme3.objectives count], @"Oops");
    
    // check the order is good
    NSArray *orderedObjectives = [theme3 objectivesSortedByOrder];
    STAssertEquals(0, [[[orderedObjectives objectAtIndex:0] order] intValue], @"Oops");
    STAssertEquals(0, [[[orderedObjectives lastObject] order] intValue], @"Oops");
    
    // check to make sure we filtered
    NSArray *financial = [Theme objectivesFilteredByCategory:ObjectiveCategoryFinancial objectives:orderedObjectives];
    STAssertEquals((uint)3, [financial count], @"Oops");

    // make sure we maintained order after filtering
    STAssertEquals(0, [[[financial objectAtIndex:0] order] intValue], @"Oops");
    
    // try another filter just for good measure
    NSArray *process = [Theme objectivesFilteredByCategory:ObjectiveCategoryProcess objectives:orderedObjectives];
    STAssertEquals((uint)1, [process count], @"Oops");
    

    // what happens if we don't have an objective type? STRATPAD-478
    Objective *objective = (Objective*)[DataManager createManagedInstance:NSStringFromClass([Objective class])];
    objective.order = [NSNumber numberWithInt:0];
    
    int idx = objective.objectiveType.category.intValue;
    DLog(@"idx: %i", idx);
    
    STAssertTrue(idx == 0, @"oops");

    // what about a crazy index?
    objective.objectiveType = [ObjectiveType objectiveTypeForCategory:87];
    idx = objective.objectiveType.category.intValue;
    DLog(@"idx: %i", idx);    

    // satisfy core data for tests
    objective.objectiveType = [ObjectiveType objectiveTypeForCategory:ObjectiveCategoryFinancial];
    [theme3 addObjectivesObject:objective];
    

}

- (void)testThemeWidth 
{    
    Theme *theme1 = [TestSupport createTheme1];
    STAssertEquals((uint)2, [theme1 themeWidth], @"Oops");
    
    Theme *theme2 = [TestSupport createTheme2];
    STAssertEquals((uint)2, [theme2 themeWidth], @"Oops");
    
    Theme *theme3 = [TestSupport createTheme3];
    STAssertEquals((uint)3, [theme3 themeWidth], @"Oops");

}

- (void)testSplit1
{
    
    Theme *theme = [TestSupport createThemeWithTitle:@"Theme 1" andFinancialWidth:3 andOrder:0];
    NSSet *objectives1 = [SplitTheme subSetOfObjectivesForTheme:theme forWidth:2 forRemainder:NO];
    STAssertEquals((uint)2, [objectives1 count], @"Oops");
    
    NSSet *objectives2 = [SplitTheme subSetOfObjectivesForTheme:theme forWidth:2 forRemainder:YES];
    STAssertEquals((uint)1, [objectives2 count], @"Oops");
    
    // did it get the remainder in the right order?
    STAssertEquals((uint)2, [[[objectives2 anyObject] order] unsignedIntValue], @"Oops"); 
    
}

- (void)testSplit2
{
    
    Theme *theme = [TestSupport createThemeWithTitle:@"Theme 1" andFinancialWidth:13 andOrder:0];
    
    NSSet *objectives1 = [SplitTheme subSetOfObjectivesForTheme:theme forWidth:6 forRemainder:NO];
    STAssertEquals((uint)6, [objectives1 count], @"Oops");
    
    // this should be the first 6 objectives, by their order prop
    NSSortDescriptor *orderSort = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
    NSArray *sortedObjectives1 = [objectives1 sortedArrayUsingDescriptors:[NSArray arrayWithObject:orderSort]];
    STAssertEqualObjects([[sortedObjectives1 objectAtIndex:4] order], [NSNumber numberWithInt:4], @"Oops");
    
    // this should be the rest of the objectives 
    NSSet *objectives2 = [SplitTheme subSetOfObjectivesForTheme:theme forWidth:6 forRemainder:YES];
    STAssertEquals((uint)7, [objectives2 count], @"Oops");
    NSArray *sortedObjectives2 = [objectives2 sortedArrayUsingDescriptors:[NSArray arrayWithObject:orderSort]];
    STAssertEqualObjects([[sortedObjectives2 objectAtIndex:0] order], [NSNumber numberWithInt:6], @"Oops");
    
}


- (void)testNumberOfPages1
{
    // one theme, width of two objectives    
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    [stratFile addThemesObject:[TestSupport createThemeWithTitle:@"Theme 1" andFinancialWidth:2 andOrder:0]];
    STAssertEquals((uint)1, [StrategyMapViewController numberOfPages:stratFile], @"Oops");
}

- (void)testNumberOfPages2 
{
    // two themes, 2* w=2    
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    [stratFile addThemesObject:[TestSupport createThemeWithTitle:@"Theme 1" andFinancialWidth:2 andOrder:0]];
    [stratFile addThemesObject:[TestSupport createThemeWithTitle:@"Theme 2" andFinancialWidth:2 andOrder:1]];
    STAssertEquals((uint)1, [StrategyMapViewController numberOfPages:stratFile], @"Oops");
}

- (void)testNumberOfPages3 
{
    // two themes, 3* w=2    
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    [stratFile addThemesObject:[TestSupport createThemeWithTitle:@"Theme 1" andFinancialWidth:2 andOrder:0]];
    [stratFile addThemesObject:[TestSupport createThemeWithTitle:@"Theme 2" andFinancialWidth:2 andOrder:1]];
    [stratFile addThemesObject:[TestSupport createThemeWithTitle:@"Theme 3" andFinancialWidth:2 andOrder:2]];
    STAssertEquals((uint)1, [StrategyMapViewController numberOfPages:stratFile], @"Oops");
}

- (void)testNumberOfPages4 
{
    // two themes, w=2 && w=3    
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    [stratFile addThemesObject:[TestSupport createThemeWithTitle:@"Theme 1" andFinancialWidth:2 andOrder:0]];
    [stratFile addThemesObject:[TestSupport createThemeWithTitle:@"Theme 2" andFinancialWidth:3 andOrder:1]];
    STAssertEquals((uint)1, [StrategyMapViewController numberOfPages:stratFile], @"Oops");
}

- (void)testNumberOfPages5 
{
    // three themes, 2* w=2 && w=3
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    [stratFile addThemesObject:[TestSupport createThemeWithTitle:@"Theme 1" andFinancialWidth:2 andOrder:0]];
    [stratFile addThemesObject:[TestSupport createThemeWithTitle:@"Theme 2" andFinancialWidth:2 andOrder:1]];
    [stratFile addThemesObject:[TestSupport createThemeWithTitle:@"Theme 3" andFinancialWidth:3 andOrder:2]];
    
    NSDictionary *dict = [StrategyMapViewController createStratMapThemes:stratFile];
    
    STAssertEquals((uint)2, [StrategyMapViewController numberOfPages:stratFile], @"Oops");
    STAssertEquals((uint)2, [dict count], @"Oops");
    STAssertEquals((uint)3, [[dict objectForKey:[NSNumber numberWithInt:0]] count], @"Oops"); // page 1
    STAssertEquals((uint)1, [[dict objectForKey:[NSNumber numberWithInt:1]] count], @"Oops"); // page 2

    // Theme 3 is split over page 1 and page 2
    STAssertEqualObjects(@"Theme 3", [[[[dict objectForKey:[NSNumber numberWithInt:0]] objectAtIndex:2] theme] title], @"Oops");
    STAssertEqualObjects(@"Theme 3", [[[[dict objectForKey:[NSNumber numberWithInt:1]] objectAtIndex:0] theme] title], @"Oops");
    
}

- (void)testNumberOfPages6 
{
    // three themes, 3* w=3
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    [stratFile addThemesObject:[TestSupport createThemeWithTitle:@"Theme 1" andFinancialWidth:3 andOrder:0]];
    [stratFile addThemesObject:[TestSupport createThemeWithTitle:@"Theme 2" andFinancialWidth:3 andOrder:1]];
    [stratFile addThemesObject:[TestSupport createThemeWithTitle:@"Theme 3" andFinancialWidth:3 andOrder:2]];
    STAssertEquals((uint)2, [StrategyMapViewController numberOfPages:stratFile], @"Oops");
}

- (void)testNumberOfPages7 
{
    // one theme, w=7    
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    [stratFile addThemesObject:[TestSupport createThemeWithTitle:@"Theme 1" andFinancialWidth:7 andOrder:0]];
    STAssertEquals((uint)2, [StrategyMapViewController numberOfPages:stratFile], @"Oops");
}

- (void)testNumberOfPages8
{
    // 0 themes
    StratFile *stratFile = [TestSupport createEmptyStratFile];    
    STAssertEquals((uint)1, [StrategyMapViewController numberOfPages:stratFile], @"Oops"); // pages
}

- (void)testNumberOfPages9
{
    // one theme, w=13    
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    [stratFile addThemesObject:[TestSupport createThemeWithTitle:@"Theme 1" andFinancialWidth:13 andOrder:0]];
    
    NSDictionary *dict = [StrategyMapViewController createStratMapThemes:stratFile];
    
    STAssertEquals((uint)3, [StrategyMapViewController numberOfPages:stratFile], @"Oops");
    
    // number of themes on each page
    STAssertEquals((uint)1, [[dict objectForKey:[NSNumber numberWithInt:0]] count], @"Oops"); // page 1
    STAssertEquals((uint)1, [[dict objectForKey:[NSNumber numberWithInt:1]] count], @"Oops"); // page 2
    STAssertEquals((uint)1, [[dict objectForKey:[NSNumber numberWithInt:2]] count], @"Oops"); // page 3

    // Theme 1 is split over page 1, 2, 3
    STAssertEqualObjects(@"Theme 1", [[[[dict objectForKey:[NSNumber numberWithInt:0]] objectAtIndex:0] theme] title], @"Oops");
    STAssertEqualObjects(@"Theme 1", [[[[dict objectForKey:[NSNumber numberWithInt:2]] objectAtIndex:0] theme] title], @"Oops");

    // check objectives on each page
    StratMapTheme *smt = [[dict objectForKey:[NSNumber numberWithInt:0]] objectAtIndex:0]; // page 1, first stratMapTheme
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
    NSArray *sortedObjectives = [smt.objectives sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    STAssertEquals([[[sortedObjectives objectAtIndex:0] order] intValue], 0, @"Oops");
    STAssertEquals([[[sortedObjectives objectAtIndex:5] order] intValue], 5, @"Oops");

    smt = [[dict objectForKey:[NSNumber numberWithInt:1]] objectAtIndex:0]; // page 2, first stratMapTheme
    sortedObjectives = [smt.objectives sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    STAssertEquals([[[sortedObjectives objectAtIndex:0] order] intValue], 6, @"Oops");
    STAssertEquals([[[sortedObjectives objectAtIndex:5] order] intValue], 11, @"Oops");

    smt = [[dict objectForKey:[NSNumber numberWithInt:2]] objectAtIndex:0]; // page 3, first stratMapTheme
    sortedObjectives = [smt.objectives sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    STAssertEquals([[[sortedObjectives objectAtIndex:0] order] intValue], 12, @"Oops");
    STAssertEquals([[[sortedObjectives lastObject] order] intValue], 12, @"Oops");

}


- (void)testCreateStratMapPages1 
{
    // 4 themes, 3x 1w and 1x 2w would be 2 pages    
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    [stratFile addThemesObject:[TestSupport createThemeWithTitle:@"Theme 1" andFinancialWidth:1 andOrder:0]];
    [stratFile addThemesObject:[TestSupport createThemeWithTitle:@"Theme 2" andFinancialWidth:1 andOrder:1]];
    [stratFile addThemesObject:[TestSupport createThemeWithTitle:@"Theme 3" andFinancialWidth:1 andOrder:2]];
    [stratFile addThemesObject:[TestSupport createThemeWithTitle:@"Theme 4" andFinancialWidth:2 andOrder:3]];
    NSDictionary *dict = [StrategyMapViewController createStratMapThemes:stratFile];
        
    STAssertEquals((uint)2, [dict count], @"Oops");
    STAssertEquals((uint)3, [[dict objectForKey:[NSNumber numberWithInt:0]] count], @"Oops"); // page 1
    STAssertEquals((uint)1, [[dict objectForKey:[NSNumber numberWithInt:1]] count], @"Oops"); // page 2

}

- (void)testCreateStratMapPages2
{
    // 2 themes, 1x 1w and 1x 4w would be 1 page    
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    [stratFile addThemesObject:[TestSupport createThemeWithTitle:@"Theme 1" andFinancialWidth:1 andOrder:0]];
    [stratFile addThemesObject:[TestSupport createThemeWithTitle:@"Theme 2" andFinancialWidth:4 andOrder:1]];
    NSDictionary *dict = [StrategyMapViewController createStratMapThemes:stratFile];
        
    STAssertEquals((uint)1, [dict count], @"Oops"); // pages
    STAssertEquals((uint)2, [[dict objectForKey:[NSNumber numberWithInt:0]] count], @"Oops"); // page 1    
}

- (void)testCreateStratMapPages3
{
    // 2 themes, 1x 5w and 1x 2w would be 2 pages (don't split in this case)
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    [stratFile addThemesObject:[TestSupport createThemeWithTitle:@"Theme 1" andFinancialWidth:5 andOrder:0]];
    [stratFile addThemesObject:[TestSupport createThemeWithTitle:@"Theme 2" andFinancialWidth:2 andOrder:1]];
    NSDictionary *dict = [StrategyMapViewController createStratMapThemes:stratFile];
    
    STAssertEquals((uint)2, [dict count], @"Oops"); // pages
    STAssertEquals((uint)1, [[dict objectForKey:[NSNumber numberWithInt:0]] count], @"Oops"); // page 1    
    STAssertEquals((uint)1, [[dict objectForKey:[NSNumber numberWithInt:1]] count], @"Oops"); // page 2    

}



@end
