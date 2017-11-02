//
//  RoundedRectView.h
//  MBExperimental
//
//  Created by Julian Wood on 11-07-30.
//  Copyright 2011 Mobilesce Inc. All rights reserved.
//
//  This view will make a rounded rect corresponding to this view's bounds, 
//  filled with whatever backgroundColor was specified;

#import <UIKit/UIKit.h>


@interface MBRoundedRectView : UIView {
    UIColor *roundedRectBackgroundColor_;
}

@property (nonatomic,retain) UIColor *roundedRectBackgroundColor;

@end
