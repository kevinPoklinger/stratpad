//
//  AbstractReportDelegate.m
//  StratPad
//
//  Created by Eric on 11-09-21.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "AbstractReportDelegate.h"
#import "StratFileManager.h"
#import "NSDate-StratPad.h"
#import <CoreText/CoreText.h>
#import "MBDrawableLabel.h"
#import "UIColor-Expanded.h"
#import "MBDrawableReportHeader.h"
#import "UIColor-HSVAdditions.h"
#import "NSNumber-StratPad.h"

@implementation NSNumber (AbstractReportDelegate)

- (NSString*)formattedNumberForReports
{
    return [self decimalFormattedNumberForCurrencyDisplay];
}


@end

@implementation AbstractReportDelegate

- (id)init
{
    if ((self = [super init])) {
        reportHelper_ = [[ReportHelper alloc] init];
        screenInsets_ = reportHelper_.screenInsets;
        printInsets_ = reportHelper_.printInsets;
    }
    return self;
}

#pragma mark - Protected

- (NSString*)companyName
{
    return [reportHelper_ companyName];
}

- (NSString*)stratFileName
{
    return [reportHelper_ stratFileName];
}

- (NSString*)reportTitle
{
    return [reportHelper_ reportTitle];
}


#pragma mark - Drawing

+ (void)drawLabelWithText:(NSString*)text 
                   inRect:(CGRect)rect 
                 withFont:(UIFont*)font 
                    color:(UIColor*)color
      horizontalAlignment:(UITextAlignment)horizontalAlignment
     andVerticalAlignment:(VerticalTextAlignment)verticalAlignment;
{      
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGSize size = [text sizeWithFont:font constrainedToSize:rect.size lineBreakMode:UILineBreakModeTailTruncation];
    
    CGContextSaveGState(context);
    
    CGFloat textMarginTop;
    
    switch (verticalAlignment) {
        case VerticalTextAlignmentTop:
            textMarginTop = 0;
            break;
            
        case VerticalTextAlignmentBottom:
            textMarginTop = rect.size.height - 
            size.height;
            break;
            
        default:
            textMarginTop = (rect.size.height-size.height)/2; 
            break;
    }
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    [text drawInRect:CGRectMake(rect.origin.x, rect.origin.y + textMarginTop, rect.size.width, rect.size.height)
            withFont:font
       lineBreakMode:UILineBreakModeTailTruncation 
           alignment:horizontalAlignment];
    
    CGContextRestoreGState(context);
}

+ (CGSize)drawWrappedLabelWithText:(NSString*)text 
                            inRect:(CGRect)rect 
                          withFont:(UIFont*)font 
                             color:(UIColor*)color 
                         alignment:(UITextAlignment)alignment;
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGSize maxSize = CGSizeMake(rect.size.width, 9999);
    CGSize size = [text sizeWithFont:font constrainedToSize:maxSize lineBreakMode:UILineBreakModeWordWrap];
    
    CGContextSaveGState(context);
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    [text drawInRect:CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, size.height)
            withFont:font
       lineBreakMode:UILineBreakModeWordWrap
           alignment:alignment];
    
    CGContextRestoreGState(context);    
    return size;
}

+ (void)drawHorizontalLineAtPoint:(CGPoint)origin width:(CGFloat)width thickness:(CGFloat)thickness color:(UIColor*)color
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, CGRectMake(origin.x, origin.y, width, thickness));
    
    
    CGContextRestoreGState(context);
}

+ (void)verticallyAlignDrawable:(id<Drawable>)drawable inRect:(CGRect)rect withAlignment:(VerticalTextAlignment)alignment
{
    switch (alignment) {
        case VerticalTextAlignmentMiddle:
            [drawable setRect: CGRectMake(drawable.rect.origin.x, 
                                          rect.origin.y + (rect.size.height - drawable.rect.size.height)/2, 
                                          drawable.rect.size.width, 
                                          drawable.rect.size.height)];
            break;
            
        case VerticalTextAlignmentBottom:
            [drawable setRect: CGRectMake(drawable.rect.origin.x, 
                                          rect.origin.y + rect.size.height - drawable.rect.size.height, 
                                          drawable.rect.size.width, 
                                          drawable.rect.size.height)];
            break;
            
        default:
            //top
            [drawable setRect: CGRectMake(drawable.rect.origin.x, 
                                          rect.origin.y,
                                          drawable.rect.size.width, 
                                          drawable.rect.size.height)];
            break;
    }    
}

@end
