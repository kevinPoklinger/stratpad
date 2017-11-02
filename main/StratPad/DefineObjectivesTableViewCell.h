//
//  DefineObjectivesTableViewCell.h
//  StratPad
//
//  Created by Eric Rogers on August 17, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "MBRoundedTableViewCell.h"


@interface DefineObjectivesTableViewCell : MBRoundedTableViewCell {
 @private
    UILabel *lblDescription_;
    UILabel *lblMetric_;
    UILabel *lblTargetValue_;
    UILabel *lblTargetDate_;
    UILabel *lblFrequency_;
}

@property(nonatomic, retain) IBOutlet UILabel *lblDescription;
@property(nonatomic, retain) IBOutlet UILabel *lblMetric;
@property(nonatomic, retain) IBOutlet UILabel *lblTargetValue;
@property(nonatomic, retain) IBOutlet UILabel *lblTargetDate;
@property(nonatomic, retain) IBOutlet UILabel *lblFrequency;

@end
