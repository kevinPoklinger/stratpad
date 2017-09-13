//
//  SliderInputViewController.h
//  StratPad
//
//  Created by Julian Wood on 2013-04-18.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//
//  Hook up to min, max value and sliderChanged yourself.

#import <UIKit/UIKit.h>
#import "SliderTextField.h"

@interface SliderInputViewController : UIViewController

// float; must fall between min and max
@property (nonatomic,retain) NSNumber *value;

// custom routine to format the output into lblValue
@property(readwrite, copy) ValueFormatter valueFormatter;


// all required
@property (nonatomic, retain) NSString *desc;
@property (assign, nonatomic) float minimumValue;
@property (assign, nonatomic) float maximumValue;

@property (nonatomic, retain) id target;
@property (nonatomic, assign) SEL action;


@end
