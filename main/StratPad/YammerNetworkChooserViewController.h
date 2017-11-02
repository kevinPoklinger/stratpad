//
//  YammerNetworkChooserViewController.h
//  StratPad
//
//  Created by Julian Wood on 12-07-27.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YammerNetwork.h"

@protocol YammerNetworkChooser <NSObject>
@required
-(void)networkChosen:(YammerNetwork*)network;
@end


@interface YammerNetworkChooserViewController : UIViewController<UITableViewDataSource, UITableViewDelegate> {
    NSMutableArray *networks_;
    id<YammerNetworkChooser> yammerNetworkChooser_;
    YammerNetwork *selectedNetwork_;
}

@property (retain, nonatomic) IBOutlet UITableView *tblNetworks;

- (id)initWithYammerNetworkChooser:(id<YammerNetworkChooser>)yammerNetworkChooser andSelectedNetwork:(YammerNetwork*)network;

@end
