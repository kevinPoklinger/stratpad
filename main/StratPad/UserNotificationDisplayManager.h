//
//  UserNotificationDisplayManager.h
//  StratPad
//
//  Created by Julian Wood on 12-08-19.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//
//  Displays a single line of text for a few seconds at the bottom of the StratPad UI, then fades away.
//  Error messages will stay until dismissed.
//  Messages display over top of one another, with relatively high alpha, but not complete opacity.

#import <Foundation/Foundation.h>

@interface UserNotificationDisplayManager : NSObject

@property (nonatomic, retain) NSMutableArray *queue;

// init
+ (UserNotificationDisplayManager *)sharedManager;

-(void)showMessage:(NSString*)message, ...;
-(void)showMessageAfterDelay:(NSTimeInterval)delay message:(NSString*)message, ...;
-(void)showMessageAfterDelay:(NSTimeInterval)delay color:(UIColor*)color message:(NSString*)message, ...;
-(void)showMessageAfterDelay:(NSTimeInterval)delay color:(UIColor*)color autoDismiss:(BOOL)autoDismiss message:(NSString*)message, ...;

-(void)showErrorMessage:(NSString*)message, ...;

-(void)updateMessage:(NSString*)message;

// the top most message
-(void)dismiss;


@end
