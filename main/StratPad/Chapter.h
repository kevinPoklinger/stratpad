//
//  Chapter.h
//  StratPad
//
//  Created by Eric Rogers on July 28, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

// ChapterIndex provides a reference of indexes into the chapters array
// so that one can quickly find a specific chapter at runtime.  The indexes
// must be in the same order as you see in Pages.plist
typedef enum
{
    ChapterIndexWelcome,
    ChapterIndexOnStratPad,
    ChapterIndexOnStrategy,
    ChapterIndexToolkit,
    ChapterIndexAboutYourStrategy,
    ChapterIndexStrategyStatement,
    ChapterIndexStratFileBasics,
    ChapterIndexBrainstormThemes,
    ChapterIndexThemeDetail,
    ChapterIndexDefineObjectives,
    ChapterIndexActivity,
    ChapterIndexFinance,
    ChapterIndexStrategyMap,                        // R1
    ChapterIndexStrategyFinancialAnalysisMonth,     // R2
    ChapterIndexStrategyFinancialAnalysisTheme,     // R3
    ChapterIndexThemeFinancialAnalysisMonth,        // R4
    ChapterIndexThemeDetailReport,                  // R5
    ChapterIndexGantt,                              // R6
    ChapterIndexProjectPlan,                        // R7
    ChapterIndexMeetingAgenda,                      // R8
    ChapterIndexBusinessPlan,                       // R9
    ChapterIndexFinancialStatementSummary,          // R10
    ChapterIndexFinancialStatementDetail,           // R11
    ChapterIndexStratBoard,                         // S1

    
    ChapterIndexNone                            = 999999
    
} ChapterIndex;


@interface Chapter : NSObject 

@property(nonatomic, copy) NSString *chapterNumber;
@property(nonatomic, copy) NSString *title;
@property(nonatomic, retain) NSMutableArray *pages;
@property(nonatomic, assign) ChapterIndex chapterIndex;

- (id)initWithDictionary:(NSDictionary*)dict;

// can we print something in this chapter?
- (BOOL) isPrintable;

// does this chapter contain any reports?
- (BOOL) isReport;

@end
