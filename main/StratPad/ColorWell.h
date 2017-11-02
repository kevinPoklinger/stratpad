//
//  ColorWell.h
//  StratPad
//
//  Created by Julian Wood on 12-05-17.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Drawable.h"

@interface ColorWell : NSObject<Drawable>

- (id)initWithRect:(CGRect)rect color:(UIColor*)color;

@property(nonatomic, assign) CGRect rect;
@property(nonatomic, retain) UIColor *color;
@property(nonatomic, assign) BOOL readyForPrint;

@end
