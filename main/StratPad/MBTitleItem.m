//
//  MBTitleItem.m
//  StratPad
//
//  Created by Eric Rogers on September 6, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "MBTitleItem.h"

@implementation MBTitleItem

- (void)setTitle:(NSString *)title
{
    [super setTitle:title];
    lblTitle_.text = self.title;
}

-(void)awakeFromNib
{
    // default to 400px in width if no width has been set.
    CGFloat width = self.width > 0 ? self.width : 400.f;
    
    lblTitle_ = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, 22.f)];
    lblTitle_.backgroundColor = [UIColor clearColor];
    lblTitle_.textColor = [UIColor colorWithRed:116 / 255.0f green:125 / 255.0f blue:125 / 255.0f alpha:1.0f];
    lblTitle_.textAlignment = UITextAlignmentCenter;
    lblTitle_.lineBreakMode = UILineBreakModeTailTruncation;
    lblTitle_.font = [UIFont boldSystemFontOfSize:20.f];
    //lblTitle_.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    lblTitle_.adjustsFontSizeToFitWidth = NO;
    lblTitle_.text = self.title;
    self.customView = lblTitle_;
    [lblTitle_ release];
}

@end
