//
//  Financials.h
//  StratPad
//
//  Created by Julian Wood on 2013-04-17.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Frequency.h"

@class Loan, StratFile, Asset, Equity, EmployeeDeductions, SalesTax, IncomeTax, OpeningBalances;

@interface Financials : NSManagedObject

@property (nonatomic, retain) NSNumber * percentCogsIsInventory;
@property (nonatomic, retain) NSNumber * accountsPayableTerm;
@property (nonatomic, retain) NSNumber * accountsReceivableTerm;
@property (nonatomic, retain) NSNumber * inventoryLeadTime;

@property (nonatomic, retain) NSOrderedSet *loans;
@property (nonatomic, retain) NSOrderedSet *assets;
@property (nonatomic, retain) NSOrderedSet *equities;
@property (nonatomic, retain) EmployeeDeductions *employeeDeductions;
@property (nonatomic, retain) SalesTax *salesTax;
@property (nonatomic, retain) IncomeTax *incomeTax;
@property (nonatomic, retain) OpeningBalances *openingBalances;

// inverse
@property (nonatomic, retain) StratFile *stratFile;

@end

@interface Financials (CoreDataGeneratedAccessors)

- (void)insertObject:(Equity *)value inEquitiesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromEquitiesAtIndex:(NSUInteger)idx;
- (void)insertEquities:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeEquitiesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInEquitiesAtIndex:(NSUInteger)idx withObject:(Equity *)value;
- (void)replaceEquitiesAtIndexes:(NSIndexSet *)indexes withEquities:(NSArray *)values;
- (void)addEquitiesObject:(Equity *)value;
- (void)removeEquitiesObject:(Equity *)value;
- (void)addEquities:(NSOrderedSet *)values;
- (void)removeEquities:(NSOrderedSet *)values;

- (void)insertObject:(Asset *)value inAssetsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromAssetsAtIndex:(NSUInteger)idx;
- (void)insertAssets:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeAssetsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInAssetsAtIndex:(NSUInteger)idx withObject:(Asset *)value;
- (void)replaceAssetsAtIndexes:(NSIndexSet *)indexes withAssets:(NSArray *)values;
- (void)addAssetsObject:(Asset *)value;
- (void)removeAssetsObject:(Asset *)value;
- (void)addAssets:(NSOrderedSet *)values;
- (void)removeAssets:(NSOrderedSet *)values;

- (void)insertObject:(Loan *)value inLoansAtIndex:(NSUInteger)idx;
- (void)removeObjectFromLoansAtIndex:(NSUInteger)idx;
- (void)insertLoans:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeLoansAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInLoansAtIndex:(NSUInteger)idx withObject:(Loan *)value;
- (void)replaceLoansAtIndexes:(NSIndexSet *)indexes withLoans:(NSArray *)values;
- (void)addLoansObject:(Loan *)value;
- (void)removeLoansObject:(Loan *)value;
- (void)addLoans:(NSOrderedSet *)values;
- (void)removeLoans:(NSOrderedSet *)values;

@end

