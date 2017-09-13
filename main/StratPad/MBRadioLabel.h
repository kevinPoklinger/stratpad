//
//  MBRadioLabel.h
//  Experimental
//
//  Created by Julian Wood on 12-05-03.
//  Copyright (c) 2012 Mobilesce Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBSuccessIndicator.h"
#import "RadioGroup.h"

@interface MBRadioLabel : UILabel {
    @private
    id<MBRadioGroup> radioGroup_;
}

- (id)initWithFrame:(CGRect)frame andRadioGroup:(id<MBRadioGroup>)radioGroup;

// when on, we draw a rounded rect behind the label
@property (nonatomic,assign) BOOL on;
@property (nonatomic,retain) UIColor *onColor;

// as part of a group, this value is returned when selected
@property (nonatomic,retain) id radioValue;

@end
