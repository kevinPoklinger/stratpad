//
//  ThemeDetailReportViewController.m
//  StratPad
//
//  Created by Eric Rogers on August 30, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "ThemeDetailReportViewController.h"
#import "Settings.h"
#import "DataManager.h"
#import "Responsible.h"
#import "NSDate-StratPad.h"
#import "NSString-Expanded.h"
#import "UIColor-Expanded.h"
#import "ThemeDetailReport.h"
#import "EventManager.h"

@implementation ThemeDetailReportViewController

@synthesize scrollView = scrollView_;
@synthesize pdfView = pdfView_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andThemeOrNil:(Theme*)theme
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        theme_ = theme;
        
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
    [pdfView_ release];
    [scrollView_ release];
    
    [super dealloc];
}


#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    ThemeDetailReport *screenDelegate = [[ThemeDetailReport alloc] init];
    
    if (theme_) {
        [screenDelegate setTheme:theme_];
        [screenDelegate setResponsibleDescription:[self responsibleDescriptionForCurrentTheme]];
        [screenDelegate setThemeDescription:[self descriptionForCurrentTheme]];
    }
    
    pdfView_.screenDelegate = screenDelegate;
    [screenDelegate release];
    
    ThemeDetailReport *printDelegate = [[ThemeDetailReport alloc] init];

    if (theme_) {
        [printDelegate setTheme:theme_];
        [printDelegate setResponsibleDescription:[self responsibleDescriptionForCurrentTheme]];
        [printDelegate setThemeDescription:[self descriptionForCurrentTheme]];
    }

    pdfView_.printDelegate = printDelegate;
    [printDelegate release];
    
    // adjust the height of the pdfView to adjust for the required height of the on-screen content.
    CGFloat viewHeight = [screenDelegate heightToDisplayContentForBounds:self.pdfView.bounds];
    self.pdfView.frame = CGRectMake(self.pdfView.frame.origin.x, self.pdfView.frame.origin.y, self.pdfView.frame.size.width, viewHeight);                
    
    // set the size of the content for the scroll view based on the size of the Gantt chart it contains.
    self.scrollView.contentSize = CGSizeMake(self.pdfView.frame.size.width, self.pdfView.frame.size.height);
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

#pragma mark - ContentViewController Overrides

- (void)exportToPDF
{   
    // only print pages if they actually have a theme and that theme has an objective
    if ([self isEnabled]) {
        [pdfView_ drawPDFPagesWithOrientation:PageOrientationLandscape];
    }
}

- (BOOL)isEnabled
{
    return (theme_ != nil) && (theme_.objectives.count > 0);
}

- (NSString*)messageWhenDisabled
{
    if (theme_ == nil) {
        return LocalizedString(@"MSG_NO_THEMES", nil);    
    } else {
        return LocalizedString(@"MSG_NO_OBJECTIVES", nil);    
    }
}


#pragma mark - Private

- (NSString*)responsibleDescriptionForCurrentTheme
{
    if (!theme_) {
        return @"";
    }
    
    NSString *responsibleSummary = theme_.responsible.summary;
    
    if (responsibleSummary && ![responsibleSummary isBlank]) {

        if (theme_.startDate) {
            
            if (theme_.endDate) {
                return [NSString stringWithFormat:LocalizedString(@"RESPONSIBLE_TEMPLATE_ALL_DATA", nil), 
                        responsibleSummary, [theme_.startDate formattedDate2], [theme_.endDate formattedDate2]];
            } else {
                return [NSString stringWithFormat:LocalizedString(@"RESPONSIBLE_TEMPLATE_RESPONSIBLE_AND_NO_END_DATE", nil), 
                        responsibleSummary, [theme_.startDate formattedDate2]];
            }
            
        } else {
         
            if (theme_.endDate) {
                return [NSString stringWithFormat:LocalizedString(@"RESPONSIBLE_TEMPLATE_RESPONSIBLE_AND_NO_START_DATE", nil), 
                        responsibleSummary, [theme_.endDate formattedDate2]];
            } else {
                return [NSString stringWithFormat:LocalizedString(@"RESPONSIBLE_TEMPLATE_RESPONSIBLE_AND_NO_START_DATE_OR_END_DATE", nil), 
                        responsibleSummary];
            }
        }
        
    } else {
        
        if (theme_.startDate) {
            
            if (theme_.endDate) {
                return [NSString stringWithFormat:LocalizedString(@"RESPONSIBLE_TEMPLATE_NO_RESPONSIBLE", nil), [theme_.startDate formattedDate2], [theme_.endDate formattedDate2]];

            } else {
                return [NSString stringWithFormat:LocalizedString(@"RESPONSIBLE_TEMPLATE_NO_RESPONSIBLE_AND_NO_END_DATE", nil), [theme_.startDate formattedDate2]];
            }
            
        } else {
            
            if (theme_.endDate) {
                return [NSString stringWithFormat:LocalizedString(@"RESPONSIBLE_TEMPLATE_NO_RESPONSIBLE_AND_NO_START_DATE", nil), [theme_.endDate formattedDate2]];

            } else {
                return LocalizedString(@"RESPONSIBLE_TEMPLATE_NO_DATA", nil);
            }
        }
        
    }
    
    return responsibleSummary;
}

- (NSString*)descriptionForCurrentTheme
{
    if (!theme_) {
        return @"";
    }
 
    if ([theme_.mandatory boolValue] == YES) {
        
        if ([theme_.enhanceUniqueness boolValue] == YES) {
            
            if ([theme_.enhanceCustomerValue boolValue] == YES) {                
                return LocalizedString(@"THEME_DESCRIPTION_MANDATORY_ENHANCE_UNIQUENESS_IMPROVES_CUST_VALUE", nil);                

            } else {
                return LocalizedString(@"THEME_DESCRIPTION_MANDATORY_ENHANCE_UNIQUENESS_DOES_NOT_IMPROVE_CUST_VALUE", nil);
            }
            
        } else {
            
            if ([theme_.enhanceCustomerValue boolValue] == YES) {
                return LocalizedString(@"THEME_DESCRIPTION_MANDATORY_DOES_NOT_ENHANCE_UNIQUENESS_IMPROVES_CUST_VALUE", nil);
                
            } else {
                return LocalizedString(@"THEME_DESCRIPTION_MANDATORY_DOES_NOT_ENHANCE_UNIQUENESS_DOES_NOT_IMPROVE_CUST_VALUE", nil);
            }
        }
        
    } else {
        
        if ([theme_.enhanceUniqueness boolValue] == YES) {
            
            if ([theme_.enhanceCustomerValue boolValue] == YES) {
                return LocalizedString(@"THEME_DESCRIPTION_NOT_MANDATORY_ENHANCE_UNIQUENESS_IMPROVES_CUST_VALUE", nil);                
                
            } else {
                return LocalizedString(@"THEME_DESCRIPTION_NOT_MANDATORY_ENHANCE_UNIQUENESS_DOES_NOT_IMPROVE_CUST_VALUE", nil);
            }
            
        } else {
            
            if ([theme_.enhanceCustomerValue boolValue] == YES) {
               return LocalizedString(@"THEME_DESCRIPTION_NOT_MANDATORY_DOES_NOT_ENHANCE_UNIQUENESS_IMPROVES_CUST_VALUE", nil); 
                
            } else {
                return LocalizedString(@"THEME_DESCRIPTION_NOT_MANDATORY_DOES_NOT_ENHANCE_UNIQUENESS_DOES_NOT_IMPROVE_CUST_VALUE", nil);
            }
        }        
    }
    
    return nil;
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
    //return @"http://player.vimeo.com/external/70704394.m3u8?p=high,standard,mobile&s=ecbece3eff9fed2c2deffbe9ab274d8d";
    NSString* path = [[NSBundle mainBundle] pathForResource:@"SP iPad R5" ofType:@"mp4"];
    return path;
}



@end

