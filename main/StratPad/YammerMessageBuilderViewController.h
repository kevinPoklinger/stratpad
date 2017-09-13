//
//  YammerMessageBuilderViewController.h
//  StratPad
//
//  Created by Julian Wood on 12-07-10.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIFormDataRequest.h"
#import <QuartzCore/QuartzCore.h>
#import "YammerGroupChooserViewController.h"
#import "YammerTopicChooserViewController.h"
#import "YammerNetworkChooserViewController.h"
#import "YammerMessageViewController.h"
#import "YammerUser.h"
#import "YammerNetwork.h"
#import "YammerGroup.h"
#import "StratFile.h"
#import "Chapter.h"

typedef enum {
    YammerLoadStateLoading,
    YammerLoadStateSuccess,
    YammerLoadStateError
} YammerLoadState;

@interface YammerMessage : NSObject
@property (nonatomic,retain) YammerGroup *group;
@property (nonatomic, retain) NSString *message;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) YammerUser *user;
@property (nonatomic, retain) YammerNetwork *network;
@property (nonatomic, assign) YammerLoadState networkState;
@property (nonatomic, assign) YammerLoadState groupState;
@property (nonatomic, assign) YammerLoadState userState;
@property (nonatomic, copy) NSString *userLoadError;
@property (nonatomic, copy) NSString *networkLoadError;
@property (nonatomic, copy) NSString *groupLoadError;
@property (nonatomic, retain) StratFile *stratFile;
@property (nonatomic, retain) Chapter *chapter;
@property (nonatomic, assign) NSInteger pageNumber;
@end

@interface YammerMessageBuilderViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,YammerGroupChooser,YammerNetworkChooser> {
@private
    // used for posting to yammer
    ASIFormDataRequest *request_;
    
    // we've already generated the file for posting
    NSString *path_;
    
    // used for the body
    NSString *reportName_;
    
    // message params
    NSArray *messageAttributes_;
    
    // gives the table a nice fade out
    CAGradientLayer *maskLayer_;
    
    // container for the table cell data
    YammerMessage *yammerMessage_;
}

- (id)initWithPath:(NSString*)path
        reportName:(NSString*)reportName;


@end
