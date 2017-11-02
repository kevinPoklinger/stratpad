//
//  MBReportHeaderView.h
//  StratPad
//
//  Created by Eric Rogers on October 14, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//
//  Wraps our MBReportHeader in a view so that it can 
//  be embedded in a xib. Includes a skinned background image, as well
//  as skinned title font and size and color.

#import "MBReportHeader.h"

@interface MBReportHeaderView : UIView {
@private
    MBReportHeader *reportHeader_;
}

@property (nonatomic, assign) BOOL shouldDrawLogo;

- (void)setTextInsetLeft:(CGFloat)textInsetLeft;

- (void)setReportTitle:(NSString*)reportTitle;

- (void)addTitleItemWithText:(NSString*)text font:(UIFont*)font andColor:(UIColor*)color;

- (void)addDescriptionItemWithText:(NSString*)text font:(UIFont*)font andColor:(UIColor*)color;

- (void)setBackgroundImage:(UIImage*)image;

@end
