//
//  SkinManager.m
//  StratPad
//
//  Created by Julian Wood on 12-01-15.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "SkinManager.h"
#import "SynthesizeSingleton.h"
#import "UIColor-Expanded.h"
#import "ReportPrintFonts.h"

@implementation SkinManager

SYNTHESIZE_SINGLETON_FOR_CLASS(SkinManager);

- (id)init {
    self = [super init];
    if (self) {
        NSString *baseSkinPath = [[NSBundle mainBundle] pathForResource:@"baseskin" ofType:@"plist"];
        baseskin_ = [[NSDictionary dictionaryWithContentsOfFile:baseSkinPath] retain];        
        
        NSString *skinPath = [[NSBundle mainBundle] pathForResource:@"skin" ofType:@"plist"];
        skin_ = [[[NSDictionary dictionaryWithContentsOfFile:skinPath] objectForKey:@"Skin"] retain];        

        NSString *printSkinPath = [[NSBundle mainBundle] pathForResource:@"printskin" ofType:@"plist"];
        printSkin_ = [[NSDictionary dictionaryWithContentsOfFile:printSkinPath] retain];        
    }
    return self;
}

- (UIColor*)colorForProperty:(NSString*)property forMediaType:(MediaType)mediaType
{
    NSString *value = [self stringForProperty:property forMediaType:mediaType];
    if (value) {
        return [UIColor colorWithHexString:value];
    } else {
        return [UIColor redColor];
    }
}

- (UIColor*)colorForProperty:(NSString*)property
{
    return [self colorForProperty:property forMediaType:MediaTypeScreen];
}


- (CGFloat)fontSizeForProperty:(NSString*)property forMediaType:(MediaType)mediaType
{
    NSString *value = [self stringForProperty:property forMediaType:mediaType];
    if (value) {
        return [value floatValue];
    } else {
        return 10.f;
    }
}

- (CGFloat)fontSizeForProperty:(NSString*)property
{
    return [self fontSizeForProperty:property forMediaType:MediaTypeScreen];
}



- (NSString*)stringForProperty:(NSString*)property forMediaType:(MediaType)mediaType
{
    NSDictionary *dict = nil;
    if (mediaType == MediaTypePrint) {
        dict = [printSkin_ objectForKey:property];
    }
    
    // screen or fallback for print
    if (!dict) {
        dict = [skin_ objectForKey:property];
        if (!dict) {
            dict = [baseskin_ objectForKey:property];
            if (!dict) {
                WLog(@"Invalid skin property: %@; mediaType: %i", property, mediaType);
                return nil;
            }
        }        
    }

    return [dict objectForKey:@"Value"];
}

- (NSString*)stringForProperty:(NSString*)property
{
    return [self stringForProperty:property forMediaType:MediaTypeScreen];
}


- (UIImage*)imageForProperty:(NSString*)property forMediaType:(MediaType)mediaType
{
    NSString *value = [self stringForProperty:property forMediaType:mediaType];
    return [UIImage imageNamed:value];
}

- (UIImage*)imageForProperty:(NSString*)property
{
    return [self imageForProperty:property forMediaType:MediaTypeScreen];
}


-(UIFont*)fontWithName:(NSString*)propertyForName andSize:(NSString*)propertyForSize forMediaType:(MediaType)mediaType
{
    NSString *fontName = [self stringForProperty:propertyForName forMediaType:mediaType];
    CGFloat fontSize = [self fontSizeForProperty:propertyForSize forMediaType:mediaType];
    return [UIFont fontWithName:fontName size:fontSize];
}

-(UIFont*)fontWithName:(NSString*)propertyForName andSize:(NSString*)propertyForSize
{
    return [self fontWithName:propertyForName andSize:propertyForSize forMediaType:MediaTypeScreen];
}

- (void)dealloc
{
    [baseskin_ release];
    [printSkin_ release];
    [skin_ release];
    [super dealloc];
}

// --

NSString* const kSkinCanvasImage                            = @"CANVAS_IMAGE";

NSString* const kSkinSidebarBackgroundImage                 = @"SIDEBAR_BACKGROUND_IMAGE";
NSString* const kSkinSidebarSelectedImage                   = @"SIDEBAR_SELECTED_IMAGE";

NSString* const kSkinSidebarSection1ButtonImage             = @"SIDEBAR_SECTION_1_BUTTON_IMAGE";
NSString* const kSkinSidebarSection2ButtonImage             = @"SIDEBAR_SECTION_2_BUTTON_IMAGE";
NSString* const kSkinSidebarSection3ButtonImage             = @"SIDEBAR_SECTION_3_BUTTON_IMAGE";
NSString* const kSkinSidebarSection4ButtonImage             = @"SIDEBAR_SECTION_4_BUTTON_IMAGE";

NSString* const kSkinSidebarSection1ButtonTextColor         = @"SIDEBAR_SECTION_1_BUTTON_TEXT_COLOR";
NSString* const kSkinSidebarSection2ButtonTextColor         = @"SIDEBAR_SECTION_2_BUTTON_TEXT_COLOR";
NSString* const kSkinSidebarSection3ButtonTextColor         = @"SIDEBAR_SECTION_3_BUTTON_TEXT_COLOR";
NSString* const kSkinSidebarSection4ButtonTextColor         = @"SIDEBAR_SECTION_4_BUTTON_TEXT_COLOR";

NSString* const kSkinSection1BackgroundImage                = @"SECTION_1_BACKGROUND_IMAGE";

NSString* const kSkinSection1TitleFontName                  = @"SECTION_1_TITLE_FONT_NAME";
NSString* const kSkinSection1TitleFontSize                  = @"SECTION_1_TITLE_FONT_SIZE";
NSString* const kSkinSection1TitleFontColor                 = @"SECTION_1_TITLE_FONT_COLOR";

NSString* const kSkinSection1SubtitleFontName               = @"SECTION_1_SUBTITLE_FONT_NAME";
NSString* const kSkinSection1SubtitleFontSize               = @"SECTION_1_SUBTITLE_FONT_SIZE";
NSString* const kSkinSection1SubtitleFontColor              = @"SECTION_1_SUBTITLE_FONT_COLOR";

NSString* const kSkinSection1BodyFontName                   = @"SECTION_1_BODY_FONT_NAME";
NSString* const kSkinSection1BodyFontSize                   = @"SECTION_1_BODY_FONT_SIZE";
NSString* const kSkinSection1BodyFontColor                  = @"SECTION_1_BODY_FONT_COLOR";

NSString* const kSkinSection1BodyLinkFontColor              = @"SECTION_1_BODY_LINK_FONT_COLOR";
NSString* const kSkinSection1BodyImportantFontColor         = @"SECTION_1_BODY_IMPORTANT_FONT_COLOR";

NSString* const kSkinSection2BackgroundImage                = @"SECTION_2_BACKGROUND_IMAGE";
NSString* const kSkinSection2FormBackgroundColor            = @"SECTION_2_FORM_BACKGROUND_COLOR";
NSString* const kSkinSection2FormSubtableBackgroundColor    = @"kSkinSection2FormSubtableBackgroundColor";

NSString* const kSkinSection2InfoBoxBackgroundColor         = @"SECTION_2_INFO_BOX_BACKGROUND_COLOR";
NSString* const kSkinSection2InfoBoxStrokeColor             = @"SECTION_2_INFO_BOX_STROKE_COLOR";

NSString* const kSkinSection2InfoBoxFontName                = @"SECTION_2_INFO_BOX_FONT_NAME";
NSString* const kSkinSection2InfoBoxFontSize                = @"SECTION_2_INFO_BOX_FONT_SIZE";
NSString* const kSkinSection2InfoBoxFontColor               = @"SECTION_2_INFO_BOX_FONT_COLOR";

NSString* const kSkinSection2TitleFontName                  = @"SECTION_2_TITLE_FONT_NAME";
NSString* const kSkinSection2TitleFontSize                  = @"SECTION_2_TITLE_FONT_SIZE";
NSString* const kSkinSection2TitleFontColor                 = @"SECTION_2_TITLE_FONT_COLOR";

NSString* const kSkinSection2SubtitleFontName               = @"SECTION_2_SUBTITLE_FONT_NAME";
NSString* const kSkinSection2SubtitleFontSize               = @"SECTION_2_SUBTITLE_FONT_SIZE";
NSString* const kSkinSection2SubtitleFontColor              = @"SECTION_2_SUBTITLE_FONT_COLOR";

NSString* const kSkinSection2BodyFontName                   = @"SECTION_2_BODY_FONT_NAME";
NSString* const kSkinSection2BodyFontSize                   = @"SECTION_2_BODY_FONT_SIZE";
NSString* const kSkinSection2BodyFontSizeSmall              = @"kSkinSection2BodyFontSizeSmall";
NSString* const kSkinSection2BodyFontColor                  = @"SECTION_2_BODY_FONT_COLOR";

NSString* const kSkinSection2FieldLabelFontColor            = @"SECTION_2_FIELD_LABEL_FONT_COLOR";
NSString* const kSkinSection2PlaceHolderFontColor           = @"SECTION_2_PLACE_HOLDER_FONT_COLOR";
NSString* const kSkinSection2TextValueFontColor             = @"SECTION_2_TEXT_VALUE_FONT_COLOR";

NSString* const kSkinSection2TextFieldBackgroundColor       = @"SECTION_2_TEXT_FIELD_BACKGROUND_COLOR";
NSString* const kSkinSection2TextFieldCalculationColor      = @"SECTION_2_TEXT_FIELD_CALCULATION_COLOR";

NSString* const kSkinSection2F1F3FieldLabelFontName         = @"SECTION_2_F1_F3_FIELD_LABEL_FONT_NAME";
NSString* const kSkinSection2F1F3FieldLabelFontSize         = @"SECTION_2_F1_F3_FIELD_LABEL_FONT_SIZE";

NSString* const kSkinSection2F1TextValueFontName            = @"SECTION_2_F1_TEXT_VALUE_FONT_NAME";
NSString* const kSkinSection2F1TextValueFontSize            = @"SECTION_2_F1_TEXT_VALUE_FONT_SIZE";

NSString* const kSkinSection2F2F3TextValueFontName          = @"SECTION_2_F2_F3_TEXT_VALUE_FONT_NAME";
NSString* const kSkinSection2F2F3TextValueFontSize          = @"SECTION_2_F2_F3_TEXT_VALUE_FONT_SIZE";

NSString* const kSkinSection2TableCellBackgroundColor       = @"SECTION_2_TABLE_CELL_BACKGROUND_COLOR";
NSString* const kSkinSection2TableCellFontColor             = @"SECTION_2_TABLE_CELL_FONT_COLOR";

NSString* const kSkinSection2TableCellBoldFontName          = @"SECTION_2_TABLE_CELL_BOLD_FONT_NAME";
NSString* const kSkinSection2TableCellFontName              = @"SECTION_2_TABLE_CELL_FONT_NAME";

NSString* const kSkinSection2TableCellExtraLargeFontSize    = @"SECTION_2_TABLE_CELL_EXTRA_LARGE_FONT_SIZE";
NSString* const kSkinSection2TableCellLargeFontSize         = @"SECTION_2_TABLE_CELL_LARGE_FONT_SIZE";
NSString* const kSkinSection2TableCellMediumFontSize        = @"SECTION_2_TABLE_CELL_MEDIUM_FONT_SIZE";
NSString* const kSkinSection2TableCellSmallFontSize         = @"SECTION_2_TABLE_CELL_SMALL_FONT_SIZE";

NSString* const kSkinSection3BackgroundImage                = @"SECTION_3_BACKGROUND_IMAGE";
NSString* const kSkinSection3HeaderImage                    = @"SECTION_3_HEADER_IMAGE";

NSString* const kSkinSection3FontName                       = @"SECTION_3_FONT_NAME";
NSString* const kSkinSection3BoldFontName                   = @"SECTION_3_BOLD_FONT_NAME";
NSString* const kSkinSection3ItalicFontName                 = @"SECTION_3_ITALIC_FONT_NAME";

NSString* const kSkinSection3FontSize                       = @"SECTION_3_FONT_SIZE";
NSString* const kSkinSection3FontColor                      = @"SECTION_3_FONT_COLOR";

NSString* const kSkinSection3ReportTitleFontSize            = @"SECTION_3_REPORT_TITLE_FONT_SIZE";
NSString* const kSkinSection3ReportTitleFontColor           = @"SECTION_3_REPORT_TITLE_FONT_COLOR";

NSString* const kSkinSection3ReportSubTitleFontSize         = @"SECTION_3_REPORT_SUBTITLE_FONT_SIZE";
NSString* const kSkinSection3ReportSubTitleFontColor        = @"SECTION_3_REPORT_SUBTITLE_FONT_COLOR";

NSString* const kSkinSection3ReportDescriptionFontSize      = @"SECTION_3_REPORT_DESCRIPTION_FONT_SIZE";
NSString* const kSkinSection3ReportDescriptionFontColor     = @"SECTION_3_REPORT_DESCRIPTION_FONT_COLOR";

NSString* const kSkinSection3SectionHeadingFontColor        = @"SECTION_3_SECTION_HEADING_FONT_COLOR";

NSString* const kSkinSection3FinancialAnalysisFontSize      = @"SECTION_3_FINANCIAL_ANALYSIS_FONT_SIZE";

NSString* const kSkinSection3ChartLineColor                 = @"SECTION_3_CHART_LINE_COLOR";
NSString* const kSkinSection3ChartAlternatingRowColor       = @"SECTION_3_CHART_ALTERNATING_ROW_COLOR";
NSString* const kSkinSection3ChartHeadingFontColor          = @"SECTION_3_CHART_HEADING_FONT_COLOR";
NSString* const kSkinSection3ChartFontColor                 = @"SECTION_3_CHART_FONT_COLOR";

NSString* const kSkinSection3HeadingBoxColor                = @"SECTION_3_HEADING_BOX_COLOR";
NSString* const kSkinSection3HeadingBoxFontColor            = @"SECTION_3_HEADING_BOX_FONT_COLOR";

NSString* const kSkinSection3LargeArrowColor                = @"SECTION_3_LARGE_ARROW_COLOR";
NSString* const kSkinSection3SmallArrowColor                = @"SECTION_3_SMALL_ARROW_COLOR";
NSString* const kSkinSection3DiamondColor                   = @"SECTION_3_DIAMOND_COLOR";

NSString* const kSkinSection3StrategyMapFontColor                   = @"SECTION_3_STRATEGY_MAP_FONT_COLOR";
NSString* const kSkinSection3StrategyMapObjectiveFontSize           = @"SECTION_3_STRATEGY_MAP_OBJECTIVE_FONT_SIZE";
NSString* const kSkinSection3StrategyMapStrategyStatementLineColor  = @"SECTION_3_STRATEGY_MAP_STRATEGY_STATEMENT_LINE_COLOR";
NSString* const kSkinSection3StrategyMapStrategyStatementFillColor  = @"SECTION_3_STRATEGY_MAP_STRATEGY_STATEMENT_FILL_COLOR";
NSString* const kSkinSection3StrategyMapThemeBoxColor               = @"SECTION_3_STRATEGY_MAP_THEME_BOX_COLOR";
NSString* const kSkinSection3StrategyMapFinancialObjectiveBoxColor  = @"SECTION_3_STRATEGY_MAP_FINANCIAL_OBJECTIVE_BOX_COLOR";
NSString* const kSkinSection3StrategyMapCustomerObjectiveBoxColor   = @"SECTION_3_STRATEGY_MAP_CUSTOMER_OBJECTIVE_BOX_COLOR";
NSString* const kSkinSection3StrategyMapProcessObjectiveBoxColor    = @"SECTION_3_STRATEGY_MAP_PROCESS_OBJECTIVE_BOX_COLOR";
NSString* const kSkinSection3StrategyMapStaffObjectiveBoxColor      = @"SECTION_3_STRATEGY_MAP_STAFF_OBJECTIVE_BOX_COLOR";

NSString* const kSkinSection4FontSize                    = @"kSkinSection4FontSize";
NSString* const kSkinSection4FontColor                   = @"kSkinSection4FontColor";
NSString* const kSkinSection4GridColor                   = @"kSkinSection4GridColor";

NSString* const kSkinReportCardCommentFontSize           = @"kSkinReportCardCommentFontSize";

NSString* const kSkinTableCellHighlightColor           = @"kSkinTableCellHighlightColor";

@end
