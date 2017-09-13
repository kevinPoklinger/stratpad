//
//  MBDisabledView.m
//  StratPad
//
//  Created by Julian Wood on 11-08-25.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "MBDisabledView.h"
#import "MBFancyLabel.h"

@implementation MBDisabledView

- (id)initWithFrame:(CGRect)frame andTitle:(NSString*)title
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        
        MBFancyLabel *lblMessage = [[MBFancyLabel alloc] initWithTitle:title];
        lblMessage.frame = CGRectMake((frame.size.width-lblMessage.bounds.size.width)/2,
                                      (frame.size.height-lblMessage.bounds.size.height)/2, 
                                      lblMessage.bounds.size.width, 
                                      lblMessage.bounds.size.height);
        
        [self addSubview:lblMessage];
        [lblMessage release];
    }
    return self;
}

- (void)showInView:(UIView*)view
{
    if (self.superview == view) {
        return;
    }
    self.alpha = 0;
    [view addSubview:self];
    [UIView animateWithDuration:0.2
                     animations:^{
                         self.alpha = 1;
                     } completion:nil
     ];    
}

- (void)dealloc
{
    [super dealloc];
}

@end
