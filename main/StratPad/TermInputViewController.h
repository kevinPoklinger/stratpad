//
//  TermInputViewController.h
//  StratPad
//
//  Created by Julian Wood on 2013-05-30.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TermInputViewController : UIViewController<UIPickerViewDataSource,UIPickerViewDelegate>

// number of months
@property (nonatomic,retain) NSNumber *value;

// these fields are all required
@property (nonatomic, retain) NSString *desc;

@property (nonatomic, retain) id target;
@property (nonatomic, assign) SEL action;

@end
