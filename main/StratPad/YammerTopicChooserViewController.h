//
//  YammerTopicChooserViewController.h
//  StratPad
//
//  Created by Julian Wood on 12-07-11.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//
//  You can't get a list of topics from Yammer. Doh.
//  We will have to keep our own list of tags, and select from that. Sucks, cause there may be other tags, plus we have to be able to create them on the fly.

#import <UIKit/UIKit.h>
#import "YammerTopic.h"
#import "ASIHTTPRequest.h"

@protocol YammerTopicChooser <NSObject>
@required
-(void)topicChosen:(YammerTopic*)topic;
@end

@interface YammerTopicChooserViewController : UIViewController {
    NSMutableArray *topics_;
    id<YammerTopicChooser> yammerTopicChooser_;
}

- (id)initWithYammerTopicChooser:(id<YammerTopicChooser>)yammerTopicChooser;


@end
