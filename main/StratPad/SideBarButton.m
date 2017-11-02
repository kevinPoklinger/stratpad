//
//  SideBarButton.m
//  StratPad
//
//  Created by Julian Wood on 11-11-15.
//  Copyright (c) 2011 Glassey Strategy. All rights reserved.
//

#import "SideBarButton.h"
#import "UIColor-Expanded.h"
#import "SkinManager.h"
#import "MKNumberBadgeView.h"
#import "PublicationStatusView.h"

@implementation SideBarButton

@synthesize chapterNumberLabel = chapterNumberLabel_;
@synthesize chapterIndex = chapterIndex_;
@synthesize section = section_;

- (id)initWithFrame:(CGRect)frame title:(NSString*)title chapterNumberLabel:(UILabel*)chapterNumberLabel 
       chapterIndex:(NSUInteger)chapterIndex section:(NSString*)section
{
    SkinManager *skinMan = [SkinManager sharedManager];    
    NSDictionary *sectionButtonImageNames = [NSDictionary dictionaryWithObjectsAndKeys:
                                             [skinMan stringForProperty:kSkinSidebarSection1ButtonImage forMediaType:MediaTypeScreen], @"i", 
                                             [skinMan stringForProperty:kSkinSidebarSection2ButtonImage forMediaType:MediaTypeScreen], @"ii", 
                                             [skinMan stringForProperty:kSkinSidebarSection3ButtonImage forMediaType:MediaTypeScreen], @"iii", 
                                             [skinMan stringForProperty:kSkinSidebarSection4ButtonImage forMediaType:MediaTypeScreen], @"iv", 
                                             nil];
    
    NSDictionary *sectionButtonTitleColors = [NSDictionary dictionaryWithObjectsAndKeys:
                                              [skinMan stringForProperty:kSkinSidebarSection1ButtonTextColor forMediaType:MediaTypeScreen], @"i", 
                                              [skinMan stringForProperty:kSkinSidebarSection2ButtonTextColor forMediaType:MediaTypeScreen], @"ii", 
                                              [skinMan stringForProperty:kSkinSidebarSection3ButtonTextColor forMediaType:MediaTypeScreen], @"iii", 
                                              [skinMan stringForProperty:kSkinSidebarSection4ButtonTextColor forMediaType:MediaTypeScreen], @"iv", 
                                              nil];
    
    self = [super initWithFrame:frame];
    if (self) {
        UIImage *img = [UIImage imageNamed:[sectionButtonImageNames objectForKey:section]];
        [self setBackgroundImage:img forState:UIControlStateNormal];
        [self setTitle:title forState:UIControlStateNormal];
        self.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:12];
        self.titleLabel.numberOfLines = 2;
        self.titleLabel.textAlignment = UITextAlignmentCenter;
        self.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
                
        UIColor *titleColor = [UIColor colorWithHexString:[sectionButtonTitleColors objectForKey:section]];        
        [self setTitleColor:titleColor forState:UIControlStateNormal];
//        [self setTitleShadowColor:[UIColor colorWithWhite:0.7 alpha:0.4] forState:UIControlStateNormal];
//        self.titleLabel.shadowOffset = CGSizeMake(1,1);
        self.chapterIndex = chapterIndex;
        self.chapterNumberLabel = chapterNumberLabel;
        self.adjustsImageWhenHighlighted = NO;
        arrowView_ = nil;
    }
    return self;
}

-(void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    if (selected) {
        SkinManager *skinMan = [SkinManager sharedManager];
        UIImage *img = [UIImage imageNamed:[skinMan stringForProperty:kSkinSidebarSelectedImage forMediaType:MediaTypeScreen]];
        if (!arrowView_) {
            arrowView_ = [[UIImageView alloc] initWithImage:img];
        }
        arrowView_.frame = CGRectMake(0, self.frame.origin.y-5, img.size.width, img.size.height);
        [self.superview insertSubview:arrowView_ belowSubview:chapterNumberLabel_];
    } else {
        if (arrowView_) {
            [arrowView_ retain];
            [arrowView_ removeFromSuperview];            
        }
    }
}

-(void)showBadge:(NSUInteger)value
{
    TLog(@"Showing badge for %@ with ct: %u", chapterNumberLabel_.text, value);

    // make sure we don't have any others
    MKNumberBadgeView *badge = (MKNumberBadgeView*)[self viewWithTag:9876];
    
    if (!badge) {
        badge = [[MKNumberBadgeView alloc] initWithFrame:CGRectMake(75, -10, 30, 30)];
        badge.tag = 9876;
        badge.hideWhenZero = YES;
        badge.value = value;
        badge.strokeWidth = 1;
        badge.fillColor = [UIColor colorWithHexString:@"22A4D5"];
        badge.font = [UIFont boldSystemFontOfSize:10];
        badge.alpha = 0;
        [self addSubview:badge];

        [UIView animateWithDuration:0.3 animations:^{
            badge.alpha = 1.f;
        } completion:^(BOOL finished) {
            [badge release];
        }];
    }
    else {
        badge.value = value;
    }
}

-(void)hideBadge
{
    TLog(@"Hiding badge for %@", chapterNumberLabel_.text);
    UIView *badge = [self viewWithTag:9876];
    [badge removeFromSuperview];
}

-(NSUInteger)badgeValue
{
    UIView *badge = [self viewWithTag:9876];
    if (badge) {
        return [(MKNumberBadgeView*)badge value];
    } else {
        return 0;
    }
}

-(void)showYammerPublicationStatus:(BOOL)isPublished
{
    if (isPublished) {
        // show a little triangle in the top left; don't show it again if already up
        UIView *statusView = [self viewWithTag:4523];
        if (!statusView) {
            statusView = [[PublicationStatusView alloc] initWithFrame:CGRectMake(3, 3, 15, 15)];
            statusView.tag = 4523;
            [self addSubview:statusView];
            [statusView release];            
        }
    } else {
        // hide it
        UIView *statusView = [self viewWithTag:4523];
        [statusView removeFromSuperview];
    }
}

- (void)dealloc {
    [arrowView_ release];    
    [chapterNumberLabel_ release];
    [section_ release];
    [super dealloc];
}

@end
