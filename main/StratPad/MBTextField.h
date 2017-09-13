//
//  MBTextField.h
//  StratPad
//
//  Created by Eric Rogers on August 15, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//
//  Provides a way to associate a textfield to its corresponding label.
//  This is used for figuring out what label is for what textfield when
//  scrolling a form to adjust for the keyboard.

#import "Bindable.h"

@interface MBTextField : UITextField<Bindable>

@property(nonatomic, retain) IBOutlet UILabel *label;
@property(nonatomic, copy) NSString *boundProperty;
@property(nonatomic, retain) id boundEntity;

@end
