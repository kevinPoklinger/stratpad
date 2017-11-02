//
//  YammerMessageCell.m
//  StratPad
//
//  Created by Julian Wood on 12-10-01.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "YammerMessageCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation YammerMessageCell

@synthesize imgSenderPhoto;
@synthesize lblSender;
@synthesize btnLike;
@synthesize lblCreationDate;
@synthesize lblCommentText;

- (void)awakeFromNib
{
    // pretty up the image
    self.imgSenderPhoto.layer.cornerRadius = 5.0;
    self.imgSenderPhoto.layer.masksToBounds = YES;
    self.imgSenderPhoto.layer.borderColor = [UIColor lightGrayColor].CGColor;
    //    self.imgSenderPhoto.layer.borderWidth = 1.0;
}

- (void)dealloc {
    [imgSenderPhoto release];
    [lblSender release];
    [btnLike release];
    [lblCreationDate release];
    [lblCommentText release];
    [super dealloc];
}

@end
