//
//  MeetingAgendaReport.m
//  StratPad
//
//  Created by Julian Wood on 9/15/11.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "MeetingAgendaReport.h"
#import "StratFileManager.h"
#import "Theme.h"
#import "NSDate-StratPad.h"
#import "Meeting.h"
#import "StratFileAgendaItem.h"
#import "ThemeAgendaItem.h"
#import "Objective.h"
#import "Activity.h"
#import "ObjectiveAgendaItem.h"
#import "Frequency.h"
#import "NSString-Expanded.h"
#import "ActivityAgendaItem.h"
#import "CustomAgendaItem.h"
#import "Drawable.h"
#import "MBDrawableLabel.h"
#import "MBRichDrawableLabel.h"
#import "MBDrawableReportHeader.h"
#import "Metric.h"
#import "PageSpooler.h"
#import "UIColor-Expanded.h"
#import "ReportPrintFonts.h"
#import "ApplicationSkin.h"
#import "MBReportHeader.h"
#import <QuartzCore/QuartzCore.h>
#import "Settings.h"
#import "EditionManager.h"
#import "UIImage-Expanded.h"
#import "DataManager.h"
#import "UIImage+Resize.h"


@implementation NSDate (MeetingAgendaReport)
-(BOOL)isBeforeDay:(NSDate*)date { return ([self compareDayMonthAndYearTo:date] == NSOrderedAscending); }
-(BOOL)isAfterDay:(NSDate*)date { return ([self compareDayMonthAndYearTo:date] == NSOrderedDescending); }
@end


@interface MeetingAgendaReport (Private)

- (void)drawString:(CGRect)rect;
- (NSAttributedString*)newAttributedStringWithBoldWords:(NSString*)string boldWords:(NSArray*)boldWords;
- (BOOL)addAgendaItemToCorrectWeeklyMeeting:(AgendaItem*)agendaItem;
- (void)addObjectiveToCorrectMeetings:(Objective*)objective;
- (BOOL)addActivityItemToCorrectMeeting:(ActivityAgendaItem*)agendaItem;
- (void)addAgendaItemsToMeetings:(NSDate*)strategyStartDate strategyEndDate:(NSDate*)strategyEndDate;
- (void)addStrategyProgressAndReviewAgendaItems:(StratFile*)stratFile;
- (void)addFinancialThemePerformanceAgendaItems:(StratFile*)stratFile;
- (NSDictionary*)drawables:(CGRect)contentRect;
- (void)drawPageNumberInFooterRect:(CGRect)footerRect;
-(NSArray*)agendaItemsLogicallySortedForMeeting:(Meeting*)meeting;
@end

@implementation MeetingAgendaReport

@synthesize meetings = meetings_;

- (id)init
{
    if ((self = [super init])) {
        // always at least 1 page
        hasMorePages_ = YES;
        
        ApplicationSkin *skin = [ApplicationSkin currentSkin];
        fontName_ = skin.section3FontName;    
        boldFontName_ = skin.section3BoldFontName;
        obliqueFontName_ = skin.section3ItalicFontName;
        fontSize_ = [skin.section3TextFontSize floatValue];
        fontColor_ = [[UIColor colorWithHexString:skin.section3TextFontColor] retain];

        
        if ([[[[StratFileManager sharedManager] currentStratFile] themes] count] > 0) {
            
            // create weekly, monthly, quarterly, annual meetings over the term of the strategy
            meetings_ = [NSMutableArray array];
            NSDate *strategyStartDate = [MeetingAgendaReport strategyStartDate];
            NSDate *strategyEndDate = [MeetingAgendaReport strategyEndDate];
            
            [Meeting addWeeklyMeetings:strategyStartDate endDate:strategyEndDate meetings:meetings_];
            [Meeting addMonthlyMeetings:strategyStartDate endDate:strategyEndDate meetings:meetings_];
            [Meeting addQuarterlyMeetings:strategyStartDate endDate:strategyEndDate meetings:meetings_];
            [Meeting addYearlyMeetings:strategyStartDate endDate:strategyEndDate meetings:meetings_];
            
            // sort the meetings
            NSArray *sortedMeetings = [meetings_ sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                return [[(Meeting*)obj1 startDate] compare:[(Meeting*)obj2 startDate]];
            }];
            [meetings_ removeAllObjects];
            [meetings_ addObjectsFromArray:sortedMeetings];
            [meetings_ retain];
            
            // now add agenda items to meetings
            [self addAgendaItemsToMeetings:strategyStartDate strategyEndDate:strategyEndDate];
            
            lastDrawBlockYOffset_ = [NSNumber numberWithFloat:0];

        }

    }
    return self;
}

- (void)dealloc
{
    [meetings_ release];
    [fontColor_ release];
    [super dealloc];
}


#pragma mark - Public


+ (NSDate*)strategyStartDate
{
    return [[[StratFileManager sharedManager] currentStratFile] strategyStartDate];
}

+ (NSDate*)strategyEndDate
{
    return [[[StratFileManager sharedManager] currentStratFile] strategyEndDate];
}

#pragma mark - PrintReportDelegate


- (BOOL)hasMorePages
{
    return hasMorePages_;
}

- (void)drawPage:(NSInteger)pageIndex inRect:(CGRect)rect
{
    isPrint_ = YES;

    fontName_ = fontNameForPrint;
    boldFontName_ = boldFontNameForPrint;
    obliqueFontName_ = obliqueFontNameForPrint;
    fontSize_ = textFontSizeForPrint;
    fontColor_ = [chartFontColorForPrint retain];

    CGRect printInsetRect = CGRectMake(rect.origin.x + printInsets_.left, 
                                       rect.origin.y + printInsets_.top, 
                                       rect.size.width - printInsets_.left - printInsets_.right, 
                                       rect.size.height - printInsets_.top - printInsets_.bottom);
    
    // for print we shift the header to the left slightly, but keep the text aligned with the rest of the page.
    CGFloat headerLeftShift = 5.f;
    CGRect headerRect = CGRectMake(printInsetRect.origin.x - headerLeftShift, 
                                   printInsetRect.origin.y, 
                                   printInsetRect.size.width + headerLeftShift, 
                                   printInsetRect.size.height);

    CGRect footerRect = CGRectMake(printInsetRect.origin.x, 
                                   printInsetRect.origin.y + printInsetRect.size.height - 2*fontSize_,
                                   printInsetRect.size.width, 
                                   2*fontSize_);        
    
    MBDrawableReportHeader *reportHeader = [[MBDrawableReportHeader alloc] initWithRect:headerRect textInsetLeft:headerLeftShift andReportTitle:[self reportTitle]];
    [reportHeader addTitleItemWithText:[self companyName] font:[UIFont fontWithName:boldFontNameForPrint size:reportHeaderSubTitleFontSizeForPrint] andColor:reportHeaderFontColorForPrint];
    [reportHeader addTitleItemWithText:[self stratFileName] font:[UIFont fontWithName:fontNameForPrint size:reportHeaderSubTitleFontSizeForPrint] andColor:reportHeaderFontColorForPrint];
    [reportHeader addTitleItemWithText:[[NSDate date] formattedDate2] font:[UIFont fontWithName:obliqueFontNameForPrint size:reportHeaderSubTitleFontSizeForPrint] andColor:reportHeaderFontColorForPrint];
    [reportHeader sizeToFit];
    
    CGFloat headerHeight = [reportHeader rect].size.height;        
    [reportHeader draw];
    [reportHeader release];
    
    CGFloat marginTop = 20.f;
    
    CGRect contentRect = CGRectMake(printInsetRect.origin.x, printInsetRect.origin.y + headerHeight + marginTop, 
                             printInsetRect.size.width, printInsetRect.size.height - headerHeight - marginTop - footerRect.size.height);

    // now draw what we can into this rect
    
    // get draw blocks and draw them
    NSDictionary *drawables = [self drawables:contentRect];        
    NSArray *keys = [[drawables allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2];
    }];
    for (NSNumber *yOffset in keys) {
        if ([yOffset floatValue] < [lastDrawBlockYOffset_ floatValue]) {
            continue;
        }
        
        // the value at each line may be a single drawable, or an
        // array of drawables.
        NSArray *drawableRow = [drawables objectForKey:yOffset];
        
        // figure out if all the drawables in the row fit on the current page
        BOOL allDrawablesFit = YES;        
        for (id<Drawable> drawable in drawableRow) {
            if ([yOffset floatValue] + drawable.rect.size.height - [lastDrawBlockYOffset_ floatValue] >= contentRect.size.height) {
                allDrawablesFit = NO;
                break;
            }
        }

        // draw the current row if it fits, or move on to the next page.
        if (allDrawablesFit) {
            for (id<Drawable> drawable in drawableRow) {
                [drawable setRect:CGRectMake(drawable.rect.origin.x, drawable.rect.origin.y - [lastDrawBlockYOffset_ floatValue],
                                             drawable.rect.size.width, drawable.rect.size.height)];
                [drawable draw];
            }
        } else {
            hasMorePages_ = YES;
            lastDrawBlockYOffset_ = yOffset;
            
            // draw the 1-based page number
            [self drawPageNumberInFooterRect:footerRect];            
            
            return;
        }        
    }  
    
    // draw the 1-based page number
    [self drawPageNumberInFooterRect:footerRect];
    
    hasMorePages_ = NO;
}

#pragma mark - ReportDelegate

- (NSString*)reportTitle
{
    // default date is today
    NSDate *date = [NSDate date];
    
    NSArray *themes = [[[StratFileManager sharedManager] currentStratFile] themesSortedByStartDate];
    if ([themes count] > 0) {
        for (Theme *theme in themes) {
            if (theme.startDate) {
                date = theme.startDate;
                break;
            }
        }
    }
    
    if (isPrint_) {    
        return [NSString stringWithFormat:@"%@: %@", 
                LocalizedString(@"MEETING_AGENDA_REPORT_TITLE", nil),
                [NSString stringWithFormat:LocalizedString(@"LABEL_STARTING_FROM", nil), [date formattedDate2]]];
    } else {
        return [NSString stringWithFormat:@"%@:\n%@", 
                LocalizedString(@"MEETING_AGENDA_REPORT_TITLE", nil),
                [NSString stringWithFormat:LocalizedString(@"LABEL_STARTING_FROM", nil), [date formattedDate2]]];        
    }
    
}


#pragma mark - Private

-(NSDictionary*)drawables:(CGRect)contentRect
{
    NSMutableDictionary *drawables = [NSMutableDictionary dictionary];
        
    CGFloat rowSpacer = 3.f;  // spacing between meeting items

    // we add an array of drawables for each "row" in the report.
    NSMutableArray *drawableRow = nil;
    
    NSArray *agendaItems = nil;
    
    // draw the meeting headers, agenda items, and responsibles
    CGFloat yOffset = 0;
    for (Meeting *meeting in meetings_) {
        
        // sort the agenda items logicially first...
        agendaItems = [self agendaItemsLogicallySortedForMeeting:meeting];
        
        if ([agendaItems count] > 0) {

            drawableRow = [NSMutableArray array];
            
            CGRect rect = CGRectMake(contentRect.origin.x, contentRect.origin.y + yOffset, contentRect.size.width, 20);
            NSAttributedString *attrHeading = [meeting newHeadingWithFontName:fontName_ boldFontName:boldFontName_ fontSize:fontSize_ andFontColor:fontColor_];
            MBRichDrawableLabel *label = [[MBRichDrawableLabel alloc] initWithAtrributedString:attrHeading andRect:rect];            
            [attrHeading release];                    
            [drawableRow addObject:label];            
            [drawables setObject:drawableRow forKey:[NSNumber numberWithFloat:yOffset]];
            [label release];
            yOffset += 20;            

            for (AgendaItem *agendaItem in agendaItems) {
                
                drawableRow = [NSMutableArray array];
                
                CGFloat checkmarkTopMargin = 2.f;
                MBDrawableLabel *checkLabel = [[MBDrawableLabel alloc] initWithText:@"✓"
                                                                          font:[UIFont fontWithName:@"HiraKakuProN-W6" size:fontSize_]
                                                                         color:fontColor_
                                                                 lineBreakMode:UILineBreakModeTailTruncation
                                                                     alignment:UITextAlignmentLeft
                                                                       andRect:CGRectMake(contentRect.origin.x, contentRect.origin.y + yOffset + checkmarkTopMargin, contentRect.size.width, 15)];
                [drawableRow addObject:checkLabel];
                [checkLabel release];
                
                MBDrawableLabel *label = [[MBDrawableLabel alloc] initWithText:[agendaItem description]
                                                                font:[UIFont fontWithName:fontName_ size:fontSize_] 
                                                               color:fontColor_
                                                       lineBreakMode:UILineBreakModeWordWrap
                                                           alignment:UITextAlignmentLeft
                                                             andRect:CGRectMake(contentRect.origin.x + 15, contentRect.origin.y + yOffset, contentRect.size.width - 15, 9999)];
                [label sizeToFit];                
                [drawableRow addObject:label];
                                
                [drawables setObject:drawableRow forKey:[NSNumber numberWithFloat:yOffset]];                                
                yOffset += label.rect.size.height + rowSpacer;                
                [label release];
            }
            
            NSString *responsiblePhrase = [meeting responsiblePhrase];
            if (responsiblePhrase) {
                drawableRow = [NSMutableArray array];
                MBDrawableLabel *label = [[MBDrawableLabel alloc] initWithText:[NSString stringWithFormat:LocalizedString(@"MAR_RESPONSIBLE_PEOPLE", nil), responsiblePhrase]
                                                                font:[UIFont fontWithName:fontName_ size:fontSize_] 
                                                               color:fontColor_
                                                       lineBreakMode:UILineBreakModeWordWrap
                                                           alignment:UITextAlignmentLeft
                                                             andRect:CGRectMake(contentRect.origin.x + 15, contentRect.origin.y + yOffset, contentRect.size.width - 15, 9999)];
                [label sizeToFit];
                [drawableRow addObject:label];
                [drawables setObject:drawableRow forKey:[NSNumber numberWithFloat:yOffset]];                
                yOffset += label.rect.size.height + rowSpacer;
                [label release];
            }
            
            yOffset += 10; // spacing between meetings
        }
    }
        
    return drawables;
}



-(NSArray*)agendaItemsLogicallySortedForMeeting:(Meeting*)meeting
{
    NSMutableArray *strategyStartItems  = [NSMutableArray array];
    NSMutableArray *themeStartItems     = [NSMutableArray array];
    NSMutableArray *activityStartItems  = [NSMutableArray array];
    NSMutableArray *strategyProgressItems  = [NSMutableArray array];
    NSMutableArray *metricProgressItems  = [NSMutableArray array];    
    NSMutableArray *strategyReviewItems = [NSMutableArray array];
    NSMutableArray *financialReviewItems = [NSMutableArray array];
    NSMutableArray *activityStopItems = [NSMutableArray array];
    NSMutableArray *themeStopItems = [NSMutableArray array];
    NSMutableArray *strategyStopItems = [NSMutableArray array];    
    
    for (AgendaItem *item in meeting.agendaItems) {
        
        if (item.agendaItemType == AgendaItemStrategyStart) {
            [strategyStartItems addObject:item];
            
        } else if (item.agendaItemType == AgendaItemThemeStart) {
            [themeStartItems addObject:item];
            
        } else if (item.agendaItemType == AgendaItemActivityStart) {
            [activityStartItems addObject:item];
                        
        } else if (item.agendaItemType == AgendaItemStrategyProgress) {
            [strategyProgressItems addObject:item];
            
        } else if (item.agendaItemType == AgendaItemMetricProgress) {
            [metricProgressItems addObject:item];
            
        } else if (item.agendaItemType == AgendaItemStrategyReview) {
            [strategyReviewItems addObject:item];
            
        } else if (item.agendaItemType == AgendaItemFinancialPerformanceReview) {
            [financialReviewItems addObject:item];
            
        }  else if (item.agendaItemType == AgendaItemActivityStop) {
            [activityStopItems addObject:item];
            
        }  else if (item.agendaItemType == AgendaItemThemeStop) {
            [themeStopItems addObject:item];
            
        } else if (item.agendaItemType == AgendaItemStrategyStop) {
            [strategyStopItems addObject:item];
            
        } else {
            WLog(@"Unsupported agenda item type: %i", item.agendaItemType);
        }
    }
    
    NSMutableArray *results = [NSMutableArray array];
    [results addObjectsFromArray:strategyStartItems];
    [results addObjectsFromArray:themeStartItems];
    [results addObjectsFromArray:activityStartItems];
    [results addObjectsFromArray:strategyProgressItems];
    [results addObjectsFromArray:metricProgressItems];
    [results addObjectsFromArray:strategyReviewItems];
    [results addObjectsFromArray:financialReviewItems];
    [results addObjectsFromArray:activityStopItems];
    [results addObjectsFromArray:themeStopItems];
    [results addObjectsFromArray:strategyStopItems];
    
    return results;
}

-(void)addAgendaItemsToMeetings:(NSDate*)strategyStartDate strategyEndDate:(NSDate*)strategyEndDate
{
    // strategy start
    StratFile *stratFile = [[StratFileManager sharedManager] currentStratFile];
    StratFileAgendaItem *stratFileAgendaItem = [[StratFileAgendaItem alloc] 
                                                initWithStratFile:stratFile 
                                                agendaItemType:AgendaItemStrategyStart 
                                                startDate:strategyStartDate];
    [self addAgendaItemToCorrectWeeklyMeeting:stratFileAgendaItem];
    [stratFileAgendaItem release];
    
    // strategy end
    StratFileAgendaItem *endStratFileAgendaItem = [[StratFileAgendaItem alloc] 
                                                   initWithStratFile:stratFile 
                                                   agendaItemType:AgendaItemStrategyStop 
                                                   startDate:strategyEndDate];
    [self addAgendaItemToCorrectWeeklyMeeting:endStratFileAgendaItem];
    [endStratFileAgendaItem release];
    
    
    for (Theme *theme in stratFile.themes) {
        // add theme start
        ThemeAgendaItem *themeAgendaItem = [[ThemeAgendaItem alloc] 
                                            initWithTheme:theme 
                                            agendaItemType:AgendaItemThemeStart 
                                            startDate:(theme.startDate ? theme.startDate : [[NSDate date] dateWithZeroedTime])];
        [self addAgendaItemToCorrectWeeklyMeeting:themeAgendaItem];
        [themeAgendaItem release];
        
        // add theme end
        ThemeAgendaItem *endThemeAgendaItem = [[ThemeAgendaItem alloc] 
                                               initWithTheme:theme 
                                               agendaItemType:AgendaItemThemeStop 
                                               startDate:(theme.endDate ? theme.endDate : strategyEndDate)];
        [self addAgendaItemToCorrectWeeklyMeeting:endThemeAgendaItem];
        [endThemeAgendaItem release];        
        
        for (Objective *objective in theme.objectives) {

            [self addObjectiveToCorrectMeetings:objective];
            
            for (Activity *activity in objective.activities) {

                // startActivity
                ActivityAgendaItem *activityAgendaItem = [[ActivityAgendaItem alloc] 
                                                          initWithActivity:activity
                                                          agendaItemType:AgendaItemActivityStart 
                                                          startDate:activity.startDate ? activity.startDate : [[NSDate date] dateWithZeroedTime]];
                [self addActivityItemToCorrectMeeting:activityAgendaItem];
                [activityAgendaItem release];
                
                // end activity
                ActivityAgendaItem *endActivityAgendaItem = [[ActivityAgendaItem alloc] 
                                                             initWithActivity:activity
                                                             agendaItemType:AgendaItemActivityStop 
                                                             startDate:activity.endDate ? activity.endDate : strategyEndDate];
                [self addActivityItemToCorrectMeeting:endActivityAgendaItem];
                [endActivityAgendaItem release];
            }
        }
    }
    [self addStrategyProgressAndReviewAgendaItems:stratFile];
    [self addFinancialThemePerformanceAgendaItems:stratFile];
}

-(void)addStrategyProgressAndReviewAgendaItems:(StratFile*)stratFile
{
    for (Meeting *meeting in meetings_) {
        if (meeting.meetingType == MeetingTypeQuarterly) {
            StratFileAgendaItem *agendaItem = [[StratFileAgendaItem alloc]
                                               initWithStratFile:stratFile
                                               agendaItemType:AgendaItemStrategyProgress
                                               startDate:nil];
            [meeting.agendaItems addObject:agendaItem];
            [agendaItem release];
        } else if (meeting.meetingType == MeetingTypeAnnually) {
            StratFileAgendaItem *agendaItem = [[StratFileAgendaItem alloc]
                                               initWithStratFile:stratFile
                                               agendaItemType:AgendaItemStrategyReview
                                               startDate:nil];
            [meeting.agendaItems addObject:agendaItem];
            [agendaItem release];
        }
    }        
}

- (void)addFinancialThemePerformanceAgendaItems:(StratFile*)stratFile
{
    // look through themes to see if they have any of these values
    // if so, check off monthly, quarterly, and/or annually
    
    // look at monthly values on a monthly basis
    // look at monthly and quarterly values on a quarterly basis
    // look at monthly, quarterly and annual values on a yearly basis
    
    // in other words, if monthly is checked, we add a review agenda item to all monthly, quarterly and annual meetings
    // if Qu, we add a review agenda item to all Qu and An meetings
    // if An, we add a review agenda item to all An meetings

    NSString *financialReviewPhrase = LocalizedString(@"AGENDA_ITEM_FINANCIAL_REVIEW", nil);
    
    BOOL monthly = NO, quarterly = NO, annually = NO;
    for (Theme *theme in stratFile.themes) {
        if (theme.revenueMonthly || theme.generalAndAdminMonthly || theme.researchAndDevelopmentMonthly || theme.cogsMonthly) {
            monthly = YES;
        }
        
        if (theme.revenueQuarterly || theme.generalAndAdminQuarterly || theme.researchAndDevelopmentQuarterly || theme.cogsQuarterly) {
            quarterly = YES;
        }
        
        if (theme.revenueAnnually || theme.generalAndAdminAnnually || theme.researchAndDevelopmentAnnually || theme.cogsAnnually) {
            annually = YES;
        }
        
        if (monthly) {
            for (Meeting *meeting in meetings_) {
                if (meeting.meetingType != MeetingTypeWeekly) {
                    // does the term defined by this theme overlap this meeting date?
                    if ([theme.startDate compareDayMonthAndYearTo:meeting.startDate] != NSOrderedDescending &&
                        [theme.endDate compareDayMonthAndYearTo:meeting.startDate] != NSOrderedAscending) {
                        CustomAgendaItem *agendaItem = [[CustomAgendaItem alloc] 
                                                        initWithDescription:[NSString stringWithFormat:financialReviewPhrase, 
                                                                             meeting.frequencyString, theme.title]
                                                        agendaItemType:AgendaItemFinancialPerformanceReview];
                        [meeting.agendaItems addObject:agendaItem];
                        [agendaItem release];
                    }
                }
            }
            
        } else if (quarterly) {
            for (Meeting *meeting in meetings_) {
                if (meeting.meetingType == MeetingTypeQuarterly || meeting.meetingType == MeetingTypeAnnually) {
                    if ([theme.startDate compareDayMonthAndYearTo:meeting.startDate] != NSOrderedDescending &&
                        [theme.endDate compareDayMonthAndYearTo:meeting.startDate] != NSOrderedAscending) {
                        CustomAgendaItem *agendaItem = [[CustomAgendaItem alloc] 
                                                        initWithDescription:[NSString stringWithFormat:financialReviewPhrase, 
                                                                             meeting.frequencyString, theme.title]
                                                        agendaItemType:AgendaItemFinancialPerformanceReview];
                        [meeting.agendaItems addObject:agendaItem];
                        [agendaItem release];
                    }
                }
            }
            
        } else if (annually) {
            for (Meeting *meeting in meetings_) {
                if (meeting.meetingType == MeetingTypeAnnually) {
                    if ([theme.startDate compareDayMonthAndYearTo:meeting.startDate] != NSOrderedDescending &&
                        [theme.endDate compareDayMonthAndYearTo:meeting.startDate] != NSOrderedAscending) {
                        CustomAgendaItem *agendaItem = [[CustomAgendaItem alloc] 
                                                        initWithDescription:[NSString stringWithFormat:financialReviewPhrase, 
                                                                             meeting.frequencyString, theme.title]
                                                        agendaItemType:AgendaItemFinancialPerformanceReview];
                        [meeting.agendaItems addObject:agendaItem];
                        [agendaItem release];
                    }
                }
            }
        } 

    }
}


-(BOOL)addAgendaItemToCorrectWeeklyMeeting:(AgendaItem*)agendaItem
{
    if (agendaItem.agendaItemType == AgendaItemStrategyStart || agendaItem.agendaItemType == AgendaItemThemeStart) {
        // if something is starting on Wednesday, then we want to talk about it on the preceding Monday, even if that is before the strategy kickoff
        // we need to find the first meeting which exceeds the agendaItem.startDate-1wk
        NSDate *testDate = [agendaItem.startDate dateByAddingTimeInterval:-7*24*60*60];
        for (Meeting *meeting in meetings_) {
            if (meeting.meetingType == MeetingTypeWeekly) {
                if ([meeting.startDate isAfterDay:testDate]) {
                    [meeting.agendaItems addObject:agendaItem];
                    return TRUE;
                }
            }
        }        
    } else {
        for (int i=[meetings_ count]-1; i>=0; --i) {
            Meeting *meeting = [meetings_ objectAtIndex:i];
            if (meeting.meetingType == MeetingTypeWeekly) {
                if ([meeting.startDate compareDayMonthAndYearTo:agendaItem.startDate] != NSOrderedDescending) {
                    [meeting.agendaItems addObject:agendaItem];
                    return TRUE;
                }
            }
        }        
    }
    
    return FALSE;
}

-(BOOL)addActivityItemToCorrectMeeting:(ActivityAgendaItem*)agendaItem
{
    for (int i=[meetings_ count]-1; i>=0; --i) {
        Meeting *meeting = [meetings_ objectAtIndex:i];
        if ([meeting matchesFrequency:agendaItem.activity.ongoingFrequency]) {
            if ([meeting.startDate compareDayMonthAndYearTo:agendaItem.startDate] != NSOrderedDescending) {
                [meeting.agendaItems addObject:agendaItem];
                return TRUE;                
            }
        }
    }        
    
    return FALSE;        
}

-(void)addObjectiveToCorrectMeetings:(Objective*)objective
{
    // alternative rule: if an objective has 1 or more metrics, and at least one has a targetDate, then get the latest target date, and if that target date is lt the iterating meeting startDate, and that metric has a summary, then include the objective
    
    // for now: if there are multiple metrics and the latestTargetDate fits, include it, 
    // otherwise use the same rules as before (ie also looks at metric summary)

    Metric *metric = [objective.metrics anyObject];
    
    // goes in all weekly/monthly/quarterly or annual meetings up until by when (target) date, or all of them if not specified
    for (Meeting *meeting in meetings_) {
        if ([meeting matchesFrequency:objective.reviewFrequency]) {
            if (objective.metrics.count == 1) {
                
                if (metric.targetDate == nil || [meeting.startDate compareDayMonthAndYearTo:metric.targetDate] != NSOrderedDescending) {
                    if (metric.summary != nil && ![metric.summary isBlank]) {
                        ObjectiveAgendaItem *objectiveAgendaItem = [[ObjectiveAgendaItem alloc] initWithObjective:objective
                                                                                                   agendaItemType:AgendaItemMetricProgress
                                                                                                        startDate:meeting.startDate];
                        [meeting.agendaItems addObject:objectiveAgendaItem];
                        [objectiveAgendaItem release];                    
                    }
                }
                
            } else if (objective.metrics.count > 1) {
                
                NSDate *latestTargetDate = [NSDate distantPast];
                for (Metric *metric in objective.metrics) {
                    if ([metric.targetDate isAfterDay:latestTargetDate]) {
                        latestTargetDate = metric.targetDate;
                    }
                }

                if ([meeting.startDate compareDayMonthAndYearTo:latestTargetDate] != NSOrderedDescending) {
                    ObjectiveAgendaItem *objectiveAgendaItem = [[ObjectiveAgendaItem alloc] initWithObjective:objective
                                                                                               agendaItemType:AgendaItemMetricProgress
                                                                                                    startDate:meeting.startDate];
                    [meeting.agendaItems addObject:objectiveAgendaItem];
                    [objectiveAgendaItem release];                    
                }
                
            }
        }
    }    

}

- (void)drawPageNumberInFooterRect:(CGRect)footerRect
{
    // now draw the page number in the footer
    NSString *footerText = [NSString stringWithFormat:@"%@ %i", LocalizedString(@"PAGE", nil), 
                            [[PageSpooler sharedManager] cumulativePageNumberForReport]];
    
    MBDrawableLabel *footerLabel = [[MBDrawableLabel alloc] initWithText:footerText 
                                                                    font:[UIFont fontWithName:fontName_ size:fontSize_] 
                                                                   color:fontColor_
                                                           lineBreakMode:UILineBreakModeTailTruncation 
                                                               alignment:UITextAlignmentCenter
                                                                 andRect:footerRect];
    [footerLabel sizeToFit];
    
    // center the footer label horizontally and align it with the bottom of the footer rect.
    footerLabel.rect = CGRectMake(footerRect.origin.x + (footerRect.size.width - footerLabel.rect.size.width)/2, 
                                  footerRect.origin.y + (footerRect.size.height - footerLabel.rect.size.height), 
                                  footerLabel.rect.size.width, 
                                  footerLabel.rect.size.height);
    
    [footerLabel draw];
    [footerLabel release];    
}

#pragma mark - HTML construction for webview

- (NSString*)html
{
    XMLWriter *writer = [[XMLWriter alloc] init];
    [writer writeStartDocumentWithEncodingAndVersion:@"UTF-8" version:@"1.0"];
    [writer write:@"<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">"];
    
    [writer writeStartElement:@"html"];
    [writer writeAttribute:@"xmlns" value:@"http://www.w3.org/1999/xhtml"];
    
    ////// head
    [writer writeStartElement:@"head"];
    
    // title
    [writer writeStartElement:@"title"];
    [writer writeCharacters:@"R8"];
    [writer writeEndElement];
    
    // charset
    [writer writeStartElement:@"meta"];
    [writer writeAttribute:@"http-equiv" value:@"content-type"];
    [writer writeAttribute:@"content" value:@"application/xhtml+xml; charset=UTF-8"];
    [writer writeEndElement];
    
    // css
    [writer writeStartElement:@"link"];
    [writer writeAttribute:@"href" value:@"R8.css"];
    [writer writeAttribute:@"rel" value:@"stylesheet"];
    [writer writeAttribute:@"type" value:@"text/css"];
    [writer writeEndElement];

    // override text color
    [writer writeStartElement:@"style"];
    [writer writeAttribute:@"type" value:@"text/css"];
    NSString *color = [[SkinManager sharedManager] stringForProperty:kSkinSection3FontColor];
    [writer writeCharacters:[NSString stringWithFormat:@"html, body {color: #%@;}", color]];
    [writer writeEndElement];
    
    // head end
    [writer writeEndElement];
    
    ////// body
    [writer writeStartElement:@"body"];
    
    // report header
    [self addReportHeader:writer];
    
    // add sections for each meeting, with items in each meeting
    for (Meeting *meeting in meetings_) {
        
        // sort the agenda items logicially first...
        NSArray *agendaItems = [self agendaItemsLogicallySortedForMeeting:meeting];
        
        if ([agendaItems count] > 0) {
            
            [writer writeStartElement:@"ul"];
            [writer writeAttribute:@"class" value:@"section"];

            [self addSectionHeading:writer meeting:meeting];
            
            for (AgendaItem *agendaItem in agendaItems) {
                [writer writeStartElement:@"li"];
                [writer writeAttribute:@"class" value:@"row"];
                [writer writeCharacters:agendaItem.description];
                [writer writeEndElement];
            }
            
            NSString *responsiblePhrase = [NSString stringWithFormat:LocalizedString(@"MAR_RESPONSIBLE_PEOPLE", nil), meeting.responsiblePhrase];
            if (responsiblePhrase) {
                [writer writeStartElement:@"li"];
                [writer writeAttribute:@"class" value:@"last"];
                [writer writeCharacters:responsiblePhrase];
                [writer writeEndElement];
            }
            
            [writer writeEndElement]; // section
        }
    }
        
    // adds the rest of the end elements
    [writer writeEndDocument];
    
    NSString *html = [writer.toString copy];
    DLog(@"html: %@", html);
    [writer release];
    
    return [html autorelease];
}

-(void)addReportHeader:(XMLWriter*)writer
{
    Settings *settings = (Settings*)[DataManager objectForEntity:NSStringFromClass([Settings class])
                                            sortDescriptorsOrNil:nil
                                                  predicateOrNil:nil];
    BOOL shouldWriteLogo = ([[EditionManager sharedManager] isFeatureEnabled:FeatureLogoOnReport] && settings.consultantLogo);
    
    NSArray *parts = [[self reportTitle] componentsSeparatedByString:@"\n"];
    [writer writeStartElement:@"div"];
    [writer writeAttribute:@"id" value:@"header"];
    [writer writeCharacters:[parts objectAtIndex:0]];
    [writer write:@"<br/>"];
    [writer writeCharacters:[parts objectAtIndex:1]];
    
    // company logo - NB. this only works on device
    if (shouldWriteLogo) {
        CGFloat maxDim = logoMaxDim;
        UIImage *imgLogo = settings.consultantLogo;
        CGSize sizeForLogo = [imgLogo sizeForProportionalImageWithMaxDim:maxDim];
        imgLogo = [imgLogo resizedImage:sizeForLogo interpolationQuality:kCGInterpolationDefault];
        
        // draw it out to temp directory
        NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"r8_logo.png"];
        DLog(@"logo path: %@", filePath);
        NSData *imageData = UIImagePNGRepresentation(imgLogo);
        [imageData writeToFile:filePath atomically:NO];

        [writer writeStartElement:@"div"];
        [writer writeAttribute:@"id" value:@"logo"];
        NSString *style = [NSString stringWithFormat:@"width: %.fpx; height: %.fpx; background: url(%@) no-repeat;",
                           sizeForLogo.width, sizeForLogo.height, [[NSURL fileURLWithPath:filePath] absoluteString]];
        [writer writeAttribute:@"style" value:style];
        [writer writeCloseStartElement];
        [writer writeEndElement];
    }
    
    [writer writeEndElement];
}

-(void)addSectionHeading:(XMLWriter*)writer meeting:(Meeting*)meeting
{
    [writer writeStartElement:@"li"];
    [writer writeAttribute:@"class" value:@"heading"];
    [writer writeCloseStartElement];
    [writer write:[meeting htmlHeading]];
    [writer writeEndElement];
}


@end
