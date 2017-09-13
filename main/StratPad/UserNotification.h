//
//  UserNotification.h
//  StratPad
//
//  Created by Julian Wood on 2013-06-25.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserNotification : NSObject

@property (nonatomic,assign) NSTimeInterval delay;
@property (nonatomic,retain) UIColor *color;
@property (nonatomic, assign) BOOL autoDismiss;
@property (nonatomic, retain) NSString *message;

@end
