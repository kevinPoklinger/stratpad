//
//  MBLabel.h
//  Powercents
//
//  Created by Julian Wood on 11-05-31.
//  Copyright 2011 EnergyMobile Inc. All rights reserved.
//
//  Allows a label to have insets (padding).


@interface MBLabel : UILabel {
    UIEdgeInsets insets_;
}

@property (nonatomic,assign) UIEdgeInsets insets;

@end
