//
//  ChartReport.h
//  StratPad
//
//  Created by Julian Wood on 12-05-12.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//
//  Represents a ChartReportHeader and 3 sections: summary, chart and comments.

#import <UIKit/UIKit.h>

#import "ChartReportSection.h"
#import "ChartReportHeader.h"

@interface ChartReport : NSObject {
    BOOL isSplit_;
    NSMutableArray *boundingLines_;
}

@property (nonatomic,assign) CGRect rect;
@property (nonatomic,retain) ChartReportHeader *chartReportHeader;
@property (nonatomic,retain) ChartReportSection *summarySection;
@property (nonatomic,retain) ChartReportSection *chartSection;
@property (nonatomic,retain) ChartReportSection *commentSection;

@property (nonatomic,readonly) NSArray *drawables;

-(BOOL)fitsInRect:(CGRect)bodyRect atOrigin:(CGPoint)originOnPage;
-(void)fitSectionsIntoColumn:(NSUInteger)col page:(NSUInteger)page atOrigin:(CGPoint)origin bodyRect:(CGRect)bodyRect;
-(BOOL)partiallyFitsInRect:(CGRect)bodyRect atOrigin:(CGPoint)originOnPage;
-(void)updateAllDrawableOrigins:(CGPoint)newOrigin;

// have all drawables been set to print?
-(BOOL)readyForPrint;

// because rect is not accurate after having split a chart
-(CGFloat)getMaxY;

@end
