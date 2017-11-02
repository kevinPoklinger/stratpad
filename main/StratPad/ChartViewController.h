//
//  ChartViewController.h
//  StratPad
//
//  Created by Julian Wood on 12-03-12.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContentViewController.h"
#import "Chart.h"
#import "MBGradientView.h"
#import "MainChartView.h"
#import "ChartOptionsViewController.h"
#import "MeasurementViewController.h"

@interface ChartViewController : ContentViewController<RedrawableChart> {
    NSUInteger pageNumber_;
    MeasurementViewController *measurementVC_;
}

@property (nonatomic,retain) Chart* chart;
@property (retain, nonatomic) IBOutlet MBGradientView *viewHeader;
@property (retain, nonatomic) IBOutlet UILabel *lblThemeObjective;
@property (retain, nonatomic) IBOutlet UIButton *btnOptions;
@property (retain, nonatomic) IBOutlet UIButton *btnMeasurements;
@property (retain, nonatomic) IBOutlet MainChartView *viewChart;

// the key here to remember is that this is a 0-based local index within the chapter
// the stratboard is at index 0 while the first chart is at index 1
- (id)initWithChart:(Chart*)chart andPageNumber:(NSUInteger)pageNumber;

- (IBAction)showOptions;
- (IBAction)showMeasurements;

@end
