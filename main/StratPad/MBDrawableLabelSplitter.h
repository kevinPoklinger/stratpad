//
//  MBDrawableLabelSplitter.h
//  StratPad
//
//  Created by Eric Rogers on October 6, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//
//  Splits the text in a single MBPDFLabel across multiple 
//  instances, the first having a size equal to firstSize, and all
//  others having a size equal to subsequentSize.

#import "DrawableSplitter.h"
#import "MBDrawableLabel.h"

@interface MBDrawableLabelSplitter : NSObject<DrawableSplitter> {
@private
    CGRect firstRect_;
    CGRect subsequentRect_;
}

@end


@interface MBDrawableLabelSplitter (Private)

// returns all characters from the given text up to and including the next whitespace or newline if one exists.
- (NSString*)nextWordFromText:(NSString*)text withFont:(UIFont*)font restrictedToMaxWidth:(CGFloat)maxWidth;

- (MBDrawableLabel*)newDrawableLabelWithText:(NSString*)text andSourceLabel:(MBDrawableLabel*)sourceLabel confinedToRect:(CGRect)rect;

@end
