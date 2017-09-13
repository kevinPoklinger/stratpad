//
//  MiniChartView.h
//  StratPad
//
//  Created by Julian Wood on 12-03-14.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChartView.h"

@interface MiniChartView : ChartView {
}

@property (nonatomic,assign) Chart *chart;

// the date at which we should start plotting
// used for the plot itself, as well as the monthYearHeader
+ (NSDate*)startDate;

@end
