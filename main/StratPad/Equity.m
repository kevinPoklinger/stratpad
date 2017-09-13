//
//  Equity.m
//  StratPad
//
//  Created by Julian Wood on 2013-04-23.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//

#import "Equity.h"
#import "Financials.h"
#import "NSString-Expanded.h"


@implementation Equity

@dynamic name;
@dynamic date;
@dynamic value;
@dynamic financials;

@synthesize isNew;

- (BOOL)isValid
{
    return ![self.name isBlank] &&
    self.date != nil &&
    self.value != nil;
}


@end
