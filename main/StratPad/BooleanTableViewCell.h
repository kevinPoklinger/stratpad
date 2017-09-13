//
//  BooleanTableViewCell.h
//  StratPad
//
//  Created by Julian Wood on 11-08-16.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBBindableRoundSwitch.h"

@interface BooleanTableViewCell : UITableViewCell {
@private
    UILabel *lblName_;
    MBBindableRoundSwitch *switchOption_;
}

@property(nonatomic, retain) IBOutlet UILabel *lblName;
@property(nonatomic, retain) IBOutlet MBBindableRoundSwitch *switchOption;

@end
