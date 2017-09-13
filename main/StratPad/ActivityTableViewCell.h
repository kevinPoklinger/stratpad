//
//  ActivityTableViewCell.h
//  StratPad
//
//  Created by Eric on 11-08-19.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "MBRoundedTableViewCell.h"

@interface ActivityTableViewCell : MBRoundedTableViewCell {
 @private
    UILabel *lblAction_;
    UILabel *lblResponsible_;
    UILabel *lblDateRange_;
    UILabel *lblUpfrontCost_;
    UILabel *lblOngoingCost_;
}

@property(nonatomic, retain) IBOutlet UILabel *lblAction;
@property(nonatomic, retain) IBOutlet UILabel *lblResponsible;
@property(nonatomic, retain) IBOutlet UILabel *lblDateRange;
@property(nonatomic, retain) IBOutlet UILabel *lblUpfrontCost;
@property(nonatomic, retain) IBOutlet UILabel *lblOngoingCost;

@end
