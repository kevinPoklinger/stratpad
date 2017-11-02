//
//  YearMonthTextField.h
//  StratPad
//
//  Created by Julian Wood on 2013-04-19.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PropertyTextField.h"
#import "LinkedFieldOrganizer.h"

@interface YearMonthTextField : PropertyTextField

// yyyymm - eg 201301 (Jan 2013)
@property (nonatomic,retain) NSNumber *value;

// these fields are all required
@property (nonatomic, retain) NSString *desc;

@end
