//
//  MBSuccessIndicator.m
//  Experimental
//
//  Created by Julian Wood on 12-05-03.
//  Copyright (c) 2012 Mobilesce Inc. All rights reserved.
//

#import "MBSuccessIndicator.h"
#import "SkinManager.h"

@implementation MBSuccessIndicator

@synthesize selection=selection_;

// supports nil as selection
- (void)setup:(NSNumber*)selection
{
    SkinManager *skinMan = [SkinManager sharedManager];
    
    static CGFloat spacer = 8.f;
    CGFloat width = (self.frame.size.width-spacer)/2;
    
    r1_ = [[MBRadioLabel alloc] initWithFrame:CGRectMake(0, 0, width, self.frame.size.height) andRadioGroup:self];
    r1_.font = [UIFont systemFontOfSize:13];
    r1_.backgroundColor = [UIColor clearColor];
    r1_.textColor = [skinMan colorForProperty:kSkinSection2TextValueFontColor forMediaType:MediaTypeScreen];
    r1_.text = LocalizedString(@"GT_TARGET", nil);
    r1_.radioValue = [NSNumber numberWithBool:0];
    r1_.on = ([selection isEqualToNumber:r1_.radioValue]);
    [self addSubview:r1_];
//    [r1_ release];
    
    r2_ = [[MBRadioLabel alloc] initWithFrame:CGRectMake(width+spacer, 0, width, self.frame.size.height) andRadioGroup:self];
    r2_.font = [UIFont systemFontOfSize:13];
    r2_.backgroundColor = [UIColor clearColor];
    r2_.textColor = [skinMan colorForProperty:kSkinSection2TextValueFontColor forMediaType:MediaTypeScreen];
    r2_.text = LocalizedString(@"LT_TARGET", nil);
    r2_.radioValue = [NSNumber numberWithBool:1];
    r2_.on = ([selection isEqualToNumber:r2_.radioValue]);
    [self addSubview:r2_];
//    [r2_ release];
    
    self.backgroundColor = [UIColor clearColor];
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setup:nil];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame andSelection:(NSNumber*)selection
{
    self = [super initWithFrame:frame];
    if (self) {    
        [self setup:selection];                
    }
    return self;
}

-(void)updateGrouping:(MBRadioLabel*)radioLabel
{
    // we support on/off/neither
    if ([radioLabel isEqual:r1_]) {
        r1_.on = !r1_.on;
        r2_.on = NO;
    } else {
        r2_.on = !r2_.on;
        r1_.on = NO;
    }
    [r1_ setNeedsDisplay];
    [r2_ setNeedsDisplay];
    
    if ([target_ respondsToSelector:action_]) {
        [target_ performSelector:action_ withObject:[self selection]];
    }
}

-(void)addTarget:(id)target action:(SEL)action 
{
    target_=target;
    action_=action;
}

-(void)setSelection:(NSNumber *)selection
{
    r1_.on = ([selection isEqualToNumber:r1_.radioValue]);
    r2_.on = ([selection isEqualToNumber:r2_.radioValue]);
    [r1_ setNeedsDisplay];
    [r2_ setNeedsDisplay];    
}

-(NSNumber*)selection
{
    if (r1_.on) {
        return r1_.radioValue;
    }
    else if (r2_.on) {
        return r2_.radioValue;
    }
    else {
        return nil;
    }
}

- (void)dealloc
{
    [selection_ release];
    [r1_ release];
    [r2_ release];
    [super dealloc];
}

@end
