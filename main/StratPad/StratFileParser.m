//
//  StratFileParser.m
//  StratPad
//
//  Created by Julian Wood on 9/9/11.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "StratFileParser.h"
#import "NSDate-StratPad.h"
#import "NSString-Expanded.h"
#import "DataManager.h"
#import "Responsible.h"
#import "Theme.h"
#import "Objective.h"
#import "Activity.h"
#import "Frequency.h"
#import "Metric.h"
#import "EditionManager.h"
#import "Measurement.h"
#import "Chart.h"
#import "UAKeychainUtils+StratPad.h"
#import "RegistrationManager.h"
#import "Financials.h"
#import "Loan.h"
#import "Asset.h"
#import "Equity.h"
#import "EmployeeDeductions.h"
#import "SalesTax.h"
#import "IncomeTax.h"
#import "OpeningBalances.h"
#import "NSString-Expanded.h"

@implementation StratFileParser

@synthesize failWithMismatchedEmails = failWithMismatchedEmails_;

- (id)initWithStratFile:(StratFile*)stratFile xmlData:(NSData*)xmlData
{
    self = [super init];
    if (self) {
        stratFile_ = [stratFile retain];
        xmlData_ = [xmlData retain];
        failWithMismatchedEmails_ = NO;
    }
    return self;
}

- (void)parse
{
    TBXML *tbxml = [TBXML tbxmlWithXMLData:xmlData_];
    
    TBXMLElement *stratFileRoot = [tbxml rootXMLElement];
    NSString *rootName = [TBXML elementName:stratFileRoot];
    if (![rootName isEqualToString:@"stratfile"]) {
        ELog(@"XML is not well-formed!");
        @throw [NSException exceptionWithName:@"IncompatibleStratFileException" 
                                       reason:LocalizedString(@"INCOMPATIBLE_STRATFILE_EXC", nil) 
                                     userInfo:[NSDictionary dictionaryWithObject:stratFile_ forKey:@"stratfile"]];
    }
        
    stratFile_.dateCreated = [StratFileParser dateTimeFromElementName:@"dateCreated" parentElement:stratFileRoot];
    stratFile_.dateLastAccessed = [StratFileParser dateTimeFromElementName:@"dateLastAccessed" parentElement:stratFileRoot];
    stratFile_.dateModified = [StratFileParser dateTimeFromElementName:@"dateModified" parentElement:stratFileRoot];
        
    // version 1.0 xml will be missing model and permissions
    // update it's model to the current one
    NSString *model = [StratFileParser stringFromElementName:@"model" parentElement:stratFileRoot];
    if (!model) {
        // version 1.1 upgrades here
        stratFile_.model = [[EditionManager sharedManager] modelVersion];
        stratFile_.permissions = @"0600";
    } 
    else if ([model hasPrefix:@"StratPad 1.0"]) {
        // none of these actually exist
        
    } 
    else {
        stratFile_.permissions = [StratFileParser stringFromElementName:@"permissions" parentElement:stratFileRoot]; 
        stratFile_.model = model;
    }
    
    // simple security check, if this is a backup file
    if (failWithMismatchedEmails_) {
        NSString *email = [StratFileParser stringFromElementName:@"email" parentElement:stratFileRoot];
        NSString *storedEmail = [[NSUserDefaults standardUserDefaults] stringForKey:keyEmail];
        BOOL isVerified = [[UAKeychainUtils valueForKey:keyChainVerified] boolValue];
        if (!email || !isVerified || ![email isEqualToString:storedEmail]) {
            ELog(@"Invalid email when restoring backup. StratFile email: %@. Stored email: %@", email, storedEmail);
            @throw [NSException exceptionWithName:@"IllegalStratFileException"
                                           reason:LocalizedString(@"ILLEGAL_STRATFILE_EXC", nil)
                                         userInfo:[NSDictionary dictionaryWithObject:stratFile_ forKey:@"stratfile"]];
        }
    }
    
    // uuid, @since 1.6
    NSString *uuid = [StratFileParser stringFromElementName:@"uuid" parentElement:stratFileRoot];
    if (!uuid) {
        uuid = [NSString stringWithUUID];
    }
    stratFile_.uuid = uuid;
        
    stratFile_.name = [StratFileParser stringFromElementName:@"name" parentElement:stratFileRoot];
    stratFile_.companyName = [StratFileParser stringFromElementName:@"companyName" parentElement:stratFileRoot];
    stratFile_.city = [StratFileParser stringFromElementName:@"city" parentElement:stratFileRoot];
    stratFile_.provinceState = [StratFileParser stringFromElementName:@"provinceState" parentElement:stratFileRoot];
    stratFile_.country = [StratFileParser stringFromElementName:@"country" parentElement:stratFileRoot];
    stratFile_.industry = [StratFileParser stringFromElementName:@"industry" parentElement:stratFileRoot];

    stratFile_.keyProblems = [StratFileParser stringFromElementName:@"keyProblems" parentElement:stratFileRoot];
    stratFile_.addressProblems = [StratFileParser stringFromElementName:@"addressProblems" parentElement:stratFileRoot];
    stratFile_.customersDescription = [StratFileParser stringFromElementName:@"customersDescription" parentElement:stratFileRoot];
    stratFile_.competitorsDescription = [StratFileParser stringFromElementName:@"competitorsDescription" parentElement:stratFileRoot];
    stratFile_.businessModelDescription = [StratFileParser stringFromElementName:@"businessModelDescription" parentElement:stratFileRoot];
    stratFile_.expansionOptionsDescription = [StratFileParser stringFromElementName:@"expansionOptionsDescription" parentElement:stratFileRoot];
    stratFile_.ultimateAspiration = [StratFileParser stringFromElementName:@"ultimateAspiration" parentElement:stratFileRoot];
    stratFile_.mediumTermStrategicGoal = [StratFileParser stringFromElementName:@"mediumTermStrategicGoal" parentElement:stratFileRoot];
    
    // financials, as of 1.6
    Financials *financials = stratFile_.financials;
    
    TBXMLElement *financialsEle = [TBXML childElementNamed:@"financials" parentElement:stratFileRoot];
    if (financialsEle) {
        financials.accountsReceivableTerm = [StratFileParser intNumberFromElementName:@"accountsReceivableTerm" parentElement:financialsEle];
        financials.accountsPayableTerm = [StratFileParser intNumberFromElementName:@"accountsPayableTerm" parentElement:financialsEle];
        financials.percentCogsIsInventory = [StratFileParser intNumberFromElementName:@"percentCogsIsInventory" parentElement:financialsEle];
        financials.inventoryLeadTime = [StratFileParser intNumberFromElementName:@"inventoryLeadTime" parentElement:financialsEle];
        
        // loans
        TBXMLElement *loansEle = [TBXML childElementNamed:@"loans" parentElement:financialsEle];
        TBXMLElement *loanEle;
        NSMutableOrderedSet *loans = [NSMutableOrderedSet orderedSet];
        if ((loanEle = loansEle->firstChild)) {
            [loans addObject:[self createLoanFromElement:loanEle]];
            
            while ((loanEle = loanEle->nextSibling)) {
                [loans addObject:[self createLoanFromElement:loanEle]];
            }
        }
        financials.loans = loans;
        
        // assets
        TBXMLElement *assetsEle = [TBXML childElementNamed:@"assets" parentElement:financialsEle];
        TBXMLElement *assetEle;
        NSMutableOrderedSet *assets = [NSMutableOrderedSet orderedSet];
        if ((assetEle = assetsEle->firstChild)) {
            [assets addObject:[self createAssetFromElement:assetEle]];
            
            while ((assetEle = assetEle->nextSibling)) {
                [assets addObject:[self createAssetFromElement:assetEle]];
            }
        }
        financials.assets = assets;
        
        // equities
        TBXMLElement *equitiesEle = [TBXML childElementNamed:@"equities" parentElement:financialsEle];
        TBXMLElement *equityEle;
        NSMutableOrderedSet *equities = [NSMutableOrderedSet orderedSet];
        if ((equityEle = equitiesEle->firstChild)) {
            [equities addObject:[self createEquityFromElement:equityEle]];
            
            while ((equityEle = equityEle->nextSibling)) {
                [equities addObject:[self createEquityFromElement:loanEle]];
            }
        }
        financials.equities = equities;

        // employee deductions
        TBXMLElement *deductionsEle = [TBXML childElementNamed:@"employeeDeductions" parentElement:financialsEle];
        financials.employeeDeductions = [self createDeductionsFromElement:deductionsEle];

        // sales tax
        TBXMLElement *salesTaxEle = [TBXML childElementNamed:@"salesTax" parentElement:financialsEle];
        financials.salesTax = [self createSalesTax:salesTaxEle];
        
        // income tax
        TBXMLElement *incomeTaxEle = [TBXML childElementNamed:@"incomeTax" parentElement:financialsEle];
        financials.incomeTax = [self createIncomeTax:incomeTaxEle];
        
        // opening balances
        TBXMLElement *balancesEle = [TBXML childElementNamed:@"openingBalances" parentElement:financialsEle];
        financials.openingBalances = [self createOpeningBalances:balancesEle];
        
    }
    
    // themes
    TBXMLElement *themesEle = [TBXML childElementNamed:@"themes" parentElement:stratFileRoot];
    TBXMLElement *themeEle;
    if ((themeEle = themesEle->firstChild)) {
        NSMutableSet *themes = [NSMutableSet set];
        [themes addObject:[self createThemeFromElement:themeEle]];
        
        while ((themeEle = themeEle->nextSibling)) {
            [themes addObject:[self createThemeFromElement:themeEle]];
        }
        stratFile_.themes = themes;
    }

}

-(Loan*)createLoanFromElement:(TBXMLElement*)loanEle
{
    Loan *loan = (Loan*)[DataManager createManagedInstance:NSStringFromClass([Loan class])];
    loan.name = [StratFileParser stringFromElementName:@"name" parentElement:loanEle];
    loan.date = [StratFileParser intNumberFromElementName:@"date" parentElement:loanEle];
    loan.amount = [StratFileParser intNumberFromElementName:@"amount" parentElement:loanEle];
    loan.term = [StratFileParser intNumberFromElementName:@"term" parentElement:loanEle];
    loan.rate = [StratFileParser decimalNumberFromElementName:@"rate" parentElement:loanEle];
    loan.type = [StratFileParser intNumberFromElementName:@"type" parentElement:loanEle];
    loan.frequency = [StratFileParser intNumberFromElementName:@"frequency" parentElement:loanEle];
    return loan;
}


-(Asset*)createAssetFromElement:(TBXMLElement*)assetEle
{
    Asset *asset = (Asset*)[DataManager createManagedInstance:NSStringFromClass([Asset class])];
    asset.name = [StratFileParser stringFromElementName:@"name" parentElement:assetEle];
    asset.date = [StratFileParser intNumberFromElementName:@"date" parentElement:assetEle];
    asset.value = [StratFileParser intNumberFromElementName:@"value" parentElement:assetEle];
    asset.depreciationTerm = [StratFileParser intNumberFromElementName:@"depreciationTerm" parentElement:assetEle];
    asset.salvageValue = [StratFileParser intNumberFromElementName:@"salvageValue" parentElement:assetEle];
    asset.depreciationType = [StratFileParser intNumberFromElementName:@"depreciationType" parentElement:assetEle];
    asset.type = [StratFileParser intNumberFromElementName:@"type" parentElement:assetEle];
    return asset;
}

-(Equity*)createEquityFromElement:(TBXMLElement*)equityEle
{
    Equity *equity = (Equity*)[DataManager createManagedInstance:NSStringFromClass([Equity class])];
    equity.name = [StratFileParser stringFromElementName:@"name" parentElement:equityEle];
    equity.date = [StratFileParser intNumberFromElementName:@"date" parentElement:equityEle];
    equity.value = [StratFileParser intNumberFromElementName:@"value" parentElement:equityEle];
    return equity;
}

-(EmployeeDeductions*)createDeductionsFromElement:(TBXMLElement*)deductionsEle
{
    EmployeeDeductions *deductions = (EmployeeDeductions*)[DataManager createManagedInstance:NSStringFromClass([EmployeeDeductions class])];
    deductions.percentCogsAreWages = [StratFileParser intNumberFromElementName:@"percentCogsAreWages" parentElement:deductionsEle];
    deductions.percentGandAAreWages = [StratFileParser intNumberFromElementName:@"percentGandAAreWages" parentElement:deductionsEle];
    deductions.percentRandDAreWages = [StratFileParser intNumberFromElementName:@"percentRandDAreWages" parentElement:deductionsEle];
    deductions.percentSandMAreWages = [StratFileParser intNumberFromElementName:@"percentSandMAreWages" parentElement:deductionsEle];
    deductions.employeeContributionPercentage = [StratFileParser intNumberFromElementName:@"employeeContributionPercentage" parentElement:deductionsEle];
    deductions.employerContributionPercentage = [StratFileParser intNumberFromElementName:@"employerContributionPercentage" parentElement:deductionsEle];
    deductions.dueDate = [StratFileParser intNumberFromElementName:@"dueDate" parentElement:deductionsEle];
    return deductions;
}

-(SalesTax*)createSalesTax:(TBXMLElement*)salesTaxEle
{
    SalesTax *salesTax = (SalesTax*)[DataManager createManagedInstance:NSStringFromClass([SalesTax class])];
    salesTax.percentRevenuesIsTaxable = [StratFileParser intNumberFromElementName:@"percentRevenuesIsTaxable" parentElement:salesTaxEle];
    salesTax.rate = [StratFileParser decimalNumberFromElementName:@"rate" parentElement:salesTaxEle];
    salesTax.remittanceFrequency = [StratFileParser intNumberFromElementName:@"remittanceFrequency" parentElement:salesTaxEle];
    salesTax.remittanceMonth = [StratFileParser intNumberFromElementName:@"remittanceMonth" parentElement:salesTaxEle];
    return salesTax;
}

-(IncomeTax*)createIncomeTax:(TBXMLElement*)incomeTaxEle
{
    IncomeTax *incomeTax = (IncomeTax*)[DataManager createManagedInstance:NSStringFromClass([IncomeTax class])];
    incomeTax.rate1 = [StratFileParser intNumberFromElementName:@"rate1" parentElement:incomeTaxEle];
    incomeTax.rate2 = [StratFileParser intNumberFromElementName:@"rate2" parentElement:incomeTaxEle];
    incomeTax.rate3 = [StratFileParser intNumberFromElementName:@"rate3" parentElement:incomeTaxEle];
    incomeTax.salaryLimit1 = [StratFileParser intNumberFromElementName:@"salaryLimit1" parentElement:incomeTaxEle];
    incomeTax.salaryLimit2 = [StratFileParser intNumberFromElementName:@"salaryLimit2" parentElement:incomeTaxEle];
    incomeTax.yearsCarryLossesForward = [StratFileParser intNumberFromElementName:@"yearsCarryLossesForward" parentElement:incomeTaxEle];
    incomeTax.remittanceFrequency = [StratFileParser intNumberFromElementName:@"remittanceFrequency" parentElement:incomeTaxEle];
    incomeTax.remittanceMonth = [StratFileParser intNumberFromElementName:@"remittanceMonth" parentElement:incomeTaxEle];
    return incomeTax;
}

-(OpeningBalances*)createOpeningBalances:(TBXMLElement*)openingBalancesEle
{
    OpeningBalances *balances = (OpeningBalances*)[DataManager createManagedInstance:NSStringFromClass([OpeningBalances class])];
    balances.cash = [StratFileParser intNumberFromElementName:@"cash" parentElement:openingBalancesEle];
    balances.accountsReceivable = [StratFileParser intNumberFromElementName:@"accountsReceivable" parentElement:openingBalancesEle];
    balances.inventory = [StratFileParser intNumberFromElementName:@"inventory" parentElement:openingBalancesEle];
    balances.prepaidExpenses = [StratFileParser intNumberFromElementName:@"prepaidExpenses" parentElement:openingBalancesEle];
    balances.longTermAssets = [StratFileParser intNumberFromElementName:@"longTermAssets" parentElement:openingBalancesEle];
    balances.otherAssets = [StratFileParser intNumberFromElementName:@"otherAssets" parentElement:openingBalancesEle];
    balances.accountsPayable = [StratFileParser intNumberFromElementName:@"accountsPayable" parentElement:openingBalancesEle];
    balances.employeeDeductionsPayable = [StratFileParser intNumberFromElementName:@"employeeDeductionsPayable" parentElement:openingBalancesEle];
    balances.salesTaxPayable = [StratFileParser intNumberFromElementName:@"salesTaxPayable" parentElement:openingBalancesEle];
    balances.incomeTaxesPayable = [StratFileParser intNumberFromElementName:@"incomeTaxesPayable" parentElement:openingBalancesEle];
    balances.shortTermLoan = [StratFileParser intNumberFromElementName:@"shortTermLoan" parentElement:openingBalancesEle];
    balances.currentPortionofLTD = [StratFileParser intNumberFromElementName:@"currentPortionofLTD" parentElement:openingBalancesEle];
    balances.longTermLoan = [StratFileParser intNumberFromElementName:@"longTermLoan" parentElement:openingBalancesEle];
    balances.prepaidPurchases = [StratFileParser intNumberFromElementName:@"prepaidPurchases" parentElement:openingBalancesEle];
    balances.otherLiabilities = [StratFileParser intNumberFromElementName:@"otherLiabilities" parentElement:openingBalancesEle];
    balances.loansFromShareholders = [StratFileParser intNumberFromElementName:@"loansFromShareholders" parentElement:openingBalancesEle];
    balances.capitalStock = [StratFileParser intNumberFromElementName:@"capitalStock" parentElement:openingBalancesEle];
    balances.retainedEarnings = [StratFileParser intNumberFromElementName:@"retainedEarnings" parentElement:openingBalancesEle];
    return balances;
}

-(Theme*)createThemeFromElement:(TBXMLElement*)themeEle
{
    Theme *theme = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])];
    theme.title = [StratFileParser stringFromElementName:@"title" parentElement:themeEle];
    theme.startDate = [StratFileParser dateFromElementName:@"startDate" parentElement:themeEle];
    theme.endDate = [StratFileParser dateFromElementName:@"endDate" parentElement:themeEle];
    
    theme.mandatory = [StratFileParser intNumberFromElementName:@"mandatory" parentElement:themeEle];
    theme.enhanceCustomerValue = [StratFileParser intNumberFromElementName:@"enhanceCustomerValue" parentElement:themeEle];
    theme.enhanceUniqueness = [StratFileParser intNumberFromElementName:@"enhanceUniqueness" parentElement:themeEle];
    theme.order = [StratFileParser intNumberFromElementName:@"order" parentElement:themeEle];
    theme.responsible = [self findOrCreateResponsible:[StratFileParser stringFromElementName:@"responsible" parentElement:themeEle]];

    // if we have <1.6 expenses... and costs..., import those
    // if we have >-1.6 r&d, g&a, s&m then import those
    // there is no way to get both in a single file (unsupported if it happens)

    NSString *actualVersion = stratFile_.model;
    NSString *requiredVersion = @"StratPad 1.6";
    
    if ([requiredVersion compare:actualVersion options:NSNumericSearch] == NSOrderedDescending) {
        // actualVersion is lower than the requiredVersion
        theme.researchAndDevelopmentOneTime = [StratFileParser intNumberFromElementName:@"expensesOneTime" parentElement:themeEle];
        theme.researchAndDevelopmentMonthly = [StratFileParser intNumberFromElementName:@"expensesMonthly" parentElement:themeEle];
        theme.researchAndDevelopmentQuarterly = [StratFileParser intNumberFromElementName:@"expensesQuarterly" parentElement:themeEle];
        theme.researchAndDevelopmentAnnually = [StratFileParser intNumberFromElementName:@"expensesAnnually" parentElement:themeEle];

        theme.generalAndAdminOneTime = [StratFileParser intNumberFromElementName:@"costsOneTime" parentElement:themeEle];
        theme.generalAndAdminMonthly = [StratFileParser intNumberFromElementName:@"costsMonthly" parentElement:themeEle];
        theme.generalAndAdminQuarterly = [StratFileParser intNumberFromElementName:@"costsQuarterly" parentElement:themeEle];
        theme.generalAndAdminAnnually = [StratFileParser intNumberFromElementName:@"costsAnnually" parentElement:themeEle];
        
        theme.researchAndDevelopmentMonthlyAdjustment = [StratFileParser decimalNumberFromElementName:@"expensesMonthlyAdjustment" parentElement:themeEle];
        theme.researchAndDevelopmentQuarterlyAdjustment = [StratFileParser decimalNumberFromElementName:@"expensesQuarterlyAdjustment" parentElement:themeEle];
        theme.researchAndDevelopmentAnnuallyAdjustment = [StratFileParser decimalNumberFromElementName:@"expensesAnnuallyAdjustment" parentElement:themeEle];
        
        theme.generalAndAdminMonthlyAdjustment = [StratFileParser decimalNumberFromElementName:@"costsMonthlyAdjustment" parentElement:themeEle];
        theme.generalAndAdminQuarterlyAdjustment = [StratFileParser decimalNumberFromElementName:@"costsQuarterlyAdjustment" parentElement:themeEle];
        theme.generalAndAdminAnnuallyAdjustment = [StratFileParser decimalNumberFromElementName:@"costsAnnuallyAdjustment" parentElement:themeEle];        

    } else {
        theme.researchAndDevelopmentOneTime = [StratFileParser intNumberFromElementName:@"researchAndDevelopmentOneTime" parentElement:themeEle];
        theme.researchAndDevelopmentMonthly = [StratFileParser intNumberFromElementName:@"researchAndDevelopmentMonthly" parentElement:themeEle];
        theme.researchAndDevelopmentQuarterly = [StratFileParser intNumberFromElementName:@"researchAndDevelopmentQuarterly" parentElement:themeEle];
        theme.researchAndDevelopmentAnnually = [StratFileParser intNumberFromElementName:@"researchAndDevelopmentAnnually" parentElement:themeEle];

        theme.generalAndAdminOneTime = [StratFileParser intNumberFromElementName:@"generalAndAdminOneTime" parentElement:themeEle];
        theme.generalAndAdminMonthly = [StratFileParser intNumberFromElementName:@"generalAndAdminMonthly" parentElement:themeEle];
        theme.generalAndAdminQuarterly = [StratFileParser intNumberFromElementName:@"generalAndAdminQuarterly" parentElement:themeEle];
        theme.generalAndAdminAnnually = [StratFileParser intNumberFromElementName:@"generalAndAdminAnnually" parentElement:themeEle];
        
        theme.researchAndDevelopmentMonthlyAdjustment = [StratFileParser decimalNumberFromElementName:@"researchAndDevelopmentMonthlyAdjustment" parentElement:themeEle];
        theme.researchAndDevelopmentQuarterlyAdjustment = [StratFileParser decimalNumberFromElementName:@"researchAndDevelopmentQuarterlyAdjustment" parentElement:themeEle];
        theme.researchAndDevelopmentAnnuallyAdjustment = [StratFileParser decimalNumberFromElementName:@"researchAndDevelopmentAnnuallyAdjustment" parentElement:themeEle];

        theme.generalAndAdminMonthlyAdjustment = [StratFileParser decimalNumberFromElementName:@"generalAndAdminMonthlyAdjustment" parentElement:themeEle];
        theme.generalAndAdminQuarterlyAdjustment = [StratFileParser decimalNumberFromElementName:@"generalAndAdminQuarterlyAdjustment" parentElement:themeEle];
        theme.generalAndAdminAnnuallyAdjustment = [StratFileParser decimalNumberFromElementName:@"generalAndAdminAnnuallyAdjustment" parentElement:themeEle];

    }
    

    theme.revenueOneTime = [StratFileParser intNumberFromElementName:@"revenueOneTime" parentElement:themeEle];
    theme.revenueMonthly = [StratFileParser intNumberFromElementName:@"revenueMonthly" parentElement:themeEle];
    theme.revenueQuarterly = [StratFileParser intNumberFromElementName:@"revenueQuarterly" parentElement:themeEle];
    theme.revenueAnnually = [StratFileParser intNumberFromElementName:@"revenueAnnually" parentElement:themeEle];
    theme.cogsOneTime = [StratFileParser intNumberFromElementName:@"cogsOneTime" parentElement:themeEle];
    theme.cogsMonthly = [StratFileParser intNumberFromElementName:@"cogsMonthly" parentElement:themeEle];
    theme.cogsQuarterly = [StratFileParser intNumberFromElementName:@"cogsQuarterly" parentElement:themeEle];
    theme.cogsAnnually = [StratFileParser intNumberFromElementName:@"cogsAnnually" parentElement:themeEle];
    theme.salesAndMarketingOneTime = [StratFileParser intNumberFromElementName:@"salesAndMarketingOneTime" parentElement:themeEle];
    theme.salesAndMarketingMonthly = [StratFileParser intNumberFromElementName:@"salesAndMarketingMonthly" parentElement:themeEle];
    theme.salesAndMarketingQuarterly = [StratFileParser intNumberFromElementName:@"salesAndMarketingQuarterly" parentElement:themeEle];
    theme.salesAndMarketingAnnually = [StratFileParser intNumberFromElementName:@"salesAndMarketingAnnually" parentElement:themeEle];
    
    theme.revenueMonthlyAdjustment = [StratFileParser decimalNumberFromElementName:@"revenueMonthlyAdjustment" parentElement:themeEle];
    theme.revenueQuarterlyAdjustment = [StratFileParser decimalNumberFromElementName:@"revenueQuarterlyAdjustment" parentElement:themeEle];
    theme.revenueAnnuallyAdjustment = [StratFileParser decimalNumberFromElementName:@"revenueAnnuallyAdjustment" parentElement:themeEle];
    theme.cogsMonthlyAdjustment = [StratFileParser decimalNumberFromElementName:@"cogsMonthlyAdjustment" parentElement:themeEle];
    theme.cogsQuarterlyAdjustment = [StratFileParser decimalNumberFromElementName:@"cogsQuarterlyAdjustment" parentElement:themeEle];
    theme.cogsAnnuallyAdjustment = [StratFileParser decimalNumberFromElementName:@"cogsAnnuallyAdjustment" parentElement:themeEle];
    theme.salesAndMarketingMonthlyAdjustment = [StratFileParser decimalNumberFromElementName:@"salesAndMarketingMonthlyAdjustment" parentElement:themeEle];
    theme.salesAndMarketingQuarterlyAdjustment = [StratFileParser decimalNumberFromElementName:@"salesAndMarketingQuarterlyAdjustment" parentElement:themeEle];
    theme.salesAndMarketingAnnuallyAdjustment = [StratFileParser decimalNumberFromElementName:@"salesAndMarketingAnnuallyAdjustment" parentElement:themeEle];
    
    
    theme.numberOfEmployeesAtThemeStart = [StratFileParser intNumberFromElementName:@"numberOfEmployeesAtThemeStart" parentElement:themeEle];
    theme.numberOfEmployeesAtThemeEnd = [StratFileParser intNumberFromElementName:@"numberOfEmployeesAtThemeEnd" parentElement:themeEle];
    
    theme.percentSalesAndMarketingIsPayroll = [StratFileParser intNumberFromElementName:@"percentSalesAndMarketingIsPayroll" parentElement:themeEle];
    theme.percentResearchAndDevelopmentIsPayroll = [StratFileParser intNumberFromElementName:@"percentResearchAndDevelopmentIsPayroll" parentElement:themeEle];
    theme.percentGeneralAndAdminIsPayroll = [StratFileParser intNumberFromElementName:@"percentGeneralAndAdminIsPayroll" parentElement:themeEle];
    theme.percentCogsIsPayroll = [StratFileParser intNumberFromElementName:@"percentCogsIsPayroll" parentElement:themeEle];
    
        
    TBXMLElement *objectivesEle = [TBXML childElementNamed:@"objectives" parentElement:themeEle];
    TBXMLElement *objectiveEle;
    if ((objectiveEle = objectivesEle->firstChild)) {
        NSMutableSet *objectives = [NSMutableSet set];
        [objectives addObject:[self createObjectiveFromElement:objectiveEle]];
        
        while ((objectiveEle = objectiveEle->nextSibling)) {
            [objectives addObject:[self createObjectiveFromElement:objectiveEle]];
        }
        theme.objectives = objectives;
    }
    
    return theme;
}

-(Objective*)createObjectiveFromElement:(TBXMLElement*)objectiveEle
{
    Objective *objective = (Objective*)[DataManager createManagedInstance:NSStringFromClass([Objective class])];
    objective.summary = [StratFileParser stringFromElementName:@"summary" parentElement:objectiveEle];
    objective.order = [StratFileParser intNumberFromElementName:@"order" parentElement:objectiveEle];
    
    // check for nil, since nil will be passed as 0 to objectiveTypeForCategory. i.e., nil != FINANCIAL.
    NSNumber *parsedObjectiveType = [StratFileParser intNumberFromElementName:@"objectiveType" parentElement:objectiveEle];
    objective.objectiveType = parsedObjectiveType == nil ? nil : [ObjectiveType objectiveTypeForCategory:[parsedObjectiveType intValue]];
        
    // check for nil, since nil will be passed as 0 to frequencyForCategory. i.e., nil != FrequencyCategoryDaily.
    NSNumber *parsedReviewFrequency = [StratFileParser intNumberFromElementName:@"reviewFrequency" parentElement:objectiveEle];
    objective.reviewFrequency = parsedReviewFrequency == nil ? nil : [Frequency frequencyForCategory:[parsedReviewFrequency intValue]];

    
    TBXMLElement *metricsEle = [TBXML childElementNamed:@"metrics" parentElement:objectiveEle];
    TBXMLElement *metricEle;
    if ((metricEle = metricsEle->firstChild)) {
        NSMutableSet *metrics = [NSMutableSet set];
        [metrics addObject:[self createMetricFromElement:metricEle]];
        
        while ((metricEle = metricEle->nextSibling)) {
            [metrics addObject:[self createMetricFromElement:metricEle]];
        }
        objective.metrics = metrics;
    }

    TBXMLElement *activitiesEle = [TBXML childElementNamed:@"activities" parentElement:objectiveEle];
    TBXMLElement *activityEle;
    if ((activityEle = activitiesEle->firstChild)) {
        NSMutableSet *activities = [NSMutableSet set];
        [activities addObject:[self createActivityFromElement:activityEle]];
        
        while ((activityEle = activityEle->nextSibling)) {
            [activities addObject:[self createActivityFromElement:activityEle]];
        }
        objective.activities = activities;
    }

    return objective;
}

-(Metric*)createMetricFromElement:(TBXMLElement*)metricEle
{
    Metric *metric = (Metric*)[DataManager createManagedInstance:NSStringFromClass([Metric class])];
    
    metric.summary = [StratFileParser stringFromElementName:@"summary" parentElement:metricEle];
    metric.targetDate = [StratFileParser dateFromElementName:@"targetDate" parentElement:metricEle];
    metric.targetValue = [StratFileParser stringFromElementName:@"targetValue" parentElement:metricEle];
    metric.successIndicator = [StratFileParser intNumberFromElementName:@"successIndicator" parentElement:metricEle];
    
    // this is a new entity introduced in 1.3; it's entirely optional
    TBXMLElement *measurementsEle = [TBXML childElementNamed:@"measurements" parentElement:metricEle];
    TBXMLElement *measurementEle;
    if (measurementsEle && (measurementEle = measurementsEle->firstChild)) {
        NSMutableSet *measurements = [NSMutableSet set];
        [measurements addObject:[self createMeasurementFromElement:measurementEle]];
        
        while ((measurementEle = measurementEle->nextSibling)) {
            [measurements addObject:[self createMeasurementFromElement:measurementEle]];
        }
        metric.measurements = measurements;
    }

    // this is a new entity introduced in 1.3; it's entirely optional
    TBXMLElement *chartsEle = [TBXML childElementNamed:@"charts" parentElement:metricEle];
    TBXMLElement *chartEle;
    if (chartsEle && (chartEle = chartsEle->firstChild)) {
        NSMutableSet *charts = [NSMutableSet set];
        [charts addObject:[self createChartFromElement:chartEle]];
        
        while ((chartEle = chartEle->nextSibling)) {
            [charts addObject:[self createChartFromElement:chartEle]];
        }
        metric.charts = charts;
    }

    return metric;
}

-(Activity*)createActivityFromElement:(TBXMLElement*)activityEle
{
    Activity *activity = (Activity*)[DataManager createManagedInstance:NSStringFromClass([Activity class])];
    
    activity.action = [StratFileParser stringFromElementName:@"action" parentElement:activityEle];
    activity.responsible = [self findOrCreateResponsible:[StratFileParser stringFromElementName:@"responsible" parentElement:activityEle]];
    activity.endDate = [StratFileParser dateFromElementName:@"endDate" parentElement:activityEle];
    activity.startDate = [StratFileParser dateFromElementName:@"startDate" parentElement:activityEle];
    activity.upfrontCost = [StratFileParser intNumberFromElementName:@"upfrontCost" parentElement:activityEle];
    activity.ongoingCost = [StratFileParser intNumberFromElementName:@"ongoingCost" parentElement:activityEle];
    activity.order = [StratFileParser intNumberFromElementName:@"order" parentElement:activityEle];
    
    // check for nil, since nil will be passed as 0 to frequencyForCategory. i.e., nil != FrequencyCategoryDaily.
    NSNumber *parsedOngoingFrequency = [StratFileParser intNumberFromElementName:@"ongoingFrequency" parentElement:activityEle];
    activity.ongoingFrequency = parsedOngoingFrequency == nil ? nil : [Frequency frequencyForCategory:[parsedOngoingFrequency intValue]];
    
    return activity;
}

-(Measurement*)createMeasurementFromElement:(TBXMLElement*)measurementEle
{
    Measurement *measurement = (Measurement*)[DataManager createManagedInstance:NSStringFromClass([Measurement class])];
    measurement.date = [StratFileParser dateFromElementName:@"date" parentElement:measurementEle];
    measurement.value = [StratFileParser floatNumberFromElementName:@"value" parentElement:measurementEle];    
    measurement.comment = [StratFileParser stringFromElementName:@"comment" parentElement:measurementEle];    
    return measurement;
}

-(Chart*)createChartFromElement:(TBXMLElement*)chartEle
{
    Chart *chart = (Chart*)[DataManager createManagedInstance:NSStringFromClass([Chart class])];
    chart.title = [StratFileParser stringFromElementName:@"title" parentElement:chartEle];
    chart.zLayer = [StratFileParser intNumberFromElementName:@"zLayer" parentElement:chartEle];
    chart.chartType = [StratFileParser intNumberFromElementName:@"chartType" parentElement:chartEle];
    chart.showTrend = [StratFileParser intNumberFromElementName:@"showTrend" parentElement:chartEle];
    chart.colorScheme = [StratFileParser intNumberFromElementName:@"colorScheme" parentElement:chartEle];
    chart.showTarget = [StratFileParser intNumberFromElementName:@"showTarget" parentElement:chartEle];
    chart.order = [StratFileParser intNumberFromElementName:@"order" parentElement:chartEle];
    chart.uuid = [StratFileParser stringFromElementName:@"uuid" parentElement:chartEle];
    chart.overlay = [StratFileParser stringFromElementName:@"overlay" parentElement:chartEle];
    chart.yAxisMax = [StratFileParser intNumberFromElementName:@"yAxisMax" parentElement:chartEle];
    
    return chart;
}

-(Responsible*)findOrCreateResponsible:(NSString*)summary
{
    if (summary == nil) {
        return nil;
    }
    Responsible *responsible = [Responsible responsibleWithSummary:summary forStratFile:stratFile_];
    if (responsible == nil) {
        responsible = (Responsible*)[DataManager createManagedInstance:NSStringFromClass([Responsible class])];
        responsible.summary = summary;
        responsible.stratFile = stratFile_;
    }
    return responsible;
}

+(NSString*)stringFromElement:(TBXMLElement*)element
{
    if (!element) return nil;
    NSString *s = [TBXML textForElement:element];
    return [s isBlank] ? nil : [s stringByDecodingXMLEntities];    
}

+(NSString*)stringFromElementName:(NSString*)elementName parentElement:(TBXMLElement*)parentElement
{
    TBXMLElement *ele = [TBXML childElementNamed:elementName parentElement:parentElement];
    return [StratFileParser stringFromElement:ele];
}

+(NSDate*)dateFromElementName:(NSString*)elementName parentElement:(TBXMLElement*)parentElement
{
    NSString *s = [StratFileParser stringFromElementName:elementName parentElement:parentElement];
    return [NSDate dateFromISO8601:s];    
}

+(NSDate*)dateTimeFromElementName:(NSString*)elementName parentElement:(TBXMLElement*)parentElement
{
    NSString *s = [StratFileParser stringFromElementName:elementName parentElement:parentElement];
    return [NSDate dateTimeFromISO8601:s];    
}

+(NSNumber*)intNumberFromElementName:(NSString*)elementName parentElement:(TBXMLElement*)parentElement
{
    NSString *s = [StratFileParser stringFromElementName:elementName parentElement:parentElement];
    return s == nil ? nil : [NSNumber numberWithInt:[s intValue]];    
}

+(NSDecimalNumber*)decimalNumberFromElementName:(NSString*)elementName parentElement:(TBXMLElement*)parentElement
{
    NSString *s = [StratFileParser stringFromElementName:elementName parentElement:parentElement];
    return s == nil ? nil : [NSDecimalNumber decimalNumberWithString:s];    
}

+(NSNumber*)floatNumberFromElementName:(NSString*)elementName parentElement:(TBXMLElement*)parentElement
{
    NSString *s = [StratFileParser stringFromElementName:elementName parentElement:parentElement];
    return s == nil ? nil : [NSNumber numberWithFloat:[s floatValue]];    
}


- (void)dealloc
{
    [stratFile_ release];
    [super dealloc];
}

@end
