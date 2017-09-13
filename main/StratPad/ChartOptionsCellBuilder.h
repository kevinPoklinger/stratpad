//
//  ChartOptionsCellBuilder.h
//  StratPad
//
//  Created by Julian Wood on 12-04-03.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Chart.h"
#import "ChartOptionsCell.h"
#import "BooleanTableViewCell.h"
#import "ColorCell.h"
#import "Metric.h"

@interface ChartOptionsCellBuilder : NSObject {
    @private
    Chart *chart_;
    UITableView *tblOptions_;
}

- (id)initWithChart:(Chart*)chart andTableView:(UITableView*)tableView;

- (ChartOptionsCell*)cellForTitle;
- (ChartOptionsCell*)cellForMetric;
- (ChartOptionsCell*)cellForChartType;
- (ChartOptionsCell*)cellForChartMaxValue;
- (ColorCell*)cellForColor;
- (UITableViewCell*)cellForOverlay;
- (BooleanTableViewCell*)booleanCellWithTitle:(NSString*)title
                                      binding:(NSString*)binding
                                       onText:(NSString*)onText
                                      offText:(NSString*)offText
                                       target:(id)target
                                       action:(SEL)action;
@end
