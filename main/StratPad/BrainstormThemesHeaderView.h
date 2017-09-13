//
//  BrainstormThemesHeaderView.h
//  StratPad
//
//  Created by Eric on 11-11-15.
//  Copyright (c) 2011 Glassey Strategy. All rights reserved.
//

#import "MBRoundedRectView.h"

@interface BrainstormThemesHeaderView : MBRoundedRectView {
@private
    UILabel *lblTheme_;
    UILabel *lblMandatory_;
    UILabel *lblEnhanceUniqueness_;
    UILabel *lblEnhanceCustomerValue_;
}

@property(nonatomic, retain) IBOutlet UILabel *lblTheme;
@property(nonatomic, retain) IBOutlet UILabel *lblMandatory;
@property(nonatomic, retain) IBOutlet UILabel *lblEnhanceUniqueness;
@property(nonatomic, retain) IBOutlet UILabel *lblEnhanceCustomerValue;

@end
