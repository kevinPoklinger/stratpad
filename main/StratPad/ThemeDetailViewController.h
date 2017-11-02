//
//  ThemeDetailViewController.h
//  StratPad
//
//  Created by Eric Rogers on August 11, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "FormViewController.h"
#import "Theme.h"
#import "MBRoundedRectView.h"
#import "MBRoundedTextField.h"
#import "MBRoundedLabel.h"
#import "MBDateSelectionViewController.h"
#import "MBAutoSuggestController.h"
#import "MBDropDownController.h"
#import "MBCalendarButton.h"
#import "MBRoundedScrollView.h"
#import "CalculationsViewController.h"
#import "ThemeDetailTextField.h"

@interface ThemeDetailViewController : FormViewController<UITextFieldDelegate, UIPopoverControllerDelegate, DateSelectionDelegate, AutoSuggestDelegate, DropDownDelegate, CalculationsViewControllerDelegate> {
 @private
                            
    MBDropDownController *themeDropDownController_;
    
    MBAutoSuggestController *autoSuggestController_;
    
    MBDateSelectionViewController *startDateController_;
    MBDateSelectionViewController *endDateController_;
    
    CalculationsViewController *calculationsVC_;
    
    NSString *dateValidationMessage_;
    NSDate *suggestedDate_;
}

@property(nonatomic, retain) IBOutlet MBCalendarButton *btnStartDate;
@property(nonatomic, retain) IBOutlet MBCalendarButton *btnEndDate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andThemeOrNil:(Theme*)theme;

@end

@interface ThemeDetailViewController (Testable)

- (NSDictionary*)calculateNetBenefits;
@end

@interface NSNumber (ThemeDetail)
- (NSString*)netBenefitFormattedNumber;
@end

