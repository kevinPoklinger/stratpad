//
//  BoundingLine.m
//  StratPad
//
//  Created by Julian Wood on 12-05-25.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "BoundingLine.h"
#import "ChartReportHeader.h"
#import "UIColor-Expanded.h"

@implementation BoundingLine

@synthesize rect = rect_;
@synthesize readyForPrint;

- (id)init
{
    self = [super init];
    if (self) {
        rect_ = CGRectMake(0, 0, 1, 0);
        boundingLineRects_ = [[NSMutableArray alloc] init];
        [boundingLineRects_ addObject:[NSValue valueWithCGRect:rect_]];
    }
    return self;
}

-(void)draw
{
    // defensive
    if (boundingLineRects_.count <= 1) {
        WLog(@"Not enough points (need 2) in the BoundingLine to actually draw a line!!");
        return;
    }
    
    // rect_ is updated externally to reflect the new chart origin
    // the difference between the current origin and the first point in boundingLinePoints_ is the offset
    CGPoint oldOrigin = [[boundingLineRects_ objectAtIndex:0] CGRectValue].origin; // should be {0,0}
    [boundingLineRects_ removeObjectAtIndex:0];    
    CGFloat offsetY = rect_.origin.y - oldOrigin.y;
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGFloat startingY = [[boundingLineRects_ objectAtIndex:0] CGRectValue].origin.y;
    CGPathMoveToPoint(path, NULL, rect_.origin.x, startingY + offsetY); // 103
    
    for (NSValue *val in boundingLineRects_) {
        CGPoint p = CGPointMake(rect_.origin.x, CGRectGetMaxY(val.CGRectValue) + offsetY);
        CGPathAddLineToPoint(path, NULL, p.x, p.y);
    }
        
    // draw it
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    CGContextSetLineWidth(context, 1.f);
    CGContextSetStrokeColorWithColor(context, [[UIColor colorWithHexString:boundingLineColor] CGColor]);
    CGContextAddPath(context, path);
    CGContextStrokePath(context);
    CGPathRelease(path);
    
    CGContextRestoreGState(context);

}

- (void)addRectForBounding:(CGRect)boundingRect
{
    [boundingLineRects_ addObject:[NSValue valueWithCGRect:boundingRect]];
}

- (void)dealloc
{
    [boundingLineRects_ release];
    [super dealloc];
}

-(NSString*)description
{
    return [NSString stringWithFormat:
            @"[readyForPrint: %i, rect: %@, boundingLinePoints_: %@]", 
            self.readyForPrint, NSStringFromCGRect(rect_), boundingLineRects_
            ];
}



@end
