//
//  MBAutoSuggestTextField.m
//  StratPad
//
//  Created by Eric Rogers on August 22, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "MBAutoSuggestTextField.h"


@implementation MBAutoSuggestTextField

@synthesize btnArrow = btnArrow_;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        UIImage *imgArrowDown = [UIImage imageNamed:@"arrow-down.png"];
        btnArrow_ = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnArrow_ setBackgroundImage:imgArrowDown forState:UIControlStateNormal];
        btnArrow_.bounds = CGRectMake(0, 0, imgArrowDown.size.width, imgArrowDown.size.height);
        self.rightViewMode = UITextFieldViewModeAlways;
        self.rightView = btnArrow_;
    }
    return self;
}

@end
