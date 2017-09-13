//
//  YearMonthInputViewController.h
//  StratPad
//
//  Created by Julian Wood on 2013-04-18.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//
//  Nice skinning library for UIPickerView at http://www.inexika.com/blog/Customizing-UIPickerView-UIDatePicker

#import <UIKit/UIKit.h>

@interface YearMonthInputViewController : UIViewController<UIPickerViewDataSource,UIPickerViewDelegate>

// 6 digit number yyyymm - this is the model; set it to give the controller an initial value; read it to get the chosen value
@property (nonatomic,retain) NSNumber *value;

// these fields are all required
@property (nonatomic, retain) NSString *desc;

@property (nonatomic, retain) id target;
@property (nonatomic, assign) SEL action;

@end
