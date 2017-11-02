//
//  SkinManager.h
//  StratPad
//
//  Created by Julian Wood on 12-01-15.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//
//  Add new properties to baseskin.plist. All properties should be in here as final fallback.
//  For each specific skin, including print, add any differences.
//  So if not in print.plist, we fall back to skin.plist.
//  If not in skin.plist, we fall back to baseskin.plist (and then some default error value for now, until all values are in basicskin.plist).

#import <Foundation/Foundation.h>

typedef enum {
    MediaTypePrint,
    MediaTypeScreen
} MediaType;

@interface SkinManager : NSObject
{
    NSDictionary *skin_;
    NSDictionary *baseskin_;
    NSDictionary *printSkin_;
}

+ (SkinManager *)sharedManager;

- (UIColor*)colorForProperty:(NSString*)property forMediaType:(MediaType)mediaType;
- (UIColor*)colorForProperty:(NSString*)property;

- (CGFloat)fontSizeForProperty:(NSString*)property forMediaType:(MediaType)mediaType;
- (CGFloat)fontSizeForProperty:(NSString*)property;

- (NSString*)stringForProperty:(NSString*)property forMediaType:(MediaType)mediaType;
- (NSString*)stringForProperty:(NSString*)property;

- (UIImage*)imageForProperty:(NSString*)property forMediaType:(MediaType)mediaType;
- (UIImage*)imageForProperty:(NSString*)property;

- (UIFont*)fontWithName:(NSString*)propertyForName andSize:(NSString*)propertyForSize forMediaType:(MediaType)mediaType;
- (UIFont*)fontWithName:(NSString*)propertyForName andSize:(NSString*)propertyForSize;

#pragma mark - Skin Properties


extern NSString* const kSkinSkinCanvasImage;

extern NSString* const kSkinSidebarBackgroundImage;
extern NSString* const kSkinSidebarSelectedImage;

extern NSString* const kSkinSidebarSection1ButtonImage;
extern NSString* const kSkinSidebarSection2ButtonImage;
extern NSString* const kSkinSidebarSection3ButtonImage;
extern NSString* const kSkinSidebarSection4ButtonImage;

extern NSString* const kSkinSidebarSection1ButtonTextColor;
extern NSString* const kSkinSidebarSection2ButtonTextColor;
extern NSString* const kSkinSidebarSection3ButtonTextColor;
extern NSString* const kSkinSidebarSection4ButtonTextColor;

extern NSString* const kSkinSection1BackgroundImage;

extern NSString* const kSkinSection1TitleFontName;
extern NSString* const kSkinSection1TitleFontSize;
extern NSString* const kSkinSection1TitleFontColor;

extern NSString* const kSkinSection1SubtitleFontName;
extern NSString* const kSkinSection1SubtitleFontSize;
extern NSString* const kSkinSection1SubtitleFontColor;

extern NSString* const kSkinSection1BodyFontName;
extern NSString* const kSkinSection1BodyFontSize;
extern NSString* const kSkinSection1BodyFontColor;

extern NSString* const kSkinSection1BodyLinkFontColor;
extern NSString* const kSkinSection1BodyImportantFontColor;

extern NSString* const kSkinSection2BackgroundImage;
extern NSString* const kSkinSection2FormBackgroundColor;
extern NSString* const kSkinSection2FormSubtableBackgroundColor;

extern NSString* const kSkinSection2InfoBoxBackgroundColor;
extern NSString* const kSkinSection2InfoBoxStrokeColor;

extern NSString* const kSkinSection2InfoBoxFontName;
extern NSString* const kSkinSection2InfoBoxFontSize;
extern NSString* const kSkinSection2InfoBoxFontColor;

extern NSString* const kSkinSection2TitleFontName;
extern NSString* const kSkinSection2TitleFontSize;
extern NSString* const kSkinSection2TitleFontColor;

extern NSString* const kSkinSection2SubtitleFontName;
extern NSString* const kSkinSection2SubtitleFontSize;
extern NSString* const kSkinSection2SubtitleFontColor;

extern NSString* const kSkinSection2BodyFontName;
extern NSString* const kSkinSection2BodyFontSize;
extern NSString* const kSkinSection2BodyFontSizeSmall;
extern NSString* const kSkinSection2BodyFontColor;

extern NSString* const kSkinSection2FieldLabelFontColor;
extern NSString* const kSkinSection2PlaceHolderFontColor;
extern NSString* const kSkinSection2TextValueFontColor;

extern NSString* const kSkinSection2TextFieldBackgroundColor;
extern NSString* const kSkinSection2TextFieldCalculationColor;

extern NSString* const kSkinSection2F1F3FieldLabelFontName;
extern NSString* const kSkinSection2F1F3FieldLabelFontSize;

extern NSString* const kSkinSection2F1TextValueFontName;
extern NSString* const kSkinSection2F1TextValueFontSize;

extern NSString* const kSkinSection2F2F3TextValueFontName;
extern NSString* const kSkinSection2F2F3TextValueFontSize;
extern NSString* const kSkinSection2TableCellBackgroundColor;
extern NSString* const kSkinSection2TableCellFontColor;

extern NSString* const kSkinSection2TableCellBoldFontName;
extern NSString* const kSkinSection2TableCellFontName;

extern NSString* const kSkinSection2TableCellExtraLargeFontSize;
extern NSString* const kSkinSection2TableCellLargeFontSize;
extern NSString* const kSkinSection2TableCellMediumFontSize;
extern NSString* const kSkinSection2TableCellSmallFontSize;

extern NSString* const kSkinSection3BackgroundImage;
extern NSString* const kSkinSection3HeaderImage;

extern NSString* const kSkinSection3FontName;
extern NSString* const kSkinSection3BoldFontName;
extern NSString* const kSkinSection3ItalicFontName;

extern NSString* const kSkinSection3FontSize;
extern NSString* const kSkinSection3FontColor;

extern NSString* const kSkinSection3ReportTitleFontSize;
extern NSString* const kSkinSection3ReportTitleFontColor;

extern NSString* const kSkinSection3ReportSubTitleFontSize;
extern NSString* const kSkinSection3ReportSubTitleFontColor;

extern NSString* const kSkinSection3ReportDescriptionFontSize;
extern NSString* const kSkinSection3ReportDescriptionFontColor;

extern NSString* const kSkinSection3SectionHeadingFontColor;

extern NSString* const kSkinSection3FinancialAnalysisFontSize;

extern NSString* const kSkinSection3ChartLineColor;
extern NSString* const kSkinSection3ChartAlternatingRowColor;
extern NSString* const kSkinSection3ChartHeadingFontColor;
extern NSString* const kSkinSection3ChartFontColor;

extern NSString* const kSkinSection3HeadingBoxColor;
extern NSString* const kSkinSection3HeadingBoxFontColor;

extern NSString* const kSkinSection3LargeArrowColor;
extern NSString* const kSkinSection3SmallArrowColor;
extern NSString* const kSkinSection3DiamondColor;

extern NSString* const kSkinSection3StrategyMapFontColor;
extern NSString* const kSkinSection3StrategyMapObjectiveFontSize;
extern NSString* const kSkinSection3StrategyMapStrategyStatementLineColor;
extern NSString* const kSkinSection3StrategyMapStrategyStatementFillColor;
extern NSString* const kSkinSection3StrategyMapThemeBoxColor;
extern NSString* const kSkinSection3StrategyMapFinancialObjectiveBoxColor;
extern NSString* const kSkinSection3StrategyMapCustomerObjectiveBoxColor;
extern NSString* const kSkinSection3StrategyMapProcessObjectiveBoxColor;
extern NSString* const kSkinSection3StrategyMapStaffObjectiveBoxColor;

extern NSString* const kSkinSection4FontSize;
extern NSString* const kSkinSection4FontColor;
extern NSString* const kSkinSection4GridColor;

extern NSString* const kSkinReportCardCommentFontSize;
extern NSString* const kSkinTableCellHighlightColor;

@end
