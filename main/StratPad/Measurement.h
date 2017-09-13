//
//  Measurement.h
//  StratPad
//
//  Created by Julian Wood on 12-02-24.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#define maxCommentLength    1000.f

@class Metric;

@interface Measurement : NSManagedObject

@property (nonatomic, retain) NSString * comment;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * value;

// inverse
@property (nonatomic, retain) Metric *metric;

@end
