//
//  ImportStratFileViewController.h
//  StratPad
//
//  Created by Julian Wood on 2013-06-10.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StratFile.h"
#import "LMViewController.h"

@interface ImportStratFileViewController : LMViewController

- (id)initWithExistingStratFile:(StratFile*)existingStratFile importedStratFile:(StratFile*)importedStratFile;

- (void)showPopoverInView:(UIView*)view;
- (void)dismissPopover;

@end
