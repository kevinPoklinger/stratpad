//
//  ReachTheseGoalsChart.m
//  StratPad
//
//  Created by Eric Rogers on September 24, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//
// - display metrics and targets only.  One line per metric/target.
// - if has numerical target and date, show numerical value in corresponding period column
// - if has alpha target, append text to metric text and show diamond in corresponding period column
// - there are cases where they shouldn't display such as no date or date too far out
// - show column heading "Periods starting:" over metric descriptions
// - show MmmYY as period column headings where the month is the first month of the period
//
// - if all values in the same period are numeric, show their sum.
// - if any of the values are text*, show the diamond.

#import "ReachTheseGoalsChart.h"
#import "ReachTheseGoalsHeadingRow.h"
#import "ReachTheseGoalsDetailRow.h"

@interface ReachTheseGoalsChart (Private)

+ (CGFloat)heightWithGoalHeading:(NSString*)goalHeading rowWidth:(CGFloat)rowWidth font:(UIFont*)font restrictedToHeight:(CGFloat)maxHeight;

@end


@implementation ReachTheseGoalsChart

@synthesize rect = rect_;
@synthesize dataSource = dataSource_;
@synthesize font = font_;
@synthesize boldFont = boldFont_;
@synthesize headingFontColor = headingFontColor_;
@synthesize fontColor = fontColor_;
@synthesize lineColor = lineColor_;
@synthesize alternatingRowColor = alternatingRowColor_;
@synthesize diamondColor = diamondColor_;

- (id)initWithRect:(CGRect)rect font:(UIFont*)font boldFont:(UIFont*)boldFont andDataSource:(ReachTheseGoalsDataSource*)dataSource
{
    if ((self = [super init])) {        
        rect_ = rect;
        font_ = [font retain];
        boldFont_ = [boldFont retain];
        dataSource_ = [dataSource retain];        
    }
    return self;
}


#pragma mark - Memory Management

- (void)dealloc
{
    [font_ release];
    [boldFont_ release];
    [dataSource_ release];
    [lineColor_ release];
    [headingFontColor_ release];
    [fontColor_ release];
    [alternatingRowColor_ release];
    [diamondColor_ release];
    [super dealloc];
}


#pragma mark - Drawable

- (void)draw
{   
    uint y = rect_.origin.y; //init to the top of the rect    
    
    // draw the heading row first
    CGFloat rowHeight = [ReachTheseGoalsHeadingRow heightWithRowWidth:rect_.size.width 
                                                             font:font_
                                               restrictedToHeight:kMaxRowHeight];

    CGRect rowRect = CGRectMake(rect_.origin.x, y, rect_.size.width, rowHeight);
    
    ReachTheseGoalsHeadingRow *headingRow = [[ReachTheseGoalsHeadingRow alloc] initWithRect:rowRect font:boldFont_ andDataSource:dataSource_];
    headingRow.fontColor = self.headingFontColor;
    headingRow.backgroundColor = self.lineColor;
    [headingRow draw];
        
    y += headingRow.rect.size.height;
    [headingRow release];
    
    // now draw the goal rows
    uint goalRowCount = 0;
    NSArray *goalHeadings = [dataSource_ goalHeadings];
    for (NSString *heading in goalHeadings) {
        
        CGFloat rowHeight = [ReachTheseGoalsDetailRow heightWithGoalHeading:heading 
                                                             rowWidth:rect_.size.width 
                                                                 font:boldFont_
                                                   restrictedToHeight:kMaxRowHeight];
        
        CGRect rowRect = CGRectMake(rect_.origin.x, y, rect_.size.width, rowHeight);
        ReachTheseGoalsDetailRow *row = [[ReachTheseGoalsDetailRow alloc] initWithRect:rowRect 
                                                               goalHeading:heading
                                                               headingFont:boldFont_ 
                                                                  valueFont:font_
                                                             andDataSource:dataSource_];
        row.lineColor = lineColor_;
        row.fontColor = self.fontColor;
        row.diamondColor = self.diamondColor;
        row.backgroundColor = goalRowCount % 2 == 0 ? alternatingRowColor_ : nil;  // alternate the background color

        // the last row should render a full bottom border
        if (goalRowCount == [[dataSource_ goalHeadings] count] - 1) {
            row.renderFullWidthBottomBorder = YES;
        }
        
        [row draw];
        
        y += row.rect.size.height;
        [row release];        
        
        goalRowCount++;                
    }
}

- (void)sizeToFit
{
    CGFloat height = 0.f;
    
    // height of the heading row
    height += [ReachTheseGoalsHeadingRow heightWithRowWidth:rect_.size.width 
                                                       font:boldFont_
                                         restrictedToHeight:kMaxRowHeight];
    
    // heights of each goal row
    for (NSString *heading in [dataSource_ goalHeadings]) {
        height += [ReachTheseGoalsDetailRow heightWithGoalHeading:heading rowWidth:rect_.size.width font:boldFont_ restrictedToHeight:kMaxRowHeight];
    }

    rect_ = CGRectMake(rect_.origin.x, rect_.origin.y, rect_.size.width, height);    
}

+ (CGFloat)heightWithDataSource:(ReachTheseGoalsDataSource*)dataSource font:(UIFont*)font andRowWidth:(CGFloat)rowWidth
{
    CGFloat height = 0.f;
    
    // height of the heading row
    height += [ReachTheseGoalsHeadingRow heightWithRowWidth:rowWidth
                                                       font:font
                                         restrictedToHeight:kMaxRowHeight];

    // heights of each goal row
    for (NSString *heading in [dataSource goalHeadings]) {
        height += [ReachTheseGoalsDetailRow heightWithGoalHeading:heading rowWidth:rowWidth font:font restrictedToHeight:kMaxRowHeight];
    }
    
    return height;
}

+ (CGFloat)heightWithGoalHeading:(NSString*)goalHeading rowWidth:(CGFloat)rowWidth font:(UIFont*)font restrictedToHeight:(CGFloat)maxHeight
{
    return [ReachTheseGoalsDetailRow heightWithGoalHeading:goalHeading rowWidth:rowWidth font:font restrictedToHeight:maxHeight];
}

@end
