//
//  MBAutoSuggestTextField.h
//  StratPad
//
//  Created by Eric Rogers on August 22, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//
//  A rounded text field with a down pointing arrow for its right view.

#import "MBRoundedTextField.h"

@interface MBAutoSuggestTextField : MBRoundedTextField {
@private
    UIButton *btnArrow_;
}

@property(nonatomic, readonly) UIButton *btnArrow;

@end
