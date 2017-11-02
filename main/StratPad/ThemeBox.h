//
//  ThemeBox.h
//  StratPad
//
//  Created by Julian Wood on 11-09-01.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PointerBox.h"
#import "Theme.h"

@interface ThemeBox : PointerBox {
    Theme *theme_;
    NSString *fontName_;
    CGFloat fontSize_;
    UIColor *fontColor_;
}

-(id)initWithTheme:(Theme *)theme frame:(CGRect)frame fontName:(NSString*)fontName fontSize:(CGFloat)fontSize fontColor:(UIColor*)fontColor color:(UIColor *)color targetFrames:(NSMutableSet *)targetFrames;

@property (nonatomic,retain) Theme *theme;

@end
