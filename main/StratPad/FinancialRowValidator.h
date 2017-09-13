//
//  FinancialRowValidator.h
//  StratPad
//
//  Created by Julian Wood on 2013-06-25.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//
//  Provides validation capabilities to Loans, Assets and Equities

#import <Foundation/Foundation.h>

@protocol FinancialRowValidator <NSObject>

@required
// this method should look through the appropriate entity, decide if it's valid, and act appropriately
-(void)check;

@end
