//
//  AllowingUsToProgressChart.m
//  StratPad
//
//  Created by Eric Rogers on September 25, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//
// ...allowing us to progress...
// - same column headings as above (reach these goals)
// - descriptions are Revenue, COGS, Gross Margin, Operating Expenses, Implementation Costs, Total Expenses, Contribution, Cumulative Contribution (make appropriate abbreviations, as necessary)
// - values calculated as per strat financial analysis.
// - if ANY value > 99,999 then present all values as (value/1000), show 5 sig figs, and show ",000s" in heading.  We may have to talk about this further but the point is to only show "-99,999" in each column, although this may look like "-.00999".

#import "AllowingUsToProgressChart.h"
#import "AllowingUsToProgressHeadingRow.h"
#import "AllowingUsToProgressDetailRow.h"
#import "AllowingUsToProgressFooterRow.h"

@interface AllowingUsToProgressChart (Private)

+ (CGFloat)heightWithRowHeading:(NSString*)rowHeading rowWidth:(CGFloat)rowWidth font:(UIFont*)font restrictedToHeight:(CGFloat)maxHeight;

- (NSArray*)valuesForDetailRow:(NSUInteger)row;

@end

@implementation AllowingUsToProgressChart

@synthesize rect = rect_;
@synthesize dataSource = dataSource_;
@synthesize font = font_;
@synthesize boldFont = boldFont_;
@synthesize headingFontColor = headingFontColor_;
@synthesize fontColor = fontColor_;
@synthesize lineColor = lineColor_;
@synthesize alternatingRowColor = alternatingRowColor_;

- (id)initWithRect:(CGRect)rect font:(UIFont*)font boldFont:(UIFont*)boldFont andAllowingUsToProgressDataSource:(AllowingUsToProgressDataSource*)dataSource
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
    [lineColor_ release];
    [headingFontColor_ release];
    [fontColor_ release];    
    [alternatingRowColor_ release];
    
    [super dealloc];
}


- (void)draw
{
    uint y = rect_.origin.y; //init to the top of the rect    
    
    // draw the heading row first
    CGFloat headerRowHeight = [AllowingUsToProgressHeadingRow heightWithRowWidth:rect_.size.width 
                                                                      font:font_
                                                        restrictedToHeight:kMaxRowHeight];
    
    CGRect rowRect = CGRectMake(rect_.origin.x, y, rect_.size.width, headerRowHeight);
    
    AllowingUsToProgressHeadingRow *columnHeadingsRow = [[AllowingUsToProgressHeadingRow alloc] initWithRect:rowRect font:boldFont_ andcolumnDates:dataSource_.columnDates];
    columnHeadingsRow.fontColor = self.headingFontColor;
    columnHeadingsRow.backgroundColor = self.lineColor;
    [columnHeadingsRow draw];
    
    y += columnHeadingsRow.rect.size.height;
    [columnHeadingsRow release];
    
    // now draw the detail rows
    uint detailRowCount = 0;
    uint index = 0;
    NSArray *rowHeadings = [dataSource_ orderedFinancialHeadings];
    NSArray *financialValues = nil;
    for (NSString *heading in rowHeadings) {
        
        financialValues = [dataSource_ financialValuesForHeading:heading];
        
        // only render a detail row if there are financial values to render.
        // practically this is for when the chart has been split into two and the data source will
        // have nil financial values for some rows.
        if (financialValues) {
        
            CGFloat detailRowHeight = [AllowingUsToProgressDetailRow heightWithRowHeading:heading 
                                                                           rowWidth:rect_.size.width 
                                                                               font:boldFont_
                                                                 restrictedToHeight:kMaxRowHeight];
            
            CGRect rowRect = CGRectMake(rect_.origin.x, y, rect_.size.width, detailRowHeight);
            AllowingUsToProgressDetailRow *row = [[AllowingUsToProgressDetailRow alloc] initWithRect:rowRect 
                                                                                          rowHeading:heading
                                                                                         headingFont:boldFont_ 
                                                                                           valueFont:font_
                                                                                  andFinancialValues:financialValues];
            row.lineColor = lineColor_;
            row.fontColor = self.fontColor;
            row.backgroundColor = detailRowCount % 2 == 0 ? alternatingRowColor_ : nil;  // alternate the background color
            
            // the last row should render a full bottom border
            if (detailRowCount == [rowHeadings count] - 1) {
                row.renderFullWidthBottomBorder = YES;
            }
            
            [row draw];
            
            y += row.rect.size.height;
            [row release];
            detailRowCount++;                
        }
        
        index++;
    }
    
    // draw the footer
    CGFloat footerRowHeight = [AllowingUsToProgressFooterRow heightWithRowWidth:rect_.size.width 
                                                                            font:font_
                                                              restrictedToHeight:kMaxRowHeight];
    
    rowRect = CGRectMake(rect_.origin.x, y, rect_.size.width, footerRowHeight);
    
    AllowingUsToProgressFooterRow *footerRow = [[AllowingUsToProgressFooterRow alloc] initWithRect:rowRect font:font_];
    footerRow.significantDigitsTruncated = dataSource_.significantDigitsTruncated;
    footerRow.fontColor = self.fontColor;
    footerRow.backgroundColor = self.lineColor;
    [footerRow draw];
    [footerRow release];
}

- (void)sizeToFit
{
    CGFloat height = 0.f;
    
    // height of the heading row
    height += [AllowingUsToProgressHeadingRow heightWithRowWidth:rect_.size.width 
                                                       font:font_
                                         restrictedToHeight:kMaxRowHeight];

    // heights of each row
    NSArray *financialValues = nil;
    
    for (NSString *heading in [dataSource_ orderedFinancialHeadings]) {
        
        financialValues = [dataSource_ financialValuesForHeading:heading];
        
        // only include those rows that will be rendered in the height calculation.
        if (financialValues) {        
            height += [AllowingUsToProgressDetailRow heightWithRowHeading:heading rowWidth:rect_.size.width font:boldFont_ restrictedToHeight:kMaxRowHeight];
        }
    }
    
    height += [AllowingUsToProgressFooterRow heightWithRowWidth:rect_.size.width font:font_ restrictedToHeight:kMaxRowHeight];
    
    rect_ = CGRectMake(rect_.origin.x, rect_.origin.y, rect_.size.width, height);    
}

+ (CGFloat)heightWithDataSource:(AllowingUsToProgressDataSource*)dataSource font:(UIFont*)font andRowWidth:(CGFloat)rowWidth
{
    CGFloat height = 0.f;
    
    // height of the heading row
    height += [AllowingUsToProgressHeadingRow heightWithRowWidth:rowWidth
                                                            font:font
                                              restrictedToHeight:kMaxRowHeight];

    // heights of each row
    NSArray *financialValues = nil;
    for (NSString *heading in [dataSource orderedFinancialHeadings]) {
        
        financialValues = [dataSource financialValuesForHeading:heading];
        
        // only include those rows that will be rendered in the height calculation.
        if (financialValues) {        
            height += [AllowingUsToProgressDetailRow heightWithRowHeading:heading rowWidth:rowWidth font:font restrictedToHeight:kMaxRowHeight];
        }
    }
    
     height += [AllowingUsToProgressFooterRow heightWithRowWidth:rowWidth font:font restrictedToHeight:kMaxRowHeight];
    
    return height;
}

@end
