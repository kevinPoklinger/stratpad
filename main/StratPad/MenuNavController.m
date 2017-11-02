//
//  MenuNavController.m
//  StratPad
//
//  Created by Julian Wood on 11-08-16.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "MenuNavController.h"

@implementation MenuNavController

@synthesize popoverController = popoverController_;

- (id)initWithRootViewController:(UIViewController *)rootViewController
{
    // NB. we have to make nibs taller than they should be, to accommodate the  navbar
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        originalViewSize_ = rootViewController.view.bounds.size;
    }
    return self;
}

- (void)dealloc
{
    [popoverController_ release];
    [super dealloc];
}

#pragma mark - UIPopoverControllerDelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    UIViewController *rootVC = [self.viewControllers objectAtIndex:0];
    if ([rootVC conformsToProtocol:@protocol(TableBasedMenu)]) {
        [[(UIViewController <TableBasedMenu> *)rootVC tableView] setEditing:NO];        
    }
    
    // problem with [self popToRootViewControllerAnimated:NO];
    // if we say NO, then we get a bizarre animation to the top left corner
    // if we say YES, you see the viewcontrollers sliding as the popover fades out (albeit properly)
    // delaying fixes the problem (some race condition?)
    [self performSelector:@selector(pop) withObject:nil afterDelay:0.1];
    
    // because the popover doesn't resize correctly when navigating back, as part of the scheme, reset the flag
    if ([rootVC respondsToSelector:@selector(resetFirstTimeShowFlag)]) {
        [rootVC performSelector:@selector(resetFirstTimeShowFlag)];
    }
    
    [popoverController_ release];
	popoverController_ = nil;
}

-(void)pop
{
    [self popToRootViewControllerAnimated:NO];
}

#pragma mark - Public

- (void)showMenu:(UIBarButtonItem*)barButtonItem
{		    
    if (popoverController_) {
        [self dismissMenu];
    }
    
    popoverController_ = [[UIPopoverController alloc] initWithContentViewController:self];
    popoverController_.delegate = self;
    popoverController_.popoverContentSize = originalViewSize_;
    
    [popoverController_ presentPopoverFromBarButtonItem:barButtonItem 
                               permittedArrowDirections:UIPopoverArrowDirectionUp 
                                               animated:YES];
    
}

- (void)dismissMenu
{
    [popoverController_ dismissPopoverAnimated:YES];
    [popoverController_.delegate popoverControllerDidDismissPopover:popoverController_];
}

-(BOOL)isPresented
{
    return popoverController_ != nil;
}


@end
