//
//  ReportPageBuilder.h
//  StratPad
//
//  Created by Eric Rogers on October 6, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//
//  Provides an abstraction for report delegates to add their drawable objects
//  to without having to worry about paging.

#import "Drawable.h"
#import "SkinManager.h"

@protocol ReportPageBuilder <NSObject>
@required
// adds a drawable instance to the builder 
- (void)addDrawable:(id<Drawable>)drawable;

// divides the drawables into pages of the configured
// page size.  Returns an array containing arrays, each corresponding
// to a page and containing the drawables for that page.
- (NSArray*)build;

// constructor which sets the page rect for the builder.
- (id)initWithPageRect:(CGRect)rect;

// are we building for print or screen?
- (MediaType)mediaType;

@end
