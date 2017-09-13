//
//  ReachTheseGoalsDetailRow.m
//  StratPad
//
//  Created by Eric Rogers on 11-12-09.
//  Copyright (c) 2011 Glassey Strategy. All rights reserved.
//

#import "ReachTheseGoalsDetailRow.h"
#import "MBDrawableHorizontalLine.h"
#import "MBDrawableVerticalLine.h"
#import "MBDrawableLabel.h"
#import "MBDiamond.h"
#import "TextGoal.h"
#import "NumericGoal.h"

@interface ReachTheseGoalsDetailRow (Private)
- (void)calculateLayoutForRow;
- (void)drawBackground;
- (void)drawLines;
- (void)drawContent;
@end

@implementation ReachTheseGoalsDetailRow

@synthesize backgroundColor;
@synthesize lineColor;
@synthesize fontColor;
@synthesize diamondColor; 
@synthesize renderFullWidthBottomBorder;

- (id)initWithRect:(CGRect)rect 
       goalHeading:(NSString*)goalHeading 
       headingFont:(UIFont*)headingFont 
         valueFont:(UIFont*)valueFont 
     andDataSource:(ReachTheseGoalsDataSource*)dataSource;
{
    if ((self = [super initWithRect:rect andDataSource:dataSource])) {
        goalHeading_ = goalHeading;        
        headingFont_ = [headingFont retain];
        valueFont_ = [valueFont retain];
    }
    return self;
}

#pragma mark - Memory Management

- (void)dealloc 
{
    [headingFont_ release];
    [valueFont_ release];
    [lineColor release];
    [diamondColor release];
    [super dealloc];
}

+ (CGFloat)heightWithGoalHeading:(NSString*)goalHeading rowWidth:(CGFloat)rowWidth font:(UIFont*)font restrictedToHeight:(CGFloat)maxHeight
{
    CGFloat labelWidth = 0.3f * rowWidth;
    CGSize labelSize = [MBDrawableLabel sizeThatFits:CGSizeMake(labelWidth - 2*kCellPadding, maxHeight) 
                                            withText:goalHeading 
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
    valueColumnWidth_ = (endingXForValueColumns_ - startingXForValueColumns_) / (dataSource_.columnDates.count - 1);  //don't render the last quarter date as a column
    
    rowHeight_ = [ReachTheseGoalsDetailRow heightWithGoalHeading:goalHeading_ rowWidth:rect_.size.width font:headingFont_ restrictedToHeight:kMaxRowHeight];
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
    for (int i = 0; i < dataSource_.columnDates.count - 1; i++) {        
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
    MBDrawableLabel *headingLabel = [[MBDrawableLabel alloc] initWithText:goalHeading_ 
                                                                     font:headingFont_ 
                                                                    color:self.fontColor 
                                                            lineBreakMode:UILineBreakModeWordWrap 
                                                                alignment:UITextAlignmentLeft 
                                                                  andRect:cellRect];
    [headingLabel draw];
    [headingLabel release];
    
    NSArray *goalsForCell;    
    for (uint i = 0; i < dataSource_.columnDates.count - 1; i++) {        

        goalsForCell = [dataSource_ goalsForHeading:goalHeading_ fromColumnDateAtIndex:i];               
        cellRect = CGRectInset([self rectForColumn:i + 1], kCellPadding, kCellPadding);
        
        int goalSum = 0;
        
        // the idea here is if any of the goals are text, draw a diamond.
        // if not, then sum the values up and display the sum in the cell.
        for (id<Goal>goal in goalsForCell) {
            if ([goal isKindOfClass:[TextGoal class]]) {
                         
                CGFloat diamondRadius = 16.f;
                
                // center the diamond vertically in the cell
                CGRect diamondRect = CGRectMake(cellRect.origin.x, 
                                                cellRect.origin.y + (cellRect.size.height - diamondRadius)/2, 
                                                diamondRadius,   
                                                diamondRadius);
                
                MBDiamond *diamond = [[MBDiamond alloc] initWithRect:diamondRect];
                diamond.color = self.diamondColor;
                [diamond draw];
                [diamond release];
                return;
            } else {
                // pad the rect for the value text                
                goalSum += [((NumericGoal*)goal).value intValue];
            }
        }
        
        // only show non-zero values...
        if (goalSum != 0) {
            // todo: move vertical centering option into MBDrawableLabel init
            NSString *text = [NSString stringWithFormat:@"%i", goalSum];
            CGSize size = [MBDrawableLabel sizeThatFits:cellRect.size withText:text andFont:valueFont_ lineBreakMode:UILineBreakModeTailTruncation];
            CGRect centeredRect = CGRectMake(cellRect.origin.x, cellRect.origin.y + (cellRect.size.height-size.height)/2, cellRect.size.width, size.height);
            
            MBDrawableLabel *valueLabel = [[MBDrawableLabel alloc] initWithText:[NSString stringWithFormat:@"%i", goalSum] 
                                                                           font:valueFont_ color:self.fontColor 
                                                                  lineBreakMode:UILineBreakModeTailTruncation 
                                                                      alignment:UITextAlignmentRight 
                                                                        andRect:centeredRect];
            [valueLabel draw];
            [valueLabel release];
        }
    }
}

@end
