//
//  SalesTax.h
//  StratPad
//
//  Created by Julian Wood on 2013-04-25.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Financials;

@interface SalesTax : NSManagedObject

// int, 0-100
@property (nonatomic, retain) NSNumber * percentRevenuesIsTaxable;

// NSDecimal, 0-100
@property (nonatomic, retain) NSNumber * rate;

// int, a financial frequency
@property (nonatomic, retain) NSNumber * remittanceFrequency;

// int, 0-11
@property (nonatomic, retain) NSNumber * remittanceMonth;

// inverse
@property (nonatomic, retain) Financials *financials;


@end
