//
//  NavigationConfig.m
//  StratPad
//
//  Created by Eric Rogers on July 27, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "NavigationConfig.h"
#import "SynthesizeSingleton.h"
#import "ContentViewController.h"
#import "ThemeDetailViewController.h"
#import "DefineObjectivesViewController.h"
#import "ActivityViewController.h"
#import "StrategyMapViewController.h"
#import "StrategyFinancialAnalysisThemeViewController.h"
#import "ThemeFinancialAnalysisMonthViewController.h"
#import "ThemeDetailReportViewController.h"
#import "HTMLPage.h"
#import "FormPage.h"
#import "ReportPage.h"
#import "StratFile.h"
#import "Theme.h"
#import "Objective.h"
#import "Activity.h"
#import "EventManager.h"
#import "ProjectPlanViewController.h"
#import "MeetingAgendaViewController.h"
#import "BusinessPlanViewController.h"
#import "EditionManager.h"
#import "AdManager.h"
#import "AdPage.h"
#import "StrategyFinancialAnalysisMonthViewController.h"
#import "HTMLViewController.h"
#import "StratBoardViewController.h"
#import "Chart.h"
#import "ChartViewController.h"

@interface NavigationConfig (Private)
- (void)stratFileLoaded:(NSNotification*)notification;
- (void)populateThemeDetailPagesForStratFileOrNil:(StratFile*)stratFile;
- (void)populateDefineObjectivePagesForStratFileOrNil:(StratFile*)stratFile;
- (void)populateActivityPagesForStratFileOrNil:(StratFile*)stratFile;
- (void)populateStrategyMapPagesForStratFileOrNil:(StratFile*)stratFile;
- (void)populateStrategyFinancialAnalysisMonthPagesForStratFileOrNil:(StratFile*)stratFile;
- (void)populateStrategyFinancialAnalysisThemePagesForStratFileOrNil:(StratFile*)stratFile;
- (void)populateThemeFinancialAnalysisMonthPagesForStratFileOrNil:(StratFile*)stratFile;
- (void)populateThemeDetailReportPagesForStratFileOrNil:(StratFile*)stratFile;
- (void)populateStratBoardPagesForStratFileOrNil:(StratFile*)stratFile;
- (void)calculateTotalPages;
- (NSUInteger)indexOfThemeInStratFile:(Theme*)theme includeObjectives:(BOOL)includeObjectives;
- (ThemeDetailViewController*)newThemeDetailControllerForPageAtIndex:(NSUInteger)index;
- (DefineObjectivesViewController*)newDefineObjectivesControllerForPageAtIndex:(NSUInteger)index;
- (ActivityViewController*)newActivityControllerForPageAtIndex:(NSUInteger)index;
- (StrategyMapViewController*)newStrategyMapViewControllerForPageAtIndex:(NSUInteger)index;
- (StrategyFinancialAnalysisMonthViewController*)newStrategyFinancialAnalysisMonthViewControllerForPageAtIndex:(NSUInteger)index;
- (StrategyFinancialAnalysisThemeViewController*)newStrategyFinancialAnalysisThemeViewControllerForPageAtIndex:(NSUInteger)index;
- (ThemeFinancialAnalysisMonthViewController*)newThemeFinancialAnalysisMonthViewControllerForPageAtIndex:(NSUInteger)index;
- (ThemeDetailReportViewController*)newThemeDetailReportViewControllerForPageAtIndex:(NSUInteger)index;
- (StratBoardViewController*)newChartViewControllerForPageAtIndex:(NSUInteger)index;
@end

@implementation NavigationConfig

@synthesize chapters = chapters_;
@synthesize totalPages = totalPages_;

SYNTHESIZE_SINGLETON_FOR_CLASS(NavigationConfig)

- (id)init
{
    if ((self = [super init])) {    
        
        // build an initial navigation tree to start with.
        [self buildNavigationFromStratFileOrNil:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(stratFileLoaded:)
													 name:kEVENT_STRATFILE_LOADED
												   object:nil];
    }
    return self;
}


#pragma mark - Memory Management

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [chapters_ release];
    
    [super dealloc];
}


#pragma mark - NSNotification Handlers

- (void)stratFileLoaded:(NSNotification*)notification
{
    [self buildNavigationFromStratFileOrNil:[StratFileManager sharedManager].currentStratFile];
}


#pragma mark - Public

- (NSInteger)indexOfPage:(Page*)page
{
    NSUInteger index = 0;
    Chapter *chapter;
    for (int i = 0; i < chapters_.count; i++) {
        chapter = [chapters_ objectAtIndex:i];        
        for (int j = 0; j < chapter.pages.count; j++) {                                    
            if ([chapter.pages objectAtIndex:j] == page) {
                return index;
            }
            index++;
        }
    } 
    
    ELog(@"Couldn't find index of page: %@", page);
    
    return -1;
}

- (Page*)pageAtIndex:(NSUInteger)pageIndex
{
    NSUInteger pageCount = 0;
    Chapter *chapter;
    for (int i = 0; i < chapters_.count; i++) {
        chapter = [chapters_ objectAtIndex:i];
        NSUInteger chapCt = chapter.pages.count;
        if (pageCount + chapCt > pageIndex) {
            for (int j = 0; j < chapter.pages.count; j++) {
                if (pageCount == pageIndex) {
                    return [chapter.pages objectAtIndex:j];
                }
                pageCount++;
            }            
        } else {
            pageCount += chapCt;
        }
    }

    return nil;    
}

- (Chapter*)chapterAtIndex:(NSUInteger)pageIndex
{
    NSUInteger pageCount = 0;
    Chapter *chapter;
    for (int i = 0; i < chapters_.count; i++) {
        chapter = [chapters_ objectAtIndex:i];
        NSUInteger chapCt = chapter.pages.count;
        if (pageCount + chapCt > pageIndex) {
            return chapter;
        } else {
            pageCount += chapCt;
        }
    }
    
    return nil;
}

- (Chapter*)chapterAtChapterIndex:(ChapterIndex)chapterIndex
{
    return [chapters_ objectAtIndex:chapterIndex];
}


- (NSUInteger)pageNumberAtIndex:(NSUInteger)pageIndex
{
    NSUInteger pageCount = 0;
    Chapter *chapter;
    for (int i = 0; i < chapters_.count; i++) {
        chapter = [chapters_ objectAtIndex:i];
        NSUInteger chapCt = chapter.pages.count;
        if (pageCount + chapCt > pageIndex) {
            for (int j = 0; j < chapter.pages.count; j++) {
                if (pageCount == pageIndex) {
                    return j;
                }
                pageCount++;
            }
        } else {
            pageCount += chapCt;
        }
    }
    
    return INT_MAX;
}



- (void)buildNavigationFromStratFileOrNil:(StratFile*)stratFile
{
    // build the base navigation from Config.plist.
    [self buildBaseNavigationFromPlist];

    // build dynamic forms (F5, F6, F7) based off of the StratFile.
    [self populateThemeDetailPagesForStratFileOrNil:stratFile];    
    [self populateDefineObjectivePagesForStratFileOrNil:stratFile];    
    [self populateActivityPagesForStratFileOrNil:stratFile];
    
    // build dynamic reports (with variable numbers of pages)
    [self populateStrategyMapPagesForStratFileOrNil:stratFile];
    [self populateStrategyFinancialAnalysisMonthPagesForStratFileOrNil:stratFile];
    [self populateStrategyFinancialAnalysisThemePagesForStratFileOrNil:stratFile];
    [self populateThemeFinancialAnalysisMonthPagesForStratFileOrNil:stratFile];
    [self populateThemeDetailReportPagesForStratFileOrNil:stratFile];
    [self populateStratBoardPagesForStratFileOrNil:stratFile];
    
    [self calculateTotalPages];
}

- (void)buildBaseNavigationFromPlist
{
    NSString *configDataPath = [[NSBundle mainBundle] pathForResource:@"Pages" ofType:@"plist"];
    NSArray *chapters = [[NSMutableDictionary dictionaryWithContentsOfFile:configDataPath] objectForKey:@"Chapters"];  
    
    if (!chapters_) {
        chapters_ = [[NSMutableArray alloc] initWithCapacity:[chapters count]];        
    } else {
        [chapters_ removeAllObjects];
    }
    
    int chapterCount = 0;
    for (NSDictionary *chapterDict in chapters) {
        Chapter *chapter = [[Chapter alloc] initWithDictionary:chapterDict];
        chapter.chapterIndex = chapterCount++;
        [chapters_ addObject:chapter];
        [chapter release];
    }  
/*
    // no toolkit for free users - just the first page
    if (![[EditionManager sharedManager] isFeatureEnabled:FeatureToolkit]) {
        Chapter *chapter = [self.chapters objectAtIndex:ChapterIndexToolkit];
        [chapter.pages removeObjectsInRange:NSMakeRange(1, chapter.pages.count-1)];
    }
*/
}

// F5
- (void)populateThemeDetailPagesForStratFileOrNil:(StratFile*)stratFile 
{
    Chapter *themeDetailChapter = [chapters_ objectAtIndex:ChapterIndexThemeDetail];
    [themeDetailChapter.pages removeAllObjects];
    
    FormPage *themeDetailPage;
    
    if (!stratFile || stratFile.themes.count == 0) {
        // ensure that we always have at least one theme detail page.
        themeDetailPage = [[FormPage alloc] init];
        themeDetailPage.viewControllerClass = NSStringFromClass([ThemeDetailViewController class]);
        [themeDetailChapter.pages addObject:themeDetailPage];
        [themeDetailPage release];
        
    } else {        
        for (Theme *theme in stratFile.themes) {
            themeDetailPage = [[FormPage alloc] init];
            themeDetailPage.viewControllerClass = NSStringFromClass([ThemeDetailViewController class]);
            [themeDetailChapter.pages addObject:themeDetailPage];
            [themeDetailPage release];
        }
    }            
}

// F6
- (void)populateDefineObjectivePagesForStratFileOrNil:(StratFile*)stratFile
{
    Chapter *defineObjectivesChapter = [chapters_ objectAtIndex:ChapterIndexDefineObjectives];
    [defineObjectivesChapter.pages removeAllObjects];    
    
    FormPage *defineObjectivePage;
    
    if (!stratFile || stratFile.themes.count == 0) {
        // ensure that we always have at least one define objectives page.        
        defineObjectivePage = [[FormPage alloc] init];
        defineObjectivePage.viewControllerClass = NSStringFromClass([DefineObjectivesViewController class]);
        [defineObjectivesChapter.pages addObject:defineObjectivePage];
        [defineObjectivePage release];
        
    } else {
        for (Theme *theme in stratFile.themes) {
            defineObjectivePage = [[FormPage alloc] init];
            defineObjectivePage.viewControllerClass = NSStringFromClass([DefineObjectivesViewController class]);
            [defineObjectivesChapter.pages addObject:defineObjectivePage];
            [defineObjectivePage release];
        }
    }
}

// F7
- (void)populateActivityPagesForStratFileOrNil:(StratFile*)stratFile
{
    Chapter *activityChapter = [chapters_ objectAtIndex:ChapterIndexActivity];
    [activityChapter.pages removeAllObjects];    
    
    FormPage *activityPage;
    
    if (!stratFile || stratFile.themes.count == 0) {
        // ensure that we always have at least one activity page.        
        activityPage = [[FormPage alloc] init];
        activityPage.viewControllerClass = NSStringFromClass([ActivityViewController class]);
        [activityChapter.pages addObject:activityPage];
        [activityPage release];
        
    } else {
        for (Theme *theme in stratFile.themes) {
            
            if (theme.objectives.count == 0) {
                // ensure that we always have at least one activity page per theme.
                activityPage = [[FormPage alloc] init];
                activityPage.viewControllerClass = NSStringFromClass([ActivityViewController class]);
                [activityChapter.pages addObject:activityPage];
                [activityPage release];
            } else {            
                for (Objective *objective in theme.objectives) {
                    activityPage = [[FormPage alloc] init];
                    activityPage.viewControllerClass = NSStringFromClass([ActivityViewController class]);
                    [activityChapter.pages addObject:activityPage];
                    [activityPage release];
                }
            }
        }
    }
}

// R1
- (void)populateStrategyMapPagesForStratFileOrNil:(StratFile*)stratFile
{
    Chapter *chapter = [chapters_ objectAtIndex:ChapterIndexStrategyMap];
    [chapter.pages removeAllObjects];    

    NSUInteger numberOfPages = [StrategyMapViewController numberOfPages:stratFile];
        
    ReportPage *strategyMapPage;
    
    for (uint i = 0; i < numberOfPages; i++) {
        strategyMapPage = [[ReportPage alloc] init];
        strategyMapPage.viewControllerClass = NSStringFromClass([StrategyMapViewController class]);
        [chapter.pages addObject:strategyMapPage];
        [strategyMapPage release];
    }    
}

// R2
- (void)populateStrategyFinancialAnalysisMonthPagesForStratFileOrNil:(StratFile*)stratFile
{
    Chapter *chapter = [chapters_ objectAtIndex:ChapterIndexStrategyFinancialAnalysisMonth];
    [chapter.pages removeAllObjects];    
    
    NSUInteger numberOfPages = [StrategyFinancialAnalysisMonthViewController numberOfPages:stratFile];    
    ReportPage *page;
    
    for (uint i = 0; i < numberOfPages; i++) {
        page = [[ReportPage alloc] init];
        page.viewControllerClass = NSStringFromClass([StrategyFinancialAnalysisMonthViewController class]);
        [chapter.pages addObject:page];
        [page release];
    }
    
    // append an ad (R2-R5 only)
    if ([[EditionManager sharedManager] isFeatureEnabled:FeatureAds]) {
        NSDictionary *pageDict = [[AdManager sharedManager] ad];
        AdPage *adPage = [[AdPage alloc] initWithDictionary:pageDict];
        [chapter.pages addObject:adPage];
        [adPage release];
    }

}

// R3
- (void)populateStrategyFinancialAnalysisThemePagesForStratFileOrNil:(StratFile*)stratFile
{
    Chapter *chapter = [chapters_ objectAtIndex:ChapterIndexStrategyFinancialAnalysisTheme];
    [chapter.pages removeAllObjects];    
    
    NSUInteger numberOfPages = [StrategyFinancialAnalysisThemeViewController numberOfPages:stratFile];    
    ReportPage *page;
    
    for (uint i = 0; i < numberOfPages; i++) {
        page = [[ReportPage alloc] init];
        page.viewControllerClass = NSStringFromClass([StrategyFinancialAnalysisThemeViewController class]);
        [chapter.pages addObject:page];
        [page release];
    }
    
    // append an ad (R2-R5 only)
    if ([[EditionManager sharedManager] isFeatureEnabled:FeatureAds]) {
        NSDictionary *pageDict = [[AdManager sharedManager] ad];
        AdPage *adPage = [[AdPage alloc] initWithDictionary:pageDict];
        [chapter.pages addObject:adPage];
        [adPage release];
    }
}

// R4
- (void)populateThemeFinancialAnalysisMonthPagesForStratFileOrNil:(StratFile*)stratFile 
{
    Chapter *chapter = [chapters_ objectAtIndex:ChapterIndexThemeFinancialAnalysisMonth];
    [chapter.pages removeAllObjects];
    
    NSUInteger numberOfPages = [ThemeFinancialAnalysisMonthViewController numberOfPages:stratFile];    
    ReportPage *page;
    
    for (uint i = 0; i < numberOfPages; i++) {
        page = [[ReportPage alloc] init];
        page.viewControllerClass = NSStringFromClass([ThemeFinancialAnalysisMonthViewController class]);
        [chapter.pages addObject:page];
        [page release];
    }

    // append an ad (R2-R5 only)
    if ([[EditionManager sharedManager] isFeatureEnabled:FeatureAds]) {
        NSDictionary *pageDict = [[AdManager sharedManager] ad];
        AdPage *adPage = [[AdPage alloc] initWithDictionary:pageDict];
        [chapter.pages addObject:adPage];
        [adPage release];
    }
}

// R5
- (void)populateThemeDetailReportPagesForStratFileOrNil:(StratFile*)stratFile 
{
    Chapter *chapter = [chapters_ objectAtIndex:ChapterIndexThemeDetailReport];
    [chapter.pages removeAllObjects];
    
    ReportPage *themeDetailReportPage;

    for (Theme *theme in [stratFile themesSortedByOrder]) {
        // only add a themedetail page if that theme has objectives
        if (theme.objectives.count) {
            themeDetailReportPage = [[ReportPage alloc] init];
            themeDetailReportPage.viewControllerClass = NSStringFromClass([ThemeDetailReportViewController class]);
            [chapter.pages addObject:themeDetailReportPage];
            [themeDetailReportPage release];                
        }
    }

    if (chapter.pages.count == 0) {
        // ensure that we always have at least one theme detail report page.
        themeDetailReportPage = [[ReportPage alloc] init];
        themeDetailReportPage.viewControllerClass = NSStringFromClass([ThemeDetailReportViewController class]);
        [chapter.pages addObject:themeDetailReportPage];
        [themeDetailReportPage release];
    } 
    
    // append an ad (R2-R5 only)
    if ([[EditionManager sharedManager] isFeatureEnabled:FeatureAds]) {
        NSDictionary *pageDict = [[AdManager sharedManager] ad];
        AdPage *adPage = [[AdPage alloc] initWithDictionary:pageDict];
        [chapter.pages addObject:adPage];
        [adPage release];
    }
}

// StratBoard
- (void)populateStratBoardPagesForStratFileOrNil:(StratFile*)stratFile;
{
    Chapter *chapter = [chapters_ objectAtIndex:ChapterIndexStratBoard];
    [chapter.pages removeAllObjects];
    
    // there is always an index page and then one for each chart, ordered by the user        
    ReportPage *stratBoardPage = [[ReportPage alloc] init];
    stratBoardPage.viewControllerClass = NSStringFromClass([StratBoardViewController class]);
    [chapter.pages addObject:stratBoardPage];
    [stratBoardPage release];
    
    // add pages for charts
    if ([[EditionManager sharedManager] isFeatureEnabled:FeatureHasStratBoard]) {
        NSArray *charts = [Chart chartsSortedByOrderForStratFile:stratFile];
        for (Chart *chart in charts) {
            ReportPage *reportPage = [[ReportPage alloc] init];
            reportPage.viewControllerClass = NSStringFromClass([ChartViewController class]);
            [chapter.pages addObject:reportPage];
            [reportPage release];
        }        
    }
}



- (ContentViewController*)newContentControllerForPageAtIndex:(NSUInteger)index
{
    Page *page = [self pageAtIndex:index];    

    ContentViewController *cvc;
    if ([page isKindOfClass:[HTMLPage class]]) { // includes AdPage
        HTMLPage *htmlPage = ((HTMLPage*)page);        
        cvc = [[NSClassFromString(htmlPage.viewControllerClass) alloc] initWithNibName:@"HTMLViewController" bundle:nil andHTMLFileName:htmlPage.filename];
        
    } else if ([page isKindOfClass:[FormPage class]]) {
        
        // for some VC's, we need a specific constructor, otherwise just use the generic
        FormPage *formPage = ((FormPage*)page);
        
        if ([formPage.viewControllerClass isEqualToString:NSStringFromClass([ThemeDetailViewController class])]) {
            
           cvc = [self newThemeDetailControllerForPageAtIndex:index];
            
        } else if ([formPage.viewControllerClass isEqualToString:NSStringFromClass([DefineObjectivesViewController class])]) {

            cvc = [self newDefineObjectivesControllerForPageAtIndex:index];
            
        } else if ([formPage.viewControllerClass isEqualToString:NSStringFromClass([ActivityViewController class])]) {
            
            cvc = [self newActivityControllerForPageAtIndex:index];
                    
        } else {
            cvc = [[NSClassFromString(formPage.viewControllerClass) alloc] initWithNibName:nil bundle:nil];
        }
        
    } else if ([page isKindOfClass:[ReportPage class]]) {
        
        // for some VC's, we need a specific constructor, otherwise just use the generic
        ReportPage *reportPage = ((ReportPage*)page);
                
        if ([reportPage.viewControllerClass isEqualToString:NSStringFromClass([StrategyMapViewController class])]) {
            cvc = [self newStrategyMapViewControllerForPageAtIndex:index]; 
            
        } else if ([reportPage.viewControllerClass isEqualToString:NSStringFromClass([StrategyFinancialAnalysisThemeViewController class])]) {
            cvc = [self newStrategyFinancialAnalysisThemeViewControllerForPageAtIndex:index];

        } else if ([reportPage.viewControllerClass isEqualToString:NSStringFromClass([StrategyFinancialAnalysisMonthViewController class])]) {
            cvc = [self newStrategyFinancialAnalysisMonthViewControllerForPageAtIndex:index];

        } else if ([reportPage.viewControllerClass isEqualToString:NSStringFromClass([ThemeFinancialAnalysisMonthViewController class])]) {
            cvc = [self newThemeFinancialAnalysisMonthViewControllerForPageAtIndex:index];

        } else if ([reportPage.viewControllerClass isEqualToString:NSStringFromClass([ThemeDetailReportViewController class])]) {
            cvc = [self newThemeDetailReportViewControllerForPageAtIndex:index];

        } else if ([reportPage.viewControllerClass isEqualToString:NSStringFromClass([ChartViewController class])]) {
            cvc = [self newChartViewControllerForPageAtIndex:index];

        } else {
            cvc = [[NSClassFromString(page.viewControllerClass) alloc] initWithNibName:nil bundle:nil];    
        }
    }
    else {
        ELog(@"No page found for page index: %i", index);
        return nil;
    }
    
    // todo: make sure all VC's call their super's init, and move these props into that init, and make them readonly
    Chapter *chapter = [self chapterAtIndex:index];
    NSUInteger pageNumber = [self pageNumberAtIndex:index];
    cvc.chapter = chapter;
    cvc.pageNumber = pageNumber;
    return cvc;
}

- (ThemeDetailViewController*)newThemeDetailControllerForPageAtIndex:(NSUInteger)index
{    
    NSUInteger startingIndex = [self startingPageIndexForChapterAtIndex:ChapterIndexThemeDetail];
    NSUInteger themeIndex = index - startingIndex;
    
    Theme *theme = nil;
    if ([StratFileManager sharedManager].currentStratFile.themes.count > 0) {            
        theme = (Theme*)[[[StratFileManager sharedManager].currentStratFile themesSortedByOrder] objectAtIndex: themeIndex];    
    }
    return [[ThemeDetailViewController alloc] initWithNibName:nil bundle:nil andThemeOrNil:theme];    
}

- (DefineObjectivesViewController*)newDefineObjectivesControllerForPageAtIndex:(NSUInteger)index
{
    NSUInteger startingIndex = [self startingPageIndexForChapterAtIndex:ChapterIndexDefineObjectives];
    NSUInteger themeIndex = index - startingIndex;
    
    Theme *theme = nil;
    if ([StratFileManager sharedManager].currentStratFile.themes.count > 0) {            
        theme = (Theme*)[[[StratFileManager sharedManager].currentStratFile themesSortedByOrder] objectAtIndex: themeIndex];    
    }
    return [[DefineObjectivesViewController alloc] initWithNibName:nil bundle:nil andThemeOrNil:theme];
}

- (ActivityViewController*)newActivityControllerForPageAtIndex:(NSUInteger)index
{
    NSUInteger startingIndex = [self startingPageIndexForChapterAtIndex:ChapterIndexActivity];
    NSUInteger activityPageIndex = index - startingIndex;
    
    StratFile *stratFile = [StratFileManager sharedManager].currentStratFile;
    
    NSArray *sortedThemes = [stratFile themesSortedByOrder];
    NSArray *sortedObjectives;
    
    // each page represents an objective and its theme
    // there should be 1 page per objective
    // if a theme has no objectives, then we give it one page
        
    uint pageCtr = 0;
    if (sortedThemes.count > 0) {
        // 4 pages are ordered:
        // theme1 - no obj
        // theme2 - obj1, obj2
        // theme3 - obj1
        // each page represents an objective in a theme
        // so activityPageIndex = 2 -> theme2, obj2
        
        for (Theme *theme in sortedThemes) {
            sortedObjectives = [theme objectivesSortedByOrder];

            // no objectives
            if (sortedObjectives.count == 0 && pageCtr == activityPageIndex) {
                return [[ActivityViewController alloc] initWithNibName:nil bundle:nil andThemeOrNil:theme andObjectiveOrNil:nil];                    
            }

            // if we have objectives
            for (Objective *objective in sortedObjectives) {
                if (pageCtr == activityPageIndex) {
                    return [[ActivityViewController alloc] initWithNibName:nil bundle:nil andThemeOrNil:theme andObjectiveOrNil:objective];                    
                }
                pageCtr++;
            }
            
            if (sortedObjectives.count == 0) {
                pageCtr++;
            }
        }
        
    }
    
    // if no themes, we show one anyway, which will be disabled
    return [[ActivityViewController alloc] initWithNibName:nil bundle:nil andThemeOrNil:nil andObjectiveOrNil:nil];    
}

// R1
- (StrategyMapViewController*)newStrategyMapViewControllerForPageAtIndex:(NSUInteger)index
{
    NSUInteger startingIndex = [self startingPageIndexForChapterAtIndex:ChapterIndexStrategyMap];
    NSUInteger pageNumber = index - startingIndex;
    
    return [[StrategyMapViewController alloc] initWithNibName:nil bundle:nil andPageNumber:pageNumber];
}

// R2
- (StrategyFinancialAnalysisMonthViewController*)newStrategyFinancialAnalysisMonthViewControllerForPageAtIndex:(NSUInteger)index
{
    NSUInteger startingIndex = [self startingPageIndexForChapterAtIndex:ChapterIndexStrategyFinancialAnalysisMonth];
    NSUInteger pageNumber = index - startingIndex;
    
    return [[StrategyFinancialAnalysisMonthViewController alloc] initWithNibName:nil bundle:nil andPageNumber:pageNumber];    
}

// R3
- (StrategyFinancialAnalysisThemeViewController*)newStrategyFinancialAnalysisThemeViewControllerForPageAtIndex:(NSUInteger)index
{
    NSUInteger startingIndex = [self startingPageIndexForChapterAtIndex:ChapterIndexStrategyFinancialAnalysisTheme];
    NSUInteger localIndex = index - startingIndex;
    
    StratFile *stratFile = [StratFileManager sharedManager].currentStratFile;
    NSIndexPath *yearAndPage = [StrategyFinancialAnalysisThemeViewController yearAndPageForPageIndex:localIndex stratFile:stratFile];
    return [[StrategyFinancialAnalysisThemeViewController alloc] initWithNibName:nil bundle:nil 
                                                                         andYear:[yearAndPage indexAtPosition:0]
                                                                   andPageNumber:[yearAndPage indexAtPosition:1]];
}

// R4
- (ThemeFinancialAnalysisMonthViewController*)newThemeFinancialAnalysisMonthViewControllerForPageAtIndex:(NSUInteger)index
{
    NSUInteger startingIndex = [self startingPageIndexForChapterAtIndex:ChapterIndexThemeFinancialAnalysisMonth];
    NSUInteger localIndex = index - startingIndex;
    
    StratFile *stratFile = [StratFileManager sharedManager].currentStratFile;
    NSUInteger durationInYears = stratFile.strategyDurationInYears;
    NSArray *themes = [stratFile themesSortedByOrder];
    Theme *theme = nil;
    NSInteger year = 0;
    if (themes.count > 0) {
        // pages are ordered:
        // theme1 - page1, page2
        // theme2 - page1, page2
        // theme3 - page1, page2
        // each page represents a year in the theme: first, second, etc
        
        // this has to match the new algorithm - each theme has the same number of years
        int themeIndex = localIndex / durationInYears;
        theme = [themes objectAtIndex:themeIndex];
        year = localIndex % durationInYears;
    }
    return [[ThemeFinancialAnalysisMonthViewController alloc] initWithNibName:nil bundle:nil andThemeOrNil:theme andYear:year];        
}

// R5
- (ThemeDetailReportViewController*)newThemeDetailReportViewControllerForPageAtIndex:(NSUInteger)index
{    
    NSUInteger startingIndex = [self startingPageIndexForChapterAtIndex:ChapterIndexThemeDetailReport];
    NSUInteger themeIndex = index - startingIndex;
    
    Theme *theme = nil;
    if ([StratFileManager sharedManager].currentStratFile.themes.count > 0) {            
        theme = (Theme*)[[[StratFileManager sharedManager].currentStratFile themesSortedByOrder] objectAtIndex: themeIndex];    
    }
    return [[ThemeDetailReportViewController alloc] initWithNibName:nil bundle:nil andThemeOrNil:theme];    
}

// StratBoard
- (ContentViewController*)newChartViewControllerForPageAtIndex:(NSUInteger)index
{
    NSUInteger startingIndex = [self startingPageIndexForChapterAtIndex:ChapterIndexStratBoard];
    NSUInteger localIndex = index - startingIndex;

    // there will be a page for every chart + the index page
    // ie individual charts start at index == 1
    if (localIndex > 0) {
        NSArray *chartList = [Chart chartsSortedByOrderForStratFile:[[StratFileManager sharedManager] currentStratFile]];
        return [[ChartViewController alloc] initWithChart:[chartList objectAtIndex:localIndex-1] andPageNumber:localIndex];
    } else {
        ELog(@"Oops - shouldn't have any charts with a local index of: %i for main index: %i", localIndex, index);
        return nil;
    }
}


- (void)calculateTotalPages
{
    NSUInteger pageCount = 0;
    Chapter *chapter;
    for (int i = 0; i < chapters_.count; i++) {
        chapter = [chapters_ objectAtIndex:i];        
        for (int j = 0; j < chapter.pages.count; j++) {                        
            pageCount++;
        }
    }    
    totalPages_ = pageCount;
}

- (NSUInteger)themeDetailsPageIndexForTheme:(Theme*)theme
{
    NSUInteger pageIndex = [self startingPageIndexForChapterAtIndex:ChapterIndexThemeDetail];        
    pageIndex += [self indexOfThemeInStratFile:theme includeObjectives:NO];    
    return pageIndex;
}

- (NSUInteger)defineObjectivesPageIndexForTheme:(Theme*)theme
{
    NSUInteger pageIndex = [self startingPageIndexForChapterAtIndex:ChapterIndexDefineObjectives];        
    pageIndex += [self indexOfThemeInStratFile:theme includeObjectives:NO];    
    return pageIndex;
}

- (NSUInteger)activityPageIndexForTheme:(Theme*)theme
{
    NSUInteger pageIndex = [self startingPageIndexForChapterAtIndex:ChapterIndexActivity];        
    pageIndex += [self indexOfThemeInStratFile:theme includeObjectives:YES];    
    return pageIndex;
}

- (NSUInteger)activityPageIndexForObjective:(Objective*)objective
{
    NSUInteger pageIndex = [self startingPageIndexForChapterAtIndex:ChapterIndexActivity];
        
    // now we need to determine the index at which the theme begins in the activity chapter...
    StratFile *stratFile = [StratFileManager sharedManager].currentStratFile;
    NSArray *sortedThemes = [stratFile themesSortedByOrder];
    NSArray *sortedObjectives;
    
    for (Theme *theme in sortedThemes) {        
        
        sortedObjectives = [theme objectivesSortedByOrder];
        
        for (Objective *obj in sortedObjectives) {
            
            if (obj == objective) {
                return pageIndex;
            }
            
            pageIndex++;
        }
    }
    
    return pageIndex;
}

- (NSUInteger)startingPageIndexForChapterAtIndex:(ChapterIndex)chapterIndex
{
    NSUInteger index = 0;
    
    for (int i = 0; i < chapters_.count; i++) {
        if (i == chapterIndex) {
            break;
        } else {
            index += ((Chapter*)[chapters_ objectAtIndex:i]).pages.count;
        }
    }
    return index;
}

- (NSUInteger)indexOfThemeInStratFile:(Theme*)theme includeObjectives:(BOOL)includeObjectives
{
    NSUInteger index= 0;
    StratFile *stratFile = [StratFileManager sharedManager].currentStratFile;    
    NSArray *sortedThemes = [stratFile themesSortedByOrder];
    NSArray *sortedObjectives;
    
    for (Theme *aTheme in sortedThemes) {        
        
        if (theme == aTheme) {
            break;
        }
        
        if (includeObjectives) {
            sortedObjectives = [aTheme objectivesSortedByOrder];
            index += sortedObjectives.count;
        } else {
            index++;
        }
    }   
    return index;
}

- (ContentViewController*)newViewControllerForPage:(Page*)page
{
    NSUInteger index = [self indexOfPage:page];    
    ContentViewController *viewController = [self newContentControllerForPageAtIndex:index];
    
    // initialize the vc so it loads its data
    [viewController loadView];
    [viewController viewDidLoad];
    [viewController viewWillAppear:NO];
    [viewController viewDidAppear:NO];
    
    return viewController;
}

@end
