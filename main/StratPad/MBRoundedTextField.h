//
//  MBRoundedTextField.h
//  StratPad
//
//  Created by Eric Rogers on August 12, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//
//  Styles a textfield with rounded corners and fills it using
//  the colour set in the backgroundColor property.

#import "MBTextField.h"

@interface MBRoundedTextField : MBTextField {
 @private
    UIColor *roundedRectBackgroundColor_;
}

@property(nonatomic, retain) UIColor *roundedRectBackgroundColor;

@end
