//
//  ReportCardHeader.m
//  StratPad
//
//  Created by Julian Wood on 12-05-15.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "ReportCardHeader.h"
#import "UIColor-Expanded.h"
#import "ReportCardPrinter.h"
#import "NSDate-StratPad.h"
#import "Responsible.h"

#define lineSpacer  2.f
#define lineHeight  12.f

@implementation ReportCardHeader

@synthesize rect = rect_;
@synthesize themeKey = themeKey_;

- (id)initWithThemeKey:(ThemeKey*)themeKey rect:(CGRect)rect
{
    self = [super init];
    if (self) {
        self.themeKey = themeKey;
        rect_ = rect;
        padding_ = UIEdgeInsetsMake(3, 5, 3, 5);
        [self sizeToFit];
    }
    return self;
}

- (void)dealloc
{
    [themeKey_ release];
    [super dealloc];
}

- (void)sizeToFit
{
    // figure out appropriate height
    CGFloat height = 3*lineHeight + padding_.top + padding_.bottom + 2*lineSpacer;
    rect_ = CGRectMake(rect_.origin.x, rect_.origin.y, rect_.size.width, height);
}

- (void)draw
{
    CGContextRef context = UIGraphicsGetCurrentContext();    
    CGContextSaveGState(context);
    
    // background for text    
    CGContextAddRect(context, rect_);
    CGContextClip(context);
    
    // make the gradient
    UIColor *colorStart = [UIColor colorWithHexString:@"1B668F"];
    UIColor *colorEnd = [UIColor whiteColor];
    
    CGFloat colors [] = { 
        colorStart.red, colorStart.green, colorStart.blue, 0.9,
        colorEnd.red, colorEnd.green, colorEnd.blue, 0.9
    };
    
    CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, colors, NULL, 2);
    CGColorSpaceRelease(baseSpace), baseSpace = NULL;
    
    // draw the gradient in our clipped area
    CGPoint startPoint = CGPointMake(CGRectGetMinX(rect_), CGRectGetMidY(rect_));
    CGPoint endPoint = CGPointMake(CGRectGetMaxX(rect_), CGRectGetMidY(rect_));
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGGradientRelease(gradient);
        
    // the text  
    CGFloat titleWidth = 150.f;
    CGRect textRect = CGRectMake(rect_.origin.x+padding_.left, rect_.origin.y+padding_.top, rect_.size.width-titleWidth-padding_.right, lineHeight);
    CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
        
    // theme
    NSString *themeText = [NSString stringWithFormat:@"Theme: %@", themeKey_.title];
    [themeText drawInRect:textRect 
                 withFont:[UIFont fontWithName:reportCardFontNameBold size:reportCardFontSize]
            lineBreakMode:UILineBreakModeTailTruncation
                alignment:UITextAlignmentLeft];
    
    // date text
    textRect.origin.y = textRect.origin.y + lineHeight + lineSpacer;
    NSString *dateText = [NSString stringWithFormat:@"- from %@ to %@", 
                          [[themeKey_ startDate] formattedDate1],
                          [[themeKey_ endDate] formattedDate1]
                          ];
    [dateText drawInRect:textRect 
                withFont:[UIFont fontWithName:reportCardFontName size:reportCardFontSize]
           lineBreakMode:UILineBreakModeTailTruncation
               alignment:UITextAlignmentLeft];
    

    // responsible text
    if (themeKey_.responsible) {
        textRect.origin.y = textRect.origin.y + lineHeight + lineSpacer;
        NSString *responsibleText = [NSString stringWithFormat:@"- %@ responsible", themeKey_.responsible];
        [responsibleText drawInRect:textRect 
                           withFont:[UIFont fontWithName:reportCardFontName size:reportCardFontSize]
                      lineBreakMode:UILineBreakModeTailTruncation
                          alignment:UITextAlignmentLeft];
    }
    

    // Report Card title
    CGContextSetFillColorWithColor(context, [[UIColor colorWithHexString:@"2B4853"] CGColor]);    
    textRect = CGRectMake(CGRectGetMaxX(rect_) - titleWidth - padding_.right, rect_.origin.y+padding_.top, titleWidth, reportCardFontSize*2.5);
    [LocalizedString(@"REPORT_CARD", nil) drawInRect:textRect 
                                              withFont:[UIFont fontWithName:reportCardFontNameBold size:reportCardFontSize*2.5]
                                         lineBreakMode:UILineBreakModeClip
                                             alignment:UITextAlignmentRight];
    
    
    // date
    textRect.origin.y = CGRectGetMaxY(rect_) - padding_.bottom - lineHeight;
    NSString *dateString = [NSString stringWithFormat:@"at %@", [[NSDate date] formattedDate2]];
    [dateString drawInRect:textRect 
                      withFont:[UIFont fontWithName:reportCardFontNameBold size:reportCardFontSize]
                 lineBreakMode:UILineBreakModeClip
                     alignment:UITextAlignmentRight];
    
    CGContextRestoreGState(context);        
}

@end
