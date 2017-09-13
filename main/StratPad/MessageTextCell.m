//
//  TextCell.m
//  StratPad
//
//  Created by Julian Wood on 12-01-09.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "MessageTextCell.h"
#import "UIColor-Expanded.h"

@implementation MessageTextCell

@synthesize lblText, btnRestorePurchases;

- (void)awakeFromNib
{
    UIImage *btnGrey = [[UIImage imageNamed:@"button-grey.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:0];
    [btnRestorePurchases setBackgroundImage:btnGrey forState:UIControlStateNormal];
    [btnRestorePurchases setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnRestorePurchases setTitleShadowColor:[[UIColor colorWithHexString:@"7F7F7F"] colorWithAlphaComponent:0.3] forState:UIControlStateNormal];
    [btnRestorePurchases.titleLabel setFont:[UIFont boldSystemFontOfSize:15.f]];
    [btnRestorePurchases.titleLabel setShadowOffset:CGSizeMake(0, -1)];    
}

- (void)dealloc
{
    [lblText release];
    [btnRestorePurchases release];
    [super dealloc];
}

@end
