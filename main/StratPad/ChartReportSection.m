//
//  ChartReportSection.m
//  StratPad
//
//  Created by Julian Wood on 12-05-12.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "ChartReportSection.h"
#import "Drawable.h"

@implementation ChartReportSection

@synthesize pageNum=pageNum_, col=col_, drawables=drawables_, rect;

- (id)initWithDrawables:(NSMutableArray*)drawables
{
    self = [super init];
    if (self) {
        drawables_ = drawables;
        if (drawables_.count) {
            id<Drawable>firstDrawable = [drawables_ objectAtIndex:0];
            id<Drawable>lastDrawable = [drawables_ lastObject];
            CGFloat height = CGRectGetMaxY(lastDrawable.rect) - firstDrawable.rect.origin.y;
            CGFloat width = 0;
            for (id<Drawable>drawable in drawables) {
                width = MAX(width, drawable.rect.size.width);
            }
            rect = CGRectMake(firstDrawable.rect.origin.x, firstDrawable.rect.origin.y,
                              width, height);
        } else {
            rect = CGRectZero;
        }
    }
    return self;
}

- (BOOL)hasDrawables
{
    return drawables_.count > 0;
}

- (BOOL)fitsInRect:(CGRect)bodyRect atOrigin:(CGPoint)chartReportOrigin
{
    // remember this section rect is relative to the ChartReport origin
    CGRect laidOutRect = CGRectMake(chartReportOrigin.x+rect.origin.x, chartReportOrigin.y+rect.origin.y, self.rect.size.width, self.rect.size.height);
    return CGRectContainsRect(bodyRect, laidOutRect);
}

- (BOOL)readyForPrint
{
    if ([self hasDrawables]) {
        return [[drawables_ lastObject] readyForPrint];
    } else {
        // nothing to draw, so we're good to go
        return YES;
    }
}

- (NSString*)description
{    
    return [NSString stringWithFormat:
            @"[rect: %@, readyForPrint: %@]", 
            NSStringFromCGRect(self.rect), [NSNumber numberWithBool:[self readyForPrint]]
            ];
}


@end
