//
//  MBRichDrawableLabel.m
//  StratPad
//
//  Created by Julian Wood on 9/22/11.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "MBRichDrawableLabel.h"
#import <CoreText/CoreText.h>

@implementation MBRichDrawableLabel

@synthesize rect=rect_;
@synthesize attributedString=attributedString_;

- (id)initWithAtrributedString:(NSAttributedString*)attributedString 
                       andRect:(CGRect)rect;
{
    if ((self = [super init])) {
        attributedString_ = [attributedString retain];
        rect_ = rect;
    }
    return self;
}

- (void)dealloc
{
    [attributedString_ release];
    [super dealloc];
}

- (void)draw
{    
    // make frame
	CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedString_);
	CGMutablePathRef framePath = CGPathCreateMutable();
	CGPathAddRect(framePath, NULL, 
                  CGRectMake(rect_.origin.x, -rect_.origin.y, rect_.size.width, rect_.size.height));
	CTFrameRef frame = CTFramesetterCreateFrame(framesetter, 
                                                CFRangeMake(0, 0),
                                                framePath, NULL);
    
	// flip the coordinate system
	CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
	CGContextSetTextMatrix(context, CGAffineTransformIdentity);
	CGContextTranslateCTM(context, 0, rect_.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
    
	// draw
	CTFrameDraw(frame, context);
    
    CGContextRestoreGState(context);
    
	// cleanup
	CFRelease(frame);
	CGPathRelease(framePath);
	CFRelease(framesetter);

}

-(NSString*)description
{
    return [NSString stringWithFormat:@"attrString: %@, rect: %@", [attributedString_ string], NSStringFromCGRect(rect_)];
}

@end
