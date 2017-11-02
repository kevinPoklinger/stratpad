//
//  AllowingUsToProgressHeadingRow.h
//  StratPad
//
//  Created by Eric Rogers on 11-12-09.
//  Copyright (c) 2011 Glassey Strategy. All rights reserved.
//

#import "AllowingUsToProgressRow.h"

@interface AllowingUsToProgressHeadingRow : AllowingUsToProgressRow {
@private    
    // font used for the row
    UIFont *font_;    
    
    // stores the quarterly dates to display in the row
    NSArray *columnDates_;
}

- (id)initWithRect:(CGRect)rect font:(UIFont*)font andcolumnDates:(NSArray*)columnDates;

// returns the height required by the row to display the goal heading when it has a given width and font size.
+ (CGFloat)heightWithRowWidth:(CGFloat)rowWidth font:(UIFont*)font restrictedToHeight:(CGFloat)maxHeight;

@end
