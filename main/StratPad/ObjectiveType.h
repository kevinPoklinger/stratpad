//
//  ObjectiveType.h
//  StratPad
//
//  Created by Eric on 11-09-13.
//  Copyright (c) 2011 Glassey Strategy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class LocalizableText, Objective;

typedef enum {
    ObjectiveCategoryFinancial   = 0,
    ObjectiveCategoryCustomer    = 1,
    ObjectiveCategoryProcess     = 2,
    ObjectiveCategoryStaff       = 3,
    ObjectiveCategoryCommunity   = 4,
    ObjectiveCategoryFunder      = 5
} ObjectiveCategory;

extern NSUInteger const kNumberOfObectiveCategories;

@interface ObjectiveType : NSManagedObject {
@private
}

// props
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSNumber * category; // an ObjectiveCategory

// inverse relationships
@property (nonatomic, retain) NSSet* objective;

+ (ObjectiveType*)objectiveTypeForCategory:(ObjectiveCategory)category;
+ (NSArray*)objectiveTypesSortedByOrder;

- (NSString*)nameForCurrentLocale;
- (ObjectiveCategory)categoryRaw;
- (void)setCategoryRaw:(ObjectiveCategory)category;

- (void)addObjectiveObject:(Objective *)value;
- (void)removeObjectiveObject:(Objective *)value;
- (void)addObjective:(NSSet *)value;
- (void)removeObjective:(NSSet *)value;

@end
