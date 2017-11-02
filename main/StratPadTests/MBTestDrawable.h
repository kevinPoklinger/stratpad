//
//  MBTestDrawable.h
//  StratPad
//
//  Created by Julian Wood on 12-05-13.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import"Drawable.h"

@interface MBTestDrawable : NSObject<Drawable>

@property(nonatomic, assign) CGRect rect;

- (id)initWithRect:(CGRect)rect;


@end
