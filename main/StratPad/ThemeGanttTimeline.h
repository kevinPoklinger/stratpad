//
//  ThemeGanttTimeline.h
//  StratPad
//
//  Created by Eric on 11-09-22.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "GanttTimeline.h"
#import "Theme.h"

@interface ThemeGanttTimeline : GanttTimeline {
@private
    NSString *title_;
    NSDate *startDate_;
    NSDate *endDate_;
}

@property(nonatomic, readonly) NSString *title;
@property(nonatomic, readonly) NSDate *startDate;
@property(nonatomic, readonly) NSDate *endDate;

- (id)initWithTheme:(Theme *)theme andStrategyStartDate:(NSDate*)strategyStartDate;

@end
