//
//  AllowingUsToProgressDetailRow.h
//  StratPad
//
//  Created by Eric Rogers on 11-12-09.
//  Copyright (c) 2011 Glassey Strategy. All rights reserved.
//

#import "AllowingUsToProgressRow.h"

@interface AllowingUsToProgressDetailRow : AllowingUsToProgressRow {
@private
    // heading for the row
    NSString *rowHeading_;
    
    // financial values for the row
    NSArray *financialValues_;
    
    // fonts used for the row heading and values.
    UIFont *headingFont_;
    UIFont *valueFont_;            
}

// color of the lines in the row
@property(nonatomic, retain) UIColor *lineColor;

// controls the renering fo a full-width bottom border for the row
@property(nonatomic, assign) BOOL renderFullWidthBottomBorder;

- (id)initWithRect:(CGRect)rect 
       rowHeading:(NSString*)rowHeading 
       headingFont:(UIFont*)headingFont 
         valueFont:(UIFont*)valueFont 
andFinancialValues:(NSArray*)financialValues;

// returns the height required by the row to display the row heading when it has a given width and font size.
+ (CGFloat)heightWithRowHeading:(NSString*)heading rowWidth:(CGFloat)rowWidth font:(UIFont*)font restrictedToHeight:(CGFloat)maxHeight;

@end
