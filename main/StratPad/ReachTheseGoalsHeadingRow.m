//
//  ReachTheseGoalsHeadingRow.m
//  StratPad
//
//  Created by Eric Rogers on 11-12-09.
//  Copyright (c) 2011 Glassey Strategy. All rights reserved.
//

#import "ReachTheseGoalsHeadingRow.h"
#import "NSDate-StratPad.h"
#import "MBDrawableLabel.h"

@interface ReachTheseGoalsHeadingRow (Private)
- (void)calculateLayoutForRow;
- (void)drawBackground;
- (void)drawContent;
@end

@implementation ReachTheseGoalsHeadingRow

- (id)initWithRect:(CGRect)rect font:(UIFont*)font andDataSource:(ReachTheseGoalsDataSource*)dataSource
{
    if ((self = [super initWithRect:rect andDataSource:dataSource])) {
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
    CGSize labelSize = [MBDrawableLabel sizeThatFits:CGSizeMake(labelWidth - 2*kCellPadding, maxHeight) 
                                            withText:LocalizedString(@"QUARTERS_STARTING", nil)
                                             andFont:font 
                                       lineBreakMode:UILineBreakModeWordWrap];
    return labelSize.height + 2*kCellPadding;
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
    valueColumnWidth_ = (endingXForValueColumns_ - startingXForValueColumns_) / (dataSource_.columnDates.count - 1);  //don't render the last quarter date as a column
    
    rowHeight_ = [ReachTheseGoalsHeadingRow heightWithRowWidth:rect_.size.width font:font_ restrictedToHeight:kMaxRowHeight];
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
    CGRect cellRect = CGRectInset([self rectForColumn:0], kCellPadding, kCellPadding);
    MBDrawableLabel *headingLabel = [[MBDrawableLabel alloc] initWithText:LocalizedString(@"QUARTERS_STARTING", nil) 
                                                                     font:font_ 
                                                                    color:self.fontColor 
                                                            lineBreakMode:UILineBreakModeWordWrap 
                                                                alignment:UITextAlignmentLeft 
                                                                  andRect:cellRect];
    [headingLabel draw];
    [headingLabel release];
    
    // draw the dates over the quarter columns, don't draw a heading for the last quarter date,
    // since it doesn't render as a column.
    for (uint i = 0; i < dataSource_.columnDates.count - 1; i++) {
        cellRect = CGRectInset([self rectForColumn:i+1], 2, 2);        
        NSDate *quarterDate = [dataSource_.columnDates objectAtIndex:i];
        NSString *formattedDate = [quarterDate formattedMonthYear];
        
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
