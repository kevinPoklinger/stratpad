//
//  EnumTextField.h
//  StratPad
//
//  Created by Julian Wood on 2013-04-22.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//
//  A textfield which when it becomes the firstResponder, it shows a popup with the mapped string values of an enum.
//  Interested classes can register a listener for UIControlEventValueChanged to get the int value of the enum as it changes.


#import "PropertyTextField.h"

@interface OptionsTextField : PropertyTextField

// if you want a custom routine to format the output into the text field
typedef void (^DisplayBlock)(OptionsTextField *optionsTextField, NSNumber *value);
@property(readwrite, copy) DisplayBlock displayBlock;

// int representing the enum choice
@property (nonatomic,assign) NSNumber *value;

// required; brief description for the field
@property (nonatomic, retain) NSString *desc;

// required; an array of localized strings, whose index matches the enum int value
@property (nonatomic, retain) NSArray *options;

// default is false, set to true if you want to dismiss the popup when a selection is made
@property (nonatomic, assign) BOOL dismissOnSelection;


@end
