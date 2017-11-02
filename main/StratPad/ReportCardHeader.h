//
//  ReportCardHeader.h
//  StratPad
//
//  Created by Julian Wood on 12-05-15.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Drawable.h"
#import "ThemeKey.h"

@interface ReportCardHeader : NSObject<Drawable> {
    UIEdgeInsets padding_;
}

- (id)initWithThemeKey:(ThemeKey*)themeKey rect:(CGRect)rect;

@property(nonatomic, assign) CGRect rect;
@property(nonatomic, retain) ThemeKey *themeKey;

@end
