//
//  Financials.m
//  StratPad
//
//  Created by Julian Wood on 2013-04-17.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//

#import "Financials.h"
#import "Loan.h"
#import "StratFile.h"
#import "Asset.h"
#import "Equity.h"
#import "EmployeeDeductions.h"
#import "SalesTax.h"
#import "IncomeTax.h"
#import "OpeningBalances.h"
#import "DataManager.h"

@implementation Financials

@dynamic percentCogsIsInventory;
@dynamic accountsPayableTerm;
@dynamic accountsReceivableTerm;
@dynamic inventoryLeadTime;
@dynamic stratFile;
@dynamic loans;
@dynamic assets;
@dynamic equities;
@dynamic employeeDeductions;
@dynamic salesTax;
@dynamic incomeTax;
@dynamic openingBalances;

- (void)awakeFromFetch
{
    if (!self.loans) {
        self.loans = [NSMutableOrderedSet orderedSet];
        self.assets = [NSMutableOrderedSet orderedSet];
        self.equities = [NSMutableOrderedSet orderedSet];
        self.employeeDeductions = (EmployeeDeductions*)[DataManager createManagedInstance:NSStringFromClass([EmployeeDeductions class])];
        self.salesTax = (SalesTax*)[DataManager createManagedInstance:NSStringFromClass([SalesTax class])];
        self.incomeTax = (IncomeTax*)[DataManager createManagedInstance:NSStringFromClass([IncomeTax class])];
        self.openingBalances = (OpeningBalances*)[DataManager createManagedInstance:NSStringFromClass([OpeningBalances class])];
    }
}

-(void)awakeFromInsert
{
    self.loans = [NSMutableOrderedSet orderedSet];
    self.assets = [NSMutableOrderedSet orderedSet];
    self.equities = [NSMutableOrderedSet orderedSet];
    self.employeeDeductions = (EmployeeDeductions*)[DataManager createManagedInstance:NSStringFromClass([EmployeeDeductions class])];
    self.salesTax = (SalesTax*)[DataManager createManagedInstance:NSStringFromClass([SalesTax class])];
    self.incomeTax = (IncomeTax*)[DataManager createManagedInstance:NSStringFromClass([IncomeTax class])];
    self.openingBalances = (OpeningBalances*)[DataManager createManagedInstance:NSStringFromClass([OpeningBalances class])];    
}

@end
