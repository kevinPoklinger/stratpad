//
//  IAPTCell.h
//  StratPad
//
//  Created by Kevin on 8/9/17.
//  Copyright © 2017 Glassey Strategy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

@interface IAPTCell : UITableViewCell

@property (assign, nonatomic) id targetOne;
@property (retain, nonatomic) SKProduct *productOne;
@property (assign, nonatomic) id targetTwo;
@property (retain, nonatomic) SKProduct *productTwo;

@property (retain, nonatomic) IBOutlet UILabel *lblTitleOne;
@property (retain, nonatomic) IBOutlet UILabel *lblDescriptionOne;
@property (retain, nonatomic) IBOutlet UIButton *btnPurchaseOne;
@property (retain, nonatomic) IBOutlet UILabel *lblPurchased;

@property (retain, nonatomic) IBOutlet UILabel *lblTitleTwo;
@property (retain, nonatomic) IBOutlet UILabel *lblDescriptionTwo;
@property (retain, nonatomic) IBOutlet UIButton *btnPurchaseTwo;
@property (retain, nonatomic) IBOutlet UILabel *lblPurchasedTwo;


@end
