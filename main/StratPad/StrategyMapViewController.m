//
//  StrategyMapViewController.m
//  StratPad
//
//  Created by Julian Wood on 11-08-18.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "StrategyMapViewController.h"
#import "StratFileManager.h"
#import "StratFile.h"
#import "NSDate-StratPad.h"
#import "Theme.h"
#import "Objective.h"
#import "ObjectiveType.h"
#import "EventManager.h"
#import "StrategyMapPrintDelegate.h"

uint const maxWidth = 6;
uint const maxThemesPerPage = 3;

#pragma mark - StratMapTheme

@implementation StratMapTheme

@synthesize theme=theme_;
@synthesize pageNum=pageNum_;
@synthesize objectives=objectives_;

-(void)dealloc
{
    [theme_ release];
    [objectives_ release];
    [super dealloc];
}

-(NSString*)description
{
    return [NSString stringWithFormat:
            @"theme: %@, pageNum: %i, objectives: %i", 
            self.theme.title, self.pageNum, [self.objectives count]
            ];
}

@end


#pragma mark - SplitTheme


@implementation SplitTheme

@synthesize theme=theme_;
@synthesize objectives=objectives_;

+ (NSSet*)subSetOfObjectives:(NSSet*)objectives forWidth:(uint)width forRemainder:(BOOL)forRemainder
{
    NSMutableSet *subset = [NSMutableSet set];
    NSArray *sortedObjectives = [Theme objectivesSortedByOrder:objectives];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:kNumberOfObectiveCategories];
    
    // organize into dict
    for (Objective *objective in sortedObjectives) {
        NSNumber *objectiveCategory = [[objective objectiveType] category];
        
        NSMutableArray *catObjectives = [dict objectForKey:objectiveCategory];
        if (catObjectives == nil) {
            catObjectives = [NSMutableArray arrayWithObject:objective];
            [dict setObject:catObjectives forKey:objectiveCategory];
        } else {
            [catObjectives addObject:objective];
        }
    }
    
    // now place objectives up to width in subset (respecting their order)
    for (NSNumber *objectiveCategory in [dict allKeys]) {
        NSArray *catObjectives = [dict objectForKey:objectiveCategory];
        for (uint i=0, ct=MIN(width,[catObjectives count]); i<ct; ++i) {
            [subset addObject:[catObjectives objectAtIndex:i]];
        }
    }
    
    // now return either the subset we made, or whatever was left over
    if (forRemainder) {
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            return ![subset containsObject:evaluatedObject];
        }];
        return [objectives filteredSetUsingPredicate:predicate];
    } else {
        return subset;
    }

}

+ (NSSet*)subSetOfObjectivesForTheme:(Theme*)theme forWidth:(uint)width forRemainder:(BOOL)forRemainder
{  
    return [SplitTheme subSetOfObjectives:theme.objectives forWidth:width forRemainder:forRemainder];
}

- (NSUInteger)themeWidth
{
    return [Theme themeWidth:objectives_];
}

-(void)dealloc
{
    [theme_ release];
    [objectives_ release];
    [super dealloc];
}

-(NSString*)description
{
    return [NSString stringWithFormat:
            @"theme: %@, objectives: %i", 
            self.theme.title, [self.objectives count]
            ];
}

@end


#pragma mark - StrategyMapViewController


@implementation StrategyMapViewController

@synthesize reportHeaderView=reportHeaderView_;
@synthesize scrollView = scrollView_;
@synthesize strategyMapView = strategyMapView_;

@synthesize lblThemesDescription;
@synthesize lblFinancialDescription;
@synthesize lblCustomerDescription;
@synthesize lblProcessDescription;
@synthesize lblStaffDescription;

@synthesize printDelegate=printDelegate_;
@synthesize lblStrategy;
@synthesize lblThemes;
@synthesize lblFinancial;
@synthesize lblCustomer;
@synthesize lblProcess;
@synthesize lblStaff;

#pragma mark - init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andPageNumber:(NSUInteger)pageNumber
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {        
        pageNumber_ = pageNumber;
        
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
    [lblThemesDescription release];
    [lblFinancialDescription release];
    [lblCustomerDescription release];
    [lblProcessDescription release];
    [lblStaffDescription release];
    
    [reportHeaderView_ release];
    [scrollView_ release];
        
    [strategyMapView_ release];
    [printDelegate_ release];
    
    [lblStrategy release];
    [lblThemes release];
    [lblFinancial release];
    [lblCustomer release];
    [lblProcess release];
    [lblStaff release];
    [super dealloc];
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    lblThemesDescription.text = LocalizedString(@"STRATEGY_MAP_VIEW_DESC_THEMES", nil);
    lblFinancialDescription.text = LocalizedString(@"STRATEGY_MAP_VIEW_DESC_FINANCIAL", nil);
    lblCustomerDescription.text = LocalizedString(@"STRATEGY_MAP_VIEW_DESC_CUSTOMER", nil);
    lblProcessDescription.text = LocalizedString(@"STRATEGY_MAP_VIEW_DESC_PROCESS", nil);
    lblStaffDescription.text = LocalizedString(@"STRATEGY_MAP_VIEW_DESC_STAFF", nil);
    
    lblThemes.text = LocalizedString(@"STRATEGY_MAP_VIEW_LABEL_THEMES", nil);
    lblStrategy.text = LocalizedString(@"STRATEGY_MAP_VIEW_LABEL_STRATEGY", nil);
    lblFinancial.text = LocalizedString(@"OBJECTIVE_TYPE_FINANCIAL", nil);
    lblCustomer.text = LocalizedString(@"OBJECTIVE_TYPE_CUSTOMER", nil);
    lblProcess.text = LocalizedString(@"OBJECTIVE_TYPE_PROCESS", nil);
    lblStaff.text = LocalizedString(@"OBJECTIVE_TYPE_STAFF", nil);
    
    // vertically align=top on all UILabels with tag=100 (in the scrollview), using IB font and bounds
    for (UIView *view in [scrollView_ subviews]) {
        if (view.tag == 100) {
            UILabel *label = (UILabel*)view;
            CGSize size = [label.text sizeWithFont:label.font constrainedToSize:label.bounds.size];
            label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y, label.bounds.size.width, size.height);
        }
    }
        
    // we have 6 rows at 80px high each
    // 2 primary columns: 165px and 522px
    // 3 columns in stratmapview: 174px each
    // in each subcolumn, we can have 1 or 2 cells: 47px - 80px - 47px or 5px - 80px - 6px - 80px - 5px
        
    // no scrolling for now...
    [scrollView_ setContentSize:CGSizeMake(scrollView_.bounds.size.width, scrollView_.bounds.size.height)];
    
    strategyMapView_.mediaType = MediaTypeScreen;
    strategyMapView_.pageNumber = pageNumber_;

    // set up a print delegate - it will override the above skin style
    StrategyMapPrintDelegate *printDelegate = [[StrategyMapPrintDelegate alloc] init];
    StrategyMapView *strategyMapPrintView = [[StrategyMapView alloc] init];
    printDelegate.strategyMapView = strategyMapPrintView;
    [strategyMapPrintView release];
    printDelegate.strategyMapView.mediaType = MediaTypePrint;
    self.printDelegate = printDelegate;
    [printDelegate release];
    
    // there is no screen delegate - the StrategyMapView is in the xib for screen
    // the report header is also set in the nib
    
    [reportHeaderView_ setTextInsetLeft:20.f];
    [reportHeaderView_ setReportTitle:[printDelegate_ reportTitle]];
}

- (void)viewDidUnload
{
    [self setLblStrategy:nil];
    [self setLblThemes:nil];
    [self setLblFinancial:nil];
    [self setLblCustomer:nil];
    [self setLblProcess:nil];
    [self setLblStaff:nil];
    [super viewDidUnload];

    [self setLblThemesDescription:nil];
    [self setLblFinancialDescription:nil];
    [self setLblCustomerDescription:nil];
    [self setLblProcessDescription:nil];
    [self setLblStaffDescription:nil];

    [reportHeaderView_ release]; reportHeaderView_ = nil;
    [scrollView_ release]; scrollView_ = nil;
        
    [strategyMapView_ release], strategyMapView_ = nil;
}

-(void)viewDidAppear:(BOOL)animated
{
    [self addYammerCommentsButton];
    [super viewDidAppear:animated];
}


#pragma mark - Testable

+ (NSDictionary*)createStratMapThemes:(StratFile*)stratFile
{
    // now we need to figure out how many pages we have
    // it is dictated by the number of themes and the number of objectives for a particular type
    // we can take up to 6 objectives across a page; 3 themes max per page
    // themes go in user order
    // fill up the 6 slots in order, splitting themes as necessary
    
    // so 1 theme, 4 objectives would be 1 page
    // 2 themes, 4 and 2 obj would be 1 page
    // 3 themes, 3 and 2 and 1 would be 1 page
    // 4 themes, 3x 1 and 2 would be 2 pages
    
    uint sumWidths=0, themeCtr=0, curPageNum=0;
    NSMutableDictionary *stratMapThemesDict = [NSMutableDictionary dictionary]; // pageNum -> nsarray of stratMapTheme
    
    // we may want to adjust this array on the fly if any themes need splitting
    NSMutableArray *sortedThemes = [[stratFile themesSortedByOrder] mutableCopy];
    
    // now go through all our themes, and assign pageNum and objectives properties 
    //   by placing them in StratMapTheme container objects
    uint ctr = 0;
    while (ctr < [sortedThemes count]) {
        
        // when a theme is split, it will be a StratMapTheme inserted into our array
        uint themeWidth;
        StratMapTheme *smt = [[StratMapTheme alloc] init];
        NSSet *objectives;
        id obj = [sortedThemes objectAtIndex:ctr];
        if ([obj isKindOfClass:[Theme class]]) {
            // just a regular theme to deal with
            smt.theme = (Theme*)obj;
            objectives = smt.theme.objectives;
            themeWidth = [smt.theme themeWidth];
            
        } else if ([obj isKindOfClass:[SplitTheme class]]) {
            // take the properties for smt from the splitTheme
            SplitTheme *splitTheme = (SplitTheme*)obj;
            smt.theme = splitTheme.theme;
            objectives = splitTheme.objectives;
            themeWidth = [splitTheme themeWidth];
            
        } else {
            // error
            [smt release];
            [sortedThemes release];
            ELog(@"Yikes - what is this in our array? %@", obj);
            @throw [NSException
                    exceptionWithName:@"IllegalArgumentException"
                    reason:@"Illegal type of class in Theme array"
                    userInfo:nil];
        }
        smt.pageNum = curPageNum;
        
        themeCtr++;
        
        // what subset of objectives are on this page?
        if (sumWidths + themeWidth > maxWidth) {
            // we have to split this theme
            uint width = maxWidth - sumWidths;
            
            // no point in splitting if only 1 slot left (need 2)
            // if less than 2, just put it on the next page 
            if (width < 2) {
                [sortedThemes insertObject:smt.theme atIndex:ctr+1];
                curPageNum++;
                sumWidths = 0;
                themeCtr = 0;
                ctr++;
                [smt release];
                continue;
            } else {
                // make a new theme to be processed
                SplitTheme *splitTheme = [[SplitTheme alloc] init];
                splitTheme.theme = smt.theme;
                
                // put the first set on the current smt
                smt.objectives = [SplitTheme subSetOfObjectives:objectives forWidth:width forRemainder:NO];
                
                // put the remainder of the objectives on the splitTheme for subsequent processing
                splitTheme.objectives = [SplitTheme subSetOfObjectives:objectives forWidth:width forRemainder:YES];
                
                // add the splitTheme for subsequent processing
                [sortedThemes insertObject:splitTheme atIndex:ctr+1];

                [splitTheme release];                
            }
            
        } else {
            // all objectives fit
            smt.objectives = objectives;
        }
        
        // store the stratMapTheme that we have assembled in an array in a dict, keyed by pagenum
        NSMutableArray *smts = [stratMapThemesDict objectForKey:[NSNumber numberWithInt:curPageNum]];
        if (!smts) {
            smts = [NSMutableArray arrayWithObject:smt];
            [stratMapThemesDict setObject:smts forKey:[NSNumber numberWithInt:curPageNum]];
        } else {
            [smts addObject:smt];
        }
        [smt release];
        // this is the full theme width for this iteration
        // do we increment the page? ie. when we add this theme's objectives to the page, will it exceed our limit? 
        sumWidths += themeWidth;
        if (sumWidths >= maxWidth || themeCtr >= maxThemesPerPage) {
            curPageNum++;
            // figure out what is going on to the next page; 
            // needs to be zero if we're not going to resolve on the next page
            if (themeWidth > maxWidth) {
                sumWidths = 0;
            } else {
                sumWidths = sumWidths % maxWidth; 
            }
            themeCtr = 0;
        }
        
        ctr++;
    }
    [sortedThemes release];

    return stratMapThemesDict;
}


#pragma mark - Public

+ (NSUInteger)numberOfPages:(StratFile*)stratFile
{
    return MAX([[StrategyMapViewController createStratMapThemes:stratFile] count], 1);
}


#pragma mark - Overrides

- (void)exportToPDF
{   
    // normally we would tell our pdfview to draw to a pdf context, which in turn tells its print delegate (set here in the vc) to draw as well
    // we've built R1 using UIKit and some custom CG graphics - want to keep the screen portion
    CGRect paperRect = CGRectMake(0, 0, 72*11, 72*8.5);

    UIGraphicsBeginPDFPageWithInfo(paperRect, nil);
    [printDelegate_ drawPage:pageNumber_ inRect:paperRect];
}

- (BOOL)isEnabled
{
    return [[[[StratFileManager sharedManager] currentStratFile] themes] count] > 0;
}

- (NSString*)messageWhenDisabled
{
    return LocalizedString(@"MSG_NO_THEMES", nil);
}

#pragma mark - Private

-(void)addYammerCommentsButton
{
    [self addYammerCommentsButtonToView:reportHeaderView_];
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
    //return @"http://player.vimeo.com/external/70704413.m3u8?p=high,standard,mobile&s=2583e08f25ffca6780cdd8944ed2e522";
    NSString* path = [[NSBundle mainBundle] pathForResource:@"SP iPad R1" ofType:@"mp4"];
    return path;
}





@end
