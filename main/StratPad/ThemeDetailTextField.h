//
//  ThemeDetailTextField.h
//  StratPad
//
//  Created by Julian Wood on 12-02-01.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//
//  Draw a little triangle in the top left corner of the textfield, when asked.

#import "MBRoundedTextField.h"

@interface ThemeDetailTextField : MBRoundedTextField
{
    BOOL hasAdjustment_;
}

@property (nonatomic,assign) BOOL hasAdjustment;

@end
