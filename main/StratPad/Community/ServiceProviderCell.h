//
//  ServiceProviderCell.h
//  StratPad
//
//  Created by Julian Wood on 2013-04-01.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UILabelVAlignment.h"

@interface ServiceProviderCell : UITableViewCell
@property (retain, nonatomic) IBOutlet UIImageView *imageViewGuruScore;
@property (retain, nonatomic) IBOutlet UILabel *lblCompanyName;
@property (retain, nonatomic) IBOutlet UILabelVAlignment *lblDescription;
@property (retain, nonatomic) IBOutlet UIImageView *imageViewCompanyLogo;
@property (retain, nonatomic) IBOutlet UILabel *lblReviews;
@property (retain, nonatomic) IBOutlet UILabel *lblGuruScore;

@end
