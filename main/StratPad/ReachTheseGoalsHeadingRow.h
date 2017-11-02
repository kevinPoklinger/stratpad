//
//  ReachTheseGoalsHeadingRow.h
//  StratPad
//
//  Created by Eric Rogers on 11-12-09.
//  Copyright (c) 2011 Glassey Strategy. All rights reserved.
//

#import "ReachTheseGoalsRow.h"

@interface ReachTheseGoalsHeadingRow : ReachTheseGoalsRow {
@private    
    // font used for the row
    UIFont *font_;    
}

- (id)initWithRect:(CGRect)rect font:(UIFont*)font andDataSource:(ReachTheseGoalsDataSource*)dataSource;

// returns the height required by the row to display the goal heading when it has a given width and font size.
+ (CGFloat)heightWithRowWidth:(CGFloat)rowWidth font:(UIFont*)font restrictedToHeight:(CGFloat)maxHeight;


@end
