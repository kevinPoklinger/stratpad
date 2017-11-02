//
//  TableCellTextView.m
//  StratPad
//
//  Created by Julian Wood on 12-10-01.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "TableCellTextView.h"
#import "UIColor-Expanded.h"

@implementation TableCellTextView

@synthesize indexPath, isShowingPlaceHolder;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        isShowingPlaceHolder = YES;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        isShowingPlaceHolder = YES;
    }
    return self;
}

-(void)showPlaceHolder
{
    self.isShowingPlaceHolder = YES;
    self.textColor = [UIColor lightGrayColor];
    self.text = LocalizedString(@"YAMMER_COMMENT_REPLY_PLACEHOLDER", nil);
    self.selectedRange = NSMakeRange(0, 0);
}

-(void)hidePlaceHolder
{
    self.isShowingPlaceHolder = NO;
    self.text = @"";
    self.textColor = [UIColor blackColor];
}


- (void)dealloc
{
    [indexPath release];
    [super dealloc];
}


@end
