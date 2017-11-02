//
//  AllowingUsToProgressRow.h
//  StratPad
//
//  Created by Eric Rogers on 11-12-09.
//  Copyright (c) 2011 Glassey Strategy. All rights reserved.
// 
//  Abstract super class for a row in the Allowing Us To Progress Chart

#import "Drawable.h"

static const CGFloat kCellPadding = 2.f;
static const CGFloat kMaxRowHeight = 400.f;

@interface AllowingUsToProgressRow : NSObject<Drawable> {
@protected
    // rect for the row
    CGRect rect_;    
        
    // define the beginning and end x-coordinates for the value columns in the row
    NSUInteger startingXForValueColumns_;
    NSUInteger endingXForValueColumns_;
    
    // width of each value column
    NSUInteger valueColumnWidth_;
    
    // height of the row
    CGFloat rowHeight_;    
}

// background color for the row
@property(nonatomic, retain) UIColor *backgroundColor;

// color of the font to use in the row
@property(nonatomic, retain) UIColor *fontColor;

- (id)initWithRect:(CGRect)rect;

// returns the rect for the column in the row
- (CGRect)rectForColumn:(NSUInteger)column;

@end
