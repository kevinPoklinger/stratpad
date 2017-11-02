//
//  ThemeKey.h
//  StratPad
//
//  Created by Julian Wood on 12-05-15.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Theme.h"

@interface ThemeKey : NSObject<NSCopying>

- (id)initWithTheme:(Theme*)theme;

@property (nonatomic,retain) NSString *title;
@property (nonatomic,retain) NSNumber *order;
@property (nonatomic,retain) NSDate *startDate;
@property (nonatomic,retain) NSDate *endDate;
@property (nonatomic,retain) NSString *responsible;

@end
