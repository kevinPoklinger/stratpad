//
//  ReportPrintFonts.h
//  StratPad
//
//  Created by Eric Rogers on October 21, 2011.
//  Copyright (c) 2011 Glassey Strategy. All rights reserved.
//
//  Central configuration of fonts and colours used in the reports.
//  The general idea is that most reports should adhere to the following font style:
//  Heading 1: Bold - all caps.
//  Subheading 1: Bold
//  Subheading 2: Italic (Oblique)
//  Body Text: Regular


// deprecated: use the SkinManager instead; these props are all in printskin.plist

// each of these should have a corresponding (identically keyed) value in both skin and printskin
// if a value is not in printskin, then use the skin value
// these are all for section 3 (reports)


#import "UIColor-Expanded.h"

// font names used in the reports
#define fontNameForPrint                @"Helvetica"            //kSkinSection3FontName
#define boldFontNameForPrint            @"Helvetica-Bold"       //kSkinSection3BoldFontName
#define obliqueFontNameForPrint         @"Helvetica-Oblique"    //kSkinSection3ItalicName

// size of the main title (text in gradient) in the report header
#define reportHeaderTitleFontSizeForPrint       14.f
#define reportHeaderTitleFontColorForPrint      [UIColor whiteColor]

// size of the font for the title items in the report header
#define reportHeaderSubTitleFontSizeForPrint    12.f    

// size of the font for the description items in the report header for both screen and print
#define reportHeaderDescriptionFontSizeForPrint 10.f     

// color for the font in the report header
#define reportHeaderFontColorForPrint           [UIColor blackColor]

// color used for section headings in reports
#define sectionHeadingFontColorForPrint         [UIColor blackColor]

// color of font used to display regular text in reports
#define textFontColorForPrint                   [UIColor blackColor]

// color of the text contained within a chart
#define chartHeadingFontColorForPrint           [UIColor blackColor]
#define chartFontColorForPrint                  [UIColor blackColor]

// colors for arrows, their corresponding lines, and diamonds in the reports
#define chartLargeArrowColorForPrint    [UIColor colorWithHexString:@"5FA736"]
#define chartSmallArrowColorForPrint    [UIColor colorWithHexString:@"818181"]
#define chartDiamondColorForPrint       [UIColor colorWithHexString:@"1D648F"]

// line color and alternating row color for charts
#define chartLineColorForPrint              [UIColor colorWithHexString:@"D9D9D9"]
#define chartAlternatingRowColorForPrint    [UIColor colorWithHexString:@"F2F2F2"]

// font sizes for reports R1, R6 - R9
#define textFontSizeForPrint         10.f // kSkinSection3FontSize

// font sizes for reports R2 - R5.
#define financialAnalysisFontSizeForPrint   8.f

// font colours specific to the theme detail report
#define themeDetailHeadingBoxColorForPrint                  [UIColor colorWithHexString:@"1B668F"]
#define themeDetailHeadingFontColorForPrint                 [UIColor whiteColor]
