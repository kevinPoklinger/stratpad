//
//  MultiPageReportBuilder.h
//  StratPad
//
//  Created by Eric Rogers on October 6, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "ReportPageBuilder.h"
#import "MBDrawableReportHeader.h"

@interface MultiPageReportBuilder : NSObject<ReportPageBuilder> {
@private
    // this is just a list of the rects to draw
    // they are already laid out such that they would look good on a very long page
    // they need to be laid out on multiple pages, which may involve splitting them (making new drawables)
    NSMutableArray *drawables_;
    
    MBDrawableReportHeader *reportHeader_;
    
    // defines the rect in which the report header will be placed
    CGRect headerRect_;
    
    // defines the rect in which drawables will be placed
    CGRect drawablesRect_;
    
    // defines the rect in which page numbers will be placed
    CGRect footerRect_;
    
    MediaType mediaType_;
}

@property (nonatomic,assign) MediaType mediaType;

// init with the rect for the page, and a report header that will be drawn at the 
// beginning of each page.
- (id)initWithPageRect:(CGRect)rect andHeader:(MBDrawableReportHeader*)header;

@end
