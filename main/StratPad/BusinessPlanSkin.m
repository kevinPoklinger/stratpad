//
//  BusinessPlanSkin.m
//  StratPad
//
//  Created by Julian Wood on 2013-06-21.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//

#import "BusinessPlanSkin.h"
#import "UIColor-Expanded.h"
#import "SkinManager.h"

@implementation BusinessPlanSkin

- (void)dealloc
{
    [_fontName release];
    [_boldFontName release];
    [_obliqueFontName release];
    
    [_chartHeadingFontColor release];
    [_chartFontColor release];
    
    [_sectionHeadingFontColor release];
    [_textFontColor release];
    [_lineColor release];
    [_alternatingRowColor release];
    [_largeArrowColor release];
    [_smallArrowColor release];
    [_diamondColor release];

    [super dealloc];
}

- (NSString*)description
{
    return [NSString stringWithFormat:
            @"[fontName: %@, boldFontName: %@, chartHeadingFontColor: %@, chartFontColor: %@, sectionHeadingFontColor: %@, textFontColor: %@, lineColor: %@, alternatingRowColor: %@, largeArrowColor: %@, smallArrowColor: %@, diamondColor: %@, fontSize: %f, chartFontSize: %f]",
            self.fontName, self.boldFontName, [self.chartHeadingFontColor hexStringFromColor], [self.chartFontColor hexStringFromColor], [self.sectionHeadingFontColor hexStringFromColor], [self.textFontColor hexStringFromColor], [self.lineColor hexStringFromColor], [self.alternatingRowColor hexStringFromColor], [self.largeArrowColor hexStringFromColor], [self.smallArrowColor hexStringFromColor], [self.diamondColor hexStringFromColor], self.fontSize, self.chartFontSize
            ];
}

+(BusinessPlanSkin*)skinForDocx
{
    SkinManager *skinMan = [SkinManager sharedManager];
    BusinessPlanSkin *skin = [[BusinessPlanSkin alloc] init];
    skin.fontName = [skinMan stringForProperty:kSkinSection3FontName forMediaType:MediaTypePrint];
    skin.boldFontName = [skinMan stringForProperty:kSkinSection3BoldFontName forMediaType:MediaTypePrint];
    skin.obliqueFontName = [skinMan stringForProperty:kSkinSection3ItalicFontName forMediaType:MediaTypePrint];
    skin.fontSize = 24.f;
    skin.chartFontSize = 22.f;
    skin.chartHeadingFontColor = [skinMan colorForProperty:kSkinSection3ChartHeadingFontColor forMediaType:MediaTypePrint];
    skin.chartFontColor = [skinMan colorForProperty:kSkinSection3ChartFontColor forMediaType:MediaTypePrint];
    skin.textFontColor = [skinMan colorForProperty:kSkinSection3FontColor forMediaType:MediaTypePrint];
    skin.sectionHeadingFontColor = [skinMan colorForProperty:kSkinSection3SectionHeadingFontColor forMediaType:MediaTypePrint];
    skin.lineColor = [skinMan colorForProperty:kSkinSection3ChartLineColor forMediaType:MediaTypePrint];
    skin.alternatingRowColor = [skinMan colorForProperty:kSkinSection3ChartAlternatingRowColor forMediaType:MediaTypePrint];
    skin.largeArrowColor = [skinMan colorForProperty:kSkinSection3LargeArrowColor forMediaType:MediaTypePrint];
    skin.smallArrowColor = [skinMan colorForProperty:kSkinSection3SmallArrowColor forMediaType:MediaTypePrint];
    skin.diamondColor = [skinMan colorForProperty:kSkinSection3DiamondColor forMediaType:MediaTypePrint];
    return [skin autorelease];
}

@end
