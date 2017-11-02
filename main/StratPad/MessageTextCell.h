//
//  TextCell.h
//  StratPad
//
//  Created by Julian Wood on 12-01-09.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageTextCell : UITableViewCell
@property (retain, nonatomic) IBOutlet UILabel *lblText;
@property (retain, nonatomic) IBOutlet UIButton *btnRestorePurchases;

@end
