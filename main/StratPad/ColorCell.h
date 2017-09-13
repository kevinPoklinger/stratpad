//
//  ColorCell.h
//  StratPad
//
//  Created by Julian Wood on 12-04-02.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//
//  Like a UITableViewCellStyleSubtitle except with a colorview on the far right side.

#import <UIKit/UIKit.h>
#import "ColorView.h"

@interface ColorCell : UITableViewCell
@property (retain, nonatomic) IBOutlet UILabel *lblColor;
@property (retain, nonatomic) IBOutlet ColorView *colorView;
@property (retain, nonatomic) IBOutlet UILabel *lblColorScheme;

@end
