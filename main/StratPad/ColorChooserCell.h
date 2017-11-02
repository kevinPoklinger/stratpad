//
//  ColorChooserCell.h
//  StratPad
//
//  Created by Julian Wood on 12-04-13.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//
//  Shows a colorview on the left, text on the right, and can nicely use an accessory (checkmark) - unlike ColorCell.

#import <UIKit/UIKit.h>
#import "ColorView.h"

@interface ColorChooserCell : UITableViewCell
@property (retain, nonatomic) IBOutlet ColorView *colorView;
@property (retain, nonatomic) IBOutlet UILabel *lblTitle;

@end
