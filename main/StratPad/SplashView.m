//
//  SplashView.m
//  StratPad
//
//  Created by Julian Wood on 11-10-20.
//  Copyright (c) 2011 Glassey Strategy. All rights reserved.
//

#import "SplashView.h"
#import <QuartzCore/QuartzCore.h>
#import "DesignedByButton.h"
#import "EditionManager.h"
#import "EventManager.h"
#import "UIColor-Expanded.h"
#import "NSUserDefaults+StratPad.h"

#define splashTextColor   @"E1E7E8"

@implementation SplashView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImage *imgBackground = [UIImage imageNamed:@"Default-Landscape.png"];
        UIImageView *imgViewBackground = [[UIImageView alloc] initWithImage:imgBackground];
        imgViewBackground.frame = CGRectMake(0, 0, imgBackground.size.width, imgBackground.size.height);
        imgViewBackground.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] 
                                                        initWithTarget:self 
                                                        action:@selector(splashTapped:)];
        [imgViewBackground addGestureRecognizer:tapGestureRecognizer];
        [self addSubview:imgViewBackground];
        [tapGestureRecognizer release];
        [imgViewBackground release];
        
        [self addRegularElements];
                
        // 'designed by' button
        DesignedByButton *btnDesignedBy = [[DesignedByButton alloc] initWithFrame:CGRectZero];
        CGSize preferredSize = [btnDesignedBy sizeThatFits:CGSizeZero];
        CGRect b = self.bounds;
        CGFloat marginRight = 10;
        btnDesignedBy.frame = CGRectMake(b.origin.x + b.size.width - preferredSize.width - marginRight,
                                         b.origin.y + b.size.height - preferredSize.height,
                                         preferredSize.width, preferredSize.height);
        [btnDesignedBy addTarget:self action:@selector(goGlasseyStrategy:) forControlEvents:UIControlEventTouchUpInside];
        btnDesignedBy.alpha = 0;
        [self addSubview:btnDesignedBy];
        [btnDesignedBy release];
        
        // copyright year
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];        
        [formatter setDateFormat:@"yyyy"];
        NSString *years = [formatter stringFromDate:[NSDate date]];
        [formatter release];
        
        // copyright label
        UILabel *lblCopy = [[UILabel alloc] init];
        lblCopy.font = [UIFont fontWithName:@"Helvetica" size:14];
        lblCopy.textColor = [UIColor whiteColor];
        lblCopy.textAlignment = UITextAlignmentLeft;
        lblCopy.text = [NSString stringWithFormat:LocalizedString(@"SPLASH_COPY", nil), years];
        lblCopy.backgroundColor = [UIColor clearColor];
        [lblCopy sizeToFit];
        lblCopy.frame = CGRectMake(10, b.size.height - lblCopy.bounds.size.height - 15,
                                   b.size.width-20, lblCopy.bounds.size.height);
        lblCopy.alpha = 0;
        [self addSubview:lblCopy];
        [lblCopy release];
    }
    return self;
}

#pragma mark - Private

-(void)addRegularElements
{
    CGRect b = self.bounds;
    
    UILabel *lblAppName = [[UILabel alloc] init];
    lblAppName.font = [UIFont fontWithName:@"Helvetica-Bold" size:24];
    lblAppName.textColor = [UIColor colorWithHexString:splashTextColor];
    lblAppName.textAlignment = UITextAlignmentCenter;
    lblAppName.text = [[EditionManager sharedManager] productDisplayName];
    lblAppName.backgroundColor = [UIColor clearColor];
    lblAppName.numberOfLines = 0;
    lblAppName.lineBreakMode = UILineBreakModeWordWrap;    
    CGSize sz = [lblAppName sizeThatFits:CGSizeMake(550, 50)];
    lblAppName.frame = CGRectMake((b.size.width-sz.width)/2, 70, sz.width, sz.height);
    lblAppName.alpha = 0;
    [self addSubview:lblAppName];
    [lblAppName release];

    
    CGRect startViewRect = CGRectMake((self.bounds.size.width-435)/2, b.size.height - 170, 435, 92);
    UIView *startView = [[UIView alloc] initWithFrame:startViewRect];
    startView.alpha = 0;        
    
    // finger
    UIImage *imgFinger = [UIImage imageNamed:@"splashscreen-finger-pointer.png"];
    UIImageView *imgViewStart = [[UIImageView alloc] initWithImage:imgFinger];
    imgViewStart.frame = CGRectMake(0, 5, imgFinger.size.width, imgFinger.size.height);
    [startView addSubview:imgViewStart];
    [imgViewStart release];
    
    // top line
    UILabel *lblGetStarted = [[UILabel alloc] init];
    lblGetStarted.font = [UIFont fontWithName:@"Helvetica-Bold" size:24];
    lblGetStarted.textColor = [UIColor colorWithHexString:splashTextColor];
    lblGetStarted.textAlignment = UITextAlignmentCenter;
    lblGetStarted.text = LocalizedString(@"BTN_START_TEXT", nil);
    lblGetStarted.backgroundColor = [UIColor clearColor];
    lblGetStarted.numberOfLines = 1;
    lblGetStarted.frame = CGRectMake(32, 2, startViewRect.size.width-32, 26);
    [startView addSubview:lblGetStarted];
    [lblGetStarted release];

    // bottom line
    UILabel *lblPowerful = [[UILabel alloc] init];
    lblPowerful.font = [UIFont fontWithName:@"Helvetica" size:20];
    lblPowerful.textColor = [UIColor colorWithHexString:splashTextColor];
    lblPowerful.textAlignment = UITextAlignmentCenter;
    lblPowerful.text = LocalizedString(@"BTN_START_SUBTEXT", nil);
    lblPowerful.backgroundColor = [UIColor clearColor];
    lblPowerful.numberOfLines = 2;
    lblPowerful.frame = CGRectMake(45, 38, startViewRect.size.width-32, startViewRect.size.height-38);
    [startView addSubview:lblPowerful];
    [lblPowerful release];
    
    [self addSubview:startView];
    [startView release];
}

- (void)goGlasseyStrategy:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.alexglassey.com"]];
}

- (void)splashTapped:(UIGestureRecognizer *)gestureRecognizer
{
    [UIView animateWithDuration:0.5
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }
     ];
    
    // show the welcome message if you haven't already seen it
    [EventManager fireStratPadReady];
}

#pragma mark - Public

-(void)fadeInInteractiveElements
{
    // animate splash elements
    [UIView animateWithDuration:0.5
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         for (UIView *view in [self subviews]) {
                             if (view.alpha < 1.0) {
                                 view.alpha = 1.0;                                 
                             }
                         }
                     }
                     completion:nil
     ];
}

@end
