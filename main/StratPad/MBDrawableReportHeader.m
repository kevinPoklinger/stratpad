//
//  MBDrawableReportHeader.m
//  StratPad
//
//  Created by Eric Rogers on October 13, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "MBDrawableReportHeader.h"
#import "MBDrawableImage.h"
#import "MBDrawableLabel.h"
#import "NSDate-StratPad.h"
#import "ReportPrintFonts.h"
#import "EditionManager.h"
#import "DataManager.h"
#import "Settings.h"
#import "UIImage-Expanded.h"

@interface MBDrawableReportHeader (Private)
- (void)layoutDrawables;
@end

@implementation MBDrawableReportHeader

@synthesize textInsetLeft = textInsetLeft_;
@synthesize reportTitle = reportTitle_;

- (id)init
{
    if ((self = [super init])) {
        drawables_ = [[NSMutableArray array] retain];
        titleItems_ = [[NSMutableArray array] retain];
        descriptionItems_ = [[NSMutableArray array] retain];
    }
    return self;
}

- (id)initWithRect:(CGRect)rect textInsetLeft:(CGFloat)textInsetLeft andReportTitle:(NSString*)reportTitle
{
    if ((self = [self init])) {        
        rect_ = rect;
        self.textInsetLeft = textInsetLeft;
        self.reportTitle = reportTitle;
    }
    return self;
}


#pragma mark - Memory Management

- (void)dealloc
{
    [drawables_ release];
    [titleItems_ release];
    [descriptionItems_ release];
    [super dealloc];
}


#pragma mark - Public

- (void)addTitleItemWithText:(NSString*)text font:(UIFont*)font andColor:(UIColor*)color
{
    MBDrawableLabel *label = [[MBDrawableLabel alloc] initWithText:text font:font color:color lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentLeft andRect:CGRectZero];
    [titleItems_ addObject:label];
    [label release];
}

- (void)addDescriptionItemWithText:(NSString*)text font:(UIFont*)font andColor:(UIColor*)color
{
    MBDrawableLabel *label = [[MBDrawableLabel alloc] initWithText:text font:font color:color lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentLeft andRect:CGRectZero];
    [descriptionItems_ addObject:label];
    [label release];
}

- (CGRect)rect
{
    return rect_;
}

- (void)setRect:(CGRect)rect
{
    rect_ = rect;
}

- (void)draw
{
    // ensure we only perform the layout once.
    if (drawables_.count == 0) {
        [self layoutDrawables];
    }
    
    for (id<Drawable> drawable in drawables_) {
        [drawable draw];
    }    
}

- (void)sizeToFit
{
    CGFloat height = 0;
    
    // ensure we only perform the layout once.
    if (drawables_.count == 0) {
        [self layoutDrawables];
    }

    for (id<Drawable> drawable in drawables_) {
        if (drawable.rect.origin.y - rect_.origin.y + drawable.rect.size.height > height) {
            height = drawable.rect.origin.y - rect_.origin.y + drawable.rect.size.height;
        }
    }    
    
    rect_ = CGRectMake(rect_.origin.x, rect_.origin.y, rect_.size.width, height);    
}


#pragma mark - Private

- (void)layoutDrawables
{    
    CGFloat contentWidth = rect_.size.width - textInsetLeft_;
    
    CGFloat leftColumnWidth = 0.75f * contentWidth;
    // right column (for the icon) will be 0.25f * contentWidth
    
    CGFloat topMargin = 2.f;
    
    // set the current y-position to the top of the rect.
    CGFloat yOffset = rect_.origin.y;
    
    // add gradient - see maxDim below for logo
    MBDrawableImage *gradient = [[MBDrawableImage alloc] initWithImage:[UIImage imageNamed:@"report-header-background-blue.png"] andRect:CGRectMake(rect_.origin.x, rect_.origin.y, rect_.size.width - 75, 20.f)];
    [drawables_ addObject:gradient];
    [gradient release];    
    
    // add report title
    MBDrawableLabel *reportTitleLabel = [[MBDrawableLabel alloc] initWithText:reportTitle_ font:[UIFont fontWithName:boldFontNameForPrint size:reportHeaderTitleFontSizeForPrint] color:reportHeaderTitleFontColorForPrint lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentCenter andRect:CGRectMake(rect_.origin.x + textInsetLeft_, yOffset, leftColumnWidth, 20.f)];
    [reportTitleLabel sizeToFit];
    [drawables_ addObject:reportTitleLabel];
    [reportTitleLabel release];
    
    yOffset += reportTitleLabel.rect.size.height + topMargin;
    
    // process the title items
    for (MBDrawableLabel *titleLabel in titleItems_) {
        [titleLabel setRect:CGRectMake(rect_.origin.x + textInsetLeft_, yOffset, contentWidth - textInsetLeft_, titleLabel.font.pointSize + 3.f)];
        [titleLabel sizeToFit];
        [drawables_ addObject:titleLabel];
        
        yOffset += titleLabel.rect.size.height + topMargin;
    }   
    
    // add some space between the title items and the description items.
    if (descriptionItems_.count > 0) {
        yOffset += 5.f;
    }
    
    // process the description items
    for (MBDrawableLabel *descriptionLabel in descriptionItems_) {
        [descriptionLabel setRect:CGRectMake(rect_.origin.x + textInsetLeft_, yOffset, contentWidth - textInsetLeft_, descriptionLabel.font.pointSize + 3.f)];
        [descriptionLabel sizeToFit];
        [drawables_ addObject:descriptionLabel];
        
        yOffset += descriptionLabel.rect.size.height + topMargin;
    }
    
    // company logo
    Settings *settings = (Settings*)[DataManager objectForEntity:NSStringFromClass([Settings class]) 
                                            sortDescriptorsOrNil:nil
                                                  predicateOrNil:nil];
    if ([[EditionManager sharedManager] isFeatureEnabled:FeatureLogoOnReport] && settings.consultantLogo) {
        CGFloat maxDim = 75; // for print, remember
        UIImage *imgLogo = settings.consultantLogo;
        CGSize sizeForLogo = [imgLogo sizeForProportionalImageWithMaxDim:maxDim];
        CGFloat margin = 0.f;
        // top, right alignment
        CGPoint origin = CGPointMake(CGRectGetMaxX(rect_) - margin - maxDim, rect_.origin.y + margin);
        CGRect rectForLogo = CGRectMake(origin.x + (maxDim - sizeForLogo.width),
                                        origin.y,
                                        sizeForLogo.width,
                                        sizeForLogo.height);
        MBDrawableImage *logo = [[MBDrawableImage alloc] initWithImage:imgLogo 
                                                               andRect:rectForLogo];
        [drawables_ addObject:logo];
        [logo release];
    }

}

@end
