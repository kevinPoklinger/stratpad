//
//  RegisterWelcomeViewController.h
//  StratPad
//
//  Created by Julian Wood on 2012-10-18.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//
//  The second view of the registration welcome sequence - can choose language.

#import "LMViewController.h"

@interface RegisterWelcomeViewController : LMViewController<UITableViewDataSource,UITableViewDelegate, UIPopoverControllerDelegate> 

- (void)showPopoverInView:(UIView*)view;
- (void)dismissPopover;


@end
