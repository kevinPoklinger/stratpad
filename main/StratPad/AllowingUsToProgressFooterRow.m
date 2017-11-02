//
//  AllowingUsToProgressFooterRow.m
//  StratPad
//
//  Created by Eric Rogers on 11-12-09.
//  Copyright (c) 2011 Glassey Strategy. All rights reserved.
//

#import "AllowingUsToProgressFooterRow.h"
#import "MBDrawableLabel.h"
#import "Settings.h"
#import "DataManager.h"

@interface AllowingUsToProgressFooterRow (Private)
- (void)calculateLayoutForRow;
- (void)drawContent;
@end

@implementation AllowingUsToProgressFooterRow

@synthesize significantDigitsTruncated;

- (id)initWithRect:(CGRect)rect font:(UIFont*)font
{
    if ((self = [super initWithRect:rect])) {
        font_ = [font retain];
        
        textRect_ = CGRectMake(startingXForValueColumns_, rect_.origin.y, endingXForValueColumns_ - startingXForValueColumns_, rect_.size.height);
        textRect_ = CGRectInset(textRect_, kCellPadding, kCellPadding);
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
                                            withText:LocalizedString(@"ALLOWING_US_TO_PROGRESS_FOOTER_THOUSANDS_TEMPLATE", nil)
                                             andFont:font 
                                       lineBreakMode:UILineBreakModeTailTruncation];
    return labelSize.height + 2*kCellPadding;
}

#pragma mark - Drawable

- (void)draw
{
    [self calculateLayoutForRow];    
    [self drawContent];
}

#pragma mark - Private

- (void)calculateLayoutForRow
{
    rowHeight_ = [AllowingUsToProgressFooterRow heightWithRowWidth:rect_.size.width font:font_ restrictedToHeight:30];
}

- (void)drawContent
{
    Settings *settings = (Settings*)[DataManager objectForEntity:NSStringFromClass([Settings class]) 
                                            sortDescriptorsOrNil:nil 
                                                  predicateOrNil:nil];
    
    NSString *footerText;
    if (self.significantDigitsTruncated) {
        footerText = [NSString stringWithFormat:LocalizedString(@"ALLOWING_US_TO_PROGRESS_FOOTER_THOUSANDS_TEMPLATE", nil), [settings currency], LocalizedString(@"ROUNDING_DISCLAIMER_SHORT", nil)];
    } else {
        footerText = [NSString stringWithFormat:LocalizedString(@"ALLOWING_US_TO_PROGRESS_FOOTER_TEMPLATE", nil), [settings currency], LocalizedString(@"ROUNDING_DISCLAIMER_SHORT", nil)];        
    }

    MBDrawableLabel *label = [[MBDrawableLabel alloc] initWithText:footerText
                                                              font:font_ 
                                                             color:self.fontColor
                                                     lineBreakMode:UILineBreakModeTailTruncation 
                                                         alignment:UITextAlignmentLeft 
                                                           andRect:textRect_];
    [label sizeToFit];
    [label draw];
    [label release];
}

@end
