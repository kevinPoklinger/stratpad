//
//  IncomeTax.h
//  StratPad
//
//  Created by Julian Wood on 2013-04-25.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Financials;

@interface IncomeTax : NSManagedObject

// ints for salaries and tax rates
@property (nonatomic, retain) NSNumber * rate1;
@property (nonatomic, retain) NSNumber * salaryLimit1;
@property (nonatomic, retain) NSNumber * rate2;
@property (nonatomic, retain) NSNumber * salaryLimit2;
@property (nonatomic, retain) NSNumber * rate3;

// int; 0-20
@property (nonatomic, retain) NSNumber * yearsCarryLossesForward;

// int; a financial frequency
@property (nonatomic, retain) NSNumber * remittanceFrequency;

// int; 0-11
@property (nonatomic, retain) NSNumber * remittanceMonth;

// inverse
@property (nonatomic, retain) Financials *financials;

@end
