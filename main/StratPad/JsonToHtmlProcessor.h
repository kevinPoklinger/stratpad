//
//  JsonToHTMLProcessor.h
//  StratPad
//
//  Created by Julian Wood on 2013-07-02.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RemoteReport.h"

@interface JsonToHtmlProcessor : UIViewController<UIWebViewDelegate>

@property (nonatomic, assign, readonly) BOOL ready;

// using the method and filename from remoteReport, convert json into an html file stored at path
// you must wait until the processor is ready before calling this method (ie use processWhenReady:target:)
-(void)exportToHtmlWithJson:(NSDictionary*)json remoteReport:(id<RemoteReport>)remoteReport path:(NSString*)path;

// target and action (usually containing calls to exportToCsvWithJson:remoteReport:path:) are invoked when the processor is ready
-(void)processWhenReady:(SEL)action target:(id)target;


@end
