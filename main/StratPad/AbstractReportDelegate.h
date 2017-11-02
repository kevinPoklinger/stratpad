//
//  AbstractReportDelegate.h
//  StratPad
//
//  Created by Eric on 11-09-21.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//
//  @deprecated use ReportHelper to delegate work rather than subclass

#import "MBPDFView.h"
#import "Report.h"
#import "ReportPageBuilder.h"
#import "ReportHelper.h"

typedef enum {
    VerticalTextAlignmentTop,
    VerticalTextAlignmentMiddle,
    VerticalTextAlignmentBottom
} VerticalTextAlignment;


@interface AbstractReportDelegate : NSObject<Report> {
@private
    ReportHelper *reportHelper_;
@protected
    // standard insets for page layout on screen
    UIEdgeInsets screenInsets_;
    
    // standard insets for page layout in print
    UIEdgeInsets printInsets_;        
}

// DEPRECATED: should make an object ala MBDrawableLabel
// draws a label with the given text, in the given rect using the given font, color, alignments and context.
+ (void)drawLabelWithText:(NSString*)text 
                   inRect:(CGRect)rect 
                 withFont:(UIFont*)font 
                    color:(UIColor*)color
      horizontalAlignment:(UITextAlignment)horizontalAlignment
     andVerticalAlignment:(VerticalTextAlignment)verticalAlignment;

// DEPRECATED: should make an object ala MBDrawableLabel
// basically fills the rect with the specified color
+ (void)drawHorizontalLineAtPoint:(CGPoint)origin width:(CGFloat)width thickness:(CGFloat)thickness color:(UIColor*)color;

// DEPRECATED: should make an object ala MBDrawableLabel
// draws a label that wraps and is dynamic in height, with the given text, in the 
// given rect using the given font, color, alignment and context.
// Returns its rendered size.
+ (CGSize)drawWrappedLabelWithText:(NSString*)text 
                            inRect:(CGRect)rect 
                          withFont:(UIFont*)font 
                             color:(UIColor*)color 
                         alignment:(UITextAlignment)alignment;

@end

@interface AbstractReportDelegate (Protected)

// vertically aligns the given drawable in the given rect according to the given vertical alignment.
+ (void)verticallyAlignDrawable:(id<Drawable>)drawable inRect:(CGRect)rect withAlignment:(VerticalTextAlignment)alignment;

- (NSString*)companyName;
- (NSString*)stratFileName;

// must be overridden
- (NSString*)reportTitle;

@end

@interface NSNumber (AbstractReportDelegate)

// uses parentheses for negative, grouping, shows zeroes when nil, shows ### when larger than maxDisplayableValue
- (NSString*)formattedNumberForReports;

@end

