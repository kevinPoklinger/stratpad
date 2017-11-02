//
//  CommentBox.m
//  StratPad
//
//  Created by Julian Wood on 12-05-01.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "CommentBox.h"

@implementation CommentBox

@synthesize hitRect,comment,chart=chart_,commentLabel=commentLabel_,level;

- (id)initWithHitRect:(CGRect)aHitRect comment:(NSString*)aComment chart:(Chart*)aChart level:(uint)aLevel
{
    self = [super init];
    if (self) {
        self.level=aLevel;
        self.chart=aChart;
        self.hitRect=aHitRect;
        self.comment=aComment;
    }
    return self;
}

- (void)dealloc
{
    [chart_ release];
    [commentLabel_ release];
    [super dealloc];
}

@end
