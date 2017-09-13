//
//  ChartTypeViewController.h
//  StratPad
//
//  Created by Julian Wood on 12-04-02.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Chart.h"

@protocol ChartTypeChooser <NSObject>
- (void)chartTypeSelected;
@end

@interface ChartTypeViewController : UIViewController<UITableViewDataSource,UITableViewDelegate> {
    @private
    Chart *chart_;
    id<ChartTypeChooser> chartTypeChooser_;
    NSArray *chartTypes_;
}
@property (retain, nonatomic) IBOutlet UITableView *tblChartTypes;

- (id)initWithChart:(Chart*)chart andChartTypeChooser:(id<ChartTypeChooser>)chartTypeChooser;

@end