//
//  ThemeTableViewCell.h
//  StratPad
//
//  Created by Eric on 11-08-05.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "MBRoundedTableViewCell.h"

@interface ThemeTableViewCell : MBRoundedTableViewCell {
 @private
    UILabel *lblTitle_;
    UILabel *lblMandatory_;
    UILabel *lblEnhanceUniqueness_;
    UILabel *lblEnhanceCustomerValue_;
}

@property (nonatomic, retain) IBOutlet UILabel *lblTitle;
@property (nonatomic, retain) IBOutlet UILabel *lblMandatory;
@property (nonatomic, retain) IBOutlet UILabel *lblEnhanceUniqueness;
@property (nonatomic, retain) IBOutlet UILabel *lblEnhanceCustomerValue;

@end
