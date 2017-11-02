//
//  AssetCell.h
//  StratPad
//
//  Created by Julian Wood on 2013-04-22.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PropertyTextField.h"
#import "YearMonthTextField.h"
#import "OptionsTextField.h"
#import "SliderTextField.h"
#import "Asset.h"
#import "FinancialRowValidator.h"

@interface AssetCell : UITableViewCell<UITextFieldDelegate>

// name of the asset
@property (retain, nonatomic) IBOutlet PropertyTextField *txtName;

// acquisition date in yyyymm; displayed in mmyy
@property (retain, nonatomic) IBOutlet YearMonthTextField *txtDate;

// initial value
@property (retain, nonatomic) IBOutlet PropertyTextField *txtValue;

// years to depreciate
@property (retain, nonatomic) IBOutlet SliderTextField *txtDepreciationTerm;

// value at end of depreciation term
@property (retain, nonatomic) IBOutlet PropertyTextField *txtSalvageValue;

// type of asset
@property (retain, nonatomic) IBOutlet OptionsTextField *txtType;

// type of depreciation curve
@property (retain, nonatomic) IBOutlet OptionsTextField *txtDepreciationType;


@property (nonatomic, retain) id<FinancialRowValidator> validator;
@property (retain, nonatomic) Asset *asset;

-(void)loadValues:(Asset*)asset;

@end
