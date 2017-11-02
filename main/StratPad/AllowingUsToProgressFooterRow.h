//
//  AllowingUsToProgressFooterRow.h
//  StratPad
//
//  Created by Eric Rogers on 11-12-09.
//  Copyright (c) 2011 Glassey Strategy. All rights reserved.
//

#import "AllowingUsToProgressRow.h"

@interface AllowingUsToProgressFooterRow : AllowingUsToProgressRow {
@private
    // font used for the row
    UIFont *font_;    
    
    // the rect that we actually insert the footer text into, so it appears
    // underneath the value columns.
    CGRect textRect_;
}

// controls whether or not the text display indicates significant digits were truncated.
@property(nonatomic, assign) BOOL significantDigitsTruncated;

- (id)initWithRect:(CGRect)rect font:(UIFont*)font;

// returns the height required by the row to display the footer text when it has a given width and font size.
+ (CGFloat)heightWithRowWidth:(CGFloat)rowWidth font:(UIFont*)font restrictedToHeight:(CGFloat)maxHeight;

@end
