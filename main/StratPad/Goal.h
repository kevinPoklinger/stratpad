//
//  Goal.h
//  StratPad
//
//  Created by Eric Rogers on September 24, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//
//  Represents a goal for the "Reach These Goals" chart in 
//  the Business Plan Report.


@protocol Goal <NSObject>

- (NSString*)metric;

- (NSDate*)date;

@end
