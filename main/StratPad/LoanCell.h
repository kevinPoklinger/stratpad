//
//  LoanCell.h
//  StratPad
//
//  Created by Julian Wood on 2013-04-16.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Loan.h"
#import "SliderTextField.h"
#import "YearMonthTextField.h"
#import "MBRoundedTableViewCell.h"
#import "OptionsTextField.h"
#import "Frequency.h"
#import "TermTextField.h"
#import "FinancialRowValidator.h"

@interface LoanCell : UITableViewCell<UITextFieldDelegate>
@property (retain, nonatomic) IBOutlet PropertyTextField *txtName;
@property (retain, nonatomic) IBOutlet YearMonthTextField *txtDate;
@property (retain, nonatomic) IBOutlet PropertyTextField *txtAmount;
@property (retain, nonatomic) IBOutlet TermTextField *txtTerm;
@property (retain, nonatomic) IBOutlet PropertyTextField *txtRate;
@property (retain, nonatomic) IBOutlet OptionsTextField *txtType;
@property (retain, nonatomic) IBOutlet OptionsTextField *txtFrequency;

@property (nonatomic, retain) id<FinancialRowValidator> validator;

@property (retain, nonatomic) Loan *loan;

// NB we use a subset of all the available frequencies, so we must translate
+(NSArray*)indexForFrequency:(FrequencyCategory)frequency;

-(void)loadValues:(Loan*)loan;

@end

