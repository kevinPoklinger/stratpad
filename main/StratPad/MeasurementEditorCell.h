//
//  MeasurementEditorCell.h
//  StratPad
//
//  Created by Julian Wood on 12-04-21.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Measurement.h"
#import "PropertyTextField.h"
#import "MBCalendarButton.h"
#import "MBDateSelectionViewController.h"

@interface NSNumber (MeasurementViewController)
- (NSString*)formattedNumberForValue;
@end

@interface MeasurementEditorCell : UITableViewCell<UITextFieldDelegate,DateSelectionDelegate> {
    @private
    MBDateSelectionViewController *datePicker_;
}

@property (retain, nonatomic) IBOutlet PropertyTextField *textFieldValue;
@property (retain, nonatomic) IBOutlet PropertyTextField *textFieldComment;

@property (retain, nonatomic) IBOutlet MBCalendarButton *btnDate;
- (IBAction)showDatePicker:(id)sender;

@property (retain, nonatomic) Measurement *measurement;

@end
