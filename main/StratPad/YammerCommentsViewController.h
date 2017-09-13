//
//  YammerCommentsViewController.h
//  StratPad
//
//  Created by Julian Wood on 12-09-28.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YammerPublishedReport.h"

@interface YammerCommentsViewController : UIViewController<UIPopoverControllerDelegate,UITableViewDataSource,UITableViewDelegate,UITextViewDelegate> {
@private
    NSUInteger numLines_;
    NSMutableDictionary *cache_;
    NSLock *cacheLock_;
}
@property (retain, nonatomic) IBOutlet UITableView *tblConversations;

- (id)initWithYammerPublishedReport:(YammerPublishedReport*)yammerReport;
- (void)showPopoverFromControl:(UIControl*)control title:(NSString*)title;

@end
