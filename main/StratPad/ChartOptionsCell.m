//
//  ChartOptionsCell.m
//  StratPad
//
//  Created by Julian Wood on 12-03-30.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "ChartOptionsCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation ChartOptionsCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // pretty up the image
        self.imageView.layer.cornerRadius = 5.0;
        self.imageView.layer.masksToBounds = YES;
        self.imageView.layer.borderColor = [UIColor blackColor].CGColor;
        self.imageView.layer.borderWidth = 2.0;
    }
    return self;
}


- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.bounds = CGRectMake(0,0,32,32);
}

@end
