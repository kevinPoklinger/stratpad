//
//  StratFilesTableViewCell.m
//  StratPad
//
//  Created by Julian Wood on 11-08-12.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "StratFilesTableViewCell.h"
#import "UIColor-Expanded.h"
#import <QuartzCore/QuartzCore.h>

@implementation StratFilesTableViewCell

@synthesize name = lblName_;
@synthesize company = lblCompany_;
@synthesize dateLastAccessed = lblDateLastAccessed_;
@synthesize lblUnreadComments = lblUnreadComments_;

-(void)awakeFromNib
{
    // right-align and resize the label as needed
    CGSize pSize = self.lblUnreadComments.preferredSize;
    CGRect f = self.lblUnreadComments.frame;
    self.lblUnreadComments.frame = CGRectMake(CGRectGetMaxX(f)-pSize.width, f.origin.y, pSize.width, pSize.height);
}

- (void)dealloc
{
    [lblName_ release];
    [lblCompany_ release];
    [lblDateLastAccessed_ release];
    [lblUnreadComments_ release];
    [super dealloc];
}

@end
