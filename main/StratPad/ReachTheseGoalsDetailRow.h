//
//  ReachTheseGoalsDetailRow.h
//  StratPad
//
//  Created by Eric Rogers on 11-12-09.
//  Copyright (c) 2011 Glassey Strategy. All rights reserved.
//

#import "ReachTheseGoalsRow.h"

@interface ReachTheseGoalsDetailRow : ReachTheseGoalsRow {
@private
    // heading for the row
    NSString *goalHeading_;

    // fonts used for the row heading and values.
    UIFont *headingFont_;
    UIFont *valueFont_;            
}

// color of the lines in the row
@property(nonatomic, retain) UIColor *lineColor;

// color of the diamonds to be used in the row
@property(nonatomic, retain) UIColor *diamondColor;

// controls the renering fo a full-width bottom border for the row
@property(nonatomic, assign) BOOL renderFullWidthBottomBorder;

- (id)initWithRect:(CGRect)rect 
       goalHeading:(NSString*)goalHeading 
       headingFont:(UIFont*)headingFont 
         valueFont:(UIFont*)valueFont 
     andDataSource:(ReachTheseGoalsDataSource*)dataSource;

// returns the height required by the row to display the goal heading when it has a given width and font size.
+ (CGFloat)heightWithGoalHeading:(NSString*)goalHeading rowWidth:(CGFloat)rowWidth font:(UIFont*)font restrictedToHeight:(CGFloat)maxHeight;

@end
