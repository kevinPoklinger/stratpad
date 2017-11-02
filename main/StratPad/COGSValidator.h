//
//  COGSValidator.h
//  StratPad
//
//  Created by Julian Wood on 2013-04-29.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//
//  COGS for inventory and COGS for payroll can't exceed 100% when summed.

#import <Foundation/Foundation.h>

@interface COGSValidator : NSObject
-(id)initWithSlider:(UISlider*)slider;
-(void)validateCOGS:(NSNumber*)inventoryPercentage wagePercentage:(NSNumber*)wagePercentage;
- (void)dismissWarning;
@end
