//
//  RootViewController.m
//  StratPad
//
//  Created by Eric Rogers on July 26, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
    //

#import "RootViewController.h"
#import "EventManager.h"
#import "Chapter.h"
#import "ThemeDetailViewController.h"
#import "DefineObjectivesViewController.h"
#import "FormPage.h"
#import "HTMLPage.h"
#import "ReportPage.h"
#import "SettingsMenuViewController.h"
#import "ActionsMenuViewController.h"
#import "StratFilesMenuViewController.h"
#import "ActivityViewController.h"
#import "DefineObjectivesViewController.h"
#import "InfoMenuViewController.h"
#import "UpgradeViewController.h"
#import "EditionManager.h"
#import "CustomUpgradeViewController.h"
#import "UAKeychainUtils+StratPad.h"
#import "NSUserDefaults+StratPad.h"
#import "UserNotificationDisplayManager.h"
#import "YammerCommentManager.h"
#import "UIColor-Expanded.h"
#import "NSDate-StratPad.h"
#import "RegistrationManager.h"

#define splashTag 765234

@interface RootViewController ()

@property(nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property(nonatomic, retain) IBOutlet UIBarButtonItem *titleItem;

@property(nonatomic, retain) MKNumberBadgeView *yammerCommentBadge;
@property(nonatomic, retain) SplashView *splashView;

@property(nonatomic, retain) SideBarViewController *sideBarController;
@property(nonatomic, retain) PageViewController *pageController;

@property(nonatomic, retain) MenuNavController *actionsMenuNavController;
@property(nonatomic, retain) MenuNavController *settingsMenuNavController;
@property(nonatomic, retain) MenuNavController *stratFilesMenuNavController;
@property(nonatomic, retain) MenuNavController *infoMenuNavController;
@property(nonatomic, retain) MenuNavController *upgradeMenuNavController;


@end



@implementation RootViewController

#pragma mark - Memory Management

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_yammerCommentBadge release];
    [_toolbar release];
    [_splashView release];

    [_titleItem release];
    [_actionsItem release];
    [_upgradeItem release];
    [_settingsItem release];
    [_infoItem release];
    [_stratFilesItem release];
    
    [_sideBarController release];
    [_pageController release];
    
    [_actionsMenuNavController release];
    [_settingsMenuNavController release];
    [_stratFilesMenuNavController release];
    [_infoMenuNavController release];
    [_upgradeMenuNavController release];
    
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    SideBarViewController *sideBarController = [[SideBarViewController alloc] initWithNibName:@"SideBarView" bundle:nil];
    self.sideBarController = sideBarController;
    [sideBarController release];
    
    _sideBarController.view.frame = CGRectMake(0, 64, _sideBarController.view.frame.size.width, 704);
    
    PageViewController *pageController = [[PageViewController alloc] initWithNibName:@"PageViewController" bundle:nil];
    self.pageController = pageController;
    [pageController release];
    
    _pageController.view.frame = CGRectMake(_sideBarController.view.frame.size.width, 64, _pageController.view.frame.size.width, 704);
    
    // page, sidebar, toolbar
    [self.view insertSubview:_pageController.view belowSubview:_toolbar];
    [self.view insertSubview:_sideBarController.view belowSubview:_toolbar];
    
    // add splash screen over top of first view (NB splash is 1024x748, already accounting for status)
    SplashView *splashView = [[SplashView alloc] initWithFrame:self.view.frame];
    splashView.tag = splashTag;
    self.splashView = splashView;
    [self.view addSubview:splashView];
    [splashView release];
    
    // used to be there was no Extras item if in Premium, but StratBoard changed that
    if (![[EditionManager sharedManager] isFeatureEnabled:FeatureExtras]) {
        NSMutableArray *toolbarItems = [_toolbar.items mutableCopy];
        [toolbarItems removeObjectIdenticalTo:_upgradeItem];
        [_toolbar setItems:toolbarItems animated:NO];
        [toolbarItems release];
    }
    
    // Note: Register here, since we only want to register this view controller once per lifecycle.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadPageNav:)
                                                 name:kEVENT_THEME_CREATED
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadPageNav:)
                                                 name:kEVENT_THEME_DELETED
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadPageNav:)
                                                 name:kEVENT_THEMES_REORDERED
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadPageNav:)
                                                 name:kEVENT_THEME_DATE_CHANGED
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadPageNav:)
                                                 name:kEVENT_OBJECTIVE_CREATED
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadPageNav:)
                                                 name:kEVENT_OBJECTIVE_DELETED
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadPageNav:)
                                                 name:kEVENT_OBJECTIVES_REORDERED
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadPageNav:)
                                                 name:kEVENT_ACTIVITY_CREATED
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadPageNav:)
                                                 name:kEVENT_ACTIVITY_DELETED
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadPageNav:)
                                                 name:kEVENT_ACTIVITIES_REORDERED
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadPageNav:)
                                                 name:kEVENT_CHART_DELETED
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadPageNav:)
                                                 name:kEVENT_CHART_ADDED
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(stratFileLoaded:)
                                                 name:kEVENT_STRATFILE_LOADED
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(stratFileTitleChanged:)
                                                 name:kEVENT_STRATFILE_TITLE_CHANGED
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(jumpToTheme:)
                                                 name:kEVENT_JUMP_TO_THEME
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(jumpToObjective:)
                                                 name:kEVENT_JUMP_TO_OBJECTIVE
                                               object:nil];
    
    // todo: what's the point of having an event listener pattern here?
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(jumpToOnStrategyPage:)
                                                 name:kEVENT_JUMP_TO_ON_STRATEGY_PAGE
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(jumpToOnStratPadPage:)
                                                 name:kEVENT_JUMP_TO_ON_STRATPAD_PAGE
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(jumpToToolkitPage:)
                                                 name:kEVENT_JUMP_TO_TOOLKIT_PAGE
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(stratPadReady:)
                                                 name:kEVENT_STRATPAD_READY
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateYammerCommentCounts:)
                                                 name:kEVENT_YAMMER_COMMENTS_UPDATED
                                               object:nil];

    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{    
    // going full screen on a movie player does the following:
    // - adds a new view to the root VC and shows the movie there
    // - thus, when it is dismissed (shrunk) it calls viewDidAppear/etc on the RootVC
    // in fact, we should only do this once anyway
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[StratFileManager sharedManager] performSelectorOnMainThread:@selector(loadMostRecentStratFile) withObject:nil waitUntilDone:NO];
    });
    
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [_splashView fadeInInteractiveElements];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}


#pragma mark - Actions

-(void)dismissAllMenus
{
    [self dismissAllMenusExcept:nil];
}

- (void)dismissAllMenusExcept:(MenuNavController*)menuNavController 
{
    // can't use the static constructor cause it bails on the first nil it sees
    NSMutableArray *menus = [NSMutableArray array];
    if (_actionsMenuNavController) [menus addObject:_actionsMenuNavController];
    if (_settingsMenuNavController) [menus addObject:_settingsMenuNavController];
    if (_stratFilesMenuNavController) [menus addObject:_stratFilesMenuNavController];
    if (_infoMenuNavController) [menus addObject:_infoMenuNavController];
    if (_upgradeMenuNavController) [menus addObject:_upgradeMenuNavController];
    
    for (MenuNavController *navController in menus) {
        if (![navController isEqual:menuNavController]) {
            [navController dismissMenu];
        }
    }
    [(SettingsMenuViewController*)[[_settingsMenuNavController viewControllers] objectAtIndex:0] dismissImagePicker];
    [(ActionsMenuViewController*)[[_actionsMenuNavController viewControllers] objectAtIndex:0] dismissPrintInteractionController];
}

- (IBAction)showActionPopover:(id)sender event:(UIEvent*)event
{
    if (!_actionsMenuNavController) {
        ActionsMenuViewController *vc = [[ActionsMenuViewController alloc] initWithNibName:@"ActionsMenuViewController" bundle:nil];
        MenuNavController *mnvc = [[MenuNavController alloc] initWithRootViewController:vc];
        self.actionsMenuNavController = mnvc;
        [mnvc release];
        [vc release];

    }
    BOOL isPrintable = [_pageController.currentChapter isPrintable];
    ActionsMenuViewController *avc = (ActionsMenuViewController*)[_actionsMenuNavController.viewControllers objectAtIndex:0];
    [avc setIsPrintable:isPrintable];
    [avc setPrintChapter:[_pageController currentChapter]];
    [avc setReportName:[[_pageController currentChapter] title]];
    [avc setPageNumber:[_pageController pageNumber]];
    
    // pressing again dismisses the menu
    if (_actionsMenuNavController.isPresented) {
        [_actionsMenuNavController dismissMenu];
        return;
    }

    // clean up
    [self dismissAllMenusExcept:_actionsMenuNavController];
    
    // show menu
    [_actionsMenuNavController showMenu:_actionsItem];        
}

- (IBAction)showSettingsPopover:(id)sender event:(UIEvent*)event
{
    if (!_settingsMenuNavController) {
        SettingsMenuViewController *vc = [[SettingsMenuViewController alloc] initWithNibName:@"SettingsMenuViewController" bundle:nil];        
        MenuNavController *mnvc = [[MenuNavController alloc] initWithRootViewController:vc];
        self.settingsMenuNavController = mnvc;
        [mnvc release];
        [vc release];

    }
    
    // pressing again dismisses the menu
    if (_settingsMenuNavController.isPresented) {
        [_settingsMenuNavController dismissMenu];
        return;
    }

    // clean up
    [self dismissAllMenusExcept:_settingsMenuNavController];
    
    // show menu
    [_settingsMenuNavController showMenu:_settingsItem];
}

- (IBAction)showStratFilesPopover:(id)sender event:(UIEvent*)event
{    
    if (!_stratFilesMenuNavController) {
        StratFilesMenuViewController *vc = [[StratFilesMenuViewController alloc] initWithNibName:@"StratFilesMenuViewController" bundle:nil];        
        MenuNavController *mnvc = [[MenuNavController alloc] initWithRootViewController:vc];
        self.stratFilesMenuNavController = mnvc;
        [mnvc release];
        [vc release];

    }
    
    // pressing again dismisses the menu
    if (_stratFilesMenuNavController.isPresented) {
        [_stratFilesMenuNavController dismissMenu];
        return;
    }
    
    // clean up
    [self dismissAllMenusExcept:_stratFilesMenuNavController];
    
    // show menu
    [_stratFilesMenuNavController showMenu:_stratFilesItem];
}

- (IBAction)showInfoPopover:(id)sender event:(UIEvent*)event
{
    if (!_infoMenuNavController) {
        InfoMenuViewController *vc = [[InfoMenuViewController alloc] initWithNibName:@"InfoMenuViewController" bundle:nil];
        MenuNavController *mnvc = [[MenuNavController alloc] initWithRootViewController:vc];
        self.infoMenuNavController = mnvc;
        [mnvc release];
        [vc release];

    }
    
    // pressing again dismisses the menu
    if (_infoMenuNavController.isPresented) {
        [_infoMenuNavController dismissMenu];
        return;
    }
    
    // clean up
    [self dismissAllMenusExcept:_infoMenuNavController];
    
    // show menu
    [_infoMenuNavController showMenu:_infoItem];
}

- (IBAction)showUpgradePopover:(id)sender event:(UIEvent*)event
{
    if (!_upgradeMenuNavController) {
        UpgradeViewController *vc = [[UpgradeViewController alloc] init];
        MenuNavController *mnvc = [[MenuNavController alloc] initWithRootViewController:vc];
        self.upgradeMenuNavController = mnvc;
        [mnvc release];
        [vc release];        
    }

    // pressing again dismisses the menu
    if (_upgradeMenuNavController.isPresented) {
        [_upgradeMenuNavController dismissMenu];
        return;
    }

    // clean up
    [self dismissAllMenusExcept:_upgradeMenuNavController];
    
    // show menu
    [_upgradeMenuNavController showMenu:_upgradeItem];
}



#pragma mark - NSNotification Handlers

-(void)stratPadReady:(NSNotification*)notification
{
//    // look for any version-specific welcome messages and display, record that it was displayed
//    WelcomeMessageViewController *welcomeVC = [[WelcomeMessageViewController alloc] initWithNibName:nil bundle:nil];
//    [welcomeVC view]; // force the view to load (and thus get a viewDidLoad before we call stratPadReady)
//    [welcomeVC showWelcomeMessageInView:_pageController.view];
//    [welcomeVC release];
    
    // invoked at startup only, once stratpad is ready, after splashscreen dismissed
    // this is not invoked on a resume event, if the splashscreen is frontmost
    [[RegistrationManager sharedManager] showRelevantReminderInView:self.view];
    
    // check validation
    [[RegistrationManager sharedManager] checkValidation];

}

-(void)updateYammerCommentCounts:(NSNotification*)notification
{
    // this is the badge on the 'StratFiles' button in the toolbar
    if (!_yammerCommentBadge) {
        MKNumberBadgeView *yammerCommentBadge = [[MKNumberBadgeView alloc] initWithFrame:CGRectMake(70, 0, 30, 30)];
        self.yammerCommentBadge = yammerCommentBadge;
        [yammerCommentBadge release];
        
        _yammerCommentBadge.strokeWidth = 1;
        _yammerCommentBadge.hideWhenZero = YES;
        _yammerCommentBadge.fillColor = [UIColor colorWithHexString:@"22A4D5"];
        _yammerCommentBadge.font = [UIFont boldSystemFontOfSize:10];
        _yammerCommentBadge.alpha = 0;
        [_toolbar addSubview:_yammerCommentBadge];
    }
    
    // rather than use hideWhenZero, just animate ourselves
    _yammerCommentBadge.value = [[YammerCommentManager sharedManager] unreadMessageCount];
    
    if (_yammerCommentBadge.value && _yammerCommentBadge.alpha == 0.f) {
        [UIView animateWithDuration:0.3 animations:^{
            _yammerCommentBadge.alpha = 1.f;
        }];
    }
    else if (!_yammerCommentBadge.value) {
        [UIView animateWithDuration:0.3 animations:^{
            _yammerCommentBadge.alpha = 0.f;
        }];
    }
}

- (void)reloadPageNav:(NSNotification*)notification
{
    [[NavigationConfig sharedManager] buildNavigationFromStratFileOrNil:[StratFileManager sharedManager].currentStratFile];
    [_pageController reloadNextAndPreviousPages];
    [_pageController numberOfPagesChanged];
}

- (void)stratFileLoaded:(NSNotification*)notification
{
    StratFile *stratFile = [[StratFileManager sharedManager] currentStratFile];
    [self setPageTitle:stratFile.name];
}

- (void)stratFileTitleChanged:(NSNotification*)notification
{
    StratFile *stratFile = [[StratFileManager sharedManager] currentStratFile];
    [self setPageTitle:stratFile.name];    
}

- (void)jumpToTheme:(NSNotification*)notification
{
    Theme *theme = [[notification userInfo] objectForKey:kEVENT_PARAM_THEME];
    ContentViewController *source = [notification object];
    
    if ([source isKindOfClass:[ThemeDetailViewController class]]) {
        [_pageController displayActivityPageAtIndex:[[NavigationConfig sharedManager] themeDetailsPageIndexForTheme:theme]];    
        
    } else if ([source isKindOfClass:[DefineObjectivesViewController class]]) {
        [_pageController displayActivityPageAtIndex:[[NavigationConfig sharedManager] defineObjectivesPageIndexForTheme:theme]];    

    } else if ([source isKindOfClass:[ActivityViewController class]]) {
        [_pageController displayActivityPageAtIndex:[[NavigationConfig sharedManager] activityPageIndexForTheme:theme]];    

    } else {
        WLog(@"Jumping to theme from %@ is not supported.", NSStringFromClass([source class]));        
    }    
}

- (void)jumpToObjective:(NSNotification*)notification
{
    Objective *objective = [[notification userInfo] objectForKey:kEVENT_PARAM_OBJECTIVE];
    ContentViewController *source = [notification object];

    if ([source isKindOfClass:[ActivityViewController class]]) {
        [_pageController displayActivityPageAtIndex:[[NavigationConfig sharedManager] activityPageIndexForObjective:objective]];
    } else {
        WLog(@"Jumping to objective from %@ is not supported.", NSStringFromClass([source class]));
    }
}

- (void)jumpToOnStrategyPage:(NSNotification*)notification
{
    NSString *pageName = [[notification userInfo] objectForKey:kEVENT_PARAM_ON_STRATEGY_PAGE];
    Chapter *chapter = [[[NavigationConfig sharedManager] chapters] objectAtIndex:ChapterIndexOnStrategy];
    
    HTMLPage *onStrategyPage = nil;
    for (HTMLPage *page in chapter.pages) {
        if ([page.filename isEqualToString:pageName]) {
            onStrategyPage = page;
            break;
        }
    }    
    
    if (onStrategyPage) {
        [_pageController loadPage:onStrategyPage inChapter:chapter];
    } else {
        WLog(@"No On Strategy Page found with name %@", pageName);
    }
}

- (void)jumpToOnStratPadPage:(NSNotification*)notification
{
    NSString *pageName = [[notification userInfo] objectForKey:kEVENT_PARAM_ON_STRATPAD_PAGE];
    Chapter *chapter = [[[NavigationConfig sharedManager] chapters] objectAtIndex:ChapterIndexOnStratPad];
    
    HTMLPage *onStratPadPage = nil;
    for (HTMLPage *page in chapter.pages) {
        if ([page.filename isEqualToString:pageName]) {
            onStratPadPage = page;
            break;
        }
    }    
    
    if (onStratPadPage) {
        [_pageController loadPage:onStratPadPage inChapter:chapter];
    } else {
        WLog(@"No On StratPad Page found with name %@", pageName);
    }
}

- (void)jumpToToolkitPage:(NSNotification*)notification
{
    NSString *pageName = [[notification userInfo] objectForKey:kEVENT_PARAM_TOOLKIT_PAGE];
    Chapter *chapter = [[[NavigationConfig sharedManager] chapters] objectAtIndex:ChapterIndexToolkit];
    
    HTMLPage *toolkitPage = nil;
    for (HTMLPage *page in chapter.pages) {
        if ([page.filename isEqualToString:pageName]) {
            toolkitPage = page;
            break;
        }
    }    
    
    if (toolkitPage) {
        [_pageController loadPage:toolkitPage inChapter:chapter];
    } else {
        WLog(@"No Toolkit Page found with name %@", pageName);
    }
}

-(void)jumpToFinancialsPage:(NSUInteger)index
{
    Chapter *chapter = [[[NavigationConfig sharedManager] chapters] objectAtIndex:ChapterIndexFinance];
    if (index < chapter.pages.count) {
        [_pageController loadPage:[chapter.pages objectAtIndex:index] inChapter:chapter];
    } else {
        WLog(@"No financials page: %i", index);
    }
}

#pragma mark - Public

- (void) setPageTitle:(NSString*)pageTitle
{
    if (!pageTitle) {
        pageTitle = LocalizedString(@"UNNAMED_STRATFILE_TITLE", nil);
    }
    [_titleItem setTitle:[NSString stringWithFormat:LocalizedString(@"STRATFILE_TITLE_FORMAT", nil), pageTitle]];
    
}

- (PageViewController*)pageViewController
{
    return _pageController;
}

-(BOOL)isSplashScreenShowing
{
    return [self.view viewWithTag:splashTag] != nil;
}

@end
