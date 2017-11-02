//
//  YammerGroupChooserViewController.h
//  StratPad
//
//  Created by Julian Wood on 12-07-11.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YammerGroup.h"
#import "ASIHTTPRequest.h"

@protocol YammerGroupChooser <NSObject>
@required
-(void)groupChosen:(YammerGroup*)group;
@end

@interface YammerGroupChooserViewController : UIViewController<UITableViewDataSource,UITableViewDelegate> {
    NSMutableArray *groups_;
    id<YammerGroupChooser> yammerGroupChooser_;
    YammerGroup *selectedGroup_;
}

@property (retain, nonatomic) IBOutlet UITableView *tblGroups;

- (id)initWithYammerGroupChooser:(id<YammerGroupChooser>)yammerGroupChooser andSelectedGroup:(YammerGroup*)group;
@end
