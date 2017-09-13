//
//  UIView+ObjectTagAdditions.h
//  StratPad
//
//  Created by Julian Wood on 2013-04-24.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (ObjectTagAdditions)

@property (nonatomic, retain) id objectTag;

- (UIView *)viewWithObjectTag:(id)object;

@end
