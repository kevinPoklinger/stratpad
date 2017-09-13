//
//  Metric.h
//  StratPad
//
//  Created by Eric Rogers on October 17, 2011.
//  Copyright (c) 2011 Glassey Strategy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Goal.h"

// when we look at a trandline and a target, are we hoping that projections exceed the target? ie revenues? or subcede the target ie expenses?
typedef enum {
    SuccessIndicatorMeetOrExceed    = 0,
    SuccessIndicatorMeetOrSubcede   = 1
} SuccessIndicator;

@class Objective;
@class Measurement;
@class Chart;

@interface Metric : NSManagedObject

// the name of the metric
@property (nonatomic, retain) NSString * summary;

// the date on which we would like to achieve the target value
@property (nonatomic, retain) NSDate * targetDate;

// measurements should lead up to (or down to) this target
@property (nonatomic, retain) NSString * targetValue;

// NB. this is only relevant when we have StratBoard
// for every metric, like gross revenue, there can optionally be a set of measurements made over time
@property (nonatomic, retain) NSSet *measurements;

// NB. this is only relevant when we have StratBoard
// it should be of type SuccessIndicator
@property (nonatomic, retain) NSNumber * successIndicator;


// NB. this is only relevant when we have StratBoard
// inverse relationship - every Chart has a metric
@property (nonatomic, retain) NSSet *charts;

// inverse
@property (nonatomic, retain) Objective *objective;

@end

@interface Metric (Convenience)

// returns YES if targetValue has a value and can be parsed into a numeric value.
- (BOOL)isNumeric;

// returns the numeric equivalent of the targetValue, only if the targetValue has a value and 
// it can be parsed into a number.  Returns nil otherwise.
- (NSNumber*)parseNumberFromTargetValue;

// performant way to determine if there are any measurements
-(BOOL)hasMeasurements;

// create a new Text or Numeric goal, depending on metric type
// for "Reach These Goals" chart in the Business Plan Report.
- (id<Goal>)newGoal;


@end

@interface Metric (CoreDataGeneratedAccessors)

- (void)addChartsObject:(Chart *)value;
- (void)removeChartsObject:(Chart *)value;
- (void)addCharts:(NSSet *)values;
- (void)removeCharts:(NSSet *)values;

- (void)addMeasurementsObject:(Measurement *)value;
- (void)removeMeasurementsObject:(Measurement *)value;
- (void)addMeasurements:(NSSet *)values;
- (void)removeMeasurements:(NSSet *)values;

@end

