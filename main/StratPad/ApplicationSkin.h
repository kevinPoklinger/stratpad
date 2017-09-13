//
//  ApplicationSkin.h
//  StratPad
//
//  Created by Eric on 11-11-13.
//  Copyright (c) 2011 Glassey Strategy. All rights reserved.
//
//  Encapsulates a configuration for the application's look and feel.
//  Obtains this configuration from a plist file for a skin.

@interface ApplicationSkin : NSObject {
}

// name of the main background image behind all pages in the application.
@property(nonatomic, readonly) NSString *canvasImage;

// name of the background image for the sidebar.
@property(nonatomic, readonly) NSString *sidebarBackgroundImage;

// name of the image that indicates selection of a button in the sidebar.
@property(nonatomic, readonly) NSString *sidebarSelectedImage;
        
// name of the button images in the sidebar.
@property(nonatomic, readonly) NSString *sidebarSection1ButtonImage;
@property(nonatomic, readonly) NSString *sidebarSection2ButtonImage;
@property(nonatomic, readonly) NSString *sidebarSection3ButtonImage;

// color of the text in the buttons in the sidebar
@property(nonatomic, readonly) NSString *sidebarSection1ButtonTextColor;
@property(nonatomic, readonly) NSString *sidebarSection2ButtonTextColor;
@property(nonatomic, readonly) NSString *sidebarSection3ButtonTextColor;

// name of the background image to use in section 1.
@property(nonatomic, readonly) NSString *section1BackgroundImage;

// font-family, font-size, and color of title text in section 1.
@property(nonatomic, readonly) NSString *section1TitleFontName;
@property(nonatomic, readonly) NSString *section1TitleFontSize;
@property(nonatomic, readonly) NSString *section1TitleFontColor;

// font-family, font-size, and color of subtitle text in section 1.
@property(nonatomic, readonly) NSString *section1SubtitleFontName;
@property(nonatomic, readonly) NSString *section1SubtitleFontSize;
@property(nonatomic, readonly) NSString *section1SubtitleFontColor;

// font-family, font-size, and color of body text in section 1.
@property(nonatomic, readonly) NSString *section1BodyFontName;
@property(nonatomic, readonly) NSString *section1BodyFontSize;
@property(nonatomic, readonly) NSString *section1BodyFontColor;

// color of anchors in the body text of section 1.
@property(nonatomic, readonly) NSString *section1BodyLinkFontColor;

// color of important body text in section 1.
@property(nonatomic, readonly) NSString *section1BodyImportantFontColor;


// name of the background image to use in section 2.
@property(nonatomic, readonly) NSString *section2BackgroundImage;

// hex string representing the form background color for section 2.
@property(nonatomic, readonly) NSString *section2FormBackgroundColor;

// hex string representing the background color for info boxes in section 2.
@property(nonatomic, readonly) NSString *section2InfoBoxBackgroundColor;

// hex string representing the stroke color for info boxes in section 2.
@property(nonatomic, readonly) NSString *section2InfoBoxStrokeColor;

// font name, size, and color for the text in info boxes for section 2.
@property(nonatomic, readonly) NSString *section2InfoBoxFontName;
@property(nonatomic, readonly) NSString *section2InfoBoxFontSize;
@property(nonatomic, readonly) NSString *section2InfoBoxFontColor;

// font name, size, and color for the main title text in section 2.
@property(nonatomic, readonly) NSString *section2TitleFontName;
@property(nonatomic, readonly) NSString *section2TitleFontSize;
@property(nonatomic, readonly) NSString *section2TitleFontColor;

// font name, size, and color for the sub title text in section 2.
@property(nonatomic, readonly) NSString *section2SubtitleFontName;
@property(nonatomic, readonly) NSString *section2SubtitleFontSize;
@property(nonatomic, readonly) NSString *section2SubtitleFontColor;

// font name, size, and color for the body text in section 2.
@property(nonatomic, readonly) NSString *section2BodyFontName;
@property(nonatomic, readonly) NSString *section2BodyFontSize;
@property(nonatomic, readonly) NSString *section2BodyFontColor;

// color to use for all field labels in section 2.
@property(nonatomic, readonly) NSString *section2FieldLabelFontColor;

// color to use for placeholder text values in text views in section 2.
@property(nonatomic, readonly) NSString *section2PlaceHolderFontColor;

// color to use for all text values in section 2.
@property(nonatomic, readonly) NSString *section2TextValueFontColor;

// background color to use for all opaque text fields in F5, F6, and F7 section 2.
@property(nonatomic, readonly) NSString *section2TextFieldBackgroundColor;

// font name and size for field labels for forms F1 to F3 in section 2.
@property(nonatomic, readonly) NSString *section2F1F3FieldLabelFontName;
@property(nonatomic, readonly) NSString *section2F1F3FieldLabelFontSize;

// font name and size for text values for form F1 in section 2.
@property(nonatomic, readonly) NSString *section2F1TextValueFontName;
@property(nonatomic, readonly) NSString *section2F1TextValueFontSize;

// font name and size for text values for form F2 and F3 in section 2.
@property(nonatomic, readonly) NSString *section2F2F3TextValueFontName;
@property(nonatomic, readonly) NSString *section2F2F3TextValueFontSize;

// background color for table cells in section 2.
@property(nonatomic, readonly) NSString *section2TableCellBackgroundColor;

// font names and color for text in table cells for section 2.
@property(nonatomic, readonly) NSString *section2TableCellFontName;
@property(nonatomic, readonly) NSString *section2TableCellBoldFontName;
@property(nonatomic, readonly) NSString *section2TableCellFontColor;

// font sizes for text in table cells for section 2.
@property(nonatomic, readonly) NSString *section2TableCellExtraLargeFontSize;
@property(nonatomic, readonly) NSString *section2TableCellLargeFontSize;
@property(nonatomic, readonly) NSString *section2TableCellMediumFontSize;
@property(nonatomic, readonly) NSString *section2TableCellSmallFontSize;

// background image name for section 3.
@property(nonatomic, readonly) NSString *section3BackgroundImage;

// header image name for section 3.
@property(nonatomic, readonly) NSString *section3HeaderImage;

// font names for section 3.
@property(nonatomic, readonly) NSString *section3FontName;
@property(nonatomic, readonly) NSString *section3BoldFontName;
@property(nonatomic, readonly) NSString *section3ItalicFontName;

// font size and color for the report title in section 3.
@property(nonatomic, readonly) NSString *section3ReportTitleFontSize;
@property(nonatomic, readonly) NSString *section3ReportTitleFontColor;

// font size and color for the report subtitle in section 3.
@property(nonatomic, readonly) NSString *section3ReportSubTitleFontSize;
@property(nonatomic, readonly) NSString *section3ReportSubTitleFontColor;

// font size and color for the report description text in section 3.
@property(nonatomic, readonly) NSString *section3ReportDescriptionFontSize;
@property(nonatomic, readonly) NSString *section3ReportDescriptionFontColor;

// font size for reports R1, R6 - R9 in section 3.
@property(nonatomic, readonly) NSString *section3TextFontSize;

// font color for section heading text in reports in section 3.
@property(nonatomic, readonly) NSString *section3SectionHeadingFontColor;

// font color for regular text in reports in section 3.
@property(nonatomic, readonly) NSString *section3TextFontColor;

// font sizes for reports R2 - R5 in section 3.
@property(nonatomic, readonly) NSString *section3FinancialAnalysisFontSize;

// colors used in charts in section 3.
@property(nonatomic, readonly) NSString *section3ChartLineColor;
@property(nonatomic, readonly) NSString *section3ChartAlternatingRowColor;
@property(nonatomic, readonly) NSString *section3ChartHeadingFontColor;
@property(nonatomic, readonly) NSString *section3ChartFontColor;

// color of the heading boxes and their font in R5 in section 3.
@property(nonatomic, readonly) NSString *section3HeadingBoxColor;
@property(nonatomic, readonly) NSString *section3HeadingBoxFontColor;

// colors of arrows and diamonds for the Gantt chart in section 3.
@property(nonatomic, readonly) NSString *section3LargeArrowColor;
@property(nonatomic, readonly) NSString *section3SmallArrowColor;
@property(nonatomic, readonly) NSString *section3DiamondColor;

// inits the skin with the name of a plist containing the skin configuration.
- (id)initWithSkinResource:(NSString*)resource;

// returns the current skin for the application as defined in settings,
// or the default one (DefaultSkin), if none has been set.
+ (ApplicationSkin*)currentSkin;

@end
