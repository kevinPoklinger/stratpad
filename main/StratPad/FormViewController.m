//
//  FormViewController.m
//  StratPad
//
//  Created by Julian Wood on 12-01-31.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "FormViewController.h"
#import "SkinManager.h"

@implementation FormViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage *backgroundImage = [UIImage imageNamed:[[SkinManager sharedManager] stringForProperty:kSkinSection2BackgroundImage forMediaType:MediaTypeScreen]];
    [super addBackgroundImageToView:backgroundImage];
}

@end
