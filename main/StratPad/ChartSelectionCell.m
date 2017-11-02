//
//  ChartSelectionCell.m
//  StratPad
//
//  Created by Julian Wood on 12-06-19.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "ChartSelectionCell.h"

@implementation ChartSelectionCell
@synthesize lblChartTitle;
@synthesize lblChartTheme;
@synthesize lblChartObjective;
@synthesize uuid;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
    [uuid release];
    [lblChartTitle release];
    [lblChartTheme release];
    [lblChartObjective release];
    [super dealloc];
}
@end
