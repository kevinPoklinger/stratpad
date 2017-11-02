//
//  LinearRegression.m
//  StratPad
//
//  Created by Julian Wood on 12-04-11.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "LinearRegression.h"
#import "NSCalendar+Expanded.h"
#import "Measurement.h"
#import "Metric.h"
#import "DataManager.h"

@implementation LinearRegression

@synthesize devY = devY_;

- (id)initWithChart:(Chart*)chart chartStartDate:(NSDate*)chartStartDate
{
    self = [super init];
    if (self) {
        
        NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];    
        
        // for now, let's just do a linear regression
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"metric=%@ && value!=nil", chart.metric];
        NSArray *measurements = [DataManager arrayForEntity:NSStringFromClass([Measurement class])
                                       sortDescriptorsOrNil:nil
                                             predicateOrNil:predicate];

        CGFloat sumxy=0, sumx=0, sumy=0, sumx2=0, n=[measurements count];
        if (n == 0) {
            slope_ = 0.5;
            yintercept_ = 0;
            devY_ = 0;
            return self;
        } else if (n == 1) {
            slope_ = 0.5;
            yintercept_ = [[(Measurement*)[measurements objectAtIndex:0] value] floatValue];
            devY_ = yintercept_;
            return self;
        }
        for (Measurement *measurement in measurements) {
            
            // need the number of days since the starting month (ie Jan 1, 2011 in our example) of this measurement        
            NSDateComponents *components = [gregorian components:NSDayCalendarUnit
                                                        fromDate:chartStartDate
                                                          toDate:measurement.date options:0];
            NSInteger dayOfYear = [components day];
            
            CGFloat x = (CGFloat)dayOfYear;
            CGFloat y = [[measurement value] floatValue];
            
            sumxy += x*y;
            sumx += x;
            sumy += y;
            sumx2 += x*x;
        }
        
        // y = mx + b;
        slope_ = (n*sumxy - sumx*sumy)/(n*sumx2 - sumx*sumx);
        yintercept_ = (sumy - slope_*sumx)/n;
        
        
        // if we have two or more measurements all with the same date, we'll get this
        if (isnan(slope_)) {
            slope_ = 0.5;
        }
        if (isnan(yintercept_)) {
            yintercept_ = 0;
        }
        
        // now calculate dY
        devY_ = 0;
        for (Measurement *measurement in measurements) {
            
            // need the number of days since the starting month (ie Jan 1, 2011 in our example) of this measurement        
            NSDateComponents *components = [gregorian components:NSDayCalendarUnit
                                                        fromDate:chartStartDate
                                                          toDate:measurement.date options:0];
            NSInteger dayOfYear = [components day];
            
            CGFloat x = (CGFloat)dayOfYear;
            CGFloat y = [[measurement value] floatValue];
            
            CGFloat ylr = slope_*x + yintercept_;
            devY_ = MAX(devY_, y-ylr);
        }
    }
    return self;
}

-(CGFloat)yVal:(CGFloat)x
{
    return slope_*x + yintercept_;
}

-(CGFloat)xVal:(CGFloat)y
{
    // y = mx+b;
    // x = (y-b)/m
    return (y-yintercept_)/slope_;
}

@end
