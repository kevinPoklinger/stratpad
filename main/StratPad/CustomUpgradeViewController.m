//
//  CustomUpgradeViewController.m
//  StratPad
//
//  Created by Julian Wood on 12-01-02.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "CustomUpgradeViewController.h"

@implementation CustomUpgradeViewController

- (id)init
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)dealloc
{
    [popoverController_ release];
    [super dealloc];
}

#pragma mark - UIPopoverControllerDelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    [popoverController_ release];
	popoverController_ = nil;	    
}

#pragma mark - Public

- (void)showPopoverInView:(UIView*)view
{		    
    if (popoverController_) {
        [popoverController_ release]; popoverController_ = nil;		
    }
    
    popoverController_ = [[UIPopoverController alloc] initWithContentViewController:self];
    popoverController_.delegate = self;
    CGSize size = self.view.bounds.size;
    popoverController_.popoverContentSize = self.view.bounds.size;
    // when grabbing the frame of the rootVC, it gives the portrait coords :-/
    [popoverController_ presentPopoverFromRect:CGRectMake(0, 0, 1024, 748) // stick it in the middle
                                        inView:view
                      permittedArrowDirections:0 // no arrows
                                      animated:YES];	
}

- (void)dismissPopover
{
    [popoverController_ dismissPopoverAnimated:YES];
	[popoverController_ release];
	popoverController_ = nil;
}


@end
