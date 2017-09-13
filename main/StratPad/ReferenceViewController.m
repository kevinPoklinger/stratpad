//
//  ReferenceViewController.m
//  StratPad
//
//  Created by Julian Wood on 12-01-31.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "ReferenceViewController.h"
#import "SkinManager.h"

@implementation ReferenceViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage *backgroundImage = [UIImage imageNamed:[[SkinManager sharedManager] stringForProperty:kSkinSection1BackgroundImage forMediaType:MediaTypeScreen]];
    [super addBackgroundImageToView:backgroundImage];
}

#pragma mark - Override

-(void)reloadLocalizableResources
{
    // includes all the VC's in the reference section
    // they are also all HTMLViewControllers
    if ([self respondsToSelector:@selector(loadHTML)]) {
        [self performSelector:@selector(loadHTML)];
    }
    
}

// todo: @2x images in css or html


@end
