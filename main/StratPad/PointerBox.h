//
//  PointerBox.h
//  StratPad
//
//  Created by Julian Wood on 11-08-31.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "UIColor-Expanded.h"
#import "StrategyMapView.h"

@interface PointerBox : NSObject {
@private
    NSString *text_;
    CGRect frame_;
    UIColor *color_;
    NSMutableSet *targetFrames_; // CGRects in NSValues
}

@property (nonatomic, retain) NSString *text;
@property (nonatomic, assign) CGRect frame;
@property (nonatomic, retain) UIColor *color;
@property (nonatomic, retain) NSMutableSet *targetFrames;

-(id)initWithText:(NSString *)text frame:(CGRect)frame color:(UIColor *)color targetFrames:(NSMutableSet *)targetFrames;

- (void)draw:(CGContextRef)context;
-(void)drawArrow:(CGContextRef)context;



@end
