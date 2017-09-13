//
//  SinglePageReportBuilder.h
//  StratPad
//
//  Created by Eric Rogers on October 6, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//
//  Suitable for a report which only occupies a single page onscreen and on print. We're using it to hold
//  a list of drawables which can be stored and then rendered to screen or print at any time. Also allows us
//  to calculate heights without drawing the objects twice.

#import "ReportPageBuilder.h"
#import "SkinManager.h"

@interface SinglePageReportBuilder : NSObject<ReportPageBuilder> {
@private
    NSMutableArray *drawables_;
    CGRect pageRect_;
    MediaType mediaType_;
}

@property (nonatomic,assign) MediaType mediaType;

@end
