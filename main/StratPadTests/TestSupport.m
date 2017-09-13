//
//  TestSupport.m
//  StratPad
//
//  Created by Eric on 11-09-22.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "TestSupport.h"
#import "DataManager.h"
#import "StratFileManager.h"
#import "Objective.h"
#import "Metric.h"
#import "Frequency.h"
#import "Responsible.h"
#import "Activity.h"
#import "NSDate-StratPad.h"
#import "Measurement.h"
#import "Chart.h"
#import "NSString-Expanded.h"
#import "Financials.h"
#import "Loan.h"

@implementation TestSupport

+ (StratFile*)createEmptyStratFile
{
    return [[StratFileManager sharedManager] createManagedEmptyStratFile];
}

+(StratFile*)createTestStratFile
{
    StratFile *stratFile = [TestSupport createEmptyStratFile];
    
    stratFile.name = @"Business Plan";
    stratFile.companyName = @"ACME Cool Co.";
    
    stratFile.mediumTermStrategicGoal = @"This is one heck of a great strategic goal to have.";
    
    // financials
    Loan *loan1 = (Loan*)[DataManager createManagedInstance:NSStringFromClass([Loan class])];
    loan1.name = @"Test Loan 1";
    Financials *financials = stratFile.financials;
    [financials addLoansObject:loan1];

    Loan *loan2 = (Loan*)[DataManager createManagedInstance:NSStringFromClass([Loan class])];
    loan2.name = @"Test Loan 2";
    [financials addLoansObject:loan2];
    
    Loan *loan3 = (Loan*)[DataManager createManagedInstance:NSStringFromClass([Loan class])];
    loan3.name = @"Test Loan 3";
    [financials addLoansObject:loan3];

    DLog(@"%d", financials.loans.count);
    
    [financials removeLoansObject:loan2];

    DLog(@"%d", financials.loans.count);

    
    
    // create an example theme...
    Theme *theme = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    theme.title = @"Grow the business";
    theme.order = [NSNumber numberWithInt:0];
    theme.revenueMonthly = [NSNumber numberWithInt:1000];
    theme.revenueMonthlyAdjustment = [NSDecimalNumber decimalNumberWithString:@"5.6"];
    [stratFile addThemesObject:theme];    
    
    Objective *financialObjective = (Objective*)[DataManager createManagedInstance:NSStringFromClass([Objective class])];
    financialObjective.summary = @"Increase machine capacity";
    financialObjective.order = [NSNumber numberWithInt:0];
    financialObjective.objectiveType = [ObjectiveType objectiveTypeForCategory:ObjectiveCategoryFinancial];
    financialObjective.reviewFrequency = [Frequency frequencyForCategory:FrequencyCategoryAnnually];    
    [theme addObjectivesObject:financialObjective];
    
    Metric *financialMetric = (Metric*)[DataManager createManagedInstance:NSStringFromClass([Metric class])];
    financialMetric.summary = @"Revenue";
    financialMetric.targetDate = [NSDate dateFromISO8601:@"20121029"];
    financialMetric.targetValue = @"$300,000";
    financialMetric.successIndicator = [NSNumber numberWithInt:SuccessIndicatorMeetOrExceed];
    [financialObjective addMetricsObject:financialMetric];
    
    Measurement *measurement1 = (Measurement*)[DataManager createManagedInstance:NSStringFromClass([Measurement class])];
    measurement1.date = [NSDate dateFromISO8601:@"20121023"];
    measurement1.value = [NSNumber numberWithInt:100];
    [financialMetric addMeasurementsObject:measurement1];

    Measurement *measurement2 = (Measurement*)[DataManager createManagedInstance:NSStringFromClass([Measurement class])];
    measurement2.date = [NSDate dateFromISO8601:@"20121025"];
    measurement2.value = [NSNumber numberWithInt:120];
    measurement2.comment = @"Reached revenue target";
    [financialMetric addMeasurementsObject:measurement2];

    Measurement *measurement3 = (Measurement*)[DataManager createManagedInstance:NSStringFromClass([Measurement class])];
    measurement3.date = [NSDate dateFromISO8601:@"20121027"];
    measurement3.value = [NSNumber numberWithInt:140];
    [financialMetric addMeasurementsObject:measurement3];

    Responsible *hansSolo = (Responsible*)[DataManager createManagedInstance:NSStringFromClass([Responsible class])];
    hansSolo.summary = @"Hans Solo";
    hansSolo.stratFile = stratFile;
    
    Activity *financialActivity = (Activity*)[DataManager createManagedInstance:NSStringFromClass([Activity class])];
    financialActivity.action = @"Get vendor bids";
    financialActivity.order = [NSNumber numberWithInt:0];
    financialActivity.responsible = hansSolo;
    financialActivity.startDate = [NSDate date];
    financialActivity.endDate = [NSDate date];
    financialActivity.upfrontCost = [NSNumber numberWithDouble:15000];
    financialActivity.ongoingCost = [NSNumber numberWithDouble:500];
    financialActivity.ongoingFrequency = [Frequency frequencyForCategory:FrequencyCategoryMonthly];
    [financialObjective addActivitiesObject:financialActivity];
    
    
    Objective *financialObjective2 = (Objective*)[DataManager createManagedInstance:NSStringFromClass([Objective class])];
    financialObjective2.summary = @"Cheap Office Space";
    financialObjective2.order = [NSNumber numberWithInt:1];
    financialObjective2.objectiveType = [ObjectiveType objectiveTypeForCategory:ObjectiveCategoryFinancial];
    financialObjective2.reviewFrequency = [Frequency frequencyForCategory:FrequencyCategoryBiWeekly];
    
    Metric *financialMetric2 = (Metric*)[DataManager createManagedInstance:NSStringFromClass([Metric class])];
    financialMetric2.summary = @"Expense";    
    financialMetric2.targetDate = [NSDate date];
    financialMetric2.targetValue = @"-$100,000"; 
    [financialObjective2 addMetricsObject:financialMetric2];
    
    [theme addObjectivesObject:financialObjective2];
    
    Chart *chartOverlay = (Chart*)[DataManager createManagedInstance:NSStringFromClass([Chart class])];
    chartOverlay.zLayer = overlayChartLayer;
    chartOverlay.title = @"Gross Margin %";
    chartOverlay.chartType = [NSNumber numberWithInt:ChartTypeLine];
    chartOverlay.showTrend = [NSNumber numberWithBool:NO];
    chartOverlay.colorScheme = [NSNumber numberWithInt:2];
    chartOverlay.showTarget = [NSNumber numberWithBool:NO];
    chartOverlay.metric = financialMetric2;
    chartOverlay.order = [NSNumber numberWithInt:1];
    chartOverlay.uuid = [NSString stringWithUUID];

    Chart *chart = (Chart*)[DataManager createManagedInstance:NSStringFromClass([Chart class])];
    chart.title = @"Revenue Chart";
    chart.zLayer = primaryChartLayer;
    chart.chartType = [NSNumber numberWithInt:ChartTypeBar];
    chart.showTrend = [NSNumber numberWithBool:NO];
    chart.colorScheme = [NSNumber numberWithInt:7];
    chart.showTarget = [NSNumber numberWithBool:NO];
    chart.metric = financialMetric;
    chart.order = [NSNumber numberWithInt:1];
    chart.uuid = [NSString stringWithUUID];
    chart.overlay = chartOverlay.uuid;
    chart.yAxisMax = [NSNumber numberWithInt:200];
    
    
    Objective *staffObjective = (Objective*)[DataManager createManagedInstance:NSStringFromClass([Objective class])];
    staffObjective.summary = @"Hire Elves";
    staffObjective.order = [NSNumber numberWithInt:2];
    staffObjective.objectiveType = [ObjectiveType objectiveTypeForCategory:ObjectiveCategoryStaff];
    staffObjective.reviewFrequency = [Frequency frequencyForCategory:FrequencyCategorySemiAnnually];
    
    Metric *staffMetric = (Metric*)[DataManager createManagedInstance:NSStringFromClass([Metric class])];
    staffMetric.summary = @"Expense";
    staffMetric.targetDate = [NSDate date];
    staffMetric.targetValue = @"-$250,000";
    [staffObjective addMetricsObject:staffMetric];
    
    [theme addObjectivesObject:staffObjective];
    
    
    Theme *theme2 = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    theme2.title = @"Another much more sophisticated theme";
    theme2.order = [NSNumber numberWithInt:1];
    [stratFile addThemesObject:theme2];   
    
    Objective *obj1 = (Objective*)[DataManager createManagedInstance:NSStringFromClass([Objective class])];
    obj1.summary = @"Hire Dwarves";
    obj1.order = [NSNumber numberWithInt:0];
    obj1.objectiveType = [ObjectiveType objectiveTypeForCategory:ObjectiveCategoryStaff];
    [theme2 addObjectivesObject:obj1];
    
    Objective *obj2 = (Objective*)[DataManager createManagedInstance:NSStringFromClass([Objective class])];
    obj2.summary = @"Hire Fairies";
    obj2.order = [NSNumber numberWithInt:1];
    obj2.objectiveType = [ObjectiveType objectiveTypeForCategory:ObjectiveCategoryStaff];
    [theme2 addObjectivesObject:obj2];
    
    Objective *obj6 = (Objective*)[DataManager createManagedInstance:NSStringFromClass([Objective class])];
    obj6.summary = @"Teach Fortran";
    obj6.order = [NSNumber numberWithInt:2];
    obj6.objectiveType = [ObjectiveType objectiveTypeForCategory:ObjectiveCategoryCustomer];
    [theme2 addObjectivesObject:obj6];
    
    
    Theme *theme3 = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    theme3.title = @"Yet another really long theme to see what happens in the stratmap.";
    theme3.order = [NSNumber numberWithInt:2];
    [stratFile addThemesObject:theme3];   
    
    Objective *obj3 = (Objective*)[DataManager createManagedInstance:NSStringFromClass([Objective class])];
    obj3.summary = @"Fire Laziness";
    obj3.order = [NSNumber numberWithInt:0];
    obj3.objectiveType = [ObjectiveType objectiveTypeForCategory:ObjectiveCategoryProcess];
    [theme3 addObjectivesObject:obj3];
    
    Objective *obj4 = (Objective*)[DataManager createManagedInstance:NSStringFromClass([Objective class])];
    obj4.summary = @"Fire Ineffectiveness";
    obj4.order = [NSNumber numberWithInt:1];
    obj4.objectiveType = [ObjectiveType objectiveTypeForCategory:ObjectiveCategoryProcess];
    [theme3 addObjectivesObject:obj4];
    
    Objective *obj5 = (Objective*)[DataManager createManagedInstance:NSStringFromClass([Objective class])];
    obj5.summary = @"Fire Incompetence";
    obj5.order = [NSNumber numberWithInt:2];
    obj5.objectiveType = [ObjectiveType objectiveTypeForCategory:ObjectiveCategoryProcess];
    [theme3 addObjectivesObject:obj5];
    
    Objective *obj7 = (Objective*)[DataManager createManagedInstance:NSStringFromClass([Objective class])];
    obj7.summary = @"Teach Fortran";
    obj7.order = [NSNumber numberWithInt:3];
    obj7.objectiveType = [ObjectiveType objectiveTypeForCategory:ObjectiveCategoryCustomer];
    [theme3 addObjectivesObject:obj7];
    
    return stratFile;    
}


+ (Theme*)createTheme1
{
    Theme *theme = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    theme.title = @"Test Theme 1";
    
    Objective *f1 = (Objective*)[DataManager createManagedInstance:NSStringFromClass([Objective class])];
    f1.summary = @"Increase machine capacity";
    f1.objectiveType = [ObjectiveType objectiveTypeForCategory:ObjectiveCategoryFinancial];
    f1.order = [NSNumber numberWithInt:0];
    [theme addObjectivesObject:f1];
    
    Objective *f2 = (Objective*)[DataManager createManagedInstance:NSStringFromClass([Objective class])];
    f2.summary = @"Increase machine count";
    f2.objectiveType = [ObjectiveType objectiveTypeForCategory:ObjectiveCategoryFinancial];
    f2.order = [NSNumber numberWithInt:1];
    [theme addObjectivesObject:f2];
    
    Objective *c1 = (Objective*)[DataManager createManagedInstance:NSStringFromClass([Objective class])];
    c1.summary = @"Increase community outreach";
    c1.objectiveType = [ObjectiveType objectiveTypeForCategory:ObjectiveCategoryCommunity];
    c1.order = [NSNumber numberWithInt:0];
    [theme addObjectivesObject:c1];
    
    Objective *p1 = (Objective*)[DataManager createManagedInstance:NSStringFromClass([Objective class])];
    p1.summary = @"Increase process instruction";
    p1.objectiveType = [ObjectiveType objectiveTypeForCategory:ObjectiveCategoryProcess];
    p1.order = [NSNumber numberWithInt:0];
    [theme addObjectivesObject:p1];
    
    return theme;
}

+ (Theme*)createTheme2
{
    Theme *theme = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    theme.title = @"Test Theme 2";
    
    Objective *f1 = (Objective*)[DataManager createManagedInstance:NSStringFromClass([Objective class])];
    f1.summary = @"Increase machine capacity";
    f1.objectiveType = [ObjectiveType objectiveTypeForCategory:ObjectiveCategoryFinancial];
    f1.order = [NSNumber numberWithInt:0];
    [theme addObjectivesObject:f1];
    
    Objective *f2 = (Objective*)[DataManager createManagedInstance:NSStringFromClass([Objective class])];
    f2.summary = @"Increase machine count";
    f2.objectiveType = [ObjectiveType objectiveTypeForCategory:ObjectiveCategoryFinancial];
    f2.order = [NSNumber numberWithInt:1];
    [theme addObjectivesObject:f2];
    
    Objective *c1 = (Objective*)[DataManager createManagedInstance:NSStringFromClass([Objective class])];
    c1.summary = @"Increase community outreach";
    c1.objectiveType = [ObjectiveType objectiveTypeForCategory:ObjectiveCategoryCommunity];
    c1.order = [NSNumber numberWithInt:0];
    [theme addObjectivesObject:c1];
    
    Objective *p1 = (Objective*)[DataManager createManagedInstance:NSStringFromClass([Objective class])];
    p1.summary = @"Increase process instruction";
    p1.objectiveType = [ObjectiveType objectiveTypeForCategory:ObjectiveCategoryProcess];
    p1.order = [NSNumber numberWithInt:0];
    [theme addObjectivesObject:p1];
    
    return theme;
}

+ (Theme*)createTheme3
{
    Theme *theme = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    theme.title = @"Test Theme 3";
    
    Objective *f1 = (Objective*)[DataManager createManagedInstance:NSStringFromClass([Objective class])];
    f1.objectiveType = [ObjectiveType objectiveTypeForCategory:ObjectiveCategoryFinancial];
    f1.order = [NSNumber numberWithInt:0];
    [theme addObjectivesObject:f1];
    
    Objective *f2 = (Objective*)[DataManager createManagedInstance:NSStringFromClass([Objective class])];
    f2.objectiveType = [ObjectiveType objectiveTypeForCategory:ObjectiveCategoryFinancial];
    f2.order = [NSNumber numberWithInt:1];
    [theme addObjectivesObject:f2];
    
    Objective *f3 = (Objective*)[DataManager createManagedInstance:NSStringFromClass([Objective class])];
    f3.objectiveType = [ObjectiveType objectiveTypeForCategory:ObjectiveCategoryFinancial];
    f3.order = [NSNumber numberWithInt:2];
    [theme addObjectivesObject:f3];
    
    Objective *p1 = (Objective*)[DataManager createManagedInstance:NSStringFromClass([Objective class])];
    p1.objectiveType = [ObjectiveType objectiveTypeForCategory:ObjectiveCategoryProcess];
    p1.order = [NSNumber numberWithInt:0];
    [theme addObjectivesObject:p1];
    
    return theme;
}

+ (Theme*)createThemeWithTitle:(NSString*)title andFinancialWidth:(NSUInteger)width andOrder:(NSUInteger)order
{
    Theme *theme = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    theme.title = title;
    theme.order = [NSNumber numberWithInt:order];
    
    for (int i=0; i<width; i++) {
        Objective *f1 = (Objective*)[DataManager createManagedInstance:NSStringFromClass([Objective class])];
        f1.objectiveType = [ObjectiveType objectiveTypeForCategory:ObjectiveCategoryFinancial];
        f1.order = [NSNumber numberWithInt:i];
        [theme addObjectivesObject:f1];        
    }
    
    return theme;
}

+ (NSDate*)dateFromString:(NSString*)dateString
{
    // 2011-12-01 ie. yyyy-mm-dd
    return [NSDate dateTimeFromISO8601:[NSString stringWithFormat:@"%@T00:00:00+0000", [dateString stringByReplacingOccurrencesOfString:@"-" withString:@""]]];
}

@end

@implementation NSDate (TestSupport)

- (NSString*)utcFormattedDateTime
{
    // locale independent
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];        
    [formatter setDateFormat:@"MM-dd-yyyy HH:mm"];
    [formatter setTimeZone:[NSTimeZone utcTimeZone]];
    NSString *formattedDate = [formatter stringFromDate:self];
    [formatter release];
    
    return formattedDate;
}

- (NSString*)localFormattedDateTime
{
    // locale independent
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];        
    [formatter setDateFormat:@"MM-dd-yyyy HH:mm"];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    NSString *formattedDate = [formatter stringFromDate:self];
    [formatter release];
    
    return formattedDate;
}

- (NSString*)localFormattedDate
{
    // locale independent
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];        
    [formatter setDateFormat:@"MM-dd-yyyy"];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    NSString *formattedDate = [formatter stringFromDate:self];
    [formatter release];
    
    return formattedDate;
}

@end


