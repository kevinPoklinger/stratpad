//
//  DrawableSplitter.h
//  StratPad
//
//  Created by Eric Rogers on October 6, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//
//  The idea here is to divide a tall drawable instance vertically
//  into multiple instances that can each be fit onto a page in 
//  a multiple page layout, i.e., printing to PDF.

#import "Drawable.h"

@protocol DrawableSplitter <NSObject>

// constructor - first rect defines the rect that the first chunk of content will 
// be restricted to, while subsequentRect defines the rect the remaining chunks of 
// content will be restricted to.
- (id)initWithFirstRect:(CGRect)firstRect andSubsequentRect:(CGRect)subsequentRect;

// returns smaller instances of the same type of drawable, each with a specific
// chunk of content from the original drawable.
- (NSArray*)splitDrawable:(id<Drawable>)drawable; 

// returns the minimum height for the first resulting split drawable
// for the given drawable.
+ (CGFloat)minimumSplitHeightForDrawable:(id<Drawable>)drawable;

@end
