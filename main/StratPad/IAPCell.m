//
//  IAPCell.m
//  StratPad
//
//  Created by Julian Wood on 12-01-03.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "IAPCell.h"
#import "UIColor-Expanded.h"

@implementation IAPCell
@synthesize target;
@synthesize product;
@synthesize lblTitle;
@synthesize lblDescription;
@synthesize btnPurchase;
@synthesize lblPurchased;

-(void)awakeFromNib
{
    lblPurchased.text = LocalizedString(@"IAP_PURCHASED", nil);

    UIImage *btnGrey = [[UIImage imageNamed:@"button-grey.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:0];
    [btnPurchase setBackgroundImage:btnGrey forState:UIControlStateNormal];
    [btnPurchase setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnPurchase setTitleShadowColor:[[UIColor colorWithHexString:@"7F7F7F"] colorWithAlphaComponent:0.3] forState:UIControlStateNormal];
    [btnPurchase.titleLabel setFont:[UIFont boldSystemFontOfSize:15.f]];
    [btnPurchase.titleLabel setShadowOffset:CGSizeMake(0, -1)];    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
    [product release];
    [lblTitle release];
    [lblDescription release];
    [btnPurchase release];
    [lblPurchased release];
    [super dealloc];
}

- (IBAction)purchaseUpgrade {
    [target performSelector:@selector(purchaseUpgrade:) withObject:product];
}

@end
