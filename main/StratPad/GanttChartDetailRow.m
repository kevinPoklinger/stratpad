//
//  GanttChartDetailRow.m
//  StratPad
//
//  Created by Eric Rogers on 11-12-10.
//  Copyright (c) 2011 Glassey Strategy. All rights reserved.
//

#import "GanttChartDetailRow.h"
#import "MBDrawableLabel.h"
#import "MBDrawableHorizontalLine.h"
#import "MBDrawableVerticalLine.h"

@implementation GanttChartDetailRow

@synthesize lineColor;
@synthesize renderFullWidthBottomBorder;

- (id)initWithRect:(CGRect)rect headingFont:(UIFont*)headingFont columnDates:(NSArray*)columnDates 
  andGanttTimeline:(GanttTimeline*)timeline andMediaType:(MediaType)mediaType;

{
    if ((self = [super initWithRect:rect andColumnDates:columnDates])) {
        timeline_ = [timeline retain];
        headingFont_ = [headingFont retain];
        mediaType_ = mediaType;
    }
    return self;
}

#pragma mark - Memory Management

- (void)dealloc 
{
    [timeline_ release];
    [headingFont_ release];
    [super dealloc];
}

#pragma mark - Public

+(UIEdgeInsets)rowHeaderInsets
{
    // defaults
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

+ (CGFloat)heightWithTitle:(NSString*)title rowWidth:(CGFloat)rowWidth font:(UIFont*)font restrictedToHeight:(CGFloat)maxHeight insets:(UIEdgeInsets)insets
{
    CGFloat labelWidth = 0.3f * rowWidth;
    CGSize labelSize = [MBDrawableLabel sizeThatFits:CGSizeMake(labelWidth - insets.left - insets.right, maxHeight) 
                                            withText:title 
                                             andFont:font 
                                       lineBreakMode:UILineBreakModeWordWrap];
    return labelSize.height + 2*kCellYPadding;
}

- (void)drawBackground
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextSetFillColorWithColor(context, [self.backgroundColor CGColor]);
    CGContextFillRect(context, rect_);
    CGContextRestoreGState(context);        
}

- (void)calculateLayoutForRow:(UIEdgeInsets)insets
{
    // subtract 1, since we don't want to render the last quarter date as a column
    valueColumnWidth_ = (endingXForValueColumns_ - startingXForValueColumns_) / (columnDates_.count - 1);
    rowHeight_ = [GanttChartDetailRow heightWithTitle:timeline_.title rowWidth:rect_.size.width font:headingFont_ restrictedToHeight:kMaxRowHeight insets:insets];
}


- (void)drawLines
{
    CGFloat lineWidth = 1.f;        
    
    // bottom border
    MBDrawableHorizontalLine *bottomBorder;
    if (self.renderFullWidthBottomBorder) {
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
    for (int i = 0; i < columnDates_.count - 1; i++) {        
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

@end
