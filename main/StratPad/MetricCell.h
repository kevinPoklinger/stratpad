//
//  MetricCell.h
//  StratPad
//
//  Created by Julian Wood on 12-05-03.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "MBRoundedTableViewCell.h"
#import "PropertyTextField.h"
#import "MBCalendarButton.h"
#import "MBDateSelectionViewController.h"
#import "Metric.h"
#import "MBBindableRoundSwitch.h"
#import "MBSuccessIndicator.h"
#import "MBAutoSuggestTextField.h"
#import "MBAutoSuggestController.h"

@interface MetricCell : MBRoundedTableViewCell<UITextFieldDelegate,DateSelectionDelegate,AutoSuggestDelegate> {
@private
    MBDateSelectionViewController *datePicker_;
    MBAutoSuggestController *autoSuggestController_;
}

@property (retain, nonatomic) Metric *metric;

@property (retain, nonatomic) IBOutlet MBSuccessIndicator *successIndicator;
@property (retain, nonatomic) IBOutlet MBAutoSuggestTextField *textFieldSummary;
@property (retain, nonatomic) IBOutlet PropertyTextField *textFieldTargetValue;
@property (retain, nonatomic) IBOutlet MBCalendarButton *btnTargetDate;
- (IBAction)showDatePicker:(id)sender;

- (void)updateMetricAutoSuggestValues;

@end
