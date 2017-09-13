//
//  UserNotificationDisplayManager.m
//  StratPad
//
//  Created by Julian Wood on 12-08-19.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//
//  We need a message which we can cancel at any time, either programmatically or by user, whether or not it was set to autohide or not
//  We have a problem where we dismiss a message, but a new one is scheduled to display before that message has finished dismissing
//  We need messages which disappear after preset amount of time
//  Never put messages on top of one another (only display one at a time).

// example
// 0s: showMessage for 4s
// 12s: showMessage for 4s
// 13s: dismiss (ie. cancel the above message)
// 13s: showMessage (ie. wait until dismiss finishes and then show)
// 20s: showMessage (ie. dismiss above message, wait til finished, then show)
// 25s: dismiss 

#import "UserNotificationDisplayManager.h"
#import "SynthesizeSingleton.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor-Expanded.h"
#import "RootViewController.h"
#import "UserNotification.h"
#import "UserNotificationDismissal.h"
#import "UIView+ObjectTagAdditions.h"

#define tagForMessageView   999
#define tagForMessageLabel  998

@interface UserNotificationDisplayManager ()
@end

@implementation UserNotificationDisplayManager

SYNTHESIZE_SINGLETON_FOR_CLASS(UserNotificationDisplayManager);

- (id)init
{
    self = [super init];
    if (self) {
        self.queue = [NSMutableArray array];
    }
    return self;
}

-(void)performNextAction
{
    RootViewController *rootViewController = (RootViewController*)[[[UIApplication sharedApplication] keyWindow] rootViewController];
    UIView *msgView = [rootViewController.view viewWithTag:tagForMessageView];
    BOOL isShowing = (msgView != nil);
    BOOL isError = ([msgView.objectTag isEqualToString:@"error"]);
    
    if (_queue.count) {
        // we have something to do
    
        UserNotification *un = [_queue objectAtIndex:0];
        if ([un isKindOfClass:[UserNotificationDismissal class]]) {
            
            if (isShowing) {
                // cancel any previous animations - this will invoke the fadeout in the completion, which also removes msg and invokes next action
                [_queue removeObjectAtIndex:0];
                [msgView.layer removeAllAnimations];
                return;

            }
            else {
                // msg is already gone - just invoke the next item on the queue
                [_queue removeObjectAtIndex:0];
                [self performNextAction];
                return;
                
            }
        }
        
        else if ([un isKindOfClass:[UserNotification class]]) {
            
            if (isShowing) {
                
                // only dismiss the error message automatically if we have another message to show
                if (isError) {
                    [UIView animateWithDuration:0.3
                                     animations:^{
                                         msgView.alpha = 0;
                                     }
                                     completion:^(BOOL finished) {
                                         [msgView removeFromSuperview];
                                         [self performNextAction];
                                     }];
                }
                else {
                    // cancel any previous animations - this will invoke the fadeout in the completion, which also removes msg and invokes next action
                    [msgView.layer removeAllAnimations];
                    
                }
                
                // leave this item on the queue so that it can be shown
                return;

            }
            else {
                
                // show the new one
                UIFont *font = [UIFont boldSystemFontOfSize:14];
                UIEdgeInsets insets = UIEdgeInsetsMake(5, 10, 5, 10);
                CGFloat msgViewWidth = 878;
                
                CGFloat maxLabelWidth = msgViewWidth-insets.left-insets.right;
                
                UIView *msgView = [[UIView alloc] initWithFrame:CGRectMake(134, 730, msgViewWidth, 30)];
                msgView.backgroundColor = un.color;
                msgView.opaque = NO;
                msgView.layer.borderColor = [[UIColor colorWithHexString:@"939393"] CGColor];
                msgView.layer.borderWidth = 1.0;
                msgView.layer.cornerRadius = 3;
                msgView.layer.masksToBounds = YES;
                msgView.tag = tagForMessageView;
                
                UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(insets.left, insets.top, maxLabelWidth, 20)];
                lbl.textColor = [UIColor colorWithHexString:@"DDDDDD"];
                lbl.text = un.message;
                lbl.lineBreakMode = UILineBreakModeMiddleTruncation;
                lbl.font = font;
                lbl.backgroundColor = [UIColor clearColor];
                lbl.tag = tagForMessageLabel;
                [msgView addSubview:lbl];
                [lbl release];
                
                RootViewController *rootViewController = (RootViewController*)[[[UIApplication sharedApplication] keyWindow] rootViewController];
                [rootViewController.view addSubview:msgView];
                                                
                msgView.alpha = 0;
                // fade in msg
                [_queue removeObjectAtIndex:0];
                [UIView animateWithDuration:0.3
                                      delay:un.delay
                                    options:UIViewAnimationOptionCurveEaseInOut
                                 animations:^{
                                     msgView.alpha = 1;
                                 }
                                 completion:^(BOOL finished) {
                                     // fade out after a delay
                                     DLog(@"Completed fadein. Finished: %i", finished);
                                     [UIView animateWithDuration:0.3
                                                           delay:4
                                                         options:UIViewAnimationOptionCurveEaseInOut
                                                      animations:^{
                                                          msgView.alpha = 0;
                                                      }
                                                      completion:^(BOOL finished) {
                                                          // the key issue here is that this is called regardless of whether you cancel or not
                                                          // 'finished'  lets you know which
                                                          DLog(@"Completing timed show and thus removing message. Finished: %i", finished);
                                                          if (!finished) {
                                                              DLog(@"Fading out prematurely");
                                                              // if you reset the animatable properties, you can get the animation to work properly again (but it causes other issues)
//                                                              msgView.alpha = 1.0;
                                                              [UIView animateWithDuration:0.3
                                                                               animations:^{
                                                                                   msgView.alpha = 0;
                                                                               }
                                                                               completion:^(BOOL finished) {
                                                                                   // no matter what happens here, just get rid of the message
                                                                                   DLog(@"Finished fade out. Removing.")
                                                                                   [msgView removeFromSuperview];
                                                                                   [self performNextAction];
                                                                               }
                                                               ];
                                                          }
                                                          else {
                                                              DLog(@"Finished fade out.");
                                                              [msgView removeFromSuperview];
                                                              [self performNextAction];
                                                          }
                                                      }];
                                 }];

            }            
            
        }

    }
    
}

-(void)showMessageAfterDelay:(NSTimeInterval)delay color:(UIColor*)color autoDismiss:(BOOL)autoDismiss message:(NSString*)message, ...
{
    va_list args;
    va_start(args, message);
    NSString *msg = [[[NSString alloc] initWithFormat:message arguments:args] autorelease];
    va_end(args);
    
    UserNotification *un = [[UserNotification alloc] init];
    un.delay = delay;
    un.color = color;
    un.autoDismiss = autoDismiss;
    un.message = msg;
    [_queue addObject:un];
    [un release];
    
    [self performNextAction];
}

-(void)showMessageAfterDelay:(NSTimeInterval)delay color:(UIColor*)color message:(NSString*)message, ...
{
    va_list args;
    va_start(args, message);
    NSString *msg = [[[NSString alloc] initWithFormat:message arguments:args] autorelease];
    va_end(args);
        
    [self showMessageAfterDelay:0
                          color:color
                     autoDismiss:YES
                        message:msg];
}

-(void)showMessageAfterDelay:(NSTimeInterval)delay message:(NSString*)message, ...
{
    va_list args;
    va_start(args, message);
    NSString *msg = [[[NSString alloc] initWithFormat:message arguments:args] autorelease];
    va_end(args);
    
    // green color
    UIColor *color = [[UIColor colorWithHexString:@"4cac48"] colorWithAlphaComponent:0.8];
    
    [self showMessageAfterDelay:0 color:color message:msg];
}


-(void)showMessage:(NSString*)message, ...
{
    va_list args;
    va_start(args, message);
    NSString *msg = [[[NSString alloc] initWithFormat:message arguments:args] autorelease];
    va_end(args);

    [self showMessageAfterDelay:0 message:msg];
}

-(void)showErrorMessage:(NSString*)message, ...
{
    va_list args;
    va_start(args, message);
    NSString *msg = [[[NSString alloc] initWithFormat:message arguments:args] autorelease];
    va_end(args);
    
    RootViewController *rootViewController = (RootViewController*)[[[UIApplication sharedApplication] keyWindow] rootViewController];
    UIView *msgView = [rootViewController.view viewWithTag:tagForMessageView];
    BOOL isShowing = (msgView != nil);
    
    if (isShowing) {
        [UIView animateWithDuration:0.3
                         animations:^{
                             msgView.alpha = 0;
                         }
                         completion:^(BOOL finished) {
                             [msgView removeFromSuperview];
                             [self showErrorMessage:msg];
                         }];
    }
    else {
        UIFont *font = [UIFont boldSystemFontOfSize:14];
        UIEdgeInsets insets = UIEdgeInsetsMake(5, 10, 5, 10);
        CGFloat msgViewWidth = 878;
        CGFloat btnWidth = 20;
        
        CGFloat maxLabelWidth = msgViewWidth-insets.left-insets.right-btnWidth-5;
        
        UIView *msgView = [[UIView alloc] initWithFrame:CGRectMake(134, 730, msgViewWidth, 30)];
        msgView.backgroundColor = [[UIColor colorWithHexString:@"ab2c2d"] colorWithAlphaComponent:0.85];
        msgView.opaque = NO;
        msgView.layer.borderColor = [[UIColor colorWithHexString:@"939393"] CGColor];
        msgView.layer.borderWidth = 1.0;
        msgView.layer.cornerRadius = 3;
        msgView.layer.masksToBounds = YES;
        msgView.tag = tagForMessageView;
        msgView.objectTag = @"error";
        
        UIImage *imgClose = [UIImage imageNamed:@"close.png"];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:imgClose forState:UIControlStateNormal];
        btn.frame = CGRectMake(msgViewWidth-insets.right-imgClose.size.width, (msgView.bounds.size.height-imgClose.size.height)/2,
                               imgClose.size.width, imgClose.size.height);
        [btn addTarget:self action:@selector(dismissErrorMessage) forControlEvents:UIControlEventTouchUpInside];
        [msgView addSubview:btn];
        
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(insets.left, insets.top, maxLabelWidth, 20)];
        lbl.textColor = [UIColor colorWithHexString:@"DDDDDD"];
        lbl.text = msg;
        lbl.lineBreakMode = UILineBreakModeMiddleTruncation;
        lbl.font = font;
        lbl.backgroundColor = [UIColor clearColor];
        lbl.tag = tagForMessageLabel;
        [msgView addSubview:lbl];
        [lbl release];
        
        [rootViewController.view addSubview:msgView];
        
        msgView.alpha = 0;
        [UIView animateWithDuration:0.3
                         animations:^{
                             msgView.alpha = 1;
                         }
                         completion:nil];
    }
}

-(void)updateMessage:(NSString*)message
{
    // update the top most message
    RootViewController *rootViewController = (RootViewController*)[[[UIApplication sharedApplication] keyWindow] rootViewController];
    UILabel *lbl = (UILabel*)[rootViewController.view viewWithTag:tagForMessageLabel];
    lbl.text = message;
}

-(void)dismiss
{
    // this will not dismiss the error message
    UserNotificationDismissal *dismissal = [[UserNotificationDismissal alloc] init];
    [_queue addObject:dismissal];
    [dismissal release];
    
    [self performNextAction];
}

#pragma mark- Private

-(void)dismissErrorMessage
{
    // handler for the close button in the error message
    RootViewController *rootViewController = (RootViewController*)[[[UIApplication sharedApplication] keyWindow] rootViewController];
    UIView *msgView = [rootViewController.view viewWithTag:tagForMessageView];
    [UIView animateWithDuration:0.3
                     animations:^{
                         msgView.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         [msgView removeFromSuperview];
                     }];
}

@end
