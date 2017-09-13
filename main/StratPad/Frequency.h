//
//  Frequency.h
//  StratPad
//
//  Created by Eric on 11-09-13.
//  Copyright (c) 2011 Glassey Strategy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Activity, Objective;

typedef enum {
    FrequencyCategoryDaily          = 0,
    FrequencyCategoryWeekly         = 1,
    FrequencyCategoryBiWeekly       = 2,
    FrequencyCategoryMonthly        = 3,
    FrequencyCategoryQuarterly      = 4,
    FrequencyCategorySemiAnnually   = 5,
    FrequencyCategoryAnnually       = 6   
} FrequencyCategory;

@interface Frequency : NSManagedObject {
@private
}

//props
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSNumber * category; // a FrequencyCategory

// inverse relations
@property (nonatomic, retain) NSSet* activity;
@property (nonatomic, retain) NSSet* objectives;


+ (Frequency*)frequencyForCategory:(FrequencyCategory)category;
+ (NSArray*)frequenciesSortedByOrder;

- (NSString*)nameForCurrentLocale;
- (NSString*)abbreviationForCurrentLocale;

- (FrequencyCategory)categoryRaw;
- (void)setCategoryRaw:(FrequencyCategory)category;

- (void)addObjectivesObject:(Objective *)value;
- (void)removeObjectivesObject:(Objective *)value;
- (void)addObjectives:(NSSet *)value;
- (void)removeObjectives:(NSSet *)value;

- (void)addActivityObject:(Activity *)value;
- (void)removeActivityObject:(Activity *)value;
- (void)addActivity:(NSSet *)value;
- (void)removeActivity:(NSSet *)value;

@end
