//
//  Loan.h
//  StratPad
//
//  Created by Julian Wood on 2013-04-17.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Financials;

typedef enum {
    LoanTypePrincipalPlusInterest   = 0,
    LoanTypeInterestOnly            = 1,
    
    LoanCount
} LoanType;

@interface Loan : NSManagedObject

// the name of the loan
@property (nonatomic, retain) NSString * name;

// the date the money was received; stored as an int (eg 201104); YYYYMM (unambiguous); typically display as MMYY
@property (nonatomic, retain) NSNumber * date;

// the dollar amount of the loan; can display up to 100 million, with commas
@property (nonatomic, retain) NSNumber * amount;

// number of months; can display up to 999
@property (nonatomic, retain) NSNumber * term;

// the interest rate, in percent 0-100 with 2 decimal points
@property (nonatomic, retain) NSDecimalNumber * rate;

// can be P or P+I
@property (nonatomic, retain) NSNumber * type;

// a financial frequency
@property (nonatomic, retain) NSNumber * frequency;

// reverse relation
@property (nonatomic, retain) Financials *financials;



// give us the list of LoanType available
+(NSArray*) loanTypes;

// a valid loan is completely filled in with non-nil values
- (BOOL)isValid;

// transient property used to tell us if the user just added this loan; will be NO by default
@property (nonatomic, assign) BOOL isNew;


@end
