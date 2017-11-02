//
//  MBRadioLabel.m
//  Experimental
//
//  Created by Julian Wood on 12-05-03.
//  Copyright (c) 2012 Mobilesce Inc. All rights reserved.
//

#import "MBRadioLabel.h"

@implementation MBRadioLabel

@synthesize on, onColor, radioValue;

- (id)initWithFrame:(CGRect)frame andRadioGroup:(id<MBRadioGroup>)radioGroup
{
    self = [super initWithFrame:frame];
    if (self) {
        radioGroup_ = radioGroup;
        onColor = [UIColor lightGrayColor];
        self.userInteractionEnabled = YES;
                
        UITapGestureRecognizer *tapRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
        [self addGestureRecognizer:tapRec];
        [tapRec release];
    }
    return self;
}

- (void)tapped:(UITapGestureRecognizer*)tapGestureRecognizer
{
    [radioGroup_ updateGrouping:self];
}

- (void)drawRect:(CGRect)rect
{
    if (on) {
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(5, 5)];
        [onColor setFill];
        [path fill];
    }

    // center this horizontally; assume rect is bigger than the text width
    CGSize preferredSize = [self.text sizeWithFont:self.font constrainedToSize:rect.size];
    CGRect textRect = CGRectInset(rect, (rect.size.width-preferredSize.width)/2, (rect.size.height-preferredSize.height)/2);
    [self.textColor setFill];
    [self.text drawInRect:textRect withFont:self.font];
}

- (void)dealloc
{
    [onColor release];
    [super dealloc];
}

@end
