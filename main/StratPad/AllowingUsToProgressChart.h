//
//  AllowingUsToProgressChart.h
//  StratPad
//
//  Created by Eric Rogers on September 25, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//
//  Chart that displays the quarterly financial calculations 
//  for a StratFile.


#import "Drawable.h"
#import "AllowingUsToProgressDataSource.h"

@interface AllowingUsToProgressChart : NSObject<Drawable> {
@private
    // rect to draw the chart in.
    CGRect rect_;
    
    AllowingUsToProgressDataSource *dataSource_;
            
    // fonts for the chart
    UIFont *font_;
    UIFont *boldFont_;
    
    // font color for the chart
    UIColor *headingFontColor_;
    UIColor *fontColor_;
    
    // line color for the chart.
    UIColor *lineColor_;
    
    // color for alternating rows in the chart.
    UIColor *alternatingRowColor_;
}

@property(nonatomic, assign) CGRect rect;
@property(nonatomic, readonly) AllowingUsToProgressDataSource *dataSource;
@property(nonatomic, readonly) UIFont *font;
@property(nonatomic, readonly) UIFont *boldFont;

@property(nonatomic, retain) UIColor *headingFontColor;
@property(nonatomic, retain) UIColor *fontColor;
@property(nonatomic, retain) UIColor *lineColor;
@property(nonatomic, retain) UIColor *alternatingRowColor;

- (id)initWithRect:(CGRect)rect font:(UIFont*)font boldFont:(UIFont*)boldFont andAllowingUsToProgressDataSource:(AllowingUsToProgressDataSource*)dataSource;

+ (CGFloat)heightWithDataSource:(AllowingUsToProgressDataSource*)dataSource font:(UIFont*)font andRowWidth:(CGFloat)rowWidth;

@end
