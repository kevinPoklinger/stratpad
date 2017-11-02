//
//  StrategyFinancialAnalysisMonthViewController.m
//  StratPad
//
//  Created by Eric Rogers on August 25, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "StrategyFinancialAnalysisMonthViewController.h"
#import "Settings.h"
#import "DataManager.h"
#import "R2CalculationStrategy.h"
#import "EventManager.h"
#import "R2Report.h"
#import "UIColor-Expanded.h"
#import "NSCalendar+Expanded.h"
#import "StratFile.h"

@interface StrategyFinancialAnalysisMonthViewController (Private)
- (void)handleOptimisticOrCurrencySettingChanges:(NSNotification*)notification;
- (void)updateContentForCurrentTheme;
@end

@implementation StrategyFinancialAnalysisMonthViewController

@synthesize pdfView = pdfView_;

+ (NSUInteger)numberOfPages:(StratFile*)stratFile
{
    return MAX(1, stratFile.strategyDurationInYears);
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andPageNumber:(NSUInteger)pageNumber
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        pageNumber_ = pageNumber;
        
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
    
    R2Report *screenReportDelegate = [[R2Report alloc] init];
    pdfView_.screenDelegate = screenReportDelegate;
    [screenReportDelegate release];
    
    R2Report *printReportDelegate = [[R2Report alloc] init];
    pdfView_.printDelegate = printReportDelegate;
    [printReportDelegate release];
    
    // ensure we only perform the calculations once per lifecycle.  Note a change in the 
    // currency setting will reload the calculations.
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

# pragma mark - Help Video

// @override
-(BOOL)hasVideo
{
    return [[[LocalizedManager sharedManager] localeIdentifier] hasPrefix:@"en"] && self.pageNumber == 0;
}

// @override
-(NSString*)helpVideoURL
{
    //return @"http://player.vimeo.com/external/70704410.m3u8?p=high,standard,mobile&s=3cf33d5415d47cbb308324c527c22e82";
    NSString* path = [[NSBundle mainBundle] pathForResource:@"SP iPad R2" ofType:@"mp4"];
    return path;
}


#pragma mark - Private

- (void)updateContentForCurrentTheme
{
    Settings *settings = (Settings*)[DataManager objectForEntity:NSStringFromClass([Settings class]) sortDescriptorsOrNil:nil predicateOrNil:nil];
    NSString *outlookSettingText = [settings.isCalculationOptimistic boolValue] == YES ? LocalizedString(@"OPTIMISTIC", nil) : LocalizedString(@"PESSIMISTIC", nil);
    NSString *reportInfo = [NSString stringWithFormat:LocalizedString(@"NET_FINANCIAL_CHANGES_FORMAT", nil), outlookSettingText, [settings currency]];
    
    // screen
    R2CalculationStrategy *screenCalculationStrategy = [[R2CalculationStrategy alloc] initWithStratFile:[stratFileManager_ currentStratFile] andIsOptimistic:[settings.isCalculationOptimistic boolValue]];    
    [(R2Report*)pdfView_.screenDelegate setCalculationStrategy:screenCalculationStrategy];
    [(R2Report*)pdfView_.screenDelegate setReportInfo:reportInfo];
    [(R2Report*)pdfView_.screenDelegate setPageNumber:pageNumber_];    
    [screenCalculationStrategy release];
    
    // print
    R2CalculationStrategy *printCalculationStrategy = [[R2CalculationStrategy alloc] initWithStratFile:[stratFileManager_ currentStratFile] andIsOptimistic:[settings.isCalculationOptimistic boolValue]];    
    [(R2Report*)pdfView_.printDelegate setCalculationStrategy:printCalculationStrategy];
    [(R2Report*)pdfView_.printDelegate setReportInfo:reportInfo];
    [(R2Report*)pdfView_.printDelegate setPageNumber:pageNumber_];
    [printCalculationStrategy release];
}

-(void)addYammerCommentsButton
{
    [self addYammerCommentsButtonToView:pdfView_];
}


@end

