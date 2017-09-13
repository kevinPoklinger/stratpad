//
//  ActionsMenuViewController.m
//  StratPad
//
//  Created by Julian Wood on 11-08-11.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "ActionsMenuViewController.h"
#import "UIColor-Expanded.h"
#import <QuartzCore/QuartzCore.h>
#import "RootViewController.h"
#import "StratFileManager.h"
#import "DataManager.h"
#import "Settings.h"
#import "NSDate-StratPad.h"
#import "Chapter.h"
#import "PageSpooler.h"
#import "EditionManager.h"
#import "CustomUpgradeViewController.h"
#import "CSVFileWriter.h"
#import "AdPage.h"
#import "ReportPage.h"
#import "Chart.h"
#import "ChartSelectionViewController.h"
#import "YammerMessageBuilderViewController.h"
#import "Reachability.h"
#import "YammerManager.h"
#import "YammerOAuth2LoginViewController.h"
#import "RegistrationManager.h"
#import "PdfHelper.h"
#import "Tracking.h"
#import "IncomeStatementDetailViewController.h"
#import "CashFlowDetailViewController.h"
#import "BalanceSheetDetailViewController.h"
#import "MBProgressHUD.h"
#import "AFHTTPClient.h"
#import "RemoteReport.h"
#import "JsonToCsvProcessor.h"
#import "DocxService.h"
#import "CsvService.h"

#define emailReportsSection         0
#define emailStratfileCellPath      [NSIndexPath indexPathForRow:0 inSection:1]
#define emailCSVCellPath            [NSIndexPath indexPathForRow:1 inSection:1]

// identify the lock view and the activity views for easy retrieval
#define tagLock         888
#define tagActivity     777

@interface ActionsMenuViewController ()
@property (nonatomic, retain) MFMailComposeViewController *mailComposer;

// anywhere in the StratBoard pages
@property (nonatomic, assign) BOOL isStratBoard;

// if we're on the StratBoard home page
@property (nonatomic, assign) BOOL isStratCard;

// we just have a custom menu item for this
@property (nonatomic, assign) BOOL isFinancialReport;

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSArray *menuItems;
@property (nonatomic, assign) BOOL isOnline;

@end

@implementation ActionsMenuViewController

@synthesize tableView = tableView_;
@synthesize isPrintable = isPrintable_;
@synthesize printChapter = printChapter_;
@synthesize reportName = reportName_;
@synthesize pageNumber = pageNumber_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {        
        self.navigationItem.title = LocalizedString(@"MENU_ACTIONS_TITLE", nil);
    }
    return self;
}

#pragma mark - Lifecycle

- (void)dealloc
{
    [tableView_ release];
    [_menuItems release];
    
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
        
    // array of dicts
    // each dict is a section
    // each section has two keys: one for the section title and one for its rows (an array)
    
    // if we're in stratboard, use Chart instead of Report
    self.isStratBoard = [printChapter_.chapterNumber isEqualToString:@"S1"];
    
    // if StratBoard home, use StratCard instead of Chart, but only for "This ..."
    self.isStratCard = _isStratBoard && pageNumber_ == 0;
    
    // financial report?
    self.isFinancialReport = printChapter_.chapterIndex == ChapterIndexFinancialStatementDetail || printChapter_.chapterIndex == ChapterIndexFinancialStatementSummary;
    
    // chart, report, stratcard or financial report?
    NSString *type = _isStratBoard ? LocalizedString(@"ACTION_CHART_PARAM", nil) : LocalizedString(@"ACTION_REPORT_PARAM", nil);
    NSString *singleTitle = _isFinancialReport ? LocalizedString(@"Financial Reports", nil) : [NSString stringWithFormat:LocalizedString(@"SEND_ONE_TITLE", nil), (_isStratCard ? LocalizedString(@"REPORT_CARD", nil) : type)];
    
    self.menuItems = [NSMutableArray arrayWithObjects:
                  
                  // email
                  [NSMutableDictionary dictionaryWithObjectsAndKeys:
                   [NSArray arrayWithObjects:
                    [NSDictionary dictionaryWithObjectsAndKeys:
                     singleTitle, @"text",
                     @"emailCellForTableView:atIndexPath:", @"constructor",
                     _isStratBoard ? @"emailCurrentChart" : @"emailCurrentReport", @"action",
                     nil],
                    [NSDictionary dictionaryWithObjectsAndKeys:
                     [NSString stringWithFormat:LocalizedString(@"EMAIL_ALL", nil), type], @"text",
                     @"emailCellForTableView:atIndexPath:", @"constructor",
                     _isStratBoard ? @"emailAllCharts" : @"emailAllReports", @"action",
                     nil],
                    nil], @"rows",
                   LocalizedString(@"EMAIL", nil), @"sectionTitle",
                   nil],
                  
                  // email stratfile and csv - no header
                  [NSMutableDictionary dictionaryWithObjectsAndKeys:
                   [NSArray arrayWithObjects:
                    [NSDictionary dictionaryWithObjectsAndKeys:
                     LocalizedString(@"SHARE_STRATFILE", nil), @"text",
                     LocalizedString(@"SHARE_STRATFILE_DETAILS", nil), @"detailText",
                     @"shareCellForTableView:atIndexPath:", @"constructor",
                     @"shareStratFile", @"action",
                     nil], 
                    [NSDictionary dictionaryWithObjectsAndKeys:
                     LocalizedString(@"SHARE_CSV", nil), @"text",
                     LocalizedString(@"SHARE_CSV_DETAILS", nil), @"detailText",
                     @"shareCellForTableView:atIndexPath:", @"constructor",
                     @"shareCsvFile", @"action",
                     nil],
                    [NSDictionary dictionaryWithObjectsAndKeys:
                     LocalizedString(@"SHARE_DOCX", nil), @"text",
                     LocalizedString(@"SHARE_DOCX_DETAILS", nil), @"detailText",
                     @"shareCellForTableView:atIndexPath:", @"constructor",
                     @"shareDocxFile", @"action",
                     nil],
                    nil], @"rows",
                   nil, @"sectionTitle",
                   nil],                      
                  
                  // email backup of current stratfile
                  [NSMutableDictionary dictionaryWithObjectsAndKeys:
                   [NSArray arrayWithObjects:
                    [NSDictionary dictionaryWithObjectsAndKeys:
                     LocalizedString(@"BACKUP", nil), @"text",
                     @"backupCellForTableView:atIndexPath:", @"constructor",
                     @"backupStratFile", @"action",
                     nil],
                    nil], @"rows",
                   nil, @"sectionTitle",
                   nil],    
    
                  // print
                  [NSMutableDictionary dictionaryWithObjectsAndKeys:
                   [NSArray arrayWithObjects:
                    [NSDictionary dictionaryWithObjectsAndKeys:
                     singleTitle, @"text",
                     @"printCellForTableView:atIndexPath:", @"constructor",
                     _isStratBoard ? @"printCurrentChart" : @"printCurrentReport", @"action",
                     nil], 
                    [NSDictionary dictionaryWithObjectsAndKeys:
                     [NSString stringWithFormat:LocalizedString(@"PRINT_ALL", nil), type], @"text",
                     @"printCellForTableView:atIndexPath:", @"constructor",
                     _isStratBoard ? @"printAllCharts" : @"printAllReports", @"action",
                     nil], 
                    nil], @"rows",
                   LocalizedString(@"PRINT", nil), @"sectionTitle",
                   nil],
/*
                  // yammer - worth 90px in height
                  [NSMutableDictionary dictionaryWithObjectsAndKeys:
                   [NSArray arrayWithObjects:
                    [NSDictionary dictionaryWithObjectsAndKeys:
                     singleTitle, @"text",
                     @"yammerCellForTableView:atIndexPath:", @"constructor",
                     _isStratBoard ? @"postCurrentChartToYammer" : @"postCurrentReportToYammer", @"action",
                     nil], 
                    nil], @"rows",
                   LocalizedString(@"YAMMER", nil), @"sectionTitle",
                   nil],
*/
                  nil];
    
    // in case the items are now printable/non-printable
    [self.tableView reloadData];
    
    self.isOnline = [[Reachability reachabilityForInternetConnection] isReachable];
}

// @override: this will make it so that the popover doesn't expand to full height
-(CGSize)contentSizeForViewInPopover
{
    return CGSizeMake(self.view.bounds.size.width, 100);
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return [_menuItems count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[_menuItems objectAtIndex:section] objectForKey:@"rows"] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[_menuItems objectAtIndex:section] objectForKey:@"sectionTitle"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{      
    NSArray *sectionItems = [[_menuItems objectAtIndex:[indexPath section]] objectForKey:@"rows"];
    NSDictionary *rowDict = [sectionItems objectAtIndex:[indexPath row]];
    
    SEL cellConstructor = NSSelectorFromString([rowDict objectForKey:@"constructor"]);
    UITableViewCell *cell = [self performSelector:cellConstructor withObject:tableView withObject:indexPath];
    return cell;    
}


#pragma mark - Table view delegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // even though selection style is none, still have to stop the action
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    return (cell.selectionStyle == UITableViewCellSelectionStyleNone) ? nil : indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    UIView *contentView = [[tableView cellForRowAtIndexPath:indexPath] contentView];
    
    BOOL showUpgrade = [contentView viewWithTag:tagLock] != nil;
    if (showUpgrade) {
        
        // dismiss the actions menu
        [(MenuNavController*)self.navigationController dismissMenu];
        [self showUpgrade];
    } else {

        // show activity indicator
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        indicator.tag = tagActivity;
        CGSize aSize = indicator.frame.size;
        
        indicator.frame = CGRectMake(contentView.frame.size.width - aSize.width - 5,
                                     (contentView.frame.size.height-aSize.height)/2,
                                     indicator.frame.size.width, indicator.frame.size.height);
        
        [contentView addSubview:indicator];
        [indicator startAnimating];
        [indicator release];
        
        NSArray *sectionItems = [[_menuItems objectAtIndex:[indexPath section]] objectForKey:@"rows"];
        NSDictionary *rowDict = [sectionItems objectAtIndex:[indexPath row]];
        
        // perform action (giving the activity indicator a chance to start animating)
        [self performSelector:NSSelectorFromString([rowDict objectForKey:@"action"]) withObject:nil afterDelay:0.1];
        
    }
    
}

#pragma mark - Cell construction

- (UITableViewCell*)emailCellForTableView:(UITableView*)tableView atIndexPath:(NSIndexPath*)indexPath
{    
    BOOL hasThemes = [[[[StratFileManager sharedManager] currentStratFile] themes] count] > 0;
    BOOL canSendMail = [MFMailComposeViewController canSendMail];
    BOOL isAllCell = [indexPath row] == 1; // the second row of each section is "All ..."    
    BOOL itemEnabled = hasThemes && canSendMail && (isPrintable_ || isAllCell || self.isFinancialReport) && _isOnline;

    BOOL hasStratBoard = [[EditionManager sharedManager] isFeatureEnabled:FeatureHasStratBoard];
    if (_isStratBoard && !hasStratBoard) {
        itemEnabled = NO;
    }
    
    // detail text can explain why it is disabled
    NSString *detailText = !isPrintable_ && !isAllCell && !self.isFinancialReport ? LocalizedString(@"EMAIL_1_MSG_CHOOSE_REPORT", nil) : nil;
    detailText = canSendMail ? detailText : LocalizedString(@"EMAIL_MSG_SETUP", nil);
    detailText = hasThemes ? detailText : LocalizedString(@"MSG_NO_THEMES", nil);
    detailText = _isStratBoard && !hasStratBoard ? LocalizedString(@"GET_STRATBOARD", nil) : detailText;

    UITableViewCell *cell = [self cellForTableView:tableView
                                       atIndexPath:indexPath
                                       itemEnabled:itemEnabled
                                        detailText:detailText];
    
    // for stratcard, we can choose which reports
    cell.accessoryType = _isStratCard && !isAllCell ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
    
    // add lock where necessary; separate capabilities for emailing csv, stratfile, report/chart
    if (![[EditionManager sharedManager] isFeatureEnabled:FeatureCanShareReports] && indexPath.section == emailReportsSection) {
        [self addLockToCellView:cell.contentView];
    } else
    if (![[EditionManager sharedManager] isFeatureEnabled:FeatureCanShareStratFiles] && [indexPath isEqual:emailStratfileCellPath]) {
        [self addLockToCellView:cell.contentView];
    } else
    if (![[EditionManager sharedManager] isFeatureEnabled:FeatureCanShareCsvFile] && [indexPath isEqual:emailCSVCellPath]) {
        [self addLockToCellView:cell.contentView];
    } else
    {
        [self removeLockFromCellView:cell.contentView];
    }

    return cell;
}

- (UITableViewCell*)printCellForTableView:(UITableView*)tableView atIndexPath:(NSIndexPath*)indexPath
{
    BOOL hasThemes = [[[[StratFileManager sharedManager] currentStratFile] themes] count] > 0;
    BOOL isAllCell = [indexPath row] == 1; // the second row of each section is "All ..."
    //BOOL itemEnabled = hasThemes && (isPrintable_ || isAllCell) && _isOnline;
    BOOL itemEnabled = hasThemes && (isPrintable_ || isAllCell || self.isFinancialReport) && _isOnline;
    
    BOOL hasStratBoard = [[EditionManager sharedManager] isFeatureEnabled:FeatureHasStratBoard];
    if (_isStratBoard && !hasStratBoard) {
        itemEnabled = NO;
    }
        
    // detail text can explain why it is disabled
    NSString *detailText = !isPrintable_ && !isAllCell && !self.isFinancialReport ? LocalizedString(@"EMAIL_1_MSG_CHOOSE_REPORT", nil) : nil;
    detailText = hasThemes ? detailText : LocalizedString(@"MSG_NO_THEMES", nil);
    detailText = _isStratBoard && !hasStratBoard ? LocalizedString(@"GET_STRATBOARD", nil) : detailText;
    
    UITableViewCell *cell = [self cellForTableView:tableView
                                       atIndexPath:indexPath
                                       itemEnabled:itemEnabled
                                        detailText:detailText];

    // for stratcard, we can choose which reports
    cell.accessoryType = _isStratCard && !isAllCell ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
    if (![[EditionManager sharedManager] isFeatureEnabled:FeaturePrint]) {
        [self addLockToCellView:cell.contentView];
    } else {
        [self removeLockFromCellView:cell.contentView];
    }

    
    return cell;
}

- (UITableViewCell*)shareCellForTableView:(UITableView*)tableView atIndexPath:(NSIndexPath*)indexPath
{
    BOOL hasThemes = [[[[StratFileManager sharedManager] currentStratFile] themes] count] > 0;
    BOOL itemEnabled = _isOnline && hasThemes;
    
    // get data
    NSArray *sectionItems = [[_menuItems objectAtIndex:[indexPath section]] objectForKey:@"rows"];
    NSDictionary *rowDict = [sectionItems objectAtIndex:[indexPath row]];

    
    // detail text can explain why it is disabled
    NSString *detailText = hasThemes ? [rowDict objectForKey:@"detailText"] : LocalizedString(@"MSG_NO_THEMES", nil);
    
    UITableViewCell *cell = [self cellForTableView:tableView
                                       atIndexPath:indexPath
                                       itemEnabled:itemEnabled
                                        detailText:detailText];
    
    if (![[EditionManager sharedManager] isFeatureEnabled:FeatureCanShareStratFiles]) {
        [self addLockToCellView:cell.contentView];
    } else {
        [self removeLockFromCellView:cell.contentView];
    }

    return cell;
}

- (UITableViewCell*)backupCellForTableView:(UITableView*)tableView atIndexPath:(NSIndexPath*)indexPath
{
    StratFile *stratFile = [[StratFileManager sharedManager] currentStratFile];
    
    // figure out whether enabled;
    BOOL isBackupFeatureEnabled = [[EditionManager sharedManager] isFeatureEnabled:FeatureBackup];
    BOOL isFileReadWrite = [stratFile isReadable:UserTypeOwner] && [stratFile isWritable:UserTypeOwner];
    BOOL itemEnabled = _isOnline && isBackupFeatureEnabled && isFileReadWrite;
        
    // detail text can explain why it is disabled
    NSString *detailText = isFileReadWrite ? LocalizedString(@"BACKUP_DETAILS", nil) : LocalizedString(@"BACKUP_DISABLED_NOT_READ_WRITE", nil);
    detailText = isBackupFeatureEnabled ? detailText : LocalizedString(@"REGISTER_TO_ENABLE_BACKUP", nil);
    
    UITableViewCell *cell = [self cellForTableView:tableView
                                       atIndexPath:indexPath
                                       itemEnabled:itemEnabled
                                        detailText:detailText];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    if (!isBackupFeatureEnabled) {
        [self addLockToCellView:cell.contentView];
    } else {
        [self removeLockFromCellView:cell.contentView];
    }
    
    return cell;
}


- (UITableViewCell*)yammerCellForTableView:(UITableView*)tableView atIndexPath:(NSIndexPath*)indexPath
{
    StratFile *stratfile = [[StratFileManager sharedManager] currentStratFile];

    BOOL hasThemes = [[stratfile themes] count] > 0;
    BOOL isPublished = [stratfile isPublishedToYammer:printChapter_.chapterNumber pageNumber:pageNumber_];
        
    BOOL itemEnabled = hasThemes && _isOnline && isPrintable_ && !isPublished;
    
    BOOL hasStratBoard = [[EditionManager sharedManager] isFeatureEnabled:FeatureHasStratBoard];
    if (_isStratBoard && !hasStratBoard) {
        itemEnabled = NO;
    }
    
    // detail text can explain why it is disabled
    NSString *detailText = !isPrintable_ ? LocalizedString(@"EMAIL_1_MSG_CHOOSE_REPORT", nil) : LocalizedString(@"YAMMER_DETAIL", nil);
    detailText = hasThemes ? detailText : LocalizedString(@"MSG_NO_THEMES", nil);
    detailText = isPublished ? LocalizedString(@"YAMMER_ALREADY_PUBLISHED", nil) : detailText;
    detailText = _isStratBoard && !hasStratBoard ? LocalizedString(@"GET_STRATBOARD", nil) : detailText;
    
    UITableViewCell *cell = [self cellForTableView:tableView
                                       atIndexPath:indexPath
                                       itemEnabled:itemEnabled
                                        detailText:detailText];        
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if (![[EditionManager sharedManager] isFeatureEnabled:FeatureYammer]) {
        [self addLockToCellView:cell.contentView];
    } else {
        [self removeLockFromCellView:cell.contentView];
    }
    
    return cell;
}


- (UITableViewCell*)cellForTableView:(UITableView*)tableView 
                         atIndexPath:(NSIndexPath*)indexPath
                         itemEnabled:(BOOL)itemEnabled 
                          detailText:(NSString*)detailText
{
    static NSString *CellIdentifier = @"ActionCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];        
    }
    
    // any cached activity indicators
    [[cell.contentView viewWithTag:tagActivity] removeFromSuperview];
    
    // check for online and change the detail message
    cell.detailTextLabel.text = _isOnline ? detailText : LocalizedString(@"MSG_OFFLINE", nil);
    
    // font, colour and selectability should match itemEnabled
    cell.selectionStyle = itemEnabled ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [UIFont boldSystemFontOfSize:18];
    cell.textLabel.textColor = itemEnabled ? [UIColor blackColor] : [UIColor colorWithHexString:@"d0d0d0"];
    
    // populate the primary text
    NSArray *sectionItems = [[_menuItems objectAtIndex:[indexPath section]] objectForKey:@"rows"];
    NSDictionary *rowDict = [sectionItems objectAtIndex:[indexPath row]];
    cell.textLabel.text = [rowDict objectForKey:@"text"];
    
    return cell;    
}


#pragma mark - Yammer

-(void)postCurrentChartToYammer
{
    [[YammerManager sharedManager] checkAuthentication:self action:@selector(postCurrentChartToYammer:error:)];
}

// callback
-(void)postCurrentChartToYammer:(NSDictionary*)info error:(NSError*)error
{
    [self postToYammer:ReportSizeCurrentPage isAuthenticated:!error];
}

-(void)postCurrentReportToYammer
{
    [[YammerManager sharedManager] checkAuthentication:self action:@selector(postCurrentReportToYammer:error:)];
}

// callback
-(void)postCurrentReportToYammer:(NSDictionary*)info error:(NSError*)error
{
    [self postToYammer:ReportSizeCurrentChapter isAuthenticated:!error];
}

-(void)postToYammer:(ReportSize)reportSize isAuthenticated:(BOOL)isAuthenticated
{
    
    // build the pdf
    RootViewController *rootViewController = (RootViewController*)[[[UIApplication sharedApplication] keyWindow] rootViewController];
    PageViewController *pageVC = rootViewController.pageViewController;
    PdfHelper *helper = [[PdfHelper alloc] initWithReportName:pageVC.currentChapter.title
                                                      chapter:pageVC.currentChapter
                                                   pageNumber:pageVC.pageNumber
                                                   reportSize:reportSize
                                                 reportAction:ReportActionYammer
                         ];
    
    // custom completionBlocks
    if (isAuthenticated) {
        helper.allTasksCompletedBlock = ^(NSString* path) {
            
            // go straight to MessageBuilder
            YammerMessageBuilderViewController *vc = [[YammerMessageBuilderViewController alloc] initWithPath:path reportName:reportName_];
            [self.navigationController pushViewController:vc animated:YES];
            [vc release];
        };
        
    } else {

        helper.allTasksCompletedBlock = ^(NSString* path) {
            
            // login
            YammerOAuth2LoginViewController *loginVC = [[YammerOAuth2LoginViewController alloc] initWithPath:path reportName:reportName_];
            [self.navigationController pushViewController:loginVC animated:YES];
            [loginVC release];
        };
        
    }
    
    [helper generatePdf];
    [helper release];

}

#pragma mark - Charts

- (void)emailCurrentChart
{
    if (_isStratCard) {
        ChartSelectionViewController *chartSelectionVC = [[ChartSelectionViewController alloc] initWithAction:StratCardActionEmail];
        [self.navigationController pushViewController:chartSelectionVC animated:YES];
        [chartSelectionVC release];
    } else {        
        [self generatePdf:ReportSizeCurrentPage reportAction:ReportActionEmail];
    }
}

- (void)emailAllCharts
{
    [self generatePdf:ReportSizeCurrentChapter reportAction:ReportActionEmail];
}

- (void)printCurrentChart
{
    if (_isStratCard) {
        ChartSelectionViewController *chartSelectionVC = [[ChartSelectionViewController alloc] initWithAction:StratCardActionPrint];
        [self.navigationController pushViewController:chartSelectionVC animated:YES];
        [chartSelectionVC release];
    } else {        
        [self generatePdf:ReportSizeCurrentPage reportAction:ReportActionPrint];
    }
}

- (void)printAllCharts
{
    [self generatePdf:ReportSizeCurrentChapter reportAction:ReportActionPrint];
}

#pragma mark - Reports

- (void)emailCurrentReport
{
    [self generatePdf:ReportSizeCurrentChapter reportAction:ReportActionEmail];
}

- (void)emailAllReports
{
    [self generatePdf:ReportSizeAllChapters reportAction:ReportActionEmail];
}

- (void)printCurrentReport
{
    [self generatePdf:ReportSizeCurrentChapter reportAction:ReportActionPrint];
}

- (void)printAllReports
{
    [self generatePdf:ReportSizeAllChapters reportAction:ReportActionPrint];
}

#pragma mark - StratCard

-(void)emailStratCard
{
    [self generatePdf:ReportSizeCurrentPage reportAction:ReportActionEmail];
}

-(void)printStratCard
{
    [self generatePdf:ReportSizeCurrentPage reportAction:ReportActionPrint];
}

-(void)generatePdf:(ReportSize)reportSize reportAction:(ReportAction)reportAction
{
    RootViewController *rootViewController = (RootViewController*)[[[UIApplication sharedApplication] keyWindow] rootViewController];
    PageViewController *pageVC = rootViewController.pageViewController;
    PdfHelper *helper = [[PdfHelper alloc] initWithReportName:pageVC.currentChapter.title
                                                      chapter:pageVC.currentChapter
                                                   pageNumber:pageVC.pageNumber
                                                   reportSize:reportSize
                                                 reportAction:reportAction
                         ];
    [helper generatePdf];
    [helper release];
}

#pragma mark - Share stratfile

- (void)shareStratFile
{
    
    // dismiss the actions menu
    [(MenuNavController*)self.navigationController dismissMenu];
    // generate an email with a .stratfile attachment
    
    MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
    self.mailComposer = mailComposer;
    [mailComposer release];
    
    _mailComposer.mailComposeDelegate = self;
    
    StratFile *stratFile = [[StratFileManager sharedManager] currentStratFile];
    
    // subject and body text
    NSString *subject = [NSString stringWithFormat:LocalizedString(@"SHARE_STRATFILE_SUBJECT", nil), [stratFile name]];
    NSString *emailBody = [NSString stringWithFormat:LocalizedString(@"SHARE_STRATFILE_BODY", nil), [stratFile name], [[EditionManager sharedManager] appStoreURLForProductId:kProductIdPremium]];
    [_mailComposer setSubject:subject];
    [_mailComposer setMessageBody:emailBody isHTML:YES];
    
    // Attach .stratfile to the email
    NSString *filename = [[[stratFile name] stringByReplacingOccurrencesOfString:@"/" withString:@"_"] stringByAppendingPathExtension:@"stratfile"];
    NSString *xmlPath = [NSTemporaryDirectory() stringByAppendingPathComponent:filename];
    [[StratFileManager sharedManager] exportStratFileToXmlAtPath:xmlPath stratFile:stratFile];
    
    NSData *xmlData = [NSData dataWithContentsOfFile:xmlPath];
    [_mailComposer addAttachmentData:xmlData mimeType:@"application/stratpad" fileName:filename];
    
    // show the email view
    RootViewController *rootViewController = (RootViewController*)[[[UIApplication sharedApplication] keyWindow] rootViewController];
    [rootViewController presentModalViewController:_mailComposer animated:YES];
    
    [Tracking logEvent:kTrackingEventStratfileEmailed];
}

#pragma mark - Share docx file

-(void)shareDocxFile
{
    // dismiss the actions menu; will show a hud instead
    [(MenuNavController*)self.navigationController dismissMenu];

    DocxService *docxService = [[DocxService alloc] init];
    [docxService shareSummaryBusinessPlan];
    [docxService release];
}


#pragma mark - Share csv file

-(void)shareCsvFile
{
    // dismiss the actions menu; will show a hud instead
    [(MenuNavController*)self.navigationController dismissMenu];
    
    CsvService *csvService = [[CsvService alloc] init];
    [csvService shareNetFinancials];
    [csvService release];    
}

#pragma mark - Backup stratfile

-(void)backupStratFile
{    
    StratFile *stratFile = [[StratFileManager sharedManager] currentStratFile];
    NSString *filename = [[[stratFile name] stringByReplacingOccurrencesOfString:@"/" withString:@"_"] stringByAppendingPathExtension:@"stratbak"];
    NSString *xmlPath = [NSTemporaryDirectory() stringByAppendingPathComponent:filename];
    [[StratFileManager sharedManager] exportStratFileToXmlAtPath:xmlPath stratFile:stratFile];
    
    [[RegistrationManager sharedManager] uploadBackup:xmlPath stratfile:stratFile];
    
    [Tracking logEvent:kTrackingEventStratfileBackedUp];
    
    // dismiss the actions menu
    [(MenuNavController*)self.navigationController dismissMenu];

}
#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error 
{
    ILog("Email result: %i; error: %@", result, error);
    [controller dismissModalViewControllerAnimated:YES];
}


#pragma mark - Menus

-(void)dismissPrintInteractionController
{
    [[UIPrintInteractionController sharedPrintController] dismissAnimated:YES];
}


#pragma mark - Override

-(void)reloadLocalizableResources
{
    [super reloadLocalizableResources];
    self.navigationItem.title = LocalizedString(@"MENU_ACTIONS_TITLE", nil);
}

#pragma mark - Locking & upgrades

-(void)showUpgrade
{
    // show custom upgrade vc
    RootViewController *rootViewController = (RootViewController*)[[[[UIApplication sharedApplication] delegate] window] rootViewController];
    CustomUpgradeViewController *upgradeVC = [[CustomUpgradeViewController alloc] init];
    [upgradeVC showPopoverInView:rootViewController.view];
    [upgradeVC release];
}

-(void)addLockToCellView:(UIView*)contentView
{
    UIView *viewLock = [contentView viewWithTag:tagLock];
    if (!viewLock) {
        UIImage *imgLock = [UIImage imageNamed:@"lock"];
        viewLock = [[UIImageView alloc] initWithImage:imgLock];
        viewLock.alpha = 0.6;
        viewLock.frame = CGRectMake(tableView_.bounds.size.width-4-imgLock.size.width, 4, imgLock.size.width, imgLock.size.height);
        viewLock.tag = tagLock;
        [contentView addSubview:viewLock];
        [viewLock release];        
    }
}

-(void)removeLockFromCellView:(UIView*)contentView
{
    UIView *viewLock = [contentView viewWithTag:tagLock];
    [viewLock removeFromSuperview];
}


@end
