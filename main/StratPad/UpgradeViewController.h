//
//  UpgradeViewController.h
//  StratPad
//
//  Created by Julian Wood on 11-12-06.
//  Copyright (c) 2011 Glassey Strategy. All rights reserved.
//
//  Test User @itunes connect: sally@glasseystrategy.com / S@llie3!
//  martina@mobilesce.com / M@rtina1
//  jan9@mob.com/J@nuary9
//  may31@mobilesce.com/May312012!
//  june26@mob.com/June262012!
//  j27@m.ca/June272012!
//  july3@mob.ca/July32012!
//  nov20@mob.com/Nov202012!   - russia
//  aug30@mob.com/Aug302012!   - spain
//
//  This is the Extras menu.

#import <UIKit/UIKit.h>
#import "StoreManager.h"
#import "EditionManager.h"
#import "MBLoadingView.h"

@interface UpgradeViewController : UIViewController<StoreManagerDelegate,UITableViewDataSource,UITableViewDelegate>
{
    StoreManager *storeManager_;
    MBLoadingView *loadingView_;

    // array of SKProduct
    NSMutableArray *rows_;
    
}
@property (retain, nonatomic) IBOutlet UITableView *tblInAppPurchases;

-(void) playBoardVideo;

@end
