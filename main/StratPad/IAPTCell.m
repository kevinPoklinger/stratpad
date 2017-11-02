//
//  IAPTCell.m
//  StratPad
//
//  Created by Kevin on 8/9/17.
//  Copyright © 2017 Glassey Strategy. All rights reserved.
//

#import "IAPTCell.h"
#import "UIColor-Expanded.h"

@implementation IAPTCell

@synthesize targetOne;
@synthesize targetTwo;
@synthesize productOne;
@synthesize productTwo;
@synthesize lblTitleOne;
@synthesize lblTitleTwo;
@synthesize lblDescriptionOne;
@synthesize lblDescriptionTwo;
@synthesize btnPurchaseOne;
@synthesize btnPurchaseTwo;
@synthesize lblPurchased;
@synthesize lblPurchasedTwo;


- (void)awakeFromNib {
    lblPurchased.text = LocalizedString(@"IAP_PURCHASED", nil);
    lblPurchasedTwo.text = LocalizedString(@"IAP_PURCHASED", nil);
    
    UIImage *btnGrey1 = [[UIImage imageNamed:@"button-grey.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:0];
    [btnPurchaseOne setBackgroundImage:btnGrey1 forState:UIControlStateNormal];
    [btnPurchaseOne setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnPurchaseOne setTitleShadowColor:[[UIColor colorWithHexString:@"7F7F7F"] colorWithAlphaComponent:0.3] forState:UIControlStateNormal];
    [btnPurchaseOne.titleLabel setFont:[UIFont boldSystemFontOfSize:15.f]];
    [btnPurchaseOne.titleLabel setShadowOffset:CGSizeMake(0, -1)];
    
    UIImage *btnGrey2 = [[UIImage imageNamed:@"button-grey.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:0];
    [btnPurchaseTwo setBackgroundImage:btnGrey2 forState:UIControlStateNormal];
    [btnPurchaseTwo setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnPurchaseTwo setTitleShadowColor:[[UIColor colorWithHexString:@"7F7F7F"] colorWithAlphaComponent:0.3] forState:UIControlStateNormal];
    [btnPurchaseTwo.titleLabel setFont:[UIFont boldSystemFontOfSize:15.f]];
    [btnPurchaseTwo.titleLabel setShadowOffset:CGSizeMake(0, -1)];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)purchaseOne:(id)sender {
    [targetOne performSelector:@selector(purchaseUpgrade:) withObject:productOne];
}

- (IBAction)purchaseTwo:(id)sender {
    [targetTwo performSelector:@selector(purchaseUpgrade:) withObject:productTwo];
}

- (void)dealloc {
    [lblTitleOne release];
    [lblDescriptionOne release];
    [btnPurchaseOne release];
    [lblPurchased release];
    [lblTitleTwo release];
    [lblDescriptionTwo release];
    [btnPurchaseTwo release];
    [lblPurchasedTwo release];
    [super dealloc];
}
@end
