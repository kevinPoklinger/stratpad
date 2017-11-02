//
//  ChartReport.m
//  StratPad
//
//  Created by Julian Wood on 12-05-12.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "ChartReport.h"
#import "ReportCardPrinter.h"
#import "BoundingLine.h"

@implementation ChartReport

@synthesize rect, chartReportHeader, summarySection, chartSection, commentSection;

- (id)init
{
    self = [super init];
    if (self) {
        isSplit_ = NO;
        boundingLines_ = [[NSMutableArray arrayWithCapacity:5] retain];
    }
    return self;
}

- (void)dealloc
{
    [boundingLines_ release];
    [chartReportHeader release];
    [summarySection release];
    [chartSection release];
    [commentSection release];
    [super dealloc];
}

-(BOOL)fitsInRect:(CGRect)bodyRect atOrigin:(CGPoint)originOnPage
{
    CGRect laidOutRect = CGRectMake(originOnPage.x, originOnPage.y, self.rect.size.width, self.rect.size.height);
    return (CGRectContainsRect(bodyRect, laidOutRect));
}

-(BOOL)partiallyFitsInRect:(CGRect)bodyRect atOrigin:(CGPoint)originOnPage
{    
    // as long as the chart fits, then we are good to go
    return [chartSection fitsInRect:bodyRect atOrigin:originOnPage];   
}

-(void)updateAllDrawableOrigins:(CGPoint)newOrigin
{
    [self updateDrawableOrigins:newOrigin drawables:self.drawables];
}

-(void)updateDrawableOrigins:(CGPoint)newOrigin drawables:(NSArray*)drawables
{
    // the new origin is for this chart report; all drawables rects are relative to this origin
    rect = CGRectMake(newOrigin.x, newOrigin.y, rect.size.width, rect.size.height);
    
    // change from relative to absolute by offsetting by newOrigin
    for (id<Drawable>drawable in drawables) {
        drawable.rect = CGRectMake(drawable.rect.origin.x+newOrigin.x, drawable.rect.origin.y+newOrigin.y, 
                                   drawable.rect.size.width, drawable.rect.size.height);
        drawable.readyForPrint = YES;
    }
}

-(NSArray*)drawables
{
    NSMutableArray *drawables = [NSMutableArray array];
    [drawables addObject:chartReportHeader];
    [drawables addObjectsFromArray:summarySection.drawables];
    [drawables addObjectsFromArray:chartSection.drawables];
    [drawables addObjectsFromArray:commentSection.drawables];
    [drawables addObjectsFromArray:boundingLines_];
    return drawables;
}

-(void)fitSectionsIntoColumn:(NSUInteger)col page:(NSUInteger)page atOrigin:(CGPoint)origin bodyRect:(CGRect)bodyRect
{    
    // presumably partiallyFitsInRect:atOrigin is true
    // so we want to start placing sections

    // container for drawables that will be updated for this column - can't add new ones here
    NSMutableArray *drawables = [NSMutableArray array];

    NSArray *sections = [NSArray arrayWithObjects:chartReportHeader, summarySection, chartSection, commentSection, nil];
    
    BOOL full = NO;
    // todo: these are not actually all Drawables (ie ChartReportSection)
    for (id<Drawable>section in sections) {
        if (![section readyForPrint]) {
            // need to try placing it
            if ([section isKindOfClass:[ChartReportHeader class]]) {
                // we know this fits
                [drawables addObject:chartReportHeader];
                
            } else if ([section isEqual:summarySection]) {
                // we know this fits
                [drawables addObjectsFromArray:summarySection.drawables];                
                
            } else if ([section isEqual:chartSection]) {
                // we know this fits too
                [drawables addObjectsFromArray:chartSection.drawables];
                
            } else if ([section isEqual:commentSection]) {
                // check to see if the chart is readyForPrint
                if (commentSection.hasDrawables) {
                    // get drawables not ready for printing
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"readyForPrint!=YES"];
                    NSArray *remainingDrawables = [commentSection.drawables filteredArrayUsingPredicate:predicate];
                    BoundingLine *boundingLine = nil;
                    
                    if (isSplit_) {
                        // if we've already laid out some comments, then we need to adjust the origin so that it appears to be in this new column
                        id<Drawable> nextDrawable = [remainingDrawables objectAtIndex:0];
                        origin = CGPointOffset(origin, 0, -nextDrawable.rect.origin.y);
                        
                        // add a new object to hold the bounding line for the comments in this column
                        boundingLine = [[BoundingLine alloc] init];
                    }
                    
                    // if it fits, then just draw it
                    if ([commentSection fitsInRect:bodyRect atOrigin:origin]) {
                        
                        // eg. we split between the comment section and the chartReportSection, and the comment section fits
                        for (id<Drawable> drawable in remainingDrawables) {
                            [drawables addObject:drawable];
                            [boundingLine addRectForBounding:drawable.rect];
                        }

                    } else {
                        // add one at a time until we are full
                        for (id<Drawable> drawable in remainingDrawables) {
                            CGRect laidOutRect = CGRectMake(origin.x+drawable.rect.origin.x, origin.y+drawable.rect.origin.y, drawable.rect.size.width, drawable.rect.size.height);
                            if (CGRectContainsRect(bodyRect, laidOutRect)) {
                                [drawables addObject:drawable];
                                
                                // add line for comments in this column only
                                if (isSplit_) {
                                    // in a new column
                                    [boundingLine addRectForBounding:drawable.rect];
                                } else {
                                    // we're in the original column
                                    [self.chartReportHeader addPointToBoundingLinePoints:CGPointMake(0, CGRectGetMaxY(drawable.rect))];
                                }                                
                                
                            } else {
                                full = YES;
                                isSplit_ = YES;
                                break;
                            }

                        }
                    }
                    if (boundingLine) {
                        // add for origin adjustment
                        [drawables addObject:boundingLine];

                        // add for drawing inclusion
                        [boundingLines_ removeAllObjects];
                        [boundingLines_ addObject:boundingLine];
                    }

                    [boundingLine release];
                }
                // else commentSection.readyForPrint will be true
                
            }
        } 
        
        if (full) {
            // we're done
            break;
        }
    }

    // we can re-enter this method as many times as necessary to keep placing the remaining sections, so update origins and mark as printable
    [self updateDrawableOrigins:origin drawables:drawables];    
}

-(BOOL)readyForPrint
{
    if ([commentSection hasDrawables]) {
        return [commentSection readyForPrint];
    } else {
        return [chartSection readyForPrint];
    }
}

-(CGFloat)getMaxY
{
    // takes into account splitting
    if ([commentSection hasDrawables]) {
        return CGRectGetMaxY([[commentSection.drawables lastObject] rect]);
    } else {
        return CGRectGetMaxY([[chartSection.drawables lastObject] rect]);
    }
}

- (NSString*)description
{    
    return [NSString stringWithFormat:
            @"[rect: %@, header: %@, summarySection: %@, chartSection: %@, commentSection: %@, readyForPrint: %@]", 
            NSStringFromCGRect(self.rect), chartReportHeader, summarySection, chartSection, commentSection, [NSNumber numberWithBool:[self readyForPrint]]
            ];
}


@end
