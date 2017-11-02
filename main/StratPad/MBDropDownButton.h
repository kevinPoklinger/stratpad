//
//  MBDropDownButton.h
//  StratPad
//
//  Created by Eric Rogers on August 22, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//
//  A rounded button with an inset label on the left, and down pointing arrow
//  on the right.

#import "MBRoundedButton.h"

@interface MBDropDownButton : MBRoundedButton {
 @private    
    UILabel *label_;
    UIImageView *arrowView_;
}

@property(nonatomic, readonly) UILabel *label;

@end
