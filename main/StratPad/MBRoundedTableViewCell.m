//
//  MBRoundedTableViewCell.m
//  StratPad
//
//  Created by Eric Rogers on August 16, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "MBRoundedTableViewCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation MBRoundedTableViewCell

@synthesize roundedView = roundedView_;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        
        self.contentView.backgroundColor = [UIColor clearColor];        
                        
        UIView *backgroundView = [[UIView alloc] initWithFrame:self.bounds];
        backgroundView.backgroundColor = [UIColor clearColor];
        self.backgroundView = backgroundView;
        [backgroundView release];        
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    self.roundedView.layer.masksToBounds = YES;
    self.roundedView.layer.cornerRadius = 8.0f;
    [super drawRect:rect];
}

- (void)dealloc
{
    [roundedView_ release];
    [super dealloc];
}

@end
