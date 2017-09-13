//
//  ChartOptionsViewController.h
//  StratPad
//
//  Created by Julian Wood on 12-03-29.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Chart.h"
#import "ColorChooserViewController.h"
#import "ChartTypeViewController.h"
#import "ChartOptionsCellBuilder.h"
#import "OverlayOptionsViewController.h"
#import "TitleViewController.h"
#import "ChartMaxValueViewController.h"

@protocol RedrawableChart <NSObject>
-(void)redrawChart;
@end

@interface ChartOptionsViewController : UIViewController<
    UIPopoverControllerDelegate,UITableViewDataSource,UITableViewDelegate,UINavigationControllerDelegate,
    ChartTypeChooser,OverlayChooser,TitleChooser,ColorChooser,ChartMaxValueChooser> {
@private
    UIPopoverController *popoverController_;
    NSArray *options_;
    Chart *chart_;
    id<RedrawableChart> redrawableChart_;
    ChartOptionsCellBuilder *cellBuilder_;
    BOOL doResize_;
}
@property (retain, nonatomic) IBOutlet UITableView *tblOptions;

- (id)initWithChart:(Chart*)chart andRedrawableChart:(id<RedrawableChart>)redrawableChart;

- (void)showPopoverInView:(UIView*)view fromRect:(CGRect)rect;
- (void)dismissPopover;


@end
