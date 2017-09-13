//
//  AddChartViewController.h
//  StratPad
//
//  Created by Julian Wood on 12-04-12.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MetricChooserViewController.h"

@interface AddChartViewController : UIViewController<UINavigationControllerDelegate,UIPopoverControllerDelegate> {
    @private
    UIPopoverController *popoverController_;
}

- (void)showPopoverfromBarButtonItem:(UIBarButtonItem*)barButtonItem withMetricChooser:(id<MetricChooser>)metricChooser;
- (void)dismissPopover;

@end
