//
//  MBSuccessIndicator.h
//  Experimental
//
//  Created by Julian Wood on 12-05-03.
//  Copyright (c) 2012 Mobilesce Inc. All rights reserved.
//
//  Shows two labels which can be tapped like a radio group.
//  Add a target to get notified when the selection changes.

#import <UIKit/UIKit.h>
#import "RadioGroup.h"
#import "MBRadioLabel.h"

@interface MBSuccessIndicator : UIView<MBRadioGroup> {
    MBRadioLabel *r1_;
    MBRadioLabel *r2_;
    id target_;
    SEL action_;
}

@property(nonatomic,retain) NSNumber *selection;

- (id)initWithFrame:(CGRect)frame andSelection:(NSNumber*)selection;
-(void)addTarget:(id)target action:(SEL)action;

@end
