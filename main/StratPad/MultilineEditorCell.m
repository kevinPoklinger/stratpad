//
//  MultilineEditorCell.m
//  StratPad
//
//  Created by Julian Wood on 12-10-01.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "MultilineEditorCell.h"

@implementation MultilineEditorCell
@synthesize textView;

-(void)awakeFromNib
{
    
}

-(void)showActivity
{
    self.alpha = 0.5;
    
    // activity indicator
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    indicator.tag = 9876;
    CGSize aSize = indicator.frame.size;
    
    indicator.frame = CGRectMake((self.frame.size.width - aSize.width)/2,
                                 (self.frame.size.height - aSize.height)/2,
                                 indicator.frame.size.width, indicator.frame.size.height);
    
    [self addSubview:indicator];
    [indicator startAnimating];
    [indicator release];
}

-(void)finishActivity
{
    self.alpha = 1.0;
    [[self viewWithTag:9876] removeFromSuperview];
}

- (void)dealloc {
    [textView release];
    [super dealloc];
}



@end
