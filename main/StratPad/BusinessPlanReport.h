//
//  BusinessPlanReport.h
//  StratPad
//
//  Created by Julian Wood on 9/15/11.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "AbstractReportDelegate.h"
#import "MBDrawableGanttChart.h"
#import "BusinessPlanSkin.h"
#import "AllowingUsToProgressChart.h"
#import "ReachTheseGoalsChart.h"

@interface BusinessPlanReport : AbstractReportDelegate<ScreenReportDelegate, PrintReportDelegate> {
@private
    
    // contains arrays corresponding to a page, each containing drawables for that page.
    NSArray *pagedDrawables_;
    
    CGFloat yPosition_;
        
    // defines the horizontal starting position for the content, and its width
    CGFloat contentStartX_;
    CGFloat contentWidth_;
            
    BOOL hasMorePages_;    
}

@property(nonatomic,retain) BusinessPlanSkin *businessPlanSkin;

// must be provided by the controller
@property(nonatomic, copy) NSString *sectionAContent;
@property(nonatomic, copy) NSString *sectionBContent;

// returns an autoreleased MBDrawableGanttChart that fits in the supplied rect
- (MBDrawableGanttChart*)ganttChart:(CGRect)rect;

// returns an autoreleased ReachTheseGoalsChart that fits in the supplied rect
-(ReachTheseGoalsChart*)reachTheseGoalsChart:(CGRect)rect;

// returns an autoreleased AllowingUsToProgressChart that fits in the supplied rect
-(AllowingUsToProgressChart*)allowingUsToProgressChart:(CGRect)rect;

@end
