//
//  ChartView.h
//  StratPad
//
//  Created by Julian Wood on 12-03-15.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChartView.h"
#import "AbstractReportDelegate.h"
#import "ReportHelper.h"

@interface MainChartView : ChartView<Drawable> {
@private
    ReportHelper *reportHelper_;
    SkinManager *skinMan_;

    // this is the whole area available for drawing the chart, including chart title, axis titles and grid (but not header)
    // defined by MainChartView frame in nib
    CGRect contentRect_;
    
    // just the grid itself, where we plot the graph
    CGRect gridRect_;
    
    // the difference between contentRect and gridRect
    UIEdgeInsets padding_;
}

- (id)initWithFrame:(CGRect)frame chart:(Chart*)chart;

-(void)expandComment:(UIGestureRecognizer *)gestureRecognizer;
-(void)closeAllComments;

@property (nonatomic,retain) Chart *chart;


// help out with ReportCard
@property (nonatomic,assign) CGRect rect;
@property (nonatomic,assign) UIEdgeInsets padding;
@property (nonatomic,assign) BOOL readyForPrint;

@end
