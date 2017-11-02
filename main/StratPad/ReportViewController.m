//
//  ReportViewController.m
//  StratPad
//
//  Created by Julian Wood on 12-01-31.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "ReportViewController.h"
#import "SkinManager.h"

@implementation ReportViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage *backgroundImage = [UIImage imageNamed:[[SkinManager sharedManager] stringForProperty:kSkinSection3BackgroundImage forMediaType:MediaTypeScreen]];
    [super addBackgroundImageToView:backgroundImage];
}

@end
