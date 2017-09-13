//
//  IAPCell.h
//  StratPad
//
//  Created by Julian Wood on 12-01-03.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

@interface IAPCell : UITableViewCell

@property (assign, nonatomic) id target;
@property (retain, nonatomic) SKProduct *product;
@property (retain, nonatomic) IBOutlet UILabel *lblTitle;
@property (retain, nonatomic) IBOutlet UILabel *lblDescription;
@property (retain, nonatomic) IBOutlet UIButton *btnPurchase;
@property (retain, nonatomic) IBOutlet UILabel *lblPurchased;

- (IBAction)purchaseUpgrade;

@end
