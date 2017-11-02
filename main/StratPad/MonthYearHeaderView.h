//
//  MonthYearHeaderView.h
//  StratPad
//
//  Created by Julian Wood on 12-04-20.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//
//  This is the header we see on the StratBoardViewController, showing all the months
//  We always just draw the last 2 years of the chart which extends the farthest in time

#import <UIKit/UIKit.h>

@interface MonthYearHeaderView : UIView {
    @private
    NSDate *startDate_;
}

@end
