//
//  Objective.h
//  StratPad
//
//  Created by Eric Rogers on October 17, 2011.
//  Copyright (c) 2011 Glassey Strategy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Activity, Frequency, Metric, ObjectiveType, Theme;

@interface Objective : NSManagedObject

@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSString * summary;
@property (nonatomic, retain) Frequency *reviewFrequency;
@property (nonatomic, retain) Theme *theme;
@property (nonatomic, retain) ObjectiveType *objectiveType;
@property (nonatomic, retain) NSSet *activities;
@property (nonatomic, retain) NSSet *metrics;

@end

@interface Objective (CoreDataGeneratedAccessors)

- (void)addActivitiesObject:(Activity *)value;
- (void)removeActivitiesObject:(Activity *)value;
- (void)addActivities:(NSSet *)values;
- (void)removeActivities:(NSSet *)values;
- (void)addMetricsObject:(Metric *)value;
- (void)removeMetricsObject:(Metric *)value;
- (void)addMetrics:(NSSet *)values;
- (void)removeMetrics:(NSSet *)values;
@end

@interface Objective (Convenience)

// user-defined order
- (NSMutableArray*)activitiesSortedByOrder;

// uses a combination of start and end dates
- (NSMutableArray*)activitiesSortedByDate;

// looks at metrics and activities and returns earliest date or nil
- (NSDate*)earliestDate;

// looks at metrics and activities and returns latest date or nil
- (NSDate*)latestDate;


@end
