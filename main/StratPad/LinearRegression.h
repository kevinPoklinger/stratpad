//
//  LinearRegression.h
//  StratPad
//
//  Created by Julian Wood on 12-04-11.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//
//  All x-values are in days, and y-values are in realistic units (ie dollars)

#import <Foundation/Foundation.h>
#import "Chart.h"

@interface LinearRegression : NSObject
{
    @private
    CGFloat slope_;
    CGFloat yintercept_;    
}

// pass the max value for x and y as a CGPoint
- (id)initWithChart:(Chart*)chart chartStartDate:(NSDate*)chartStartDate;

// given an x value, what is the corresponding y value
-(CGFloat)yVal:(CGFloat)x;

// given an y value, what is the corresponding x value
-(CGFloat)xVal:(CGFloat)y;

// the most any point deviates from the best fit line, in th epositive direction
@property (nonatomic,assign) CGFloat devY;

@end
