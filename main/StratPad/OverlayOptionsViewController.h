//
//  OverlayOptionsViewController.h
//  StratPad
//
//  Created by Julian Wood on 12-04-03.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Chart.h"
#import "ChartOptionsCellBuilder.h"
#import "ColorChooserViewController.h"
#import "ChartTypeViewController.h"
#import "MetricChooserViewController.h"
#import "ChartMaxValueViewController.h"

@protocol OverlayChooser <NSObject>
-(void)overlayUpdated;
@end

@interface OverlayOptionsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,
    ColorChooser,ChartTypeChooser,MetricChooser,ChartMaxValueChooser> {
        
@private
    
    // primary parent chart
    Chart *chart_;
        
    // the overlay chart on which we're working
    Chart *chartOverlay_;
    
    // backs the table
    NSArray *options_;
    
    // shared building of cells
    ChartOptionsCellBuilder *cellBuilder_;
    
    // object to notify when an overlay has been chosen
    id<OverlayChooser> overlayChooser_;
}

// note this is the parent chart, not the overlay chart
- (id)initWithChart:(Chart*)chart andOverlayChooser:(id<OverlayChooser>)overlayChooser;

@property (retain, nonatomic) IBOutlet UITableView *tblOverlayOptions;

@end
