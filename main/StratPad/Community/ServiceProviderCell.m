//
//  ServiceProviderCell.m
//  StratPad
//
//  Created by Julian Wood on 2013-04-01.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//

#import "ServiceProviderCell.h"

@implementation ServiceProviderCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
    [_imageViewGuruScore release];
    [_lblCompanyName release];
    [_lblDescription release];
    [_imageViewCompanyLogo release];
    [_lblReviews release];
    [_lblGuruScore release];
    [super dealloc];
}
@end
