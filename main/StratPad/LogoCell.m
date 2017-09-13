//
//  LogoCell.m
//  StratPad
//
//  Created by Julian Wood on 12-01-17.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "LogoCell.h"
#import "Settings.h"
#import "DataManager.h"
#import "UIColor-Expanded.h"
#import "RootViewController.h"
#import "PageViewController.h"

@interface LogoCell ()
@property (retain, nonatomic) IBOutlet UILabel *lblText;
@property (retain, nonatomic) IBOutlet UIButton *btnEditLogo;
@property (retain, nonatomic) NSString *titleForBtnEditLogo;
@end

@implementation LogoCell

- (void)awakeFromNib
{
    // store the localized edit string for when we actually have an image
    _titleForBtnEditLogo = [[_btnEditLogo titleForState:UIControlStateNormal] copy];
    _btnEditLogo.backgroundColor = [UIColor clearColor];
}

- (void)dealloc {
    [_titleForBtnEditLogo release];
    [_lblText release];
    [_btnEditLogo release];
    [super dealloc];
}

- (IBAction)clearLogo {
    Settings *settings = (Settings*)[DataManager objectForEntity:NSStringFromClass([Settings class]) 
                                            sortDescriptorsOrNil:nil
                                                  predicateOrNil:nil];
    settings.consultantLogo = nil;
    [DataManager saveManagedInstances];
    
    [self setLogoImage:nil];

    RootViewController *rootViewController = (RootViewController*)[[[UIApplication sharedApplication] keyWindow] rootViewController];
    [rootViewController.pageViewController reloadCurrentPages];
}

-(void)setLogoImage:(UIImage *)image
{
    // a little bit of trickery so that we can have dynamic localizable text for the edit button
    if (image) {
        [_btnEditLogo setBackgroundImage:nil forState:UIControlStateNormal];
        [_btnEditLogo setImage:image forState:UIControlStateNormal];
        [_btnEditLogo setTitle:nil forState:UIControlStateNormal];
    } else {
        [_btnEditLogo setBackgroundImage:[UIImage imageNamed:@"edit-logo-background.png"] forState:UIControlStateNormal];
        [_btnEditLogo setImage:nil forState:UIControlStateNormal];
        [_btnEditLogo setTitle:_titleForBtnEditLogo forState:UIControlStateNormal];
    }
}

- (IBAction)editLogo {
    [_logoEditor editLogo];
}

@end
