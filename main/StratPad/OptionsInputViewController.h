//
//  EnumInputViewController.h
//  StratPad
//
//  Created by Julian Wood on 2013-04-22.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OptionsInputViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

// int; must be a valid index into options (or nil)
@property (nonatomic,retain) NSNumber *value;


// all required
@property (nonatomic, retain) NSString *desc;

// an array of localized strings, whose index matches the enum int value
@property (nonatomic, retain) NSArray *options;

@property (nonatomic, retain) id target;
@property (nonatomic, assign) SEL action;


-(CGSize)preferredSize;

@end
