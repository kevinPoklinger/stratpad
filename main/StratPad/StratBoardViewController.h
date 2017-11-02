//
//  StratBoardViewController.h
//  StratPad
//
//  Created by Julian Wood on 12-03-08.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReportViewController.h"
#import "MBReportHeaderView.h"
#import "NoRowsTableDataSource.h"
#import "AddChartViewController.h"
#import "MetricChooserViewController.h"
#import "MonthYearHeaderView.h"
#import "MeasurementViewController.h"
#import "YouTubeView.h"
#import "StoreManager.h"

// technically we're not a report - it's a combination of forms and reports, so don't use ReportViewController
@interface StratBoardViewController : ContentViewController<UITableViewDataSource,UITableViewDelegate,MetricChooser,StoreManagerDelegate,UIWebViewDelegate> {
@private    
    // NSNumber (representing the ObjectiveType.category) -> NSArray (of Chart, in proper order)
    NSMutableDictionary *chartDict_;
    
    // instructions for when there are no charts
    NoRowsTableDataSource *noRowsTableDataSource_;

    // VC which is shown in a popover when Add button is pressed - shows metrics
    AddChartViewController *addChartVC_;
    
    // VC which is shown when tapping Measurements button - allows data entry
    MeasurementViewController *measurementVC_;
    
    // for buying StratBoard
    StoreManager *storeManager_;
    UIActivityIndicatorView *purchaseIndicator_;
    NSString *btnTitle_;

}


@end
