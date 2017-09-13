//
//  ObjectiveHeaderTableViewCell.h
//  StratPad
//
//  Created by Eric on 11-11-15.
//  Copyright (c) 2011 Glassey Strategy. All rights reserved.
//

#import "MBRoundedTableViewCell.h"

@interface ObjectiveHeaderTableViewCell : MBRoundedTableViewCell {
@private
    UILabel *lblObjectiveDescription_;
    UILabel *lblMetric_;
    UILabel *lblTargetValue_;
    UILabel *lblTargetDate_;
    UILabel *lblReviewFrequency_;
}

@property(nonatomic, retain) IBOutlet UILabel *lblObjectiveDescription;
@property(nonatomic, retain) IBOutlet UILabel *lblMetric;
@property(nonatomic, retain) IBOutlet UILabel *lblTargetValue;
@property(nonatomic, retain) IBOutlet UILabel *lblTargetDate;
@property(nonatomic, retain) IBOutlet UILabel *lblReviewFrequency;

@end
