//
//  BusinessPlanViewController.m
//  StratPad
//
//  Created by Julian Wood on 9/15/11.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "BusinessPlanViewController.h"
#import "BusinessPlanReport.h"
#import "NSString-Expanded.h"
#import "EventManager.h"

@interface BusinessPlanViewController (Private)
- (NSString*)stringByAppendingParagraphs:(NSString*)paragraphs toString:(NSString*)string;
- (NSString*)prepareContentText:(NSString*)contentText;
- (void)handleOptimisticOrCurrencySettingChanges:(NSNotification*)notification;
- (void)reloadPDFDelegates;
@end

@implementation BusinessPlanViewController

@synthesize scrollView = scrollView_;
@synthesize pdfView = pdfView_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        
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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];    
    [pdfView_ release];
    [scrollView_ release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self reloadPDFDelegates];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.pdfView = nil;
    self.scrollView = nil;
}

-(void)viewDidAppear:(BOOL)animated
{
    [self addYammerCommentsButton];
    [super viewDidAppear:animated];
}

#pragma mark - Public

// an override
- (void)exportToPDF
{    
    [self.pdfView drawPDFPagesWithOrientation:PageOrientationPortrait];
}

- (BOOL)isEnabled
{
    return [[[[StratFileManager sharedManager] currentStratFile] themes] count] > 0;
}

- (NSString*)messageWhenDisabled
{
    return LocalizedString(@"MSG_NO_THEMES", nil);
}


#pragma mark - Testable

- (NSString*)generateSectionAContentForStratFile:(StratFile*)stratFile
{
    // Section A:
    // - Company Basics
    // - What is Your Ultimate Aspiration?
    // - What is Your Medium Range Strategic Goal?
    
    NSString *sectionAContent = @"";
    
    NSString *companyBasics = [self generateCompanyBasicsDescriptionForStratFile:stratFile];    
    if (![companyBasics isBlank]) {
        sectionAContent = [sectionAContent stringByAppendingFormat:@"%@", companyBasics];
    }

    sectionAContent = [self stringByAppendingParagraphs:[self prepareContentText:stratFile.ultimateAspiration] toString:sectionAContent];
    sectionAContent = [self stringByAppendingParagraphs:[self prepareContentText:stratFile.mediumTermStrategicGoal] toString:sectionAContent];

    return sectionAContent;
}

- (NSString*)generateCompanyBasicsDescriptionForStratFile:(StratFile*)stratFile
{
    // we need to have either a company name and location, or a company name and sector.
    
    NSString *companyName = [self prepareContentText:stratFile.companyName];    
    if ([companyName isBlank]) {
        return @"";  //doesn't make sense to return anything if there is no company name.
    }    
    
    NSString *location = [self generateLocationDescriptionForStratFile:stratFile];
    NSString *sector = [self generateSectorDescriptionForStratFile:stratFile];
    
    // don't return anything if we only have a company name...
    if ([location isBlank] && [sector isBlank]) {
        return @"";
    } else {        
        if (![location isBlank] && ![sector isBlank]) {
            return [NSString stringWithFormat:@"%@ %@ %@ %@.", companyName, location, LocalizedString(@"AND", nil), sector];
        } else if ([location isBlank]) {
            return [NSString stringWithFormat:@"%@ %@.", companyName, sector];
        } else {
            return [NSString stringWithFormat:@"%@ %@.", companyName, location];   
        }        
    }
}

- (NSString*)generateLocationDescriptionForStratFile:(StratFile*)stratFile
{
    NSString *city = [self prepareContentText:stratFile.city];
    NSString *provinceState = [self prepareContentText:stratFile.provinceState];
    NSString *country = [self prepareContentText:stratFile.country];    
    NSString *location = @"";
    
    // only include a location description if we have a city.
    if (![city isBlank]) {
        
        NSString *cityProvCountry = @"";
        
        if ([provinceState isBlank]) {
            
            if ([country isBlank]) {                
                cityProvCountry = city;                
            } else {
                cityProvCountry = [NSString stringWithFormat:@"%@, %@", city, country];
            }
            
        } else {
            
            if ([country isBlank]) {
                cityProvCountry = [NSString stringWithFormat:@"%@, %@", city, provinceState];
            } else {
                cityProvCountry = [NSString stringWithFormat:@"%@, %@, %@", city, provinceState, country];
            }            
        }
        
        location = [NSString stringWithFormat:LocalizedString(@"COMPANY_LOCATION_TEMPLATE", nil), cityProvCountry];        
    }
    return location;
}

- (NSString*)generateSectorDescriptionForStratFile:(StratFile*)stratFile
{
    NSString *sector = [self prepareContentText:stratFile.industry];
    
    if (![sector isBlank]) {        
        sector = [NSString stringWithFormat:LocalizedString(@"COMPANY_SECTOR", nil), sector];
    }
    return sector;    
}

- (NSString*)generateSectionBContentForStratFile:(StratFile*)stratFile
{
    // Section B
    // - Describe Customers
    // - Key Problems
    // - How You Address Customer Problems
    // - Who Are Your Competitors?
    // - Discuss Your Business Model
    // - Discuss Expansion Options
    
    NSString *sectionBContent = @"";

    
    sectionBContent = [self stringByAppendingParagraphs:[self prepareContentText:stratFile.customersDescription] toString:sectionBContent];
    sectionBContent = [self stringByAppendingParagraphs:[self prepareContentText:stratFile.keyProblems] toString:sectionBContent];
    sectionBContent = [self stringByAppendingParagraphs:[self prepareContentText:stratFile.addressProblems] toString:sectionBContent];
    sectionBContent = [self stringByAppendingParagraphs:[self prepareContentText:stratFile.competitorsDescription] toString:sectionBContent];
    sectionBContent = [self stringByAppendingParagraphs:[self prepareContentText:stratFile.businessModelDescription] toString:sectionBContent];
    sectionBContent = [self stringByAppendingParagraphs:[self prepareContentText:stratFile.expansionOptionsDescription] toString:sectionBContent];

    return sectionBContent;
}


#pragma mark - NSNotification Handlers

- (void)handleOptimisticOrCurrencySettingChanges:(NSNotification*)notification
{
    [self reloadPDFDelegates];
    
    // tell the PDF view to draw itself again with the new delegates.
    [self.pdfView setNeedsDisplay];        
}


#pragma mark - Private

- (void)reloadPDFDelegates
{
    StratFile *stratFile = stratFileManager_.currentStratFile;
    NSString *sectionAContent = [self generateSectionAContentForStratFile:stratFile];
    NSString *sectionBContent = [self generateSectionBContentForStratFile:stratFile];
    
    BusinessPlanReport *screenDelegate = [[BusinessPlanReport alloc] init];
    screenDelegate.sectionAContent = sectionAContent;
    screenDelegate.sectionBContent = sectionBContent;
    pdfView_.screenDelegate = screenDelegate;
    [screenDelegate release];
    
    BusinessPlanReport *printDelegate = [[BusinessPlanReport alloc] init];    
    printDelegate.sectionAContent = sectionAContent;
    printDelegate.sectionBContent = sectionBContent;
    pdfView_.printDelegate = printDelegate;
    [printDelegate release];
    
    // adjust the height of the pdfView to adjust for the required height of the on-screen content.
    CGFloat viewHeight = [screenDelegate heightToDisplayContentForBounds:self.pdfView.bounds];
    self.pdfView.frame = CGRectMake(self.pdfView.frame.origin.x, self.pdfView.frame.origin.y, self.pdfView.frame.size.width, viewHeight);                
    
    // update the content size of the scroll view so we can scroll the pdf view if need be
    self.scrollView.contentSize = self.pdfView.frame.size;
}

- (NSString*)stringByAppendingParagraphs:(NSString*)paragraphs toString:(NSString*)string
{
    if ([paragraphs isBlank]) {
        return string;
    } else {
        if ([string isBlank]) {
            return paragraphs;
        } else {
            return [string stringByAppendingFormat:@"\n\n%@", paragraphs];
        }
    }    
}

- (NSString*)prepareContentText:(NSString*)contentText
{
    return contentText == nil ? @"" : [contentText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

-(void)addYammerCommentsButton
{
    [self addYammerCommentsButtonToView:pdfView_];
}

# pragma mark - Help Video

// @override
-(BOOL)hasVideo
{
    return [[[LocalizedManager sharedManager] localeIdentifier] hasPrefix:@"en"];
}

// @override
-(NSString*)helpVideoURL
{
    //return @"http://player.vimeo.com/external/70704176.m3u8?p=high,standard,mobile&s=f5bdefb6eb0e6bcd0b1b7834b58502ff";
    NSString* path = [[NSBundle mainBundle] pathForResource:@"SP iPad R9" ofType:@"mp4"];
    return path;
}



@end
