//
//  MBReportHeader.m
//  StratPad
//
//  Created by Eric on 11-11-16.
//  Copyright (c) 2011 Glassey Strategy. All rights reserved.
//

#import "MBReportHeader.h"
#import "MBDrawableImage.h"
#import "MBDrawableLabel.h"
#import "NSDate-StratPad.h"
#import "DataManager.h"
#import "Settings.h"
#import "EditionManager.h"
#import "UIImage-Expanded.h"
#import "StratFile.h"
#import "StratFileManager.h"
#import "YammerCommentManager.h"

@interface MBReportHeader (Private)
- (void)layoutDrawables;
@end

@implementation MBReportHeader

@synthesize headerImageName = headerImageName_;
@synthesize textInsetLeft = textInsetLeft_;
@synthesize reportTitle = reportTitle_;

@synthesize reportTitleFontName = reportTitleFontName_;
@synthesize reportTitleFontSize = reportTitleFontSize_;
@synthesize reportTitleFontColor = reportTitleFontColor_;

@synthesize shouldDrawLogo = shouldDrawLogo_;

- (id)init
{
    if ((self = [super init])) {
        drawables_ = [[NSMutableArray array] retain];
        titleItems_ = [[NSMutableArray array] retain];
        descriptionItems_ = [[NSMutableArray array] retain];
        shouldDrawLogo_ = YES;
    }
    return self;
}

- (id)initWithRect:(CGRect)rect textInsetLeft:(CGFloat)textInsetLeft
    andReportTitle:(NSString*)reportTitle
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
    [reportTitleFontColor_ release];     
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

#pragma mark - Drawable

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
      
    CGFloat topMargin = 2.f;
    
    // set the current y-position to the top of the rect.
    CGFloat yOffset = rect_.origin.y;
    
    // add headerImage
    CGFloat headerHeight = 104.f; // default, matches the size of the header background image
    if (headerImageName_) {
        UIImage *headerImage = [UIImage imageNamed:headerImageName_];
        MBDrawableImage *header = [[MBDrawableImage alloc] initWithImage:headerImage 
                                                                 andRect:CGRectMake(rect_.origin.x, 
                                                                                    rect_.origin.y, 
                                                                                    rect_.origin.x + headerImage.size.width,                                                                                                    
                                                                                    headerImage.size.height)];
        [drawables_ addObject:header];
        headerHeight = header.rect.size.height;
        [header release];    
    }
    
    // add report title
    yOffset += 10.f;
    MBDrawableLabel *reportTitleLabel = [[MBDrawableLabel alloc] initWithText:reportTitle_ 
                                                                         font:[UIFont fontWithName:reportTitleFontName_ size:reportTitleFontSize_] 
                                                                        color:reportTitleFontColor_ 
                                                                lineBreakMode:UILineBreakModeWordWrap
                                                                    alignment:UITextAlignmentLeft
                                                                      andRect:CGRectMake(rect_.origin.x + textInsetLeft_, yOffset, contentWidth, 2*reportTitleFontSize_)];
    [reportTitleLabel sizeToFit];
    [drawables_ addObject:reportTitleLabel];
    [reportTitleLabel release];

    yOffset += headerHeight + topMargin;

    
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
    BOOL didAddLogo = [[EditionManager sharedManager] isFeatureEnabled:FeatureLogoOnReport] && settings.consultantLogo && shouldDrawLogo_;
    if (didAddLogo) {
        UIImage *imgLogo = settings.consultantLogo;
        CGSize sizeForLogo = [imgLogo sizeForProportionalImageWithMaxDim:logoMaxDim];
        // top right alignment, with some margin
        CGPoint origin = CGPointMake(CGRectGetMaxX(rect_) - logoMargin - logoMaxDim, rect_.origin.y + logoMargin);
        CGRect rectForLogo = CGRectMake(origin.x + (logoMaxDim - sizeForLogo.width),
                                        origin.y,
                                        sizeForLogo.width,
                                        sizeForLogo.height);
        MBDrawableImage *logo = [[MBDrawableImage alloc] initWithImage:imgLogo
                                                               andRect:rectForLogo];
        [drawables_ addObject:logo]; 
        [logo release];
    }
    
    // note that the yammer comments button shows up in the header too, but it is added separately by the VC
}

@end
