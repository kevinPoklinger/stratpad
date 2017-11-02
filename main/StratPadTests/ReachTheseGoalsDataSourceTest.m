//
//  ReachTheseGoalsDataSourceTest.m
//  StratPad
//
//  Created by Eric on 11-09-25.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "ReachTheseGoalsDataSource.h"
#import "Objective.h"
#import "Metric.h"
#import "DataManager.h"
#import "NSDate-StratPad.h"
#import "AppDelegate.h"
#import "CoreDataTestCase.h"
#import "TestSupport.h"

@interface ReachTheseGoalsDataSourceTest : CoreDataTestCase
@end

@implementation ReachTheseGoalsDataSourceTest

/*
 * Test the goalHeadings method to ensure it returns the headings
 * sorted alphabetically.
 */ 
- (void)testGoalHeadings
{
    NSDate *now = [[NSDate date] dateWithZeroedTime];
    ReachTheseGoalsDataSource *dataSource = [[ReachTheseGoalsDataSource alloc] initWithStartDate:now forIntervalInMonths:3];
    

    Objective *objective1 = (Objective*)[DataManager createManagedInstance:NSStringFromClass([Objective class])];
    Metric *metric1 = (Metric*)[DataManager createManagedInstance:NSStringFromClass([Metric class])];
    metric1.summary = @"Apple";
    [objective1 addMetricsObject:metric1];
    id<Goal> goal1 = [metric1 newGoal];    
    [dataSource addGoal:goal1];
    [goal1 release];
    
    Objective *objective2 = (Objective*)[DataManager createManagedInstance:NSStringFromClass([Objective class])];
    Metric *metric2 = (Metric*)[DataManager createManagedInstance:NSStringFromClass([Metric class])];
    metric2.summary = @"Bananna";    
    [objective2 addMetricsObject:metric2];
    id<Goal> goal2 = [metric2 newGoal];    
    [dataSource addGoal:goal2];
    [goal2 release];
    
    Theme *theme = [TestSupport createThemeWithTitle:@"GoalHeadings" andFinancialWidth:1 andOrder:0];
    [theme addObjectivesObject:objective1];
    [theme addObjectivesObject:objective2];

    NSArray *headings = [dataSource goalHeadings];
    STAssertTrue([headings count] == 2, @"Should have received 2 headings but got %i", [headings count]);
    STAssertEqualObjects(@"Apple", [headings objectAtIndex:0], @"First heading should have been 'Apple' but was %@", [headings objectAtIndex:0]);
    STAssertEqualObjects(@"Bananna", [headings objectAtIndex:1], @"Second heading should have been 'Bananna' but was %@", [headings objectAtIndex:1]);
}

/*
 * Test the addGoal method to ensure that it stores goals by their metric summary, and in the case of text goals, 
 * metric and target value.
 */
- (void)testAddGoal
{
    NSDate *now = [[NSDate date] dateWithZeroedTime];
    ReachTheseGoalsDataSource *dataSource = [[ReachTheseGoalsDataSource alloc] initWithStartDate:now forIntervalInMonths:3];
    
    Objective *objective1 = (Objective*)[DataManager createManagedInstance:NSStringFromClass([Objective class])];
    Metric *metric1 = (Metric*)[DataManager createManagedInstance:NSStringFromClass([Metric class])];
    metric1.summary = @"S&M";
    metric1.targetValue = @"Staff";
    [objective1 addMetricsObject:metric1];
    id<Goal> goal1 = [metric1 newGoal];    
    [dataSource addGoal:goal1];
    [goal1 release];
    
    Objective *objective2 = (Objective*)[DataManager createManagedInstance:NSStringFromClass([Objective class])];
    Metric *metric2 = (Metric*)[DataManager createManagedInstance:NSStringFromClass([Metric class])];
    metric2.summary = @"S&M";    
    metric2.targetValue = @"Budget";
    [objective2 addMetricsObject:metric2];
    id<Goal> goal2 = [metric2 newGoal];    
    [dataSource addGoal:goal2];
    [goal2 release];

    Objective *objective3 = (Objective*)[DataManager createManagedInstance:NSStringFromClass([Objective class])];
    Metric *metric3 = (Metric*)[DataManager createManagedInstance:NSStringFromClass([Metric class])];
    metric3.summary = @"S&M";    
    metric3.targetValue = @"5000";
    [objective3 addMetricsObject:metric3];
    id<Goal> goal3 = [metric3 newGoal];    
    [dataSource addGoal:goal3];
    [goal3 release];
    
    Theme *theme = [TestSupport createThemeWithTitle:@"AddGoal" andFinancialWidth:1 andOrder:0];
    [theme addObjectivesObject:objective1];
    [theme addObjectivesObject:objective2];
    [theme addObjectivesObject:objective3];

    NSArray *headings = [dataSource goalHeadings];
    STAssertTrue([headings count] == 3, @"Should have received 3 headings but got %i", [headings count]);
    STAssertEqualObjects(@"S&M", [headings objectAtIndex:0], @"First heading should have been 'S&M Budget' but was %@", [headings objectAtIndex:0]);

    STAssertEqualObjects(@"S&M Budget", [headings objectAtIndex:1], @"First heading should have been 'S&M Budget' but was %@", [headings objectAtIndex:1]);
    STAssertEqualObjects(@"S&M Staff", [headings objectAtIndex:2], @"Second heading should have been 'S&M Staff' but was %@", [headings objectAtIndex:2]);
}

@end
