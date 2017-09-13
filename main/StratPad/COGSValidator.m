//
//  COGSValidator.m
//  StratPad
//
//  Created by Julian Wood on 2013-04-29.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//

#import "COGSValidator.h"
#import "UserNotificationDisplayManager.h"
#import "UIColor-Expanded.h"

@interface COGSValidator ()

@property (assign, nonatomic) BOOL warningMessageShowing;
@property (retain, nonatomic) UISlider *slider;

@end

@implementation COGSValidator

-(id)initWithSlider:(UISlider*)slider
{
    self = [super init];
    if (self) {
        self.slider = slider;
    }
    return self;
}

-(void)validateCOGS:(NSNumber*)inventoryPercentage wagePercentage:(NSNumber*)wagePercentage
{
    if (wagePercentage.intValue > 100-inventoryPercentage.intValue) {
        [self warnAboutCOGSWithInventoryPercentage:inventoryPercentage wagePercentage:wagePercentage];
        
    } else {
        [self dismissWarning];
        
    }
}

- (void)warnAboutCOGSWithInventoryPercentage:(NSNumber*)inventoryPercentage wagePercentage:(NSNumber*)wagePercentage
{
    if (!_warningMessageShowing) {
        NSString *msg = [NSString stringWithFormat:LocalizedString(@"COGSWarning", nil), inventoryPercentage, wagePercentage];
        [[UserNotificationDisplayManager sharedManager] showMessageAfterDelay:0
                                                                        color:[[UIColor colorWithHexString:@"800000"] colorWithAlphaComponent:0.8]
                                                                  autoDismiss:NO
                                                                      message:msg];
        _slider.minimumTrackTintColor = [UIColor colorWithHexString:@"800000"]; // red
        _slider.maximumTrackTintColor = [UIColor colorWithHexString:@"800000"]; // red
        _warningMessageShowing = YES;
    } else {
        // update existing message
        NSString *msg = [NSString stringWithFormat:LocalizedString(@"COGSWarning", nil), inventoryPercentage, wagePercentage];
        [[UserNotificationDisplayManager sharedManager] updateMessage:msg];
    }
}

- (void)dismissWarning
{
    if (_warningMessageShowing) {
        [[UserNotificationDisplayManager sharedManager] dismiss];
        _slider.minimumTrackTintColor = [UIColor colorWithHexString:@"666666"];
        _slider.maximumTrackTintColor = nil;
        _warningMessageShowing = NO;
    }
}

- (void)dealloc
{
    [_slider release];
    [super dealloc];
}

@end
