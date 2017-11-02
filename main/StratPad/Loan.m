//
//  Loan.m
//  StratPad
//
//  Created by Julian Wood on 2013-04-17.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//

#import "Loan.h"
#import "Financials.h"
#import "NSString-Expanded.h"


@implementation Loan

@dynamic name;
@dynamic date;
@dynamic amount;
@dynamic term;
@dynamic rate;
@dynamic type;
@dynamic frequency;
@dynamic financials;

@synthesize isNew;

+(NSArray*) loanTypes
{
    NSMutableArray *ary = [NSMutableArray array];
    for (int i=0; i<LoanCount; i++) {
        NSString * key = [NSString stringWithFormat:@"LoanType_%d", i];
        [ary addObject:LocalizedString(key, nil)];
    }
    return ary;
}

- (BOOL)isValid
{
    return ![self.name isBlank] &&
    self.date != nil &&
    self.amount != nil &&
    self.term != nil &&
    self.rate != nil &&
    self.type != nil &&
    self.frequency != nil;
}


@end
