//
//  ChartCell.m
//  StratPad
//
//  Created by Julian Wood on 12-03-13.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "ChartCell.h"

@implementation ChartCell
@synthesize lblChartTitle;
@synthesize lblThemeName;
@synthesize lblObjectiveName;
@synthesize miniChartView;
@synthesize lblFirstValue;
@synthesize lblMostRecent;
@synthesize lblOnTarget;
@synthesize lblUnreadMessageCount;

-(void)awakeFromNib
{
    // right-align and resize the label as needed
    CGSize pSize = self.lblUnreadMessageCount.preferredSize;
    CGRect f = self.lblUnreadMessageCount.frame;
    self.lblUnreadMessageCount.frame = CGRectMake(CGRectGetMaxX(f)-pSize.width, f.origin.y, pSize.width, pSize.height);
}

- (void)dealloc {
    [lblChartTitle release];
    [lblThemeName release];
    [lblObjectiveName release];
    [lblFirstValue release];
    [lblMostRecent release];
    [lblOnTarget release];
    [miniChartView release];
    [lblUnreadMessageCount release];
    [super dealloc];
}
@end
