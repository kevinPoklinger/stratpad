//
//  ObjectiveBox.h
//  StratPad
//
//  Created by Julian Wood on 11-09-01.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PointerBox.h"
#import "Objective.h"

@interface ObjectiveBox : PointerBox {
    Objective *objective_;
    NSString *fontName_;
    CGFloat fontSize_;
    UIColor *fontColor_;
}

@property (nonatomic,assign) Objective *objective;

-(id)initWithObjective:(Objective *)objective frame:(CGRect)frame fontName:(NSString*)fontName fontSize:(CGFloat)fontSize fontColor:(UIColor*)fontColor color:(UIColor *)color targetFrames:(NSMutableSet *)targetFrames;


@end
