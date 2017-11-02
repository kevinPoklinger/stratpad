//
//  ApplicationSkin.m
//  StratPad
//
//  Created by Eric on 11-11-13.
//  Copyright (c) 2011 Glassey Strategy. All rights reserved.
//

#import "ApplicationSkin.h"
#import "Settings.h"
#import "DataManager.h"

// name of the plist file containing the skin for the app.
static NSString *kApplicationSkinFile                       = @"skin";

// These constants define the properties that we look for in a skin plist file.
static NSString *kCanvasImageKey                            = @"CANVAS_IMAGE";

static NSString *kSidebarBackgroundImageKey                 = @"SIDEBAR_BACKGROUND_IMAGE";
static NSString *kSidebarSelectedImageKey                   = @"SIDEBAR_SELECTED_IMAGE";

static NSString *kSidebarSection1ButtonImageKey             = @"SIDEBAR_SECTION_1_BUTTON_IMAGE";
static NSString *kSidebarSection2ButtonImageKey             = @"SIDEBAR_SECTION_2_BUTTON_IMAGE";
static NSString *kSidebarSection3ButtonImageKey             = @"SIDEBAR_SECTION_3_BUTTON_IMAGE";

static NSString *kSidebarSection1ButtonTextColorKey         = @"SIDEBAR_SECTION_1_BUTTON_TEXT_COLOR";
static NSString *kSidebarSection2ButtonTextColorKey         = @"SIDEBAR_SECTION_2_BUTTON_TEXT_COLOR";
static NSString *kSidebarSection3ButtonTextColorKey         = @"SIDEBAR_SECTION_3_BUTTON_TEXT_COLOR";

static NSString *kSection1BackgroundImageKey                = @"SECTION_1_BACKGROUND_IMAGE";

static NSString *kSection1TitleFontNameKey                  = @"SECTION_1_TITLE_FONT_NAME";
static NSString *kSection1TitleFontSizeKey                  = @"SECTION_1_TITLE_FONT_SIZE";
static NSString *kSection1TitleFontColorKey                 = @"SECTION_1_TITLE_FONT_COLOR";

static NSString *kSection1SubtitleFontNameKey               = @"SECTION_1_SUBTITLE_FONT_NAME";
static NSString *kSection1SubtitleFontSizeKey               = @"SECTION_1_SUBTITLE_FONT_SIZE";
static NSString *kSection1SubtitleFontColorKey              = @"SECTION_1_SUBTITLE_FONT_COLOR";

static NSString *kSection1BodyFontNameKey                   = @"SECTION_1_BODY_FONT_NAME";
static NSString *kSection1BodyFontSizeKey                   = @"SECTION_1_BODY_FONT_SIZE";
static NSString *kSection1BodyFontColorKey                  = @"SECTION_1_BODY_FONT_COLOR";

static NSString *kSection1BodyLinkFontColorKey              = @"SECTION_1_BODY_LINK_FONT_COLOR";
static NSString *kSection1BodyImportantFontColorKey         = @"SECTION_1_BODY_IMPORTANT_FONT_COLOR";

static NSString *kSection2BackgroundImageKey                = @"SECTION_2_BACKGROUND_IMAGE";
static NSString *kSection2FormBackgroundColorKey            = @"SECTION_2_FORM_BACKGROUND_COLOR";

static NSString *kSection2InfoBoxBackgroundColorKey         = @"SECTION_2_INFO_BOX_BACKGROUND_COLOR";
static NSString *kSection2InfoBoxStrokeColorKey             = @"SECTION_2_INFO_BOX_STROKE_COLOR";

static NSString *kSection2InfoBoxFontNameKey                = @"SECTION_2_INFO_BOX_FONT_NAME";
static NSString *kSection2InfoBoxFontSizeKey                = @"SECTION_2_INFO_BOX_FONT_SIZE";
static NSString *kSection2InfoBoxFontColorKey               = @"SECTION_2_INFO_BOX_FONT_COLOR";

static NSString *kSection2TitleFontNameKey                  = @"SECTION_2_TITLE_FONT_NAME";
static NSString *kSection2TitleFontSizeKey                  = @"SECTION_2_TITLE_FONT_SIZE";
static NSString *kSection2TitleFontColorKey                 = @"SECTION_2_TITLE_FONT_COLOR";

static NSString *kSection2SubtitleFontNameKey               = @"SECTION_2_SUBTITLE_FONT_NAME";
static NSString *kSection2SubtitleFontSizeKey               = @"SECTION_2_SUBTITLE_FONT_SIZE";
static NSString *kSection2SubtitleFontColorKey              = @"SECTION_2_SUBTITLE_FONT_COLOR";

static NSString *kSection2BodyFontNameKey                   = @"SECTION_2_BODY_FONT_NAME";
static NSString *kSection2BodyFontSizeKey                   = @"SECTION_2_BODY_FONT_SIZE";
static NSString *kSection2BodyFontColorKey                  = @"SECTION_2_BODY_FONT_COLOR";

static NSString *kSection2FieldLabelFontColorKey            = @"SECTION_2_FIELD_LABEL_FONT_COLOR";
static NSString *kSection2PlaceHolderFontColorKey           = @"SECTION_2_PLACE_HOLDER_FONT_COLOR";
static NSString *kSection2TextValueFontColorKey             = @"SECTION_2_TEXT_VALUE_FONT_COLOR";

static NSString *kSection2TextFieldBackgroundColorKey       = @"SECTION_2_TEXT_FIELD_BACKGROUND_COLOR";

static NSString *kSection2F1F3FieldLabelFontNameKey         = @"SECTION_2_F1_F3_FIELD_LABEL_FONT_NAME";
static NSString *kSection2F1F3FieldLabelFontSizeKey         = @"SECTION_2_F1_F3_FIELD_LABEL_FONT_SIZE";

static NSString *kSection2F1TextValueFontNameKey            = @"SECTION_2_F1_TEXT_VALUE_FONT_NAME";
static NSString *kSection2F1TextValueFontSizeKey            = @"SECTION_2_F1_TEXT_VALUE_FONT_SIZE";

static NSString *kSection2F2F3TextValueFontNameKey          = @"SECTION_2_F2_F3_TEXT_VALUE_FONT_NAME";
static NSString *kSection2F2F3TextValueFontSizeKey          = @"SECTION_2_F2_F3_TEXT_VALUE_FONT_SIZE";
    
static NSString *kSection2TableCellBackgroundColorKey       = @"SECTION_2_TABLE_CELL_BACKGROUND_COLOR";
static NSString *kSection2TableCellFontColorKey             = @"SECTION_2_TABLE_CELL_FONT_COLOR";

static NSString *kSection2TableCellBoldFontNameKey          = @"SECTION_2_TABLE_CELL_BOLD_FONT_NAME";
static NSString *kSection2TableCellFontNameKey              = @"SECTION_2_TABLE_CELL_FONT_NAME";

static NSString *kSection2TableCellExtraLargeFontSizeKey    = @"SECTION_2_TABLE_CELL_EXTRA_LARGE_FONT_SIZE";
static NSString *kSection2TableCellLargeFontSizeKey         = @"SECTION_2_TABLE_CELL_LARGE_FONT_SIZE";
static NSString *kSection2TableCellMediumFontSizeKey        = @"SECTION_2_TABLE_CELL_MEDIUM_FONT_SIZE";
static NSString *kSection2TableCellSmallFontSizeKey         = @"SECTION_2_TABLE_CELL_SMALL_FONT_SIZE";

static NSString *kSection3BackgroundImageKey                = @"SECTION_3_BACKGROUND_IMAGE";
static NSString *kSection3HeaderImageKey                    = @"SECTION_3_HEADER_IMAGE";

static NSString *kSection3FontNameKey                       = @"SECTION_3_FONT_NAME";
static NSString *kSection3BoldFontNameKey                   = @"SECTION_3_BOLD_FONT_NAME";
static NSString *kSection3ItalicFontNameKey                 = @"SECTION_3_ITALIC_FONT_NAME";

static NSString *kSection3ReportTitleFontSizeKey            = @"SECTION_3_REPORT_TITLE_FONT_SIZE";
static NSString *kSection3ReportTitleFontColorKey           = @"SECTION_3_REPORT_TITLE_FONT_COLOR";

static NSString *kSection3ReportSubTitleFontSizeKey         = @"SECTION_3_REPORT_SUBTITLE_FONT_SIZE";
static NSString *kSection3ReportSubTitleFontColorKey        = @"SECTION_3_REPORT_SUBTITLE_FONT_COLOR";

static NSString *kSection3ReportDescriptionFontSizeKey      = @"SECTION_3_REPORT_DESCRIPTION_FONT_SIZE";
static NSString *kSection3ReportDescriptionFontColorKey     = @"SECTION_3_REPORT_DESCRIPTION_FONT_COLOR";

static NSString *kSection3SectionHeadingFontColorKey        = @"SECTION_3_SECTION_HEADING_FONT_COLOR";

static NSString *kSection3TextFontSizeKey                   = @"SECTION_3_FONT_SIZE";
static NSString *kSection3TextFontColorKey                  = @"SECTION_3_FONT_COLOR";

static NSString *kSection3FinancialAnalysisFontSizeKey      = @"SECTION_3_FINANCIAL_ANALYSIS_FONT_SIZE";

static NSString *kSection3ChartLineColorKey                 = @"SECTION_3_CHART_LINE_COLOR";
static NSString *kSection3ChartAlternatingRowColorKey       = @"SECTION_3_CHART_ALTERNATING_ROW_COLOR";
static NSString *kSection3ChartHeadingFontColorKey          = @"SECTION_3_CHART_HEADING_FONT_COLOR";
static NSString *kSection3ChartFontColorKey                 = @"SECTION_3_CHART_FONT_COLOR";

static NSString *kSection3HeadingBoxColorKey                = @"SECTION_3_HEADING_BOX_COLOR";
static NSString *kSection3HeadingBoxFontColorKey            = @"SECTION_3_HEADING_BOX_FONT_COLOR";

static NSString *kSection3LargeArrowColorKey                = @"SECTION_3_LARGE_ARROW_COLOR";
static NSString *kSection3SmallArrowColorKey                = @"SECTION_3_SMALL_ARROW_COLOR";
static NSString *kSection3DiamondColorKey                   = @"SECTION_3_DIAMOND_COLOR";

@interface ApplicationSkin (Private)

- (void)configureWithPlistDictionary:(NSDictionary*)dict;

- (NSString*)valueForKey:(NSString*)key fromSkinDictionary:(NSDictionary*)dict;

@end


@implementation ApplicationSkin

@synthesize canvasImage;

@synthesize sidebarBackgroundImage;
@synthesize sidebarSelectedImage;

@synthesize sidebarSection1ButtonImage;
@synthesize sidebarSection2ButtonImage;
@synthesize sidebarSection3ButtonImage;

@synthesize sidebarSection1ButtonTextColor;
@synthesize sidebarSection2ButtonTextColor;
@synthesize sidebarSection3ButtonTextColor;

@synthesize section1BackgroundImage;

@synthesize section1TitleFontName;
@synthesize section1TitleFontSize;
@synthesize section1TitleFontColor;

@synthesize section1SubtitleFontName;
@synthesize section1SubtitleFontSize;
@synthesize section1SubtitleFontColor;

@synthesize section1BodyFontName;
@synthesize section1BodyFontSize;
@synthesize section1BodyFontColor;

@synthesize section1BodyLinkFontColor;
@synthesize section1BodyImportantFontColor;

@synthesize section2BackgroundImage;
@synthesize section2FormBackgroundColor;

@synthesize section2InfoBoxBackgroundColor;
@synthesize section2InfoBoxStrokeColor;
@synthesize section2InfoBoxFontName;
@synthesize section2InfoBoxFontSize;
@synthesize section2InfoBoxFontColor;

@synthesize section2TitleFontName;
@synthesize section2TitleFontSize;
@synthesize section2TitleFontColor;

@synthesize section2SubtitleFontName;
@synthesize section2SubtitleFontSize;
@synthesize section2SubtitleFontColor;

@synthesize section2BodyFontName;
@synthesize section2BodyFontSize;
@synthesize section2BodyFontColor;

@synthesize section2FieldLabelFontColor;
@synthesize section2TextValueFontColor;
@synthesize section2PlaceHolderFontColor;

@synthesize section2TextFieldBackgroundColor;

@synthesize section2F1F3FieldLabelFontName;
@synthesize section2F1F3FieldLabelFontSize;

@synthesize section2F1TextValueFontName;
@synthesize section2F1TextValueFontSize;

@synthesize section2F2F3TextValueFontName;
@synthesize section2F2F3TextValueFontSize;

@synthesize section2TableCellBackgroundColor;
@synthesize section2TableCellFontColor;

@synthesize section2TableCellFontName;
@synthesize section2TableCellBoldFontName;

@synthesize section2TableCellExtraLargeFontSize;
@synthesize section2TableCellLargeFontSize;
@synthesize section2TableCellMediumFontSize;
@synthesize section2TableCellSmallFontSize;

@synthesize section3BackgroundImage;
@synthesize section3HeaderImage;

@synthesize section3FontName;
@synthesize section3BoldFontName;
@synthesize section3ItalicFontName;

@synthesize section3ReportTitleFontSize;
@synthesize section3ReportTitleFontColor;

@synthesize section3ReportSubTitleFontSize;
@synthesize section3ReportSubTitleFontColor;

@synthesize section3ReportDescriptionFontSize;
@synthesize section3ReportDescriptionFontColor;

@synthesize section3SectionHeadingFontColor;

@synthesize section3TextFontSize;
@synthesize section3TextFontColor;

@synthesize section3FinancialAnalysisFontSize;

@synthesize section3ChartLineColor;
@synthesize section3ChartAlternatingRowColor;
@synthesize section3ChartHeadingFontColor;
@synthesize section3ChartFontColor;

@synthesize section3HeadingBoxColor;
@synthesize section3HeadingBoxFontColor;

@synthesize section3LargeArrowColor;
@synthesize section3SmallArrowColor;
@synthesize section3DiamondColor;

+ (ApplicationSkin*)currentSkin
{
    static ApplicationSkin *skin = nil;
    
    if (!skin) {
        skin = [[ApplicationSkin alloc] initWithSkinResource:kApplicationSkinFile];
    }
    
    return skin;
}

- (id)initWithSkinResource:(NSString*)resource
{
    if ((self = [super init])) {
        static NSString *kSkinKey = @"Skin";
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:resource ofType:@"plist"];
        NSDictionary *plist = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
        NSDictionary *skinConfig = [plist objectForKey:kSkinKey];		
        [self configureWithPlistDictionary:skinConfig];
        [plist release];
    }
    return self;
}


#pragma mark - Private

- (void)configureWithPlistDictionary:(NSDictionary*)dict
{
    canvasImage = [[self valueForKey:kCanvasImageKey fromSkinDictionary:dict] copy];
    
    sidebarBackgroundImage = [[self valueForKey:kSidebarBackgroundImageKey fromSkinDictionary:dict] copy];
    sidebarSelectedImage = [[self valueForKey:kSidebarSelectedImageKey fromSkinDictionary:dict] copy];
    
    sidebarSection1ButtonImage = [[self valueForKey:kSidebarSection1ButtonImageKey fromSkinDictionary:dict] copy];
    sidebarSection2ButtonImage = [[self valueForKey:kSidebarSection2ButtonImageKey fromSkinDictionary:dict] copy];
    sidebarSection3ButtonImage = [[self valueForKey:kSidebarSection3ButtonImageKey fromSkinDictionary:dict] copy];
    
    sidebarSection1ButtonTextColor = [[self valueForKey:kSidebarSection1ButtonTextColorKey fromSkinDictionary:dict] copy];
    sidebarSection2ButtonTextColor = [[self valueForKey:kSidebarSection2ButtonTextColorKey fromSkinDictionary:dict] copy]; 
    sidebarSection3ButtonTextColor = [[self valueForKey:kSidebarSection3ButtonTextColorKey fromSkinDictionary:dict] copy]; 
    
    section1BackgroundImage = [[self valueForKey:kSection1BackgroundImageKey fromSkinDictionary:dict] copy];
    
    section1TitleFontName = [[self valueForKey:kSection1TitleFontNameKey fromSkinDictionary:dict] copy];
    section1TitleFontSize = [[self valueForKey:kSection1TitleFontSizeKey fromSkinDictionary:dict] copy];
    section1TitleFontColor = [[self valueForKey:kSection1TitleFontColorKey fromSkinDictionary:dict] copy];
    
    section1SubtitleFontName = [[self valueForKey:kSection1SubtitleFontNameKey fromSkinDictionary:dict] copy];
    section1SubtitleFontSize = [[self valueForKey:kSection1SubtitleFontSizeKey fromSkinDictionary:dict] copy];
    section1SubtitleFontColor = [[self valueForKey:kSection1SubtitleFontColorKey fromSkinDictionary:dict] copy];

    section1BodyFontName = [[self valueForKey:kSection1BodyFontNameKey fromSkinDictionary:dict] copy];
    section1BodyFontSize = [[self valueForKey:kSection1BodyFontSizeKey fromSkinDictionary:dict] copy];
    section1BodyFontColor = [[self valueForKey:kSection1BodyFontColorKey fromSkinDictionary:dict] copy];
    
    section1BodyLinkFontColor = [[self valueForKey:kSection1BodyLinkFontColorKey fromSkinDictionary:dict] copy];
    section1BodyImportantFontColor = [[self valueForKey:kSection1BodyImportantFontColorKey fromSkinDictionary:dict] copy];
    
    section2BackgroundImage = [[self valueForKey:kSection2BackgroundImageKey fromSkinDictionary:dict] copy];
    section2FormBackgroundColor = [[self valueForKey:kSection2FormBackgroundColorKey fromSkinDictionary:dict] copy];        

    section2InfoBoxBackgroundColor = [[self valueForKey:kSection2InfoBoxBackgroundColorKey fromSkinDictionary:dict] copy];        
    section2InfoBoxStrokeColor = [[self valueForKey:kSection2InfoBoxStrokeColorKey fromSkinDictionary:dict] copy];        
    
    section2InfoBoxFontName = [[self valueForKey:kSection2InfoBoxFontNameKey fromSkinDictionary:dict] copy];        
    section2InfoBoxFontSize = [[self valueForKey:kSection2InfoBoxFontSizeKey fromSkinDictionary:dict] copy];        
    section2InfoBoxFontColor = [[self valueForKey:kSection2InfoBoxFontColorKey fromSkinDictionary:dict] copy];        
    
    section2TitleFontName = [[self valueForKey:kSection2TitleFontNameKey fromSkinDictionary:dict] copy];        
    section2TitleFontSize = [[self valueForKey:kSection2TitleFontSizeKey fromSkinDictionary:dict] copy];        
    section2TitleFontColor = [[self valueForKey:kSection2TitleFontColorKey fromSkinDictionary:dict] copy];        
    
    section2SubtitleFontName = [[self valueForKey:kSection2SubtitleFontNameKey fromSkinDictionary:dict] copy];        
    section2SubtitleFontSize = [[self valueForKey:kSection2SubtitleFontSizeKey fromSkinDictionary:dict] copy];        
    section2SubtitleFontColor = [[self valueForKey:kSection2SubtitleFontColorKey fromSkinDictionary:dict] copy];        

    section2BodyFontName = [[self valueForKey:kSection2BodyFontNameKey fromSkinDictionary:dict] copy];        
    section2BodyFontSize = [[self valueForKey:kSection2BodyFontSizeKey fromSkinDictionary:dict] copy];        
    section2BodyFontColor = [[self valueForKey:kSection2BodyFontColorKey fromSkinDictionary:dict] copy];    
    
    section2FieldLabelFontColor = [[self valueForKey:kSection2FieldLabelFontColorKey fromSkinDictionary:dict] copy];        
    section2PlaceHolderFontColor = [[self valueForKey:kSection2PlaceHolderFontColorKey fromSkinDictionary:dict] copy];        
    section2TextValueFontColor = [[self valueForKey:kSection2TextValueFontColorKey fromSkinDictionary:dict] copy];        
    
    section2TextFieldBackgroundColor = [[self valueForKey:kSection2TextFieldBackgroundColorKey fromSkinDictionary:dict] copy];        
    
    section2F1F3FieldLabelFontName = [[self valueForKey:kSection2F1F3FieldLabelFontNameKey fromSkinDictionary:dict] copy];        
    section2F1F3FieldLabelFontSize = [[self valueForKey:kSection2F1F3FieldLabelFontSizeKey fromSkinDictionary:dict] copy];        

    section2F1TextValueFontName = [[self valueForKey:kSection2F1TextValueFontNameKey fromSkinDictionary:dict] copy];        
    section2F1TextValueFontSize = [[self valueForKey:kSection2F1TextValueFontSizeKey fromSkinDictionary:dict] copy];        

    section2F2F3TextValueFontName = [[self valueForKey:kSection2F2F3TextValueFontNameKey fromSkinDictionary:dict] copy];        
    section2F2F3TextValueFontSize = [[self valueForKey:kSection2F2F3TextValueFontSizeKey fromSkinDictionary:dict] copy];        
    
    section2TableCellBackgroundColor = [[self valueForKey:kSection2TableCellBackgroundColorKey fromSkinDictionary:dict] copy];        
    section2TableCellFontColor = [[self valueForKey:kSection2TableCellFontColorKey fromSkinDictionary:dict] copy]; 
    
    section2TableCellFontName = [[self valueForKey:kSection2TableCellFontNameKey fromSkinDictionary:dict] copy];        
    section2TableCellBoldFontName = [[self valueForKey:kSection2TableCellBoldFontNameKey fromSkinDictionary:dict] copy];        

    section2TableCellExtraLargeFontSize = [[self valueForKey:kSection2TableCellExtraLargeFontSizeKey fromSkinDictionary:dict] copy]; 
    section2TableCellLargeFontSize = [[self valueForKey:kSection2TableCellLargeFontSizeKey fromSkinDictionary:dict] copy]; 
    section2TableCellMediumFontSize = [[self valueForKey:kSection2TableCellMediumFontSizeKey fromSkinDictionary:dict] copy]; 
    section2TableCellSmallFontSize = [[self valueForKey:kSection2TableCellSmallFontSizeKey fromSkinDictionary:dict] copy]; 
    
    section3BackgroundImage = [[self valueForKey:kSection3BackgroundImageKey fromSkinDictionary:dict] copy]; 
    section3HeaderImage = [[self valueForKey:kSection3HeaderImageKey fromSkinDictionary:dict] copy]; 
    
    section3FontName = [[self valueForKey:kSection3FontNameKey fromSkinDictionary:dict] copy]; 
    section3BoldFontName = [[self valueForKey:kSection3BoldFontNameKey fromSkinDictionary:dict] copy]; 
    section3ItalicFontName = [[self valueForKey:kSection3ItalicFontNameKey fromSkinDictionary:dict] copy]; 

    section3ReportTitleFontSize = [[self valueForKey:kSection3ReportTitleFontSizeKey fromSkinDictionary:dict] copy]; 
    section3ReportTitleFontColor = [[self valueForKey:kSection3ReportTitleFontColorKey fromSkinDictionary:dict] copy]; 
    
    section3ReportSubTitleFontSize = [[self valueForKey:kSection3ReportSubTitleFontSizeKey fromSkinDictionary:dict] copy]; 
    section3ReportSubTitleFontColor = [[self valueForKey:kSection3ReportSubTitleFontColorKey fromSkinDictionary:dict] copy]; 
    
    section3ReportDescriptionFontSize = [[self valueForKey:kSection3ReportDescriptionFontSizeKey fromSkinDictionary:dict] copy]; 
    section3ReportDescriptionFontColor = [[self valueForKey:kSection3ReportDescriptionFontColorKey fromSkinDictionary:dict] copy]; 

    section3SectionHeadingFontColor = [[self valueForKey:kSection3SectionHeadingFontColorKey fromSkinDictionary:dict] copy]; 
    
    section3TextFontSize = [[self valueForKey:kSection3TextFontSizeKey fromSkinDictionary:dict] copy]; 
    section3TextFontColor = [[self valueForKey:kSection3TextFontColorKey fromSkinDictionary:dict] copy]; 
    
    section3FinancialAnalysisFontSize = [[self valueForKey:kSection3FinancialAnalysisFontSizeKey fromSkinDictionary:dict] copy]; 
    
    section3ChartLineColor = [[self valueForKey:kSection3ChartLineColorKey fromSkinDictionary:dict] copy]; 
    section3ChartAlternatingRowColor = [[self valueForKey:kSection3ChartAlternatingRowColorKey fromSkinDictionary:dict] copy]; 
    section3ChartHeadingFontColor = [[self valueForKey:kSection3ChartHeadingFontColorKey fromSkinDictionary:dict] copy]; 
    section3ChartFontColor = [[self valueForKey:kSection3ChartFontColorKey fromSkinDictionary:dict] copy];     
    
    section3HeadingBoxColor = [[self valueForKey:kSection3HeadingBoxColorKey fromSkinDictionary:dict] copy];
    section3HeadingBoxFontColor = [[self valueForKey:kSection3HeadingBoxFontColorKey fromSkinDictionary:dict] copy];
    
    section3LargeArrowColor = [[self valueForKey:kSection3LargeArrowColorKey fromSkinDictionary:dict] copy];
    section3SmallArrowColor = [[self valueForKey:kSection3SmallArrowColorKey fromSkinDictionary:dict] copy];
    section3DiamondColor = [[self valueForKey:kSection3DiamondColorKey fromSkinDictionary:dict] copy];
    
}

- (NSString*)valueForKey:(NSString*)key fromSkinDictionary:(NSDictionary*)skinDict
{
    // each entry in a skin dictionary will be a dictionary itself with two keys: Value and Comment.
    // we only care about Value.
    static NSString *valueKey = @"Value";
    NSDictionary *valueDict = [skinDict objectForKey:key];
    
    NSString *value = [valueDict objectForKey:valueKey];
    
    if (!value) {
        WLog(@"No value specified in skin file for key %@", key);
    }
    
    return value;
}

@end
