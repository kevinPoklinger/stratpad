//
//  NumericGoal.h
//  StratPad
//
//  Created by Eric Rogers on September 24, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//
//  Represents goals with numeric values for the "Reach These Goals"
//  chart in the Business Plan Report.

#import "Goal.h"

@interface NumericGoal : NSObject<Goal> {
@private
    NSString *metric_;
    NSDate *date_;
    NSNumber *value_;
}

@property(nonatomic, readonly) NSString *metric;
@property(nonatomic, readonly) NSDate *date;
@property(nonatomic, readonly) NSNumber *value;

- (id<Goal>)initWithMetric:(NSString*)metric date:(NSDate*)date andNumericValue:(NSNumber*)value;

@end
