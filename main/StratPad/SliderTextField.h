//
//  SliderTextField.h
//  StratPad
//
//  Created by Julian Wood on 2013-04-18.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//
//  A textfield which when it becomes first responder, shows a slider in a popup.
//  Add a listener to UIControlEventValueChanged to get the value as it changes (so you can persist it).
//  Add a ValueFormatter to format the value before it is shown in the popover and the textfield.

#import "PropertyTextField.h"

typedef NSString* (^ValueFormatter)(NSNumber *value);

@interface SliderTextField : PropertyTextField

// a custom routine to format the output into the text field, and in the slider popup
@property(readwrite, copy) ValueFormatter valueFormatter;

// float
@property (nonatomic,retain) NSNumber *value;

// these fields are all required
@property (nonatomic, retain) NSString *desc;
@property (assign, nonatomic) float minimumValue;
@property (assign, nonatomic) float maximumValue;


@end
