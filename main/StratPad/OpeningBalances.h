//
//  OpeningBalances.h
//  StratPad
//
//  Created by Julian Wood on 2013-04-25.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Financials;

@interface OpeningBalances : NSManagedObject

// all longs
@property (nonatomic, retain) NSNumber * cash;
@property (nonatomic, retain) NSNumber * accountsReceivable;
@property (nonatomic, retain) NSNumber * inventory;
@property (nonatomic, retain) NSNumber * prepaidExpenses;
@property (nonatomic, retain) NSNumber * longTermAssets;
@property (nonatomic, retain) NSNumber * otherAssets;
@property (nonatomic, retain) NSNumber * accountsPayable;
@property (nonatomic, retain) NSNumber * employeeDeductionsPayable;
@property (nonatomic, retain) NSNumber * salesTaxPayable;
@property (nonatomic, retain) NSNumber * incomeTaxesPayable;
@property (nonatomic, retain) NSNumber * shortTermLoan;
@property (nonatomic, retain) NSNumber * currentPortionofLTD;
@property (nonatomic, retain) NSNumber * longTermLoan;
@property (nonatomic, retain) NSNumber * prepaidPurchases;
@property (nonatomic, retain) NSNumber * otherLiabilities;
@property (nonatomic, retain) NSNumber * loansFromShareholders;
@property (nonatomic, retain) NSNumber * capitalStock;
@property (nonatomic, retain) NSNumber * retainedEarnings;

// inverse
@property (nonatomic, retain) Financials *financials;

@end
