//
//  EventManager.h
//  StratPad
//
//  Created by Eric Rogers on July 28, 2011.
//  Copyright 2011 Energy Insight. All rights reserved.
//

#import "Chapter.h"
#import "Theme.h"
#import "Objective.h"
#import "ContentViewController.h"
#import "NavigationConfig.h"
#import "Chart.h"

extern NSString * const kEVENT_CHAPTER_WILL_CHANGE;
extern NSString * const kEVENT_REPORT_VIEW_DID_DRAW;
extern NSString * const kEVENT_PARAM_CHAPTER;

extern NSString * const kEVENT_THEME_CREATED;
extern NSString * const kEVENT_THEME_DELETED;
extern NSString * const kEVENT_THEMES_REORDERED;

extern NSString * const kEVENT_OBJECTIVE_CREATED;
extern NSString * const kEVENT_OBJECTIVE_DELETED;
extern NSString * const kEVENT_OBJECTIVES_REORDERED;
extern NSString * const kEVENT_THEME_DATE_CHANGED;

extern NSString * const kEVENT_ACTIVITY_CREATED;
extern NSString * const kEVENT_ACTIVITY_DELETED;
extern NSString * const kEVENT_ACTIVITIES_REORDERED;

extern NSString * const kEVENT_STRATFILE_WILL_LOAD;
extern NSString * const kEVENT_STRATFILE_LOADED;
extern NSString * const kEVENT_PARAM_STRATFILE_CHAPTER_INDEX;

extern NSString * const kEVENT_STRATFILE_TITLE_CHANGED;

extern NSString * const kEVENT_JUMP_TO_THEME;
extern NSString * const kEVENT_PARAM_THEME;

extern NSString * const kEVENT_JUMP_TO_OBJECTIVE;
extern NSString * const kEVENT_PARAM_OBJECTIVE;

extern NSString * const kEVENT_JUMP_TO_ON_STRATEGY_PAGE;
extern NSString * const kEVENT_PARAM_ON_STRATEGY_PAGE;

extern NSString * const kEVENT_JUMP_TO_ON_STRATPAD_PAGE;
extern NSString * const kEVENT_PARAM_ON_STRATPAD_PAGE;

extern NSString * const kEVENT_JUMP_TO_TOOLKIT_PAGE;
extern NSString * const kEVENT_PARAM_TOOLKIT_PAGE;

extern NSString * const kEVENT_OPTIMISTIC_SETTING_CHANGED;

extern NSString * const kEVENT_CURRENCY_SETTING_CHANGED;

extern NSString * const kEVENT_CHART_OPTIONS_CHANGED;
extern NSString * const kEVENT_CHART_MEASUREMENTS_CHANGED;
extern NSString * const kEVENT_CHARTS_REORDERED;
extern NSString * const kEVENT_CHART_DELETED;
extern NSString * const kEVENT_CHART_ADDED;
extern NSString * const kEVENT_PARAM_CHART;

// after tapping the splash screen and showing the first page
extern NSString * const kEVENT_STRATPAD_READY;

// event if there are new comments data available
extern NSString * const kEVENT_YAMMER_COMMENTS_UPDATED;

// a successful uploading of one of the reports to yammer
extern NSString * const kEVENT_YAMMER_NEW_PUBLICATION;

// successfully logged into yammer; might want to update publications, comments
extern NSString * const kEVENT_YAMMER_LOGGED_IN;

@interface EventManager : NSObject {
    
}

+ (void)fireChapterWillChangeEventWithChapter:(Chapter*)chapter fromSource:(id)source;
+ (void)fireReportViewDidDrawEventWithChapter:(NSString*)chapter;

+ (void)fireThemeCreatedEvent;
+ (void)fireThemeDeletedEvent;
+ (void)fireThemesReorderedEvent;
+ (void)fireThemeDateChangedEvent;

+ (void)fireObjectiveCreatedEvent;
+ (void)fireObjectiveDeletedEvent;
+ (void)fireObjectivesReorderedEvent;

+ (void)fireActivityCreatedEvent;
+ (void)fireActivityDeletedEvent;
+ (void)fireActivitiesReorderedEvent;

+ (void)fireStratFileWillLoadEventWithChapterIndex:(ChapterIndex)chapterIndex;
+ (void)fireStratFileLoadedEventWithChapterIndex:(ChapterIndex)chapterIndex;

+ (void)fireStratFileDeletedEvent:(NSDictionary*)userInfo;
+ (void)fireStratFileTitleChangedEvent;

+ (void)fireJumpToThemeEventWithTheme:(Theme*)theme fromViewController:(ContentViewController*)controller;
+ (void)fireJumpToObjectiveEventWithObjective:(Objective*)objective fromViewController:(ContentViewController*)controller;

+ (void)fireJumpToOnStrategyPageWithPageName:(NSString*)pageName;
+ (void)fireJumpToOnStratPadPageWithPageName:(NSString*)pageName;
+ (void)fireJumpToToolkitPageWithPageName:(NSString*)pageName;

+ (void)fireOptimisticSettingChangeEvent;
+ (void)fireCurrencySettingChangeEvent;

+ (void)fireChartOptionsChangedEvent:(Chart*)chart;
+ (void)fireChartMeasurementsChangedEvent;
+ (void)fireChartsReorderedEvent;
+ (void)fireChartDeletedEvent;
+ (void)fireChartAddedEvent;

// after tapping the splash screen and showing the first page
+ (void)fireStratPadReady;

@end
