//
//  EventManager.m
//  StratPad
//
//  Created by Eric Rogers on July 28, 2011.
//  Copyright 2011 Energy Insight. All rights reserved.
//

#import "EventManager.h"
#import "RatingReminderManager.h"
#import "NavigationConfig.h"

NSString * const kEVENT_CHAPTER_WILL_CHANGE = @"kEVENT_CHAPTER_WILL_CHANGE";
NSString * const kEVENT_REPORT_VIEW_DID_DRAW = @"kEVENT_REPORT_VIEW_DID_DRAW";
NSString * const kEVENT_PARAM_CHAPTER = @"kEVENT_PARAM_CHAPTER";

NSString * const kEVENT_THEME_CREATED = @"kEVENT_THEME_CREATED";
NSString * const kEVENT_THEME_DELETED = @"kEVENT_THEME_DELETED";
NSString * const kEVENT_THEMES_REORDERED = @"kEVENT_THEMES_REORDERED";
NSString * const kEVENT_THEME_DATE_CHANGED = @"kEVENT_THEME_DATE_CHANGED";

NSString * const kEVENT_OBJECTIVE_CREATED = @"kEVENT_OBJECTIVE_CREATED";
NSString * const kEVENT_OBJECTIVE_DELETED = @"kEVENT_OBJECTIVE_DELETED";
NSString * const kEVENT_OBJECTIVES_REORDERED = @"kEVENT_OBJECTIVES_REORDERED";

NSString * const kEVENT_ACTIVITY_CREATED = @"kEVENT_ACTIVITY_CREATED";
NSString * const kEVENT_ACTIVITY_DELETED = @"kEVENT_ACTIVITY_DELETED";
NSString * const kEVENT_ACTIVITIES_REORDERED = @"kEVENT_ACTIVITIES_REORDERED";

NSString * const kEVENT_STRATFILE_WILL_LOAD = @"kEVENT_STRATFILE_WILL_LOAD";
NSString * const kEVENT_STRATFILE_LOADED = @"kEVENT_STRATFILE_LOADED";
NSString * const kEVENT_PARAM_STRATFILE_CHAPTER_INDEX = @"kEVENT_PARAM_STRATFILE_CHAPTER_INDEX";

NSString * const kEVENT_STRATFILE_DELETED = @"kEVENT_STRATFILE_DELETED";

NSString * const kEVENT_STRATFILE_TITLE_CHANGED = @"kEVENT_STRATFILE_TITLE_CHANGED";

NSString * const kEVENT_JUMP_TO_THEME = @"kEVENT_JUMP_TO_THEME";
NSString * const kEVENT_PARAM_THEME = @"kEVENT_PARAM_THEME";

NSString * const kEVENT_JUMP_TO_OBJECTIVE = @"kEVENT_JUMP_TO_OBJECTIVE";
NSString * const kEVENT_PARAM_OBJECTIVE = @"kEVENT_PARAM_OBJECTIVE";

NSString * const kEVENT_JUMP_TO_ON_STRATEGY_PAGE = @"kEVENT_JUMP_TO_ON_STRATEGY_PAGE";
NSString * const kEVENT_PARAM_ON_STRATEGY_PAGE = @"kEVENT_PARAM_ON_STRATEGY_PAGE";

NSString * const kEVENT_JUMP_TO_ON_STRATPAD_PAGE = @"kEVENT_JUMP_TO_ON_STRATPAD_PAGE";
NSString * const kEVENT_PARAM_ON_STRATPAD_PAGE = @"kEVENT_PARAM_ON_STRATPAD_PAGE";

NSString * const kEVENT_JUMP_TO_TOOLKIT_PAGE = @"kEVENT_JUMP_TO_TOOLKIT_PAGE";
NSString * const kEVENT_PARAM_TOOLKIT_PAGE = @"kEVENT_PARAM_TOOLKIT_PAGE";

NSString * const kEVENT_OPTIMISTIC_SETTING_CHANGED = @"kEVENT_OPTIMISTIC_SETTING_CHANGED";

NSString * const kEVENT_CURRENCY_SETTING_CHANGED = @"kEVENT_CURRENCY_SETTING_CHANGED";

NSString * const kEVENT_CHART_OPTIONS_CHANGED = @"kEVENT_CHART_OPTIONS_CHANGED";
NSString * const kEVENT_CHART_MEASUREMENTS_CHANGED = @"kEVENT_CHART_MEASUREMENTS_CHANGED";
NSString * const kEVENT_CHARTS_REORDERED = @"kEVENT_CHARTS_REORDERED";
NSString * const kEVENT_CHART_DELETED = @"kEVENT_CHART_DELETED";
NSString * const kEVENT_CHART_ADDED = @"kEVENT_CHART_ADDED";
NSString * const kEVENT_PARAM_CHART = @"kEVENT_PARAM_CHART";

NSString * const kEVENT_STRATPAD_READY = @"kEVENT_STRATPAD_READY";

NSString * const kEVENT_YAMMER_COMMENTS_UPDATED = @"kEVENT_YAMMER_COMMENTS_UPDATED";
NSString * const kEVENT_YAMMER_NEW_PUBLICATION = @"kEVENT_YAMMER_NEW_PUBLICATION";
NSString * const kEVENT_YAMMER_LOGGED_IN = @"kEVENT_YAMMER_LOGGED_IN";

@implementation EventManager

+ (void)fireChapterWillChangeEventWithChapter:(Chapter*)chapter fromSource:(id)source
{
    // note that we turned off coalescing of notifications
    // so if you click too fast on the sidebar, all chapters will load, one after the other
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
							  chapter, kEVENT_PARAM_CHAPTER,
							  nil];
	NSNotification *notification = [NSNotification notificationWithName:kEVENT_CHAPTER_WILL_CHANGE object:source userInfo:userInfo];
    [[NSNotificationQueue defaultQueue] enqueueNotification:notification postingStyle:NSPostASAP
                                               coalesceMask:NSNotificationNoCoalescing forModes:nil];
 
    if ([[[NavigationConfig sharedManager] chapters] indexOfObject:chapter] == ChapterIndexStrategyMap) {
        // user reached a milestone - visiting the first report.
        [[RatingReminderManager sharedManager] userVisitedFirstReport];    
    }
}

+ (void)fireReportViewDidDrawEventWithChapter:(NSString*)chapter
{
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
							  chapter, kEVENT_PARAM_CHAPTER,
							  nil];
	NSNotification *notification = [NSNotification notificationWithName:kEVENT_REPORT_VIEW_DID_DRAW object:nil userInfo:userInfo];
	[[NSNotificationQueue defaultQueue] enqueueNotification:notification postingStyle:NSPostASAP];		
}


+ (void)fireThemeCreatedEvent
{
	NSNotification *notification = [NSNotification notificationWithName:kEVENT_THEME_CREATED object:nil userInfo:nil];
	[[NSNotificationQueue defaultQueue] enqueueNotification:notification postingStyle:NSPostASAP];		
    
    // user reached a milestone - entering a name for a StratFile.
    [[RatingReminderManager sharedManager] userCreatedTheme];
}

+ (void)fireThemeDeletedEvent
{
	NSNotification *notification = [NSNotification notificationWithName:kEVENT_THEME_DELETED object:nil userInfo:nil];
	[[NSNotificationQueue defaultQueue] enqueueNotification:notification postingStyle:NSPostASAP];		
}

+ (void)fireThemesReorderedEvent
{
	NSNotification *notification = [NSNotification notificationWithName:kEVENT_THEMES_REORDERED object:nil userInfo:nil];
	[[NSNotificationQueue defaultQueue] enqueueNotification:notification postingStyle:NSPostASAP];		
}

+ (void)fireThemeDateChangedEvent
{
	NSNotification *notification = [NSNotification notificationWithName:kEVENT_THEME_DATE_CHANGED object:nil userInfo:nil];
	[[NSNotificationQueue defaultQueue] enqueueNotification:notification postingStyle:NSPostASAP];		
}

+ (void)fireObjectiveCreatedEvent
{
	NSNotification *notification = [NSNotification notificationWithName:kEVENT_OBJECTIVE_CREATED object:nil userInfo:nil];
	[[NSNotificationQueue defaultQueue] enqueueNotification:notification postingStyle:NSPostASAP];		
}

+ (void)fireObjectiveDeletedEvent
{
	NSNotification *notification = [NSNotification notificationWithName:kEVENT_OBJECTIVE_DELETED object:nil userInfo:nil];
	[[NSNotificationQueue defaultQueue] enqueueNotification:notification postingStyle:NSPostASAP];		
}

+ (void)fireObjectivesReorderedEvent
{
	NSNotification *notification = [NSNotification notificationWithName:kEVENT_OBJECTIVES_REORDERED object:nil userInfo:nil];
	[[NSNotificationQueue defaultQueue] enqueueNotification:notification postingStyle:NSPostASAP];		
}


+ (void)fireActivityCreatedEvent 
{
	NSNotification *notification = [NSNotification notificationWithName:kEVENT_ACTIVITY_CREATED object:nil userInfo:nil];
	[[NSNotificationQueue defaultQueue] enqueueNotification:notification postingStyle:NSPostASAP];		    
}

+ (void)fireActivityDeletedEvent
{
	NSNotification *notification = [NSNotification notificationWithName:kEVENT_ACTIVITY_DELETED object:nil userInfo:nil];
	[[NSNotificationQueue defaultQueue] enqueueNotification:notification postingStyle:NSPostASAP];		        
}

+ (void)fireActivitiesReorderedEvent
{
	NSNotification *notification = [NSNotification notificationWithName:kEVENT_ACTIVITIES_REORDERED object:nil userInfo:nil];
	[[NSNotificationQueue defaultQueue] enqueueNotification:notification postingStyle:NSPostASAP];		            
}

+ (void)fireStratFileWillLoadEventWithChapterIndex:(ChapterIndex)chapterIndex
{    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
							  [NSNumber numberWithInt:chapterIndex], kEVENT_PARAM_STRATFILE_CHAPTER_INDEX,
							  nil];
    // must post asynchronously, so that we don't have other things happening before the old stratfile is cleaned up
	NSNotification *notification = [NSNotification notificationWithName:kEVENT_STRATFILE_WILL_LOAD object:nil userInfo:userInfo];
	[[NSNotificationQueue defaultQueue] enqueueNotification:notification postingStyle:NSPostNow];		
}

+ (void)fireStratFileLoadedEventWithChapterIndex:(ChapterIndex)chapterIndex
{    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
							  [NSNumber numberWithInt:chapterIndex], kEVENT_PARAM_STRATFILE_CHAPTER_INDEX,
							  nil];
	NSNotification *notification = [NSNotification notificationWithName:kEVENT_STRATFILE_LOADED object:nil userInfo:userInfo];
	[[NSNotificationQueue defaultQueue] enqueueNotification:notification postingStyle:NSPostASAP];		
}


+ (void)fireStratFileDeletedEvent:(NSDictionary*)userInfo
{
	NSNotification *notification = [NSNotification notificationWithName:kEVENT_STRATFILE_DELETED object:nil userInfo:userInfo];
	[[NSNotificationQueue defaultQueue] enqueueNotification:notification postingStyle:NSPostASAP];		
}

+ (void)fireStratFileTitleChangedEvent
{
	NSNotification *notification = [NSNotification notificationWithName:kEVENT_STRATFILE_TITLE_CHANGED object:nil userInfo:nil];
	[[NSNotificationQueue defaultQueue] enqueueNotification:notification postingStyle:NSPostASAP];		
    
    // user reached a milestone - entering a name for a StratFile.
    [[RatingReminderManager sharedManager] userEnteredStratFileName];
}


+ (void)fireJumpToThemeEventWithTheme:(Theme*)theme fromViewController:(ContentViewController*)controller
{
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
							  theme, kEVENT_PARAM_THEME,
							  nil];
	NSNotification *notification = [NSNotification notificationWithName:kEVENT_JUMP_TO_THEME object:controller userInfo:userInfo];
	[[NSNotificationQueue defaultQueue] enqueueNotification:notification postingStyle:NSPostASAP];		
}

+ (void)fireJumpToObjectiveEventWithObjective:(Objective*)objective fromViewController:(ContentViewController*)controller
{
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
							  objective, kEVENT_PARAM_OBJECTIVE,
							  nil];
	NSNotification *notification = [NSNotification notificationWithName:kEVENT_JUMP_TO_OBJECTIVE object:controller userInfo:userInfo];
	[[NSNotificationQueue defaultQueue] enqueueNotification:notification postingStyle:NSPostASAP];		
}

+ (void)fireJumpToOnStrategyPageWithPageName:(NSString*)pageName
{
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
							  pageName, kEVENT_PARAM_ON_STRATEGY_PAGE,
							  nil];
	NSNotification *notification = [NSNotification notificationWithName:kEVENT_JUMP_TO_ON_STRATEGY_PAGE object:nil userInfo:userInfo];
	[[NSNotificationQueue defaultQueue] enqueueNotification:notification postingStyle:NSPostASAP];		    
}

+ (void)fireJumpToOnStratPadPageWithPageName:(NSString*)pageName
{
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
							  pageName, kEVENT_PARAM_ON_STRATPAD_PAGE,
							  nil];
	NSNotification *notification = [NSNotification notificationWithName:kEVENT_JUMP_TO_ON_STRATPAD_PAGE object:nil userInfo:userInfo];
	[[NSNotificationQueue defaultQueue] enqueueNotification:notification postingStyle:NSPostASAP];		        
}

+ (void)fireJumpToToolkitPageWithPageName:(NSString*)pageName
{
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
							  pageName, kEVENT_PARAM_TOOLKIT_PAGE,
							  nil];
	NSNotification *notification = [NSNotification notificationWithName:kEVENT_JUMP_TO_TOOLKIT_PAGE object:nil userInfo:userInfo];
	[[NSNotificationQueue defaultQueue] enqueueNotification:notification postingStyle:NSPostASAP];		        
}

+ (void)fireOptimisticSettingChangeEvent
{
 	NSNotification *notification = [NSNotification notificationWithName:kEVENT_OPTIMISTIC_SETTING_CHANGED object:nil userInfo:nil];
	[[NSNotificationQueue defaultQueue] enqueueNotification:notification postingStyle:NSPostASAP];		   
}

+ (void)fireCurrencySettingChangeEvent
{
 	NSNotification *notification = [NSNotification notificationWithName:kEVENT_CURRENCY_SETTING_CHANGED object:nil userInfo:nil];
	[[NSNotificationQueue defaultQueue] enqueueNotification:notification postingStyle:NSPostASAP];		       
}

+ (void)fireChartOptionsChangedEvent:(Chart*)chart
{
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
							  chart, kEVENT_PARAM_CHART,
							  nil];

 	NSNotification *notification = [NSNotification notificationWithName:kEVENT_CHART_OPTIONS_CHANGED object:nil userInfo:userInfo];
	[[NSNotificationQueue defaultQueue] enqueueNotification:notification postingStyle:NSPostASAP];		           
}

+ (void)fireChartMeasurementsChangedEvent
{
 	NSNotification *notification = [NSNotification notificationWithName:kEVENT_CHART_MEASUREMENTS_CHANGED object:nil userInfo:nil];
	[[NSNotificationQueue defaultQueue] enqueueNotification:notification postingStyle:NSPostASAP];		           
}

+ (void)fireChartsReorderedEvent
{
 	NSNotification *notification = [NSNotification notificationWithName:kEVENT_CHARTS_REORDERED object:nil userInfo:nil];
	[[NSNotificationQueue defaultQueue] enqueueNotification:notification postingStyle:NSPostASAP];		               
}

+ (void)fireChartDeletedEvent
{
 	NSNotification *notification = [NSNotification notificationWithName:kEVENT_CHART_DELETED object:nil userInfo:nil];
	[[NSNotificationQueue defaultQueue] enqueueNotification:notification postingStyle:NSPostASAP];		               
}

+ (void)fireChartAddedEvent
{
 	NSNotification *notification = [NSNotification notificationWithName:kEVENT_CHART_ADDED object:nil userInfo:nil];
	[[NSNotificationQueue defaultQueue] enqueueNotification:notification postingStyle:NSPostASAP];		               
}

+ (void)fireStratPadReady
{
 	NSNotification *notification = [NSNotification notificationWithName:kEVENT_STRATPAD_READY object:nil userInfo:nil];
	[[NSNotificationQueue defaultQueue] enqueueNotification:notification postingStyle:NSPostASAP];		                   
}

@end

