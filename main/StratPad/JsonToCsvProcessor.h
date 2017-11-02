//
//  JsonToCsvProcessor.h
//  StratPad
//
//  Created by Julian Wood on 2013-06-19.
//  Copyright (c) 2013 Julian Wood. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RemoteReport.h"

@interface JsonToCsvProcessor : UIViewController<UIWebViewDelegate>

@property (nonatomic, assign, readonly) BOOL ready;

// using the method and filename from remoteReport, convert json into a csv file stored at path
// you must wait until the processor is ready before calling this method (ie use processWhenReady:target:)
-(void)exportToCsvWithJson:(NSDictionary*)json remoteReport:(id<RemoteReport>)remoteReport path:(NSString*)path;

// target and action (usually containing calls to exportToCsvWithJson:remoteReport:path:) are invoked when the processor is ready
-(void)processWhenReady:(SEL)action target:(id)target;

@end
