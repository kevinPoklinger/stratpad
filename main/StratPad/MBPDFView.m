//
//  MBPDFView.m
//  StratPad
//
//  Created by Eric Rogers on September 9, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "MBPDFView.h"
#import "EventManager.h"
#import <QuartzCore/QuartzCore.h>

@implementation MBPDFView

- (void)dealloc
{
    [super dealloc];
}

- (void)drawRect:(CGRect)rect
{    
    NSMutableData *pdfData = [NSMutableData data];    
    
    UIGraphicsBeginPDFContextToData(pdfData, rect, nil);
    
    // Mark the beginning of a new page.                
    UIGraphicsBeginPDFPageWithInfo(rect, nil);
        
    // draw the content into the page rect.
    [screenDelegate_ drawRect:rect];
    
    // Close the PDF context and write the contents out.
    // beware that when an All Exception Breakpoint is added, we get an exception here, which is otherwise ignored
    UIGraphicsEndPDFContext();
    
    // now render the pdf on screen
    CGContextRef ctx = UIGraphicsGetCurrentContext();
        
	// Note: We want the PDF background to be transparent for screen render,
    // as there is a paper background behind it.
    
	// Flip coordinates
	CGContextGetCTM(ctx);
	CGContextScaleCTM(ctx, 1, -1);
	CGContextTranslateCTM(ctx, 0, -rect.size.height);
    
    CFDataRef myPDFData = (CFDataRef)pdfData;
    CGDataProviderRef provider = CGDataProviderCreateWithCFData(myPDFData);
    CGPDFDocumentRef pdf = CGPDFDocumentCreateWithProvider(provider);
	CGPDFPageRef page = CGPDFDocumentGetPage(pdf, 1);
    
	// get the rectangle of the cropped inside
	CGRect mediaRect = CGPDFPageGetBoxRect(page, kCGPDFCropBox);
	CGContextScaleCTM(ctx, rect.size.width / mediaRect.size.width,
                      rect.size.height / mediaRect.size.height);
	CGContextTranslateCTM(ctx, -mediaRect.origin.x, -mediaRect.origin.y);
    
	// draw it
	CGContextDrawPDFPage(ctx, page);
    
    // clean up
    CGPDFDocumentRelease(pdf);
    CGDataProviderRelease(provider);
    
    // let the sidebar clean up it's loading status    
    [EventManager fireReportViewDidDrawEventWithChapter:[screenDelegate_ description]];
}

@end
