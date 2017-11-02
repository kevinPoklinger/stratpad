//
//  ChartSelectionCell.h
//  StratPad
//
//  Created by Julian Wood on 12-06-19.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChartSelectionCell : UITableViewCell
@property (retain, nonatomic) IBOutlet UILabel *lblChartTitle;
@property (retain, nonatomic) IBOutlet UILabel *lblChartTheme;
@property (retain, nonatomic) IBOutlet UILabel *lblChartObjective;
@property (retain, nonatomic) NSString *uuid;

@end
