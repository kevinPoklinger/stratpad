//
//  DesignedByButton.m
//  StratPad
//
//  Created by Julian Wood on 11-10-19.
//  Copyright (c) 2011 Glassey Strategy. All rights reserved.
//

#import "DesignedByButton.h"

@implementation DesignedByButton

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {        
        CGFloat wordSpacing = 6;
        
        UILabel *lbl1 = [[UILabel alloc] init];
        lbl1.font = [UIFont fontWithName:@"Zapfino" size:13];
        lbl1.backgroundColor = [UIColor clearColor];
        lbl1.textColor = [UIColor whiteColor];
        lbl1.text = @"designed by";
        [lbl1 sizeToFit];
        lbl1.frame = CGRectMake(0, 0, lbl1.bounds.size.width, lbl1.bounds.size.height);
        [self addSubview:lbl1];
        [lbl1 release];
        
        UILabel *lbl2 = [[UILabel alloc] init];
        lbl2.font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
        lbl2.backgroundColor = [UIColor clearColor];
        lbl2.textColor = [UIColor whiteColor];
        lbl2.text = @"Alex";
        [lbl2 sizeToFit];
        lbl2.frame = CGRectMake(lbl1.bounds.size.width + wordSpacing, 10, 
                                lbl2.bounds.size.width, lbl2.bounds.size.height);
        [self addSubview:lbl2];
        [lbl2 release];
        
        UILabel *lbl3 = [[UILabel alloc] init];
        lbl3.font = [UIFont fontWithName:@"Helvetica" size:14];
        lbl3.backgroundColor = [UIColor clearColor];
        lbl3.textColor = [UIColor whiteColor];
        lbl3.text = @"Glassey";
        [lbl3 sizeToFit];
        lbl3.frame = CGRectMake(lbl1.bounds.size.width + wordSpacing + lbl2.bounds.size.width, 10, 
                                lbl3.bounds.size.width, lbl3.bounds.size.height);
        [self addSubview:lbl3];
        [lbl3 release];
        
        CGSize preferredSize = CGSizeMake(lbl1.bounds.size.width + wordSpacing + lbl2.bounds.size.width + lbl3.bounds.size.width, lbl1.bounds.size.height);
        
        self.bounds = CGRectMake(0, 0, preferredSize.width, preferredSize.height);
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size
{
    return self.bounds.size;
}


@end
