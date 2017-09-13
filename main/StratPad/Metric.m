//
//  Metric.m
//  StratPad
//
//  Created by Eric Rogers on October 17, 2011.
//  Copyright (c) 2011 Glassey Strategy. All rights reserved.
//

#import "Metric.h"
#import "Objective.h"
#import "NSString-Expanded.h"
#import "NSNumber-StratPad.h"
#import "DataManager.h"
#import "Settings.h"
#import "Measurement.h"
#import "Chart.h"
#import "NumericGoal.h"
#import "TextGoal.h"

@implementation Metric

@dynamic summary;
@dynamic targetDate;
@dynamic targetValue;
@dynamic measurements;
@dynamic successIndicator;

// inverse
@dynamic charts;

// inverse
@dynamic objective;

- (BOOL)isNumeric
{
    return [self parseNumberFromTargetValue] != nil;
}

- (NSNumber*)parseNumberFromTargetValue
{
    if (!self.targetValue || [self.targetValue isBlank]) {
        return nil;
    }
    
    NSNumber *parsedNumber = nil;
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    // try with a regular number format 
    parsedNumber = [formatter numberFromString:self.targetValue];    
    
    if (!parsedNumber) {
        // try to parse by including + and - signs.
        [formatter setPositiveFormat:@"+#,##0.##"];
        [formatter setNegativeFormat:@"-#,##0.##"];        
    }
    
    parsedNumber = [formatter numberFromString:self.targetValue];    
    
    if (!parsedNumber) {
        // try to parse by including $ and - signs.
        [formatter setPositiveFormat:@"$#,##0.##"];
        [formatter setNegativeFormat:@"-$#,##0.##"];        
    }    
    
    parsedNumber = [formatter numberFromString:self.targetValue];    
    
    if (!parsedNumber) {
        // try to parse by including currency symbol from settings and and - sign.
        Settings *settings = (Settings*)[DataManager objectForEntity:NSStringFromClass([Settings class]) sortDescriptorsOrNil:nil predicateOrNil:nil];
        
        [formatter setPositiveFormat:[NSString stringWithFormat:@"%@#,##0.##", settings.currency]];
        [formatter setNegativeFormat:[NSString stringWithFormat:@"-%@#,##0.##", settings.currency]];        
    }    
    
    parsedNumber = [formatter numberFromString:self.targetValue];    
    
    [formatter release];
    
    return parsedNumber;        
}

-(BOOL)hasMeasurements
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"metric=%@", self];
	NSUInteger numMeasurements = [DataManager countForEntity:NSStringFromClass([Measurement class]) predicateOrNil:predicate];
    return numMeasurements > 0;
}

- (id<Goal>)newGoal
{    
    id<Goal> goal;
    
    if ([self isNumeric]) {
        goal = [[NumericGoal alloc] initWithMetric:self.summary date:self.targetDate andNumericValue:[self parseNumberFromTargetValue]];
    } else {
        goal = [[TextGoal alloc] initWithMetric:self.summary date:self.targetDate andValue:self.targetValue];
    }
    
    return goal;
}


@end
