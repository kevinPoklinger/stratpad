//
//  Equity.h
//  StratPad
//
//  Created by Julian Wood on 2013-04-23.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Financials;

@interface Equity : NSManagedObject

// name of investment
@property (nonatomic, retain) NSString * name;

// date of investment YYYYMM; displayed as mmyy
@property (nonatomic, retain) NSNumber * date;

// amount of investment
@property (nonatomic, retain) NSNumber * value;

// inverse
@property (nonatomic, retain) Financials *financials;


// a valid Equity is completely filled in with non-nil values
- (BOOL)isValid;

// transient property used to tell us if the user just added this Equity; will be NO by default
@property (nonatomic, assign) BOOL isNew;


@end
