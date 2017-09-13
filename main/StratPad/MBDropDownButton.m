//
//  MBDropDownButton.m
//  StratPad
//
//  Created by Eric Rogers on August 22, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "MBDropDownButton.h"

@implementation MBDropDownButton

@synthesize label = label_;

static const NSUInteger kHorizontalSubviewSpace = 10;

- (id) initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {        
        UIEdgeInsets insets = UIEdgeInsetsMake(0, 10, 0, 2);
        
        UIImage *imgArrowDown = [UIImage imageNamed:@"arrow-down.png"];
        arrowView_ = [[UIImageView alloc] initWithImage:imgArrowDown];
        arrowView_.frame = CGRectMake(self.bounds.size.width - imgArrowDown.size.width - insets.right, 
                                         (self.bounds.size.height - imgArrowDown.size.height)/2, 
                                         imgArrowDown.size.width, 
                                         imgArrowDown.size.height);
        arrowView_.userInteractionEnabled = NO; // set to no, as the button should be the only event responder.
        [self addSubview:arrowView_];
        [arrowView_ release];
        
        label_ = [[UILabel alloc] initWithFrame:CGRectMake(insets.left,
                                                           0, 
                                                           self.bounds.size.width - insets.left - insets.right - arrowView_.frame.size.width - kHorizontalSubviewSpace, 
                                                           self.bounds.size.height)];
        label_.lineBreakMode = UILineBreakModeTailTruncation;
        label_.userInteractionEnabled = NO; // set to no, as the button should be the only event responder.
        label_.backgroundColor = [UIColor clearColor];
                
        [self addSubview:label_];
        [label_ release];
    }
    return self;
}

@end
