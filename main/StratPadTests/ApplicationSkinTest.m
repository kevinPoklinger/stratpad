//
//  SectionISkinTest.m
//  StratPad
//
//  Created by Eric on 11-11-13.
//  Copyright (c) 2011 Glassey Strategy. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "ApplicationSkin.h"
#import "EditionManager.h"

@interface ApplicationSkinTest : SenTestCase
@end

@implementation ApplicationSkinTest

- (void)testGlobalConfiguration
{
    if ([[EditionManager sharedManager] isPremium]) {
        ApplicationSkin *skin = [[ApplicationSkin alloc] initWithSkinResource:@"skin"];
        
        STAssertEqualObjects(@"page-background-blue-hatch.png", skin.canvasImage, nil);
        
        STAssertEqualObjects(@"sidebar-background.png", skin.sidebarBackgroundImage, nil);
        STAssertEqualObjects(@"sidebar-selected.png", skin.sidebarSelectedImage, nil);
        STAssertEqualObjects(@"sidebar-button-i.png", skin.sidebarSection1ButtonImage, nil);
        STAssertEqualObjects(@"sidebar-button-ii.png", skin.sidebarSection2ButtonImage, nil);
        STAssertEqualObjects(@"sidebar-button-iii.png", skin.sidebarSection3ButtonImage, nil);
        
        STAssertEqualObjects(@"FFFFFF", skin.sidebarSection1ButtonTextColor, nil);
        STAssertEqualObjects(@"1B2B32", skin.sidebarSection2ButtonTextColor, nil);
        STAssertEqualObjects(@"37646F", skin.sidebarSection3ButtonTextColor, nil);
        
        [skin release];        
    }
}

- (void)testSection1Configuration
{
    if ([[EditionManager sharedManager] isPremium]) {
        ApplicationSkin *skin = [[ApplicationSkin alloc] initWithSkinResource:@"skin"];
        
        STAssertEqualObjects(@"content-background-paper-midnight-blue-header.png", skin.section1BackgroundImage, nil);
        
        STAssertEqualObjects(@"helvetica", skin.section1TitleFontName, nil);
        STAssertEqualObjects(@"28pt", skin.section1TitleFontSize, nil);
        STAssertEqualObjects(@"#FFFFFF", skin.section1TitleFontColor, nil);
        
        STAssertEqualObjects(@"helvetica", skin.section1SubtitleFontName, nil);
        STAssertEqualObjects(@"20pt", skin.section1SubtitleFontSize, nil);
        STAssertEqualObjects(@"#FFFFFF", skin.section1SubtitleFontColor, nil);
        
        STAssertEqualObjects(@"helvetica", skin.section1BodyFontName, nil);
        STAssertEqualObjects(@"14pt", skin.section1BodyFontSize, nil);
        STAssertEqualObjects(@"#37646F", skin.section1BodyFontColor, nil);
        
        STAssertEqualObjects(@"#37646F", skin.section1BodyLinkFontColor, nil);
        STAssertEqualObjects(@"#000000", skin.section1BodyImportantFontColor, nil);
        
        [skin release];
    }
}

- (void)testSection2Configuration
{
    if ([[EditionManager sharedManager] isPremium]) {
        
        ApplicationSkin *skin = [[ApplicationSkin alloc] initWithSkinResource:@"skin"];
        
        STAssertEqualObjects(@"content-background-paper-turquoise-header.png", skin.section2BackgroundImage, nil);
        
        STAssertEqualObjects(@"A3ABAF", skin.section2FormBackgroundColor, nil);
        
        
        STAssertEqualObjects(@"A3ABAF", skin.section2InfoBoxBackgroundColor, nil);
        STAssertEqualObjects(@"37646F", skin.section2InfoBoxStrokeColor, nil);
        
        STAssertEqualObjects(@"Helvetica", skin.section2InfoBoxFontName, nil);
        STAssertEqualObjects(@"14", skin.section2InfoBoxFontSize, nil);
        STAssertEqualObjects(@"2D434C", skin.section2InfoBoxFontColor, nil);
        
        STAssertEqualObjects(@"Helvetica-Bold", skin.section2TitleFontName, nil);
        STAssertEqualObjects(@"40", skin.section2TitleFontSize, nil);
        STAssertEqualObjects(@"FFFFFF", skin.section2TitleFontColor, nil);
        
        STAssertEqualObjects(@"Helvetica", skin.section2SubtitleFontName, nil);
        STAssertEqualObjects(@"26", skin.section2SubtitleFontSize, nil);
        STAssertEqualObjects(@"FFFFFF", skin.section2SubtitleFontColor, nil);
        
        STAssertEqualObjects(@"Helvetica", skin.section2BodyFontName, nil);
        STAssertEqualObjects(@"20", skin.section2BodyFontSize, nil);
        STAssertEqualObjects(@"2D434C", skin.section2BodyFontColor, nil);
        
        STAssertEqualObjects(@"2D434C", skin.section2FieldLabelFontColor, nil);
        STAssertEqualObjects(@"B3B3B3", skin.section2PlaceHolderFontColor, nil);
        STAssertEqualObjects(@"2D434C", skin.section2TextValueFontColor, nil);
        
        STAssertEqualObjects(@"Helvetica-Bold", skin.section2F1F3FieldLabelFontName, nil);
        STAssertEqualObjects(@"14", skin.section2F1F3FieldLabelFontSize, nil);
        
        STAssertEqualObjects(@"Helvetica", skin.section2F1TextValueFontName, nil);
        STAssertEqualObjects(@"20", skin.section2F1TextValueFontSize, nil);
        
        STAssertEqualObjects(@"E1E7E8", skin.section2TextFieldBackgroundColor, nil);
        
        STAssertEqualObjects(@"Helvetica", skin.section2F2F3TextValueFontName, nil);
        STAssertEqualObjects(@"17", skin.section2F2F3TextValueFontSize, nil);
        
        STAssertEqualObjects(@"E1E7E8", skin.section2TableCellBackgroundColor, nil);
        
        STAssertEqualObjects(@"2D434C", skin.section2TableCellFontColor, nil);
        STAssertEqualObjects(@"Helvetica", skin.section2TableCellFontName, nil);
        STAssertEqualObjects(@"Helvetica-Bold", skin.section2TableCellBoldFontName, nil);
        STAssertEqualObjects(@"20", skin.section2TableCellExtraLargeFontSize, nil);
        STAssertEqualObjects(@"17", skin.section2TableCellLargeFontSize, nil);
        STAssertEqualObjects(@"14", skin.section2TableCellMediumFontSize, nil);
        STAssertEqualObjects(@"12", skin.section2TableCellSmallFontSize, nil);  
        
        [skin release];
    }
}

- (void)testSection3Configuration
{
    if ([[EditionManager sharedManager] isPremium]) {
        
        ApplicationSkin *skin = [[ApplicationSkin alloc] initWithSkinResource:@"skin"];
        
        STAssertEqualObjects(@"content-background-paper.png", skin.section3BackgroundImage, nil);
        
        STAssertEqualObjects(@"content-background-header.png", skin.section3HeaderImage, nil);
        
        STAssertEqualObjects(@"Helvetica", skin.section3FontName, nil);
        STAssertEqualObjects(@"Helvetica-Bold", skin.section3BoldFontName, nil);
        STAssertEqualObjects(@"Helvetica-Oblique", skin.section3ItalicFontName, nil);    
        
        STAssertEqualObjects(@"36", skin.section3ReportTitleFontSize, nil);    
        STAssertEqualObjects(@"FFFFFF", skin.section3ReportTitleFontColor, nil);
        
        STAssertEqualObjects(@"12", skin.section3ReportSubTitleFontSize, nil);    
        STAssertEqualObjects(@"000000", skin.section3ReportSubTitleFontColor, nil);
        
        STAssertEqualObjects(@"10", skin.section3ReportDescriptionFontSize, nil);    
        STAssertEqualObjects(@"000000", skin.section3ReportDescriptionFontColor, nil);
        
        STAssertEqualObjects(@"1B2B32", skin.section3SectionHeadingFontColor, nil);
        
        STAssertEqualObjects(@"12", skin.section3TextFontSize, nil);    
        STAssertEqualObjects(@"1B2B32", skin.section3TextFontColor, nil);
        
        STAssertEqualObjects(@"9", skin.section3FinancialAnalysisFontSize, nil);    
        
        STAssertEqualObjects(@"1B2B32", skin.section3ChartLineColor, nil);
        STAssertEqualObjects(@"F2F2F2", skin.section3ChartAlternatingRowColor, nil);
        STAssertEqualObjects(@"FFFFFF", skin.section3ChartHeadingFontColor, nil);
        STAssertEqualObjects(@"37646F", skin.section3ChartFontColor, nil);
        
        STAssertEqualObjects(@"1B2B32", skin.section3HeadingBoxColor, nil);
        STAssertEqualObjects(@"FFFFFF", skin.section3HeadingBoxFontColor, nil);
        
        STAssertEqualObjects(@"5FA736", skin.section3LargeArrowColor, nil);
        STAssertEqualObjects(@"818181", skin.section3SmallArrowColor, nil);
        STAssertEqualObjects(@"1D648F", skin.section3DiamondColor, nil);
                
        [skin release];
    }
}

@end
