//
//  TextGoal.h
//  StratPad
//
//  Created by Eric Rogers on September 24, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//
//  Represents goals with text values for the "Reach These Goals"
//  chart in the Business Plan Report.

#import "Goal.h"

@interface TextGoal : NSObject<Goal> {
@private
    NSString *metric_;
    NSDate *date_;
    NSString *value_;
}

@property(nonatomic, readonly) NSString *metric;
@property(nonatomic, readonly) NSDate *date;
@property(nonatomic, readonly) NSString *value;

- (id<Goal>)initWithMetric:(NSString*)metric date:(NSDate*)date andValue:(NSString*)value;

@end
