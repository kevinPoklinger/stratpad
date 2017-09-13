//
//  AllowingUsToProgressDetailRow.m
//  StratPad
//
//  Created by Eric Rogers on 11-12-09.
//  Copyright (c) 2011 Glassey Strategy. All rights reserved.
//

#import "AllowingUsToProgressDetailRow.h"
#import "MBDrawableHorizontalLine.h"
#import "MBDrawableVerticalLine.h"
#import "MBDrawableLabel.h"
#import "NSNumber-StratPad.h"

@interface AllowingUsToProgressDetailRow (Private)
- (void)calculateLayoutForRow;
- (void)drawBackground;
- (void)drawLines;
- (void)drawContent;
@end

@implementation AllowingUsToProgressDetailRow

@synthesize lineColor;
@synthesize renderFullWidthBottomBorder;

- (id)initWithRect:(CGRect)rect 
       rowHeading:(NSString*)rowHeading 
       headingFont:(UIFont*)headingFont 
         valueFont:(UIFont*)valueFont 
     andFinancialValues:(NSArray*)financialValues;
{
    if ((self = [super initWithRect:rect])) {
        rowHeading_ = rowHeading;        
        headingFont_ = [headingFont retain];
        valueFont_ = [valueFont retain];
        financialValues_ = [financialValues retain];
    }
    return self;
}

#pragma mark - Memory Management

- (void)dealloc 
{
    [headingFont_ release];
    [valueFont_ release];
    [lineColor release];
    [financialValues_ release];
    [super dealloc];
}

+ (CGFloat)heightWithRowHeading:(NSString*)rowHeading rowWidth:(CGFloat)rowWidth font:(UIFont*)font restrictedToHeight:(CGFloat)maxHeight
{
    CGFloat labelWidth = 0.3f * rowWidth;
    CGSize labelSize = [MBDrawableLabel sizeThatFits:CGSizeMake(labelWidth - 2*kCellPadding, maxHeight) 
                                            withText:rowHeading 
                                             andFont:font 
                                       lineBreakMode:UILineBreakModeWordWrap];
    return labelSize.height + 2*kCellPadding;
}

#pragma mark - Drawable

- (void)draw
{
    [self calculateLayoutForRow];
    
    // only draw a background color if one has been set
    if (self.backgroundColor) {
        [self drawBackground];
    }
    
    [self drawLines];    
    [self drawContent];
}

#pragma mark - Private

- (void)calculateLayoutForRow
{
    valueColumnWidth_ = (endingXForValueColumns_ - startingXForValueColumns_) / financialValues_.count;  //don't render the last quarter date as a column
    
    rowHeight_ = [AllowingUsToProgressDetailRow heightWithRowHeading:rowHeading_ rowWidth:rect_.size.width font:headingFont_ restrictedToHeight:kMaxRowHeight];
}

- (void)drawBackground
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextSetFillColorWithColor(context, [self.backgroundColor CGColor]);
    CGContextFillRect(context, rect_);
    CGContextRestoreGState(context);        
}

- (void)drawLines
{
    CGFloat lineWidth = 1.f;        
    
    // bottom border
    MBDrawableHorizontalLine *bottomBorder;
    if (renderFullWidthBottomBorder) {
        bottomBorder = [[MBDrawableHorizontalLine alloc] initWithOrigin:CGPointMake(rect_.origin.x, 
                                                                                    rect_.origin.y + rect_.size.height - lineWidth) 
                                                                  width:endingXForValueColumns_ - rect_.origin.x 
                                                              thickness:lineWidth 
                                                               andColor:self.lineColor];
    } else {
        bottomBorder = [[MBDrawableHorizontalLine alloc] initWithOrigin:CGPointMake(startingXForValueColumns_, 
                                                                                    rect_.origin.y + rect_.size.height - lineWidth) 
                                                                  width:endingXForValueColumns_ - startingXForValueColumns_ 
                                                              thickness:lineWidth 
                                                               andColor:self.lineColor];
    }
    [bottomBorder draw];
    [bottomBorder release];
    
    // draw left border for the row
    MBDrawableVerticalLine *leftBorder = [[MBDrawableVerticalLine alloc] initWithOrigin:CGPointMake(rect_.origin.x, rect_.origin.y) 
                                                                                 height:rect_.size.height 
                                                                              thickness:lineWidth 
                                                                               andColor:self.lineColor];
    [leftBorder draw];
    [leftBorder release];
    
    // draw left borders for value columns
    MBDrawableVerticalLine *valueColumnLeftBorder;
    for (int i = 0; i < financialValues_.count; i++) {        
        valueColumnLeftBorder = [[MBDrawableVerticalLine alloc] initWithOrigin:CGPointMake(startingXForValueColumns_ + (i * valueColumnWidth_) - lineWidth, rect_.origin.y) 
                                                                        height:rect_.size.height 
                                                                     thickness:lineWidth 
                                                                      andColor:self.lineColor];
        [valueColumnLeftBorder draw];
        [valueColumnLeftBorder release];        
    }
    
    // draw right border for the row
    MBDrawableVerticalLine *rightBorder = [[MBDrawableVerticalLine alloc] initWithOrigin:CGPointMake(endingXForValueColumns_ - lineWidth, rect_.origin.y) 
                                                                                  height:rect_.size.height 
                                                                               thickness:lineWidth 
                                                                                andColor:self.lineColor];
    [rightBorder draw];
    [rightBorder release];
}

- (void)drawContent
{
    CGRect cellRect = CGRectInset([self rectForColumn:0], kCellPadding, kCellPadding);
    MBDrawableLabel *headingLabel = [[MBDrawableLabel alloc] initWithText:rowHeading_ 
                                                                     font:headingFont_ 
                                                                    color:self.fontColor 
                                                            lineBreakMode:UILineBreakModeWordWrap 
                                                                alignment:UITextAlignmentLeft 
                                                                  andRect:cellRect];
    [headingLabel sizeToFit];
    [headingLabel draw];
    [headingLabel release];
    
    NSNumber *quarterlyValue = nil;
    for (uint i = 0; i < financialValues_.count; i++) {        
        
        cellRect = CGRectInset([self rectForColumn:i + 1], kCellPadding, kCellPadding);
        quarterlyValue  = [financialValues_ objectAtIndex:i];
        MBDrawableLabel *valueLabel = [[MBDrawableLabel alloc] initWithText:[quarterlyValue decimalFormattedNumberForCurrencyDisplay]
                                                                       font:valueFont_ color:self.fontColor 
                                                              lineBreakMode:UILineBreakModeTailTruncation 
                                                                  alignment:UITextAlignmentRight 
                                                                    andRect:cellRect];
            [valueLabel draw];
            [valueLabel release];
    }
}

@end
