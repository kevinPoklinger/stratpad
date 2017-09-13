//
//  TermTextField.h
//  StratPad
//
//  Created by Julian Wood on 2013-05-30.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//

#import "PropertyTextField.h"

@interface TermTextField : PropertyTextField

// yyyymm - eg 201301 (Jan 2013)
@property (nonatomic,retain) NSNumber *value;

// these fields are all required
@property (nonatomic, retain) NSString *desc;

@end
