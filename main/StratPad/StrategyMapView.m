//
//  StrategyMapView.m
//  StratPad
//
//  Created by Julian Wood on 11-08-19.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "StrategyMapView.h"
#import "UIColor-Expanded.h"
#import "StratFileManager.h"
#import "StrategyMapViewController.h"
#import "Theme.h"
#import "ObjectiveType.h"
#import "Objective.h"
#import "ThemeBox.h"
#import "ObjectiveBox.h"
#import "EventManager.h"

CGFloat const cornerRadius                  = 10.f;
NSUInteger const numRows                    = 8;

#pragma mark -

@interface StrategyMapView (Private)
-(void)setup;

- (void)drawStrategyStatement:(CGContextRef)context text:(NSString*)text inRect:(CGRect)rect;

// look for other objectives on this page (in other themes) with same description and category
// if there is one, remove it, and add it to the resulting set
- (NSSet*)findAndCollapseObjectives:(Objective*)objective inThemes:(NSArray*)stratMapThemes;

+ (ThemeBox*)themeBoxForTheme:(Theme*)theme boxes:(NSArray*)boxes;
@end

@implementation StrategyMapView

@synthesize pageNumber = pageNumber_;
@synthesize mediaType;

- (id)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder:aDecoder]))
	{
        [self setup];
	}
    
	return self;
}

- (id)initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame]))
	{
        [self setup];
	}
    
	return self;    
}

- (void)dealloc
{    
    [super dealloc];
}

- (void)setup
{
    skinMan_ = [SkinManager sharedManager];

    stratFile_ = [[StratFileManager sharedManager] currentStratFile];
}

- (void)drawRect:(CGRect)rect
{    
    CGFloat const paddingBottom         = 3;
    CGFloat const rowWidth              = rect.size.width;
    CGFloat const stratRowHeight        = (rect.size.height-paddingBottom)/numRows;
    CGFloat const objSpacer             = 9;
    CGFloat const minColWidth           = (rowWidth-(maxThemesPerPage-1)*objSpacer)/maxThemesPerPage; // eg. 168px
    CGFloat const objWidth              = minColWidth/2; // eg. 87px
    CGFloat const themeHeight           = 50;
    CGFloat const rowSpacer             = 29;
    CGFloat const realObjWidth          = (minColWidth-6)/2;
    CGFloat const intraObjectiveSpacer  = 5; // the actual spacing between objectives belonging to the same theme
    
    CGContextRef context = UIGraphicsGetCurrentContext();
        
    CGContextSetAllowsAntialiasing(context, true);
    CGContextSetShouldAntialias(context, true);
    
    CGContextSetAllowsFontSmoothing(context, true);
    CGContextSetShouldSmoothFonts(context, true);
    
    CGContextSetAllowsFontSubpixelQuantization(context, true);
    CGContextSetShouldSubpixelQuantizeFonts(context, true);
            
    // keep track of cells
    uint row = 0;
    
    // draw the strategy statement - row 0
    CGRect strategyStatementFrame = CGRectMake(rect.origin.x, rect.origin.y+3, rect.size.width, 57);
    [self drawStrategyStatement:context text:[stratFile_ mediumTermStrategicGoal] inRect:strategyStatementFrame];
    
    // draw the theme boxes; keep them centered
    NSDictionary *themes = [StrategyMapViewController createStratMapThemes:stratFile_];
    NSArray *stratMapThemes = [themes objectForKey:[NSNumber numberWithInt:pageNumber_]];
    
    // now figure out what sort of spacing we need
    // if there were 3 width=2 themes, then we would want 0-168-9-168-9-168-0 = 522
    // if there were 2 width=2 themes, then we would want 88.5-168-9-168-88.5 = 522
    // if there was  1 width=2 and 1 width=3 theme, then we would want 46.5-168-9-252-46.5 = 522

    uint sumWidths = 0;
    for (StratMapTheme *stratMapTheme in stratMapThemes) {
        sumWidths += [Theme themeWidth:stratMapTheme.objectives];
    }
       
    CGFloat spacing = ([stratMapThemes count]-1)*objSpacer;
    CGFloat width = sumWidths*objWidth + spacing;
    CGFloat sideMargin = (rowWidth - width)/2;
        
    NSArray *objectiveColors = [NSArray arrayWithObjects:
                                [skinMan_ colorForProperty:kSkinSection3StrategyMapFinancialObjectiveBoxColor forMediaType:mediaType],
                                [skinMan_ colorForProperty:kSkinSection3StrategyMapCustomerObjectiveBoxColor forMediaType:mediaType],
                                [skinMan_ colorForProperty:kSkinSection3StrategyMapProcessObjectiveBoxColor forMediaType:mediaType],
                                [skinMan_ colorForProperty:kSkinSection3StrategyMapStaffObjectiveBoxColor forMediaType:mediaType],
                                nil];
            
    uint themeWidth;
    uint x=sideMargin;
    NSMutableArray *boxes = [NSMutableArray array];
    for (StratMapTheme *stratMapTheme in stratMapThemes) {
        row = 1;
        themeWidth = [Theme themeWidth:stratMapTheme.objectives] * objWidth;
        ThemeBox *themeBox = [[ThemeBox alloc] initWithTheme:stratMapTheme.theme 
                                                      frame:CGRectMake(rect.origin.x + x, rect.origin.y + row*stratRowHeight, themeWidth, themeHeight)
                                                    fontName:[skinMan_ stringForProperty:kSkinSection3FontName forMediaType:mediaType] 
                                                    fontSize:[skinMan_ fontSizeForProperty:kSkinSection3FontSize forMediaType:mediaType] 
                                                   fontColor:[skinMan_ colorForProperty:kSkinSection3StrategyMapFontColor forMediaType:mediaType] 
                                                      color:[skinMan_ colorForProperty:kSkinSection3StrategyMapThemeBoxColor forMediaType:mediaType]
                                                     targetFrames:[NSMutableSet setWithObject:[NSValue valueWithCGRect:strategyStatementFrame]]];
        [boxes addObject:themeBox];
        [themeBox release];
        row++;

        // now draw Objectives for this column, from row 2-7
        for (; row<numStratMapRows; ++row) {
            ObjectiveCategory cat = row-2;
            
            // this is just the objectives for this row (category) that fit on this page and in this theme width
            NSArray *objectives = [Theme objectivesFilteredByCategory:cat objectives:[Theme objectivesSortedByOrder:stratMapTheme.objectives]];
            if ([objectives count] == 0) {
                continue;
            }
                        
            uint offsetx = x;
            // center the objectives under the theme

            CGFloat objectivesWidth = [objectives count]*realObjWidth + ([objectives count]-1)*intraObjectiveSpacer;
            offsetx += (themeWidth - objectivesWidth)/2;
            
            for (uint i=0, ct=[objectives count]; i<ct; ++i) {                    
                ObjectiveBox *objectiveBox = 
                [[ObjectiveBox alloc] initWithObjective:[objectives objectAtIndex:i]
                                                  frame:CGRectMake(rect.origin.x + offsetx, rect.origin.y + row*stratRowHeight, realObjWidth, stratRowHeight-rowSpacer)
                                               fontName:[skinMan_ stringForProperty:kSkinSection3FontName forMediaType:mediaType]  
                                               fontSize:[skinMan_ fontSizeForProperty:kSkinSection3StrategyMapObjectiveFontSize forMediaType:mediaType] 
                                              fontColor:[skinMan_ colorForProperty:kSkinSection3StrategyMapFontColor forMediaType:mediaType] 
                                                  color:[objectiveColors objectAtIndex:cat]
                                           targetFrames:[NSMutableSet setWithObject:[NSValue valueWithCGRect:themeBox.frame]]
                 ];
                [boxes addObject:objectiveBox];
                [objectiveBox release];
                offsetx += realObjWidth + intraObjectiveSpacer;
            }
        }
        
        x += themeWidth + objSpacer;        
    }
    
    // find and collapse duplicate objectives
    // look through all of our objectives for this page
    // see if any exist in type and summary in either the same theme or other themes (remember by this definition of equality could have two the same in a theme)
    // if they do, must save the first of the duplicate boxes, remove the others, and add a target frame to the first for each one removed
    // the target is always the theme box, so there can't be more than 3
// Disable this feature for now; we will eventually have object-to-object relationships    
//    NSMutableIndexSet *boxesToRemove = [NSMutableIndexSet indexSet];
//    for (int i=0, ct=[boxes count]; i<ct; ++i) {
//        PointerBox *box = [boxes objectAtIndex:i];
//        if ([box isKindOfClass:[ObjectiveBox class]]) {
//            // now look for matches in the other boxes; they are different objectives, but the same summary and category
//            Objective *obj = [(ObjectiveBox*)box objective];
//            for (uint j=[boxes count]-1; j>i; --j) {
//                PointerBox *b = [boxes objectAtIndex:j];
//                if ([b isKindOfClass:[ObjectiveBox class]]) {
//                    Objective *o = [(ObjectiveBox*)b objective];
//                    if ([obj.summary isEqualToString:o.summary] && obj.objectiveType.category == o.objectiveType.category) {
//                        // schedule for removal
//                        [boxesToRemove addIndex:j];
//                        // find the themebox for this objective
//                        ThemeBox *themeBox = [StrategyMapView themeBoxForTheme:o.theme boxes:boxes];
//                        [box.targetFrames addObject:[NSValue valueWithCGRect:themeBox.frame]];
//                    }
//                }
//            }
//        }
//    }
//    [boxes removeObjectsAtIndexes:boxesToRemove];
    
    // draw arrows
    for (PointerBox *box in boxes) {
        [box drawArrow:context];    
    }
    
    // draw boxes
    for (PointerBox *box in boxes) {
        [box draw:context];
    }
    
    // let the sidebar clean up it's loading status
    // other reports are MBPDFView's, which fire this event automatically
    [EventManager fireReportViewDidDrawEventWithChapter:LocalizedString(@"STRATEGY_MAP_REPORT_TITLE", nil)];

}

+ (ThemeBox*)themeBoxForTheme:(Theme*)theme boxes:(NSArray*)boxes
{
    for (PointerBox *box in boxes) {
        if ([box isKindOfClass:[ThemeBox class]]) {
            if ([[(ThemeBox*)box theme] isEqual:theme]) {
                return (ThemeBox*)box;
            }
        }
    }
    return nil;
}

- (NSSet*)findAndCollapseObjectives:(Objective*)objective inThemes:(NSArray*)stratMapThemes 
{
    NSMutableSet *results = [NSMutableSet set];
    for (StratMapTheme *smt in stratMapThemes) {
        NSMutableSet *smtResults = [NSMutableSet set];
        for (Objective *obj in smt.objectives) {
            if ([obj.summary isEqualToString:objective.summary] && obj.objectiveType.category == objective.objectiveType.category) {
                [smtResults addObject:obj];
            }
        }
        
        // now remove any results from the set
        if ([smtResults count] > 0) {
            // just make a new set
            NSMutableSet *set = [smt.objectives mutableCopy];
            [set minusSet:smtResults];
            smt.objectives = set;
            [set release];
            
            [results addObject:smt.theme];
        }
    }
    return results;
}

- (void)drawStrategyStatement:(CGContextRef)context text:(NSString*)text inRect:(CGRect)rect
{    
    CGContextSaveGState(context);
    
    CGContextSetLineWidth(context, 2);
    CGContextSetStrokeColorWithColor(context, [[skinMan_ colorForProperty:kSkinSection3StrategyMapStrategyStatementLineColor forMediaType:mediaType] CGColor]);
    CGContextSetFillColorWithColor(context, [[skinMan_ colorForProperty:kSkinSection3StrategyMapStrategyStatementFillColor forMediaType:mediaType] CGColor]);
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(rect, 2, 2) byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
    CGContextAddPath(context, [path CGPath]);
    CGContextFillPath(context); 
    
    CGContextAddPath(context, [path CGPath]);    
    CGContextStrokePath(context);
    
    CGRect insetRect = CGRectInset(rect, 4, 4);
    
    UIFont *font = [UIFont fontWithName:[skinMan_ stringForProperty:kSkinSection3FontName forMediaType:mediaType]  
                                   size:[skinMan_ fontSizeForProperty:kSkinSection3FontSize forMediaType:mediaType]];
    CGSize size = [text sizeWithFont:font constrainedToSize:insetRect.size lineBreakMode:UILineBreakModeTailTruncation];
    
    CGContextSetFillColorWithColor(context, [[skinMan_ colorForProperty:kSkinSection3StrategyMapFontColor forMediaType:mediaType] CGColor]);
    [text drawInRect:CGRectMake(insetRect.origin.x, insetRect.origin.y + (insetRect.size.height-size.height)/2, insetRect.size.width, insetRect.size.height)
            withFont:font
       lineBreakMode:UILineBreakModeTailTruncation 
           alignment:UITextAlignmentCenter];
    
    CGContextRestoreGState(context);
}

@end
