//
//  MBReportHeader.h
//  StratPad
//
//  Created by Eric on 11-11-16.
//  Copyright (c) 2011 Glassey Strategy. All rights reserved.
//
//  Draws to the screen, rather than to print.
//  The title is typically 2 lines, denoted by a line break in the reportTitle text.
//  Title items are just below the 104 px grey header background, such as Proprietary and confidential, in R9.
//  Description items are also below the 104 px grey header background, such as in R2.
//  Multiple items can be added and their yoffsets are calculated accordingly.

#import "Drawable.h"

#define logoMaxDim  90.f
#define logoMargin  7.f

@interface MBReportHeader : NSObject<Drawable> {
@private    
    CGRect rect_;
    
    CGFloat textInsetLeft_;
    
    NSMutableArray *drawables_;    
    
    NSString *reportTitle_;
    
    NSString *reportTitleFontName_;
    CGFloat reportTitleFontSize_;
    UIColor *reportTitleFontColor_;
    
    NSMutableArray *titleItems_;
    NSMutableArray *descriptionItems_;
    
    NSString *headerImageName_;
        
}

- (id)initWithRect:(CGRect)rect textInsetLeft:(CGFloat)textInsetLeft andReportTitle:(NSString*)reportTitle;

// amount to inset the text in the header from the left by, releative to the rect for the header.
@property(nonatomic, assign) CGFloat textInsetLeft;

// name of the header background image to use.
@property(nonatomic, copy) NSString *headerImageName;

// text that appears on top of the gradient in the header
@property(nonatomic, copy) NSString *reportTitle;

@property(nonatomic, copy) NSString *reportTitleFontName;
@property(nonatomic, assign) CGFloat reportTitleFontSize;
@property(nonatomic, retain) UIColor *reportTitleFontColor;

// default is true to draw the logo on the right side (if it exists and we have the sufficient edition)
// some reports (eg StratBoard) don't want a logo and can override the decision here
@property(nonatomic, assign) BOOL shouldDrawLogo;

- (void)addTitleItemWithText:(NSString*)text font:(UIFont*)font andColor:(UIColor*)color;

- (void)addDescriptionItemWithText:(NSString*)text font:(UIFont*)font andColor:(UIColor*)color;

@end
