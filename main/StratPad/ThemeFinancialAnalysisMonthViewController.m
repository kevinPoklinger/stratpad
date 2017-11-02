//
//  ThemeFinancialAnalysisMonthViewController.m
//  StratPad
//
//  Created by Eric Rogers on August 30, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "ThemeFinancialAnalysisMonthViewController.h"
#import "Settings.h"
#import "DataManager.h"
#import "EventManager.h"
#import "ThemeFinancialAnalysisCalculationStrategy.h"
#import "R4Report.h"
#import "UIColor-Expanded.h"
#import "NSDate-StratPad.h"
#import "StratFile.h"
#import "NSCalendar+Expanded.h"

@interface ThemeFinancialAnalysisMonthViewController (Private)
- (void)updateContentForCurrentTheme;
- (void)handleOptimisticOrCurrencySettingChanges:(NSNotification*)notification;
@end

@implementation ThemeFinancialAnalysisMonthViewController

@synthesize pdfView = pdfView_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andThemeOrNil:(Theme*)theme andYear:(NSInteger)year
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        theme_ = theme;
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

+ (NSUInteger)numberOfPages:(StratFile*)stratFile
{
    // for each theme, there is 1 page per year, up to 5 years
    int numPages = 0;
    for (Theme *theme in stratFile.themes) {
        // each theme will use the same timescale, that of the entire strategy, and going for the next 12 months at a time, up to 60 months
        numPages += [stratFile strategyDurationInYears];
    }
    return MAX(numPages, 1);    
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
    
    R4Report *screenReportDelegate = [[R4Report alloc] init];
    pdfView_.screenDelegate = screenReportDelegate;
    [screenReportDelegate release];
    
    R4Report *printReportDelegate = [[R4Report alloc] init];
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

#pragma mark - Private

- (void)updateContentForCurrentTheme
{
    Settings *settings = (Settings*)[DataManager objectForEntity:NSStringFromClass([Settings class]) sortDescriptorsOrNil:nil predicateOrNil:nil];
    NSString *outlookSettingText = [settings.isCalculationOptimistic boolValue] == YES ? LocalizedString(@"OPTIMISTIC", nil) : LocalizedString(@"PESSIMISTIC", nil);
    NSString *reportInfoText = [NSString stringWithFormat:LocalizedString(@"NET_FINANCIAL_CHANGES_FORMAT", nil), outlookSettingText, [settings currency]];

    ThemeFinancialAnalysisCalculationStrategy *screenCalculationStrategy = [[ThemeFinancialAnalysisCalculationStrategy alloc] initWithTheme:theme_  isOptimistic:[[settings isCalculationOptimistic] boolValue] isRelativeToStrategyStart:YES];
    [((R4Report*)self.pdfView.screenDelegate) setCalculationStrategy:screenCalculationStrategy];
    [((R4Report*)self.pdfView.screenDelegate) setThemeTitle:theme_ ? theme_.title : LocalizedString(@"NO_THEME_TITLE", nil)];
    [((R4Report*)self.pdfView.screenDelegate) setReportInfo:reportInfoText];
    [((R4Report*)self.pdfView.screenDelegate) setYear:year_];    
    [screenCalculationStrategy release];

    ThemeFinancialAnalysisCalculationStrategy *printCalculationStrategy = [[ThemeFinancialAnalysisCalculationStrategy alloc] initWithTheme:theme_ isOptimistic:[[settings isCalculationOptimistic] boolValue] isRelativeToStrategyStart:YES];
    [((R4Report*)self.pdfView.printDelegate) setCalculationStrategy:printCalculationStrategy];
    [((R4Report*)self.pdfView.printDelegate) setThemeTitle:theme_ ? theme_.title : LocalizedString(@"NO_THEME_TITLE", nil)];
    [((R4Report*)self.pdfView.printDelegate) setReportInfo:reportInfoText];
    [((R4Report*)self.pdfView.printDelegate) setYear:year_];    
    [printCalculationStrategy release];
}

- (void)handleOptimisticOrCurrencySettingChanges:(NSNotification*)notification
{
    if (theme_) {    
        [self updateContentForCurrentTheme];
        
        // tell the PDF view to draw itself again with the new calculation strategy.
        [self.pdfView setNeedsDisplay];        
    }    
}

-(void)addYammerCommentsButton
{
    [self addYammerCommentsButtonToView:pdfView_];
}

#pragma mark - overrides

- (BOOL)isEnabled
{
    return (theme_ != nil);
}

- (void)exportToPDF
{    
    [pdfView_ drawPDFPagesWithOrientation:PageOrientationLandscape];
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
    //return @"http://player.vimeo.com/external/70705880.m3u8?p=high,standard,mobile&s=a1884c873572bf9998d3e6b06198d669";
    NSString* path = [[NSBundle mainBundle] pathForResource:@"SP iPad R4" ofType:@"mp4"];
    return path;
}

@end

