//
//  ChartCell.h
//  StratPad
//
//  Created by Julian Wood on 12-03-13.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MiniChartView.h"
#import "MessageCountLabel.h"

@interface ChartCell : UITableViewCell
@property (retain, nonatomic) IBOutlet UILabel *lblChartTitle;
@property (retain, nonatomic) IBOutlet UILabel *lblThemeName;
@property (retain, nonatomic) IBOutlet UILabel *lblObjectiveName;
@property (retain, nonatomic) IBOutlet MiniChartView *miniChartView;
@property (retain, nonatomic) IBOutlet UILabel *lblFirstValue;
@property (retain, nonatomic) IBOutlet UILabel *lblMostRecent;
@property (retain, nonatomic) IBOutlet UILabel *lblOnTarget;
@property (retain, nonatomic) IBOutlet MessageCountLabel *lblUnreadMessageCount;


@end
