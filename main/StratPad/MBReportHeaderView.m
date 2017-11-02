//
//  MBReportHeaderView.m
//  StratPad
//
//  Created by Eric Rogers on October 14, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "MBReportHeaderView.h"
#import "ApplicationSkin.h"
#import "UIColor-Expanded.h"

@implementation MBReportHeaderView

- (void)awakeFromNib
{
    ApplicationSkin *skin = [ApplicationSkin currentSkin];
    
    reportHeader_ = [[MBReportHeader alloc] init];
    reportHeader_.headerImageName = skin.section3HeaderImage;
    reportHeader_.reportTitleFontName = skin.section3BoldFontName;
    reportHeader_.reportTitleFontSize = [skin.section3ReportTitleFontSize floatValue];
    reportHeader_.reportTitleFontColor = [UIColor colorWithHexString:skin.section3ReportTitleFontColor];
    
    [reportHeader_ setRect:self.bounds];
    self.backgroundColor = [UIColor clearColor];
}


#pragma mark - Memory Management

- (void)dealloc
{
    [reportHeader_ release];
    [super dealloc];
}

#pragma mark - Public

- (void)setTextInsetLeft:(CGFloat)textInsetLeft
{
    [reportHeader_ setTextInsetLeft:textInsetLeft];
}

- (void)setReportTitle:(NSString*)reportTitle
{
    [reportHeader_ setReportTitle:reportTitle];
}

- (void)setBackgroundImage:(UIImage*)image
{
    [reportHeader_ setHeaderImageName:nil];
}

- (void)addTitleItemWithText:(NSString*)text font:(UIFont*)font andColor:(UIColor*)color
{
    [reportHeader_ addTitleItemWithText:text font:font andColor:color];
}

- (void)addDescriptionItemWithText:(NSString*)text font:(UIFont*)font andColor:(UIColor*)color
{
    [reportHeader_ addDescriptionItemWithText:text font:font andColor:color];
}

- (void)setShouldDrawLogo:(BOOL)shouldDrawLogo
{
    [reportHeader_ setShouldDrawLogo:shouldDrawLogo];
}

- (BOOL)shouldDrawLogo
{
    return reportHeader_.shouldDrawLogo;
}


#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
    [reportHeader_ draw];
}

@end
