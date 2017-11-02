//
//  StrategyFinancialAnalysisThemeViewController.m
//  StratPad
//
//  Created by Eric Rogers on August 29, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "StrategyFinancialAnalysisThemeViewController.h"
#import "Settings.h"
#import "DataManager.h"
#import "Theme.h"
#import "EventManager.h"
#import "R3Report.h"
#import "R3CalculationStrategy.h"
#import "UIColor-Expanded.h"
#import "NSCalendar+Expanded.h"

@interface StrategyFinancialAnalysisThemeViewController (Private)
- (void)updateContentForCurrentTheme;
- (BOOL)lastPage;
- (void)handleOptimisticOrCurrencySettingChanges:(NSNotification*)notification;
+ (NSUInteger)pagesPerYearForStratFile:(StratFile*)stratFile;
+ (NSUInteger)durationInYearsForStratfile:(StratFile*)stratFile;
@end


@implementation StrategyFinancialAnalysisThemeViewController

@synthesize pdfView = pdfView_;


+ (NSUInteger)numberOfPages:(StratFile*)stratFile
{    
    NSInteger years = [StrategyFinancialAnalysisThemeViewController durationInYearsForStratfile:stratFile];
    NSInteger pages = [StrategyFinancialAnalysisThemeViewController pagesPerYearForStratFile:stratFile];
    return MAX(1, years * pages);
}

+ (NSIndexPath*)yearAndPageForPageIndex:(NSUInteger)pageIndex stratFile:(StratFile*)stratFile
{
    // pages are ordered:
    // year 1 - page 1 (first 8 themes), page 2 (second 8 themes)
    // year 2 - page 1
    // year 3 - page 1, page 2, page 3
    // pageIndex is the local, flat index in all 6 pages
    
    // figure out year and pageNum within that year
    NSInteger years = [StrategyFinancialAnalysisThemeViewController durationInYearsForStratfile:stratFile];
    NSInteger pages = [StrategyFinancialAnalysisThemeViewController pagesPerYearForStratFile:stratFile];

    for (uint i=0; i<years; ++i) {
        for (uint j=0; j<pages; ++j) {
            uint pagenum = i*pages + j;
            if (pagenum == pageIndex) {
                NSUInteger indexes[2];
                indexes[0] = i;
                indexes[1] = j;
                return [NSIndexPath indexPathWithIndexes:indexes length:2];
            }
        }
    }
    // always have at least 1 year and 1 page, though we should never hit this
    NSUInteger indexes[2];
    indexes[0] = 0;
    indexes[1] = 0;
    return [NSIndexPath indexPathWithIndexes:indexes length:2];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
              andYear:(NSUInteger)year
        andPageNumber:(NSUInteger)pageNumber
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        pageNumber_ = pageNumber;
        year_ = year;
        
        // listen for optimistic setting changes
        [[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(handleOptimisticOrCurrencySettingChanges:)
													 name:kEVENT_OPTIMISTIC_SETTING_CHANGED
												   object:nil];
        
        // listen for currency setting changes
        [[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(handleOptimisticOrCurrencySettingChanges:)
													 name:kEVENT_CURRENCY_SETTING_CHANGED
												   object:nil];
        
        // show the yammer icon if we published something
        [[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(addYammerCommentsButton)
													 name:kEVENT_YAMMER_NEW_PUBLICATION
												   object:nil];
    }
    return self;
}


#pragma mark - Memory Management

- (void)dealloc
{    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [pdfView_ release];    
    
    [super dealloc];
}


#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    R3Report *screenReportDelegate = [[R3Report alloc] init];
    pdfView_.screenDelegate = screenReportDelegate;
    [screenReportDelegate release];
    
    R3Report *printReportDelegate = [[R3Report alloc] init];
    pdfView_.printDelegate = printReportDelegate;
    [printReportDelegate release];
    
    [self updateContentForCurrentTheme];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.pdfView = nil;
}

-(void)viewDidAppear:(BOOL)animated
{
    [self addYammerCommentsButton];
    [super viewDidAppear:animated];
}

#pragma mark - NSNotification handlers

- (void)handleOptimisticOrCurrencySettingChanges:(NSNotification*)notification
{
    [self updateContentForCurrentTheme];
    
    // tell the PDF view to draw itself again with the new calculation strategy.
    [self.pdfView setNeedsDisplay];
}


#pragma mark - Public

// an override
- (void)exportToPDF
{    
    [pdfView_ drawPDFPagesWithOrientation:PageOrientationLandscape];
}

- (BOOL)isEnabled
{
    return stratFileManager_.currentStratFile.themes.count > 0;
}

- (NSString*)messageWhenDisabled
{
    return LocalizedString(@"MSG_NO_THEMES", nil);
}


#pragma mark - Private

- (void)updateContentForCurrentTheme
{
    Settings *settings = (Settings*)[DataManager objectForEntity:NSStringFromClass([Settings class]) sortDescriptorsOrNil:nil predicateOrNil:nil];    
    NSString *outlookSettingText = [settings.isCalculationOptimistic boolValue] == YES ? LocalizedString(@"OPTIMISTIC", nil) : LocalizedString(@"PESSIMISTIC", nil);
    NSString *reportInfo = [NSString stringWithFormat:LocalizedString(@"NET_FINANCIAL_CHANGES_FORMAT", nil), outlookSettingText, [settings currency]];

    R3CalculationStrategy *screenCalculationStrategy = [[R3CalculationStrategy alloc] initWithStratFile:[stratFileManager_ currentStratFile] andIsOptimistic:[settings.isCalculationOptimistic boolValue]];    
    [((R3Report*)(self.pdfView.screenDelegate)) setCalculationStrategy:screenCalculationStrategy];
    [((R3Report*)(self.pdfView.screenDelegate)) setReportInfo:reportInfo];
    [((R3Report*)(self.pdfView.screenDelegate)) setPageNumber:pageNumber_];
    [((R3Report*)(self.pdfView.screenDelegate)) setYear:year_];
    [screenCalculationStrategy release];

    R3CalculationStrategy *printCalculationStrategy = [[R3CalculationStrategy alloc] initWithStratFile:[stratFileManager_ currentStratFile] andIsOptimistic:[settings.isCalculationOptimistic boolValue]];    
    [((R3Report*)(self.pdfView.printDelegate)) setCalculationStrategy:printCalculationStrategy];
    [((R3Report*)(self.pdfView.printDelegate)) setReportInfo:reportInfo];
    [((R3Report*)(self.pdfView.printDelegate)) setPageNumber:pageNumber_];
    [((R3Report*)(self.pdfView.printDelegate)) setYear:year_];
    [printCalculationStrategy release];
}

+ (NSUInteger)durationInYearsForStratfile:(StratFile*)stratFile
{
    // how many years are we looking at?
    NSDate *startDate = [stratFile strategyStartDate];
    NSDate *endDate = [stratFile strategyEndDate];
    
    if (!endDate) {
        return strategyDurationInYearsWhenNotDefined;
    }
    
    NSCalendar *gregorian = [NSCalendar cachedGregorianCalendar];    
    NSDateComponents *components = [gregorian components:NSMonthCalendarUnit
                                                fromDate:startDate
                                                  toDate:endDate options:0];
    NSInteger months = [components month];
    return MIN(ceil(months/12.f), strategyDurationInYearsWhenNotDefined);
}

+ (NSUInteger)pagesPerYearForStratFile:(StratFile*)stratFile
{
    // how many pages to accommodate all the required columns
    // add 2 to account for the first year and subs years columns.
    return MAX(((stratFile.themes.count + 2) + kMaxColumnsPerPage - 1)/(kMaxColumnsPerPage), 1);
}

-(void)addYammerCommentsButton
{
    [self addYammerCommentsButtonToView:pdfView_];
}

# pragma mark - Help Video

// @override
-(BOOL)hasVideo
{
    return [[[LocalizedManager sharedManager] localeIdentifier] hasPrefix:@"en"] && self.pageNumber == 0;
}

// @override
-(NSString*)helpVideoURL
{
    //return @"http://player.vimeo.com/external/70704412.m3u8?p=high,standard,mobile&s=1f95f0dc00f6d176a72b9104a40a5c3e";
    NSString* path = [[NSBundle mainBundle] pathForResource:@"SP iPad R3" ofType:@"mp4"];
    return path;
}



@end
