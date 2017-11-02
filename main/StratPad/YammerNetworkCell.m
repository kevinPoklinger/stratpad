//
//  YammerNetworkCell.m
//  StratPad
//
//  Created by Julian Wood on 12-07-27.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "YammerNetworkCell.h"

@implementation YammerNetworkCell

@synthesize network;

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

@end
