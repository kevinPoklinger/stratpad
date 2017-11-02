//
//  HonedSlider.m
//  StratPad
//
//  Created by Julian Wood on 2013-06-03.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//

#import "HonedSlider.h"

@interface HonedSlider ()
@property (nonatomic, retain) NSMutableArray *lastSixValues;
@end

@implementation HonedSlider

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.lastSixValues = [NSMutableArray arrayWithCapacity:6];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.lastSixValues = [NSMutableArray arrayWithCapacity:6];        
    }
    return self;
}

-(NSInteger)honedIntegerValue
{
    NSInteger value = round(floorf(self.value));

    NSUInteger ct = _lastSixValues.count;
    if (ct && ct > 5) {
        [_lastSixValues removeObjectAtIndex:0];
    }
    [_lastSixValues addObject:[NSNumber numberWithInteger:value]];
    //    DLog(@"Cache: %@", _lastSixValues);
    
    // if one or two values change at the end of the cache array, use the previous value
    if (ct == 6) {
        NSInteger thirdVal = [[_lastSixValues objectAtIndex:2] integerValue];
        NSInteger fourthVal = [[_lastSixValues objectAtIndex:3] integerValue];
        NSInteger fifthVal = [[_lastSixValues objectAtIndex:4] integerValue];
        NSInteger sixthVal = [[_lastSixValues objectAtIndex:5] integerValue];
        if (fifthVal == sixthVal ) {
            // sometimes we get things like 0,0,0,0,1,1 where 0 was meant
            if (thirdVal == fourthVal && fourthVal != fifthVal) {
                value = fourthVal;
            } else {
                value = sixthVal;
            }
        }
        else if (fourthVal == fifthVal) {
            // ie 0,0,0,0,0,1 where 0 was meant
            value = fifthVal;
        }
        else if (thirdVal == fourthVal) {
            // 0,0,0,0,1,2 where 0 was meant
            value = fourthVal;
        }
    }
    
    return value;
}


-(float)honedFloatValue
{
    float value = self.value;

    NSUInteger ct = _lastSixValues.count;
    if (ct && ct > 5) {
        [_lastSixValues removeObjectAtIndex:0];
    }
    [_lastSixValues addObject:[NSNumber numberWithFloat:value]];
    DLog(@"Cache: %@", _lastSixValues);
    
    // if one or two values change at the end of the cache array, use the previous value
    if (ct == 6) {
        float thirdVal = [[_lastSixValues objectAtIndex:2] floatValue];
        float fourthVal = [[_lastSixValues objectAtIndex:3] floatValue];
        float fifthVal = [[_lastSixValues objectAtIndex:4] floatValue];
        float sixthVal = [[_lastSixValues objectAtIndex:5] floatValue];
        if (fifthVal == sixthVal ) {
            // sometimes we get things like 0,0,0,0,1,1 where 0 was meant
            if (thirdVal == fourthVal && fourthVal != fifthVal) {
                value = fourthVal;
            } else {
                value = sixthVal;
            }
        }
        else if (fourthVal == fifthVal) {
            // ie 0,0,0,0,0,1 where 0 was meant
            value = fifthVal;
        }
        else if (thirdVal == fourthVal) {
            // 0,0,0,0,1,2 where 0 was meant
            value = fourthVal;
        }
    }
    
    return value;
}

- (void)dealloc
{
    [_lastSixValues release];
    [super dealloc];
}


@end
