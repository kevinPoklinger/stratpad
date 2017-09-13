//
//  Report.h
//  StratPad
//
//  Created by Julian Wood on 11-10-02.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol Report <NSObject>
@required
- (NSString*)companyName;
- (NSString*)stratFileName;
- (NSString*)reportTitle;

@optional
- (NSString*)reportSubTitle;

@end

@protocol ScreenReportDelegate <Report>
@required
// determines what height to set the given view bounds to in order for 
// the delegate to display all of its content.
- (CGFloat)heightToDisplayContentForBounds:(CGRect)viewBounds;

// draws content to a PDF context with the given rectangle
// with the height determined by sizeThatFits.
- (void)drawRect:(CGRect)rect;

@end

@protocol PrintReportDelegate <Report>
@required
// returns whether or not the delegate has more pages to print
- (BOOL)hasMorePages;

// draws the content for the given zero-based page index into the 
// given rect representing the full page.
- (void)drawPage:(NSInteger)pageIndex inRect:(CGRect)rect;

@end