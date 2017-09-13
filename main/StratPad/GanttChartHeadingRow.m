//
//  GanttChartHeadingRow.m
//  StratPad
//
//  Created by Eric Rogers on 11-12-09.
//  Copyright (c) 2011 Glassey Strategy. All rights reserved.
//

#import "GanttChartHeadingRow.h"
#import "NSDate-StratPad.h"
#import "MBDrawableLabel.h"

@interface GanttChartHeadingRow (Private)
- (void)calculateLayoutForRow;
- (void)drawBackground;
- (void)drawContent;
@end

@implementation GanttChartHeadingRow

static const CGFloat kCellXPadding = 2.f;

- (id)initWithRect:(CGRect)rect font:(UIFont*)font andcolumnDates:(NSArray*)columnDates
{
    if ((self = [super initWithRect:rect andColumnDates:columnDates])) {
        font_ = [font retain];
    }
    return self;
}

#pragma mark - Memory Management

- (void)dealloc 
{
    [font_ release];
    [super dealloc];
}

+ (CGFloat)heightWithRowWidth:(CGFloat)rowWidth font:(UIFont*)font restrictedToHeight:(CGFloat)maxHeight
{
    CGFloat labelWidth = 0.3f * rowWidth;
    CGSize labelSize = [MBDrawableLabel sizeThatFits:CGSizeMake(labelWidth - 2*kCellXPadding, maxHeight) 
                                            withText:LocalizedString(@"QUARTERS_STARTING", nil)
                                             andFont:font 
                                       lineBreakMode:UILineBreakModeWordWrap];
    return labelSize.height + 2*kCellYPadding;
}

#pragma mark - Drawable

- (void)draw
{
    [self calculateLayoutForRow];    
    [self drawBackground];
    [self drawContent];
}

#pragma mark - Private

- (void)calculateLayoutForRow
{
    // subtract 1, since we don't want to render the last quarter date as a column
    valueColumnWidth_ = (endingXForValueColumns_ - startingXForValueColumns_) / (columnDates_.count - 1);          
    rowHeight_ = [GanttChartHeadingRow heightWithRowWidth:rect_.size.width font:font_ restrictedToHeight:kMaxRowHeight];
}

- (void)drawBackground
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextSetFillColorWithColor(context, [self.backgroundColor CGColor]);
    CGContextFillRect(context, rect_);
    CGContextRestoreGState(context);        
}

- (void)drawContent
{
    CGRect cellRect = CGRectInset([self rectForColumn:0], kCellXPadding, kCellYPadding);
    MBDrawableLabel *headingLabel = [[MBDrawableLabel alloc] initWithText:LocalizedString(@"QUARTERS_STARTING", nil) 
                                                                     font:font_ 
                                                                    color:self.fontColor 
                                                            lineBreakMode:UILineBreakModeWordWrap 
                                                                alignment:UITextAlignmentLeft 
                                                                  andRect:cellRect];
    [headingLabel draw];
    [headingLabel release];
    
    // draw the dates over the columns, don't draw a heading for the last column date,
    // since it doesn't render as a column.
    for (uint i = 0; i < columnDates_.count - 1; i++) {
        cellRect = CGRectInset([self rectForColumn:i+1], kCellXPadding, kCellYPadding);        
        NSDate *columnDate = [columnDates_ objectAtIndex:i];
        NSString *formattedDate = [columnDate formattedMonthYear];
        
        MBDrawableLabel *dateLabel = [[MBDrawableLabel alloc] initWithText:formattedDate 
                                                                      font:font_ 
                                                                     color:self.fontColor 
                                                             lineBreakMode:UILineBreakModeTailTruncation 
                                                                 alignment:UITextAlignmentLeft
                                                                   andRect:cellRect];
        [dateLabel draw];
        [dateLabel release];
    }    
    
}

@end
