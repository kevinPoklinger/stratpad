//
//  CSVFileWriter.m
//  StratPad
//
//  Created by Julian Wood on 12-02-02.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "CSVFileWriter.h"
#import "Settings.h"
#import "NSArray+CHCSVAdditions.h"
#import "ThemeFinancialAnalysisCalculationStrategy.h"
#import "NSCalendar+Expanded.h"
#import "NSDate-StratPad.h"
#import "DataManager.h"
#import "R2CalculationStrategy.h"
#import "IncomeStatementSummaryViewController.h"
#import "AFHTTPClient.h"


@implementation CSVFileWriter

- (BOOL)exportConsolidatedReportToCsvAtPath:(NSString*)path stratFile:(StratFile*)stratFile
{
    Settings *settings = (Settings*)[DataManager objectForEntity:NSStringFromClass([Settings class]) sortDescriptorsOrNil:nil predicateOrNil:nil];
        
    // we need to build an array of arrays of strings, from the values we see in R2
    R2CalculationStrategy *calculationStrategy = [[R2CalculationStrategy alloc] initWithStratFile:stratFile andIsOptimistic:[settings.isCalculationOptimistic boolValue]];    

    uint duration = [stratFile strategyDurationInYears] * 12;
    NSMutableArray *csvValues = [NSMutableArray array];

    // prepare for showing dates
    NSDate *startDate = [calculationStrategy reportStartDate];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];

    // add column headings (dates)
    NSMutableArray *rowValues = [NSMutableArray arrayWithCapacity:duration+3];
    [rowValues addObject:@""]; // room for the row heading
    for (uint i = 0; i < duration; ++i) { 
        [comps setMonth:i];
        NSDate *headingDate = [gregorian dateByAddingComponents:comps toDate:startDate options:0];
        [rowValues addObject:[headingDate formattedMonthYear]];
    }
    [rowValues addObject:LocalizedString(@"TOTAL", nil)];
    [comps release];
    [csvValues addObject:[[rowValues copy] autorelease]];
    
    // add values for change in revenue
    [rowValues removeAllObjects];
    [rowValues addObject:LocalizedString(@"CHANGE_IN_REVENUE", nil)];
    for (uint i = 0, ct=duration; i < ct; ++i) {
        [rowValues addObject:[calculationStrategy changeInRevenueForMonthNumber:i]];
    }
    double totalRev = [[calculationStrategy changeInRevenueForYear:0] doubleValue] + [[calculationStrategy changeInRevenueForYearsAfter:0] doubleValue];
    [rowValues addObject:[NSNumber numberWithDouble:totalRev]];
    [csvValues addObject:[[rowValues copy] autorelease]]; 

    // add values for COGS change
    [rowValues removeAllObjects];
    [rowValues addObject:LocalizedString(@"CHANGE_IN_COGS", nil)];
    for (uint i = 0, ct=duration; i < ct; ++i) {
        [rowValues addObject:[calculationStrategy changeInCOGSForMonthNumber:i]];
    }
    double totalCOGS = [[calculationStrategy changeInCOGSForYear:0] doubleValue] + [[calculationStrategy changeInCOGSForYearsAfter:0] doubleValue];
    [rowValues addObject:[NSNumber numberWithDouble:totalCOGS]];
    [csvValues addObject:[[rowValues copy] autorelease]]; 
    
    // add values for total change in Gross Profit
    [rowValues removeAllObjects];
    [rowValues addObject:LocalizedString(@"TOTAL_CHANGE_IN_GROSS_PROFIT", nil)];
    for (uint i = 0, ct=duration; i < ct; ++i) {
        [rowValues addObject:[calculationStrategy totalChangeInGrossMarginForMonthNumber:i]];
    }
    double totalProfit = [[calculationStrategy totalChangeInGrossMarginForYear:0] doubleValue] + [[calculationStrategy totalChangeInGrossMarginForYearsAfter:0] doubleValue];
    [rowValues addObject:[NSNumber numberWithDouble:totalProfit]];
    [csvValues addObject:[[rowValues copy] autorelease]]; 
    
    // next section
    
    // add values for change in R&D
    [rowValues removeAllObjects];
    [rowValues addObject:LocalizedString(@"CHANGE_IN_RAD", nil)];
    for (uint i = 0, ct=duration; i < ct; ++i) {
        [rowValues addObject:[calculationStrategy changeInRadForMonthNumber:i]];
    }
    double totalRad = [[calculationStrategy changeInRadForYear:0] doubleValue] + [[calculationStrategy changeInRadForYearsAfter:0] doubleValue];
    [rowValues addObject:[NSNumber numberWithDouble:totalRad]];
    [csvValues addObject:[[rowValues copy] autorelease]]; 
    
    // add values for change in G&A
    [rowValues removeAllObjects];
    [rowValues addObject:LocalizedString(@"CHANGE_IN_GAA", nil)];
    for (uint i = 0, ct=duration; i < ct; ++i) {
        [rowValues addObject:[calculationStrategy changeInGaaForMonthNumber:i]];
    }
    double totalGaa = [[calculationStrategy changeInGaaForYear:0] doubleValue] + [[calculationStrategy changeInGaaForYearsAfter:0] doubleValue];
    [rowValues addObject:[NSNumber numberWithDouble:totalGaa]];
    [csvValues addObject:[[rowValues copy] autorelease]];
    
    // add values for change in s&m
    [rowValues removeAllObjects];
    [rowValues addObject:LocalizedString(@"CHANGE_IN_SAM", nil)];
    for (uint i = 0, ct=duration; i < ct; ++i) {
        [rowValues addObject:[calculationStrategy changeInSamForMonthNumber:i]];
    }
    double totalSam = [[calculationStrategy changeInSamForYear:0] doubleValue] + [[calculationStrategy changeInSamForYearsAfter:0] doubleValue];
    [rowValues addObject:[NSNumber numberWithDouble:totalSam]];
    [csvValues addObject:[[rowValues copy] autorelease]];

    
    // add values for total change in expenses
    [rowValues removeAllObjects];
    [rowValues addObject:LocalizedString(@"TOTAL_CHANGE_IN_EXPENSES", nil)];
    for (uint i = 0, ct=duration; i < ct; ++i) {
        [rowValues addObject:[calculationStrategy totalChangeInExpensesForMonthNumber:i]];
    }
    double totalChangeExp = [[calculationStrategy totalChangeInExpensesForYear:0] doubleValue] + [[calculationStrategy totalChangeInExpensesForYearsAfter:0] doubleValue];
    [rowValues addObject:[NSNumber numberWithDouble:totalChangeExp]];
    [csvValues addObject:[[rowValues copy] autorelease]]; 
    
    // next section
    
    // add values for net contribution
    [rowValues removeAllObjects];
    [rowValues addObject:LocalizedString(@"NET_CONTRIBUTION", nil)];
    for (uint i = 0, ct=duration; i < ct; ++i) {
        [rowValues addObject:[calculationStrategy netContributionForMonthNumber:i]];
    }
    double totalNetCon = [[calculationStrategy netContributionForYear:0] doubleValue] + [[calculationStrategy netContributionForYearsAfter:0] doubleValue];
    [rowValues addObject:[NSNumber numberWithDouble:totalNetCon]];
    [csvValues addObject:[[rowValues copy] autorelease]]; 
    
    // add values for net cumulative contribution
    [rowValues removeAllObjects];
    [rowValues addObject:LocalizedString(@"NET_CUMULATIVE_CONTRIBUTION", nil)];
    for (uint i = 0, ct=duration; i < ct; ++i) {
        [rowValues addObject:[calculationStrategy netCumulativeForMonthNumber:i]];
    }
    // use the last value from net cumulative contribution
    [rowValues addObject:[rowValues lastObject]];
    [csvValues addObject:[[rowValues copy] autorelease]]; 
    
    DLog(@"Saving csv to: %@", path);
    
    // write array to csv file
    NSError *error;
    BOOL success = [csvValues writeToCSVFile:path atomically:NO error:&error];
    if (!success) {
        ELog(@"Couldn't export csv file to path: %@. Error: %@", path, error);
    }

    [calculationStrategy release];
    
    return YES;
}

- (BOOL)exportThemeToCsvAtPath:(NSString*)path theme:(Theme*)theme
{
    Settings *settings = (Settings*)[DataManager objectForEntity:NSStringFromClass([Settings class]) sortDescriptorsOrNil:nil predicateOrNil:nil];
    
    // we need to build an array of arrays of strings, from the values we see in R4
    ThemeFinancialAnalysisCalculationStrategy *calculationStrategy = [[ThemeFinancialAnalysisCalculationStrategy alloc] initWithTheme:theme isOptimistic:[[settings isCalculationOptimistic] boolValue] isRelativeToStrategyStart:YES];    
    
    uint calcDuration = calculationStrategy.calculationDurationInMonths;
    NSMutableArray *csvValues = [NSMutableArray array];
    
    // prepare for showing dates
    NSDate *startDate = [calculationStrategy calculationStartDate];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];
    
    // add column headings (dates)
    NSMutableArray *rowValues = [NSMutableArray arrayWithCapacity:calcDuration+2];
    [rowValues addObject:@""]; // room for the row heading
    for (uint i = 0; i < calcDuration; ++i) { 
        [comps setMonth:i];
        NSDate *headingDate = [gregorian dateByAddingComponents:comps toDate:startDate options:0];
        [rowValues addObject:[headingDate formattedMonthYear]];
    }
    [rowValues addObject:LocalizedString(@"TOTAL", nil)];
    [comps release];
    [csvValues addObject:[[rowValues copy] autorelease]];
    
    // add values for revenue change
    [rowValues removeAllObjects];
    [rowValues addObject:LocalizedString(@"CHANGE_IN_REVENUE", nil)];
    for (uint i = 0, ct=calcDuration; i < ct; ++i) {
        [rowValues addObject:[calculationStrategy changeInRevenueForMonthNumber:i]];
    }
    double totalRev = [[calculationStrategy changeInRevenueForYear:0] doubleValue] + [[calculationStrategy changeInRevenueForYearsAfter:0] doubleValue];
    [rowValues addObject:[NSNumber numberWithDouble:totalRev]];
    [csvValues addObject:[[rowValues copy] autorelease]]; 
    
    // add values for COGS change
    [rowValues removeAllObjects];
    [rowValues addObject:LocalizedString(@"CHANGE_IN_COGS", nil)];
    for (uint i = 0, ct=calcDuration; i < ct; ++i) {
        [rowValues addObject:[calculationStrategy changeInCOGSForMonthNumber:i]];
    }
    double totalCOGS = [[calculationStrategy changeInCOGSForYear:0] doubleValue] + [[calculationStrategy changeInCOGSForYearsAfter:0] doubleValue];
    [rowValues addObject:[NSNumber numberWithDouble:totalCOGS]];
    [csvValues addObject:[[rowValues copy] autorelease]]; 
    
    // add values for total change in Gross Profit
    [rowValues removeAllObjects];
    [rowValues addObject:LocalizedString(@"TOTAL_CHANGE_IN_GROSS_PROFIT", nil)];
    for (uint i = 0, ct=calcDuration; i < ct; ++i) {
        [rowValues addObject:[calculationStrategy totalChangeInGrossMarginForMonthNumber:i]];
    }
    double totalProfit = [[calculationStrategy totalChangeInGrossMarginForYear:0] doubleValue] + [[calculationStrategy totalChangeInGrossMarginForYearsAfter:0] doubleValue];
    [rowValues addObject:[NSNumber numberWithDouble:totalProfit]];
    [csvValues addObject:[[rowValues copy] autorelease]]; 
    
    // next section
    
    // add values for change in expenses
    [rowValues removeAllObjects];
    [rowValues addObject:LocalizedString(@"CHANGE_IN_RAD", nil)];
    for (uint i = 0, ct=calcDuration; i < ct; ++i) {
        [rowValues addObject:[calculationStrategy changeInRadForMonthNumber:i]];
    }
    double totalExp = [[calculationStrategy changeInRadForYear:0] doubleValue] + [[calculationStrategy changeInRadForYearsAfter:0] doubleValue];
    [rowValues addObject:[NSNumber numberWithDouble:totalExp]];
    [csvValues addObject:[[rowValues copy] autorelease]]; 
    
    // add values for change in costs
    [rowValues removeAllObjects];
    [rowValues addObject:LocalizedString(@"CHANGE_IN_GAA", nil)];
    for (uint i = 0, ct=calcDuration; i < ct; ++i) {
        [rowValues addObject:[calculationStrategy changeInGaaForMonthNumber:i]];
    }
    double totalCosts = [[calculationStrategy changeInGaaForYear:0] doubleValue] + [[calculationStrategy changeInGaaForYearsAfter:0] doubleValue];
    [rowValues addObject:[NSNumber numberWithDouble:totalCosts]];
    [csvValues addObject:[[rowValues copy] autorelease]]; 
    
    // add values for total change in expenses
    [rowValues removeAllObjects];
    [rowValues addObject:LocalizedString(@"TOTAL_CHANGE_IN_EXPENSES", nil)];
    for (uint i = 0, ct=calcDuration; i < ct; ++i) {
        [rowValues addObject:[calculationStrategy totalChangeInExpensesForMonthNumber:i]];
    }
    double totalChangeExp = [[calculationStrategy totalChangeInExpensesForYear:0] doubleValue] + [[calculationStrategy totalChangeInExpensesForYearsAfter:0] doubleValue];
    [rowValues addObject:[NSNumber numberWithDouble:totalChangeExp]];
    [csvValues addObject:[[rowValues copy] autorelease]]; 
    
    // next section
    
    // add values for net contribution
    [rowValues removeAllObjects];
    [rowValues addObject:LocalizedString(@"NET_CONTRIBUTION", nil)];
    for (uint i = 0, ct=calcDuration; i < ct; ++i) {
        [rowValues addObject:[calculationStrategy netContributionForMonthNumber:i]];
    }
    double totalNetCon = [[calculationStrategy netContributionForYear:0] doubleValue] + [[calculationStrategy netContributionForYearsAfter:0] doubleValue];
    [rowValues addObject:[NSNumber numberWithDouble:totalNetCon]];
    [csvValues addObject:[[rowValues copy] autorelease]]; 
    
    // add values for net cumulative contribution
    [rowValues removeAllObjects];
    [rowValues addObject:LocalizedString(@"NET_CUMULATIVE_CONTRIBUTION", nil)];
    for (uint i = 0, ct=calcDuration; i < ct; ++i) {
        [rowValues addObject:[calculationStrategy netCumulativeForMonthNumber:i]];
    }
    // use the last value from net cumulative contribution
    [rowValues addObject:[rowValues lastObject]];
    [csvValues addObject:[[rowValues copy] autorelease]]; 
    
    DLog(@"Saving csv to: %@", path);
    
    // write array to csv file
    NSError *error;
    BOOL success = [csvValues writeToCSVFile:path atomically:NO error:&error];
    if (!success) {
        ELog(@"Couldn't export csv file to path: %@. Error: %@", path, error);
    }
    
    [calculationStrategy release];
    
    return success;
}


#pragma mark - Financial Reports (Experimental - we actually use JsonToCsvProcessor instead)

-(void)exportIncomeStatementToCsvAtPath:(NSString*)path json:(NSDictionary*)json
{
    // manipulate json
    NSMutableArray *csvValues = [NSMutableArray array];
    
    // add dates row
    // date is in format yyyyMM
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setTimeStyle:NSDateFormatterNoStyle];
    [df setDateFormat:@"yyyyMM"];
    NSDate *startDate = [df dateFromString:[[json objectForKey:@"startDate"] stringValue]];
    [df release];
    
    [self addDatesFromStartDate:startDate csvValues:csvValues];
    
    // revenue
    NSDictionary *revenue = [json objectForKey:@"revenue"];
    NSArray *themes = [revenue objectForKey:@"data"];
    for (NSDictionary *dict in themes) {
        NSArray *rowValues = [dict objectForKey:@"values"];
        if ([self hasValues:rowValues]) {
            [self addRowWithValues:rowValues
                         rowHeader:[dict objectForKey:@"name"]
                         csvValues:csvValues];
        }
    }
    [self addRowWithValues:[revenue objectForKey:@"subtotals"]
                 rowHeader:@"Total Revenue"
                 csvValues:csvValues];
    [self addSpacer:csvValues];
    
    // cogs
    NSDictionary *cogs = [json objectForKey:@"cogs"];
    [self addRowWithValues:[cogs objectForKey:@"subtotals"]
                 rowHeader:@"Cost of Goods Sold"
                 csvValues:csvValues];
    [self addRowWithValues:[cogs objectForKey:@"totals"]
                 rowHeader:@"Subtotal"
                 csvValues:csvValues];
    [self addSpacer:csvValues];

    // expenses
    NSDictionary *expenses = [json objectForKey:@"expenses"];
    NSArray *data = [expenses objectForKey:@"data"];
    for (NSDictionary *dict in data) {
        [self addRowWithValues:[dict objectForKey:@"values"]
                     rowHeader:[dict objectForKey:@"name"]
                     csvValues:csvValues];
    }
    [self addRowWithValues:[cogs objectForKey:@"subtotals"]
                 rowHeader:@"Total Expenses"
                 csvValues:csvValues];
    [self addSpacer:csvValues];
    
    // net income
    NSDictionary *netIncome = [json objectForKey:@"netIncome"];
    [self addRowWithValues:[netIncome objectForKey:@"totals"]
                 rowHeader:@"Net Income"
                 csvValues:csvValues];
    
    
    DLog(@"Saving csv to: %@", path);
    
    // write array to csv file
    NSError *error;
    BOOL success = [csvValues writeToCSVFile:path atomically:NO error:&error];
    if (!success) {
        ELog(@"Couldn't export csv file to path: %@. Error: %@", path, error);
    }

}

-(BOOL)hasValues:(NSArray*)values
{
    for (id value in values) {
        if (value != [NSNull null]) {
            return YES;
        }
    }
    return NO;
}

-(void)addDatesFromStartDate:(NSDate*)startDate csvValues:(NSMutableArray*)csvValues
{
    NSMutableArray *dates = [NSMutableArray arrayWithCapacity:8*12];
    [dates addObject:@""];
    NSCalendar *cal = [NSCalendar cachedGregorianCalendar];
    NSDateComponents *offsetComps = [[NSDateComponents alloc] init];
    
    for (uint i=0; i<8*12; i++) {
        [offsetComps setMonth:i];
        NSDate *date = [cal dateByAddingComponents:offsetComps toDate:startDate options:0];
        [dates addObject:[date formattedMonthYear]];
    }
    [offsetComps release];
    
    [csvValues addObject:dates];
}

-(void)addRowWithValues:(NSArray*)rowValues rowHeader:(NSString*)rowHeader csvValues:(NSMutableArray*)csvValues
{
    // need to fill with zeroes, before and after the values
    NSMutableArray *row = [NSMutableArray array];
    [row addObject:rowHeader];
    [row addObjectsFromArray:rowValues];
    [csvValues addObject:row];
}

-(void)addSpacer:(NSMutableArray*)csvValues
{
    [csvValues addObject:[NSArray arrayWithObject:[NSNull null]]];
}

@end
