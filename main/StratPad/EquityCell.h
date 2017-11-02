//
//  EquityCell.h
//  StratPad
//
//  Created by Julian Wood on 2013-04-23.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Equity.h"
#import "PropertyTextField.h"
#import "YearMonthTextField.h"
#import "FinancialRowValidator.h"

@interface EquityCell : UITableViewCell<UITextFieldDelegate>
@property (retain, nonatomic) IBOutlet PropertyTextField *txtName;
@property (retain, nonatomic) IBOutlet YearMonthTextField *txtDate;
@property (retain, nonatomic) IBOutlet PropertyTextField *txtValue;

@property (nonatomic, retain) Equity *equity;

@property (nonatomic, retain) id<FinancialRowValidator> validator;

// after having set an equity, you can load values
-(void)loadValues:(Equity*)equity;

@end
