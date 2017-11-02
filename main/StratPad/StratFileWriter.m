//
//  StratFileWriter.m
//  StratPad
//
//  Created by Julian Wood on 9/8/11.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "StratFileWriter.h"
#import "NSDate-StratPad.h"
#import "NSString-Expanded.h"
#import "Responsible.h"
#import "Theme.h"
#import "Objective.h"
#import "Activity.h"
#import "Frequency.h"
#import "Metric.h"
#import "Measurement.h"
#import "Chart.h"
#import "UIColor-Expanded.h"
#import "EditionManager.h"
#import "RegistrationManager.h"
#import "UAKeychainUtils+StratPad.h"
#import "Financials.h"
#import "Loan.h"
#import "Asset.h"
#import "Equity.h"
#import "EmployeeDeductions.h"
#import "SalesTax.h"
#import "IncomeTax.h"
#import "OpeningBalances.h"

@implementation StratFileWriter

-(id)initWithStratFile:(StratFile*)stratFile
{
    self = [super init];
    if (self) {
        stratFile_ = [stratFile retain];
    }
    return self;
}

-(void)writeStratFile:(BOOL)filterInvalidData
{
    [self writeStartDocumentWithEncodingAndVersion:@"UTF-8" version:@"1.0"];
    
    [self writeStartElement:@"stratfile"];
    
    [self writeDateTime:stratFile_.dateCreated tagName:@"dateCreated"];
    [self writeDateTime:stratFile_.dateLastAccessed tagName:@"dateLastAccessed"];
    [self writeDateTime:stratFile_.dateModified tagName:@"dateModified"];
    
    [self writeString:stratFile_.permissions tagName:@"permissions"];
    
    // stratfile_.model is the model that it was imported with, and we will keep that - could just be resident in the db
    // when exporting though, we want to indicate the latest model
    NSString *model = [[EditionManager sharedManager] modelVersion];
    [self writeString:model tagName:@"model"];

    // this isn't part of the model, but is used for a simple security check when sending backups
    NSString *email = [[NSUserDefaults standardUserDefaults] stringForKey:keyEmail];
    BOOL isVerified = [[UAKeychainUtils valueForKey:keyChainVerified] boolValue];
    if (email && isVerified) {
        [self writeString:email tagName:@"email"];
    }
    
    // uuid @since 1.6
    if (!stratFile_.uuid) {
        stratFile_.uuid = [NSString stringWithUUID];
    }
    [self writeString:stratFile_.uuid tagName:@"uuid"];
    
    [self writeString:stratFile_.name tagName:@"name"];
    [self writeString:stratFile_.companyName tagName:@"companyName"];
    [self writeString:stratFile_.city tagName:@"city"];
    [self writeString:stratFile_.provinceState tagName:@"provinceState"];
    [self writeString:stratFile_.country tagName:@"country"];
    [self writeString:stratFile_.industry tagName:@"industry"];
    
    [self writeString:stratFile_.keyProblems tagName:@"keyProblems"];
    [self writeString:stratFile_.addressProblems tagName:@"addressProblems"];
    [self writeString:stratFile_.customersDescription tagName:@"customersDescription"];
    [self writeString:stratFile_.competitorsDescription tagName:@"competitorsDescription"];
    [self writeString:stratFile_.businessModelDescription tagName:@"businessModelDescription"];
    [self writeString:stratFile_.expansionOptionsDescription tagName:@"expansionOptionsDescription"];
    [self writeString:stratFile_.ultimateAspiration tagName:@"ultimateAspiration"];
    [self writeString:stratFile_.mediumTermStrategicGoal tagName:@"mediumTermStrategicGoal"];
    
    // financials, @since 1.6
    [self writeStartElement:@"financials"];
    [self writeNumber:stratFile_.financials.accountsReceivableTerm tagName:@"accountsReceivableTerm"];
    [self writeNumber:stratFile_.financials.accountsPayableTerm tagName:@"accountsPayableTerm"];
    [self writeNumber:stratFile_.financials.percentCogsIsInventory tagName:@"percentCogsIsInventory"];
    [self writeNumber:stratFile_.financials.inventoryLeadTime tagName:@"inventoryLeadTime"];
    
    [self writeStartElement:@"loans"];
    for (Loan *loan in stratFile_.financials.loans) {
        if (!filterInvalidData || [loan isValid]) {
            [self writeLoan:loan];
        }
    }
    [self writeEndElement];

    [self writeStartElement:@"assets"];
    for (Asset *asset in stratFile_.financials.assets) {
        if (!filterInvalidData || [asset isValid]) {
            [self writeAsset:asset];
        }
    }
    [self writeEndElement];

    [self writeStartElement:@"equities"];
    for (Equity *equity in stratFile_.financials.equities) {
        if (!filterInvalidData || [equity isValid]) {
            [self writeEquity:equity];
        }
    }
    [self writeEndElement];

    // these are 1:1
    [self writeDeductions:stratFile_.financials.employeeDeductions];
    [self writeSalesTax:stratFile_.financials.salesTax];
    [self writeIncomeTax:stratFile_.financials.incomeTax];
    [self writeOpeningBalances:stratFile_.financials.openingBalances];
    
    [self writeEndElement]; // financials
    
    [self writeStartElement:@"themes"];
    for (Theme *theme in stratFile_.themes) {
        [self writeTheme:theme];
    }
    [self writeEndElement];

    // metrics and respobsibles are shared, and inverse relationships, so don't add them here
    
    [self writeEndElement];
}

-(void)writeLoan:(Loan*)loan
{
    [self writeStartElement:@"loan"];

    [self writeString:loan.name tagName:@"name"];
    [self writeNumber:loan.date tagName:@"date"];
    [self writeNumber:loan.amount tagName:@"amount"];
    [self writeNumber:loan.term tagName:@"term"];
    [self writeNumber:loan.rate tagName:@"rate"];
    [self writeNumber:loan.type tagName:@"type"];
    [self writeNumber:loan.frequency tagName:@"frequency"];

    [self writeEndElement];
}

-(void)writeAsset:(Asset*)asset
{
    [self writeStartElement:@"asset"];
    
    [self writeString:asset.name tagName:@"name"];
    [self writeNumber:asset.date tagName:@"date"];
    [self writeNumber:asset.value tagName:@"value"];
    [self writeNumber:asset.depreciationTerm tagName:@"depreciationTerm"];
    [self writeNumber:asset.salvageValue tagName:@"salvageValue"];
    [self writeNumber:asset.depreciationType tagName:@"depreciationType"];
    [self writeNumber:asset.type tagName:@"type"];
    
    [self writeEndElement];
}

-(void)writeEquity:(Equity*)equity
{
    [self writeStartElement:@"equity"];
    
    [self writeString:equity.name tagName:@"name"];
    [self writeNumber:equity.date tagName:@"date"];
    [self writeNumber:equity.value tagName:@"value"];
    
    [self writeEndElement];
}

-(void)writeDeductions:(EmployeeDeductions*)deductions
{
    [self writeStartElement:@"employeeDeductions"];
    
    [self writeNumber:deductions.percentCogsAreWages tagName:@"percentCogsAreWages"];
    [self writeNumber:deductions.percentGandAAreWages tagName:@"percentGandAAreWages"];
    [self writeNumber:deductions.percentRandDAreWages tagName:@"percentRandDAreWages"];
    [self writeNumber:deductions.percentSandMAreWages tagName:@"percentSandMAreWages"];
    [self writeNumber:deductions.employeeContributionPercentage tagName:@"employeeContributionPercentage"];
    [self writeNumber:deductions.employerContributionPercentage tagName:@"employerContributionPercentage"];
    [self writeNumber:deductions.dueDate tagName:@"dueDate"];
    
    [self writeEndElement];
}

-(void)writeSalesTax:(SalesTax*)salesTax
{
    [self writeStartElement:@"salesTax"];
    
    [self writeNumber:salesTax.percentRevenuesIsTaxable tagName:@"percentRevenuesIsTaxable"];
    [self writeNumber:salesTax.rate tagName:@"rate"];
    [self writeNumber:salesTax.remittanceFrequency tagName:@"remittanceFrequency"];
    [self writeNumber:salesTax.remittanceMonth tagName:@"remittanceMonth"];
    
    [self writeEndElement];
}

-(void)writeIncomeTax:(IncomeTax*)incomeTax
{
    [self writeStartElement:@"incomeTax"];
    
    [self writeNumber:incomeTax.rate1 tagName:@"rate1"];
    [self writeNumber:incomeTax.rate2 tagName:@"rate2"];
    [self writeNumber:incomeTax.rate3 tagName:@"rate3"];
    [self writeNumber:incomeTax.salaryLimit1 tagName:@"salaryLimit1"];
    [self writeNumber:incomeTax.salaryLimit2 tagName:@"salaryLimit2"];
    [self writeNumber:incomeTax.yearsCarryLossesForward tagName:@"yearsCarryLossesForward"];
    [self writeNumber:incomeTax.remittanceFrequency tagName:@"remittanceFrequency"];
    [self writeNumber:incomeTax.remittanceMonth tagName:@"remittanceMonth"];
    
    [self writeEndElement];
}

-(void)writeOpeningBalances:(OpeningBalances*)openingBalances
{
    [self writeStartElement:@"openingBalances"];
    
    [self writeNumber:openingBalances.cash tagName:@"cash"];
    [self writeNumber:openingBalances.accountsReceivable tagName:@"accountsReceivable"];
    [self writeNumber:openingBalances.inventory tagName:@"inventory"];
    [self writeNumber:openingBalances.prepaidExpenses tagName:@"prepaidExpenses"];
    [self writeNumber:openingBalances.longTermAssets tagName:@"longTermAssets"];
    [self writeNumber:openingBalances.otherAssets tagName:@"otherAssets"];
    [self writeNumber:openingBalances.accountsPayable tagName:@"accountsPayable"];
    [self writeNumber:openingBalances.employeeDeductionsPayable tagName:@"employeeDeductionsPayable"];
    [self writeNumber:openingBalances.salesTaxPayable tagName:@"salesTaxPayable"];
    [self writeNumber:openingBalances.incomeTaxesPayable tagName:@"incomeTaxesPayable"];
    [self writeNumber:openingBalances.shortTermLoan tagName:@"shortTermLoan"];
    [self writeNumber:openingBalances.currentPortionofLTD tagName:@"currentPortionofLTD"];
    [self writeNumber:openingBalances.longTermLoan tagName:@"longTermLoan"];
    [self writeNumber:openingBalances.prepaidPurchases tagName:@"prepaidPurchases"];
    [self writeNumber:openingBalances.otherLiabilities tagName:@"otherLiabilities"];
    [self writeNumber:openingBalances.loansFromShareholders tagName:@"loansFromShareholders"];
    [self writeNumber:openingBalances.capitalStock tagName:@"capitalStock"];
    [self writeNumber:openingBalances.retainedEarnings tagName:@"retainedEarnings"];
    
    [self writeEndElement];
}

- (void)writeTheme:(Theme*)theme
{
    [self writeStartElement:@"theme"];
    
    [self writeString:theme.title tagName:@"title"];
    [self writeDate:theme.startDate tagName:@"startDate"];
    [self writeDate:theme.endDate tagName:@"endDate"];

    [self writeNumber:theme.mandatory tagName:@"mandatory"];
    [self writeNumber:theme.order tagName:@"order"];
    [self writeNumber:theme.enhanceCustomerValue tagName:@"enhanceCustomerValue"];
    [self writeNumber:theme.enhanceUniqueness tagName:@"enhanceUniqueness"];

    [self writeNumber:theme.researchAndDevelopmentOneTime tagName:@"researchAndDevelopmentOneTime"];
    [self writeNumber:theme.researchAndDevelopmentMonthly tagName:@"researchAndDevelopmentMonthly"];
    [self writeNumber:theme.researchAndDevelopmentQuarterly tagName:@"researchAndDevelopmentQuarterly"];
    [self writeNumber:theme.researchAndDevelopmentAnnually tagName:@"researchAndDevelopmentAnnually"];
    [self writeNumber:theme.revenueMonthly tagName:@"revenueMonthly"];
    [self writeNumber:theme.revenueOneTime tagName:@"revenueOneTime"];
    [self writeNumber:theme.revenueQuarterly tagName:@"revenueQuarterly"];
    [self writeNumber:theme.revenueAnnually tagName:@"revenueAnnually"];
    [self writeNumber:theme.cogsOneTime tagName:@"cogsOneTime"];
    [self writeNumber:theme.cogsMonthly tagName:@"cogsMonthly"];
    [self writeNumber:theme.cogsQuarterly tagName:@"cogsQuarterly"];
    [self writeNumber:theme.cogsAnnually tagName:@"cogsAnnually"];
    [self writeNumber:theme.generalAndAdminOneTime tagName:@"generalAndAdminOneTime"];
    [self writeNumber:theme.generalAndAdminMonthly tagName:@"generalAndAdminMonthly"];
    [self writeNumber:theme.generalAndAdminQuarterly tagName:@"generalAndAdminQuarterly"];
    [self writeNumber:theme.generalAndAdminAnnually tagName:@"generalAndAdminAnnually"];
    [self writeNumber:theme.salesAndMarketingOneTime tagName:@"salesAndMarketingOneTime"];
    [self writeNumber:theme.salesAndMarketingMonthly tagName:@"salesAndMarketingMonthly"];
    [self writeNumber:theme.salesAndMarketingQuarterly tagName:@"salesAndMarketingQuarterly"];
    [self writeNumber:theme.salesAndMarketingAnnually tagName:@"salesAndMarketingAnnually"];

    [self writeNumber:theme.researchAndDevelopmentMonthlyAdjustment tagName:@"researchAndDevelopmentMonthlyAdjustment"];
    [self writeNumber:theme.researchAndDevelopmentQuarterlyAdjustment tagName:@"researchAndDevelopmentQuarterlyAdjustment"];
    [self writeNumber:theme.researchAndDevelopmentAnnuallyAdjustment tagName:@"researchAndDevelopmentAnnuallyAdjustment"];
    [self writeNumber:theme.revenueMonthlyAdjustment tagName:@"revenueMonthlyAdjustment"];
    [self writeNumber:theme.revenueQuarterlyAdjustment tagName:@"revenueQuarterlyAdjustment"];
    [self writeNumber:theme.revenueAnnuallyAdjustment tagName:@"revenueAnnuallyAdjustment"];
    [self writeNumber:theme.cogsMonthlyAdjustment tagName:@"cogsMonthlyAdjustment"];
    [self writeNumber:theme.cogsQuarterlyAdjustment tagName:@"cogsQuarterlyAdjustment"];
    [self writeNumber:theme.cogsAnnuallyAdjustment tagName:@"cogsAnnuallyAdjustment"];
    [self writeNumber:theme.generalAndAdminMonthlyAdjustment tagName:@"generalAndAdminMonthlyAdjustment"];
    [self writeNumber:theme.generalAndAdminQuarterlyAdjustment tagName:@"generalAndAdminQuarterlyAdjustment"];
    [self writeNumber:theme.generalAndAdminAnnuallyAdjustment tagName:@"generalAndAdminAnnuallyAdjustment"];
    [self writeNumber:theme.salesAndMarketingMonthlyAdjustment tagName:@"salesAndMarketingMonthlyAdjustment"];
    [self writeNumber:theme.salesAndMarketingQuarterlyAdjustment tagName:@"salesAndMarketingQuarterlyAdjustment"];
    [self writeNumber:theme.salesAndMarketingAnnuallyAdjustment tagName:@"salesAndMarketingAnnuallyAdjustment"];
    
    [self writeNumber:theme.numberOfEmployeesAtThemeStart tagName:@"numberOfEmployeesAtThemeStart"];
    [self writeNumber:theme.numberOfEmployeesAtThemeEnd tagName:@"numberOfEmployeesAtThemeEnd"];
  
    [self writeNumber:theme.percentCogsIsPayroll tagName:@"percentCogsIsPayroll"];
    [self writeNumber:theme.percentResearchAndDevelopmentIsPayroll tagName:@"percentResearchAndDevelopmentIsPayroll"];
    [self writeNumber:theme.percentGeneralAndAdminIsPayroll tagName:@"percentGeneralAndAdminIsPayroll"];
    [self writeNumber:theme.percentSalesAndMarketingIsPayroll tagName:@"percentSalesAndMarketingIsPayroll"];

    [self writeString:theme.responsible.summary tagName:@"responsible"];
    
    [self writeStartElement:@"objectives"];
    for (Objective *objective in theme.objectives) {
        [self writeObjective:objective];
    }
    [self writeEndElement];

    [self writeEndElement];
}

-(void)writeObjective:(Objective*)objective
{
    [self writeStartElement:@"objective"];

    [self writeNumber:objective.order tagName:@"order"];
    [self writeString:objective.summary tagName:@"summary"];
    [self writeNumber:objective.objectiveType.category tagName:@"objectiveType"];
    [self writeNumber:objective.reviewFrequency.category tagName:@"reviewFrequency"];
    
    [self writeStartElement:@"metrics"];
    for (Metric *metric in objective.metrics) {
        [self writeMetric:metric];
    }    
    [self writeEndElement];
    
    [self writeStartElement:@"activities"];
    for (Activity *activity in objective.activities) {
        [self writeActivity:activity];
    }
    [self writeEndElement];
        
    [self writeEndElement];
}

- (void)writeMetric:(Metric*)metric
{
    [self writeStartElement:@"metric"];
    
    [self writeString:metric.summary tagName:@"summary"];
    [self writeDate:metric.targetDate tagName:@"targetDate"];
    [self writeString:metric.targetValue tagName:@"targetValue"];
    [self writeNumber:metric.successIndicator tagName:@"successIndicator"];
    
    [self writeStartElement:@"measurements"];
    NSArray *measurements = [metric.measurements sortedArrayUsingDescriptors:
                             [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]]
                             ];
    for (Measurement *measurement in measurements) {
        [self writeMeasurement:measurement];
    }
    [self writeEndElement];
    
    [self writeStartElement:@"charts"];
    for (Chart *chart in metric.charts) {
        [self writeChart:chart];
    }
    [self writeEndElement];

    [self writeEndElement];
}

- (void)writeActivity:(Activity*)activity 
{
    [self writeStartElement:@"activity"];
    
    [self writeString:activity.action tagName:@"action"];
    [self writeDate:activity.startDate tagName:@"startDate"];
    [self writeDate:activity.endDate tagName:@"endDate"];
    [self writeNumber:activity.upfrontCost tagName:@"upfrontCost"];
    [self writeNumber:activity.ongoingCost tagName:@"ongoingCost"];
    [self writeNumber:activity.order tagName:@"order"];
    [self writeNumber:activity.ongoingFrequency.category tagName:@"ongoingFrequency"];
    [self writeString:activity.responsible.summary tagName:@"responsible"];
    
    [self writeEndElement];
}

- (void)writeMeasurement:(Measurement*)measurement
{
    [self writeStartElement:@"measurement"];
    
    [self writeDate:measurement.date tagName:@"date"];
    [self writeNumber:measurement.value tagName:@"value"];
    [self writeString:measurement.comment tagName:@"comment"];
    
    [self writeEndElement];
}

-(void)writeChart:(Chart*)chart
{
    [self writeStartElement:@"chart"];
    
    [self writeString:chart.title tagName:@"title"];
    [self writeNumber:chart.zLayer tagName:@"zLayer"];
    [self writeNumber:chart.chartType tagName:@"chartType"];
    [self writeNumber:chart.showTrend tagName:@"showTrend"];
    [self writeNumber:chart.colorScheme tagName:@"colorScheme"];
    [self writeNumber:chart.showTarget tagName:@"showTarget"];
    [self writeNumber:chart.order tagName:@"order"];
    [self writeString:chart.uuid tagName:@"uuid"];
    [self writeString:chart.overlay tagName:@"overlay"];
    [self writeNumber:chart.yAxisMax tagName:@"yAxisMax"];
    
    [self writeEndElement];
}


- (void)writeDate:(NSDate*)date tagName:(NSString*)tagName
{
    [self writeString:[date stringForISO8601Date] tagName:tagName];
}

- (void)writeDateTime:(NSDate*)date tagName:(NSString*)tagName
{
    [self writeString:[date stringForISO8601DateTime] tagName:tagName];
}

- (void)writeNumber:(NSNumber*)number tagName:(NSString*)tagName
{
    [self writeString:[number stringValue] tagName:tagName];
}

- (void)writeString:(NSString*)s tagName:(NSString*)tagName
{
    [self writeStartElement:tagName];
    if (s != nil && ![s isBlank]) {
        [self writeCharacters:s];
    }
    [self writeEndElement];    
}

-(void)dealloc
{
    [stratFile_ release];
    [super dealloc];
}

@end