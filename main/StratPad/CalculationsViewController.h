//
//  CalculationsViewController.h
//  StratPad
//
//  Created by Julian Wood on 12-01-31.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//
//  This is a detail view in F5

#import <UIKit/UIKit.h>
#import "MBTitleItem.h"
#import "Theme.h"
#import "ContentViewController.h"

@protocol CalculationsViewControllerDelegate <NSObject>
@required
- (void)editingCalculationsComplete;
@end

@interface CalculationsViewController : ContentViewController <UITextFieldDelegate> 

@property(nonatomic, retain) id<CalculationsViewControllerDelegate> delegate;
@property (retain, nonatomic) IBOutlet MBTitleItem *titleItem;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andTheme:(Theme*)theme;

- (IBAction)done:(id)sender;

@end

@interface NSNumber (Calculations)
- (NSString*)formattedNumberForAdjustmentCalculation;
@end
