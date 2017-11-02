//
//  CsvService.m
//  StratPad
//
//  Created by Julian Wood on 2013-06-24.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//

#import "CsvService.h"
#import "RootViewController.h"
#import "Tracking.h"
#import "IncomeStatementDetailViewController.h"
#import "CashFlowDetailViewController.h"
#import "BalanceSheetDetailViewController.h"
#import "MBProgressHUD.h"
#import "AFHTTPClient.h"
#import "RemoteReport.h"
#import "JsonToCsvProcessor.h"

@interface CsvService ()
@property (nonatomic, retain) MBProgressHUD *hud;
@property (nonatomic, assign) NSUInteger progressMax;
@property (nonatomic, assign) NSUInteger progress;
@property (nonatomic, retain) MFMailComposeViewController *mailComposer;
@property (nonatomic, assign) NSUInteger hudMessageIdx;
@property (nonatomic, retain) NSTimer *hudMessageTimer;
@property (nonatomic, retain) JsonToCsvProcessor *jsonToCsvProcessor;
@property (nonatomic, retain) NSArray *loadingMessages;
@end

@implementation CsvService

- (id)init
{
    self = [super init];
    if (self) {
        RootViewController *rootViewController = (RootViewController*)[[[UIApplication sharedApplication] keyWindow] rootViewController];
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:rootViewController.view];
        self.hud = hud;
        [hud release];
        
        [rootViewController.view addSubview:_hud];
        
        // the hud tends to resize itself when you change the message, which is a little distracting, so make all messages the same size
        NSString *loading = LocalizedString(@"HUD_LOADING_MSG", nil);
        self.loadingMessages = [NSArray arrayWithObjects:
                         [NSString stringWithFormat:@"%@   ", loading],
                         [NSString stringWithFormat:@"%@.  ", loading],
                         [NSString stringWithFormat:@"%@.. ", loading],
                         [NSString stringWithFormat:@"%@...", loading],
                         nil];

    }
    return self;
}

- (void)dealloc
{
    [_loadingMessages release];
    [_jsonToCsvProcessor release];
    [_hudMessageTimer release];
    [_mailComposer release];
    [_hud release];

    [super dealloc];
}

-(void)shareNetFinancials
{	
	// Set determinate mode
	_hud.mode = MBProgressHUDModeDeterminate;
	
	_hud.labelText = [_loadingMessages objectAtIndex:0];
    
    _hudMessageIdx = 0;
	
	// myProgressTask uses the HUD instance to update progress
    [_hud show:YES];
    
    // schedule message updates on the current run loop (the "..." animation)
    self.hudMessageTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(waitingHudProgress) userInfo:nil repeats:YES];
    
    // first, we have to make sure our Processor (webview) is ready for action
    if (!_jsonToCsvProcessor) {
        JsonToCsvProcessor *csvVC = [[JsonToCsvProcessor alloc] init];
        self.jsonToCsvProcessor = csvVC;
        [csvVC release];
    }
    
    [_jsonToCsvProcessor processWhenReady:@selector(fetchAndMailCsvFile) target:self];
}

-(void)fetchAndMailCsvFile
{
    // generate an email with a .csv attachment
    MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
    self.mailComposer = mailComposer;
    [mailComposer release];
    
    _mailComposer.mailComposeDelegate = self;
    
    StratFile *stratFile = [[StratFileManager sharedManager] currentStratFile];
    int numFiles = stratFile.themes.count + 1 + 3;
    [self initHudProgress:numFiles];
    
    // subject and body text
    NSString *subject = LocalizedString(@"SHARE_CSV_SUBJECT", nil);
    NSString *emailBody = [NSString stringWithFormat:LocalizedString(@"SHARE_CSV_BODY", nil), [stratFile name]];
    [_mailComposer setSubject:subject];
    [_mailComposer setMessageBody:emailBody isHTML:NO];
    
    // 1 attachment per theme
    for (Theme *theme in stratFile.themes) {
        
        [self incrementHudProgress];
        
        // Attach .csv to the email
        NSString *filename = [[[theme title] stringByReplacingOccurrencesOfString:@"/" withString:@"_"] stringByAppendingPathExtension:@"csv"];
        NSString *csvPath = [NSTemporaryDirectory() stringByAppendingPathComponent:filename];
        
        CSVFileWriter *csvWriter = [[CSVFileWriter alloc] init];
        [csvWriter exportThemeToCsvAtPath:csvPath theme:theme];
        [csvWriter release];
        
        NSData *csvData = [NSData dataWithContentsOfFile:csvPath];
        [_mailComposer addAttachmentData:csvData mimeType:@"text/csv" fileName:filename];
        
    }
    
    [self incrementHudProgress];
    
    // also do an R2 csv file
    NSString *filename = [LocalizedString(@"CONSOLIDATED_CSV_REPORT", nil) stringByAppendingPathExtension:@"csv"];
    NSString *csvPath = [NSTemporaryDirectory() stringByAppendingPathComponent:filename];
    
    CSVFileWriter *csvWriter = [[CSVFileWriter alloc] init];
    [csvWriter exportConsolidatedReportToCsvAtPath:csvPath stratFile:stratFile];
    [csvWriter release];
    
    NSData *csvData = [NSData dataWithContentsOfFile:csvPath];
    [_mailComposer addAttachmentData:csvData mimeType:@"text/csv" fileName:filename];
    
    // finally, we need the IS, CF and BS as details; processor must be ready at this point
    IncomeStatementDetailViewController *isvc = [[IncomeStatementDetailViewController alloc] initWithNibName:nil bundle:nil];
    CashFlowDetailViewController *cfvs = [[CashFlowDetailViewController alloc] initWithNibName:nil bundle:nil];
    BalanceSheetDetailViewController *bsvc = [[BalanceSheetDetailViewController alloc] initWithNibName:nil bundle:nil];
    
    [self loadCsvReport:isvc];
    [self loadCsvReport:cfvs];
    [self loadCsvReport:bsvc];
}

-(void)showCsvEmailComposer
{
    // when we're done downloading, show the email view
    RootViewController *rootViewController = (RootViewController*)[[[UIApplication sharedApplication] keyWindow] rootViewController];
    [rootViewController presentModalViewController:_mailComposer animated:YES];
    
    [Tracking logEvent:kTrackingEventCSVEmailed];
    
}

-(void)loadCsvReport:(id<RemoteReport>)remoteReport
{
    NSDictionary *config = [[NSBundle mainBundle] infoDictionary];
    NSURL *url = [NSURL URLWithString:[config objectForKey:@"MBReportServer"]];
    AFHTTPClient *client = [AFHTTPClient clientWithBaseURL:url];
    [client setDefaultHeader:@"Authorization" value:[NSString stringWithFormat:@"token %@", MBReportServerApiToken]];
    [client setDefaultHeader:@"Content-Type" value:@"application/xml"];
    
    NSMutableURLRequest *request = [client requestWithMethod:@"POST" path:remoteReport.reportUrlPath parameters:nil];
    
    StratFile *stratFile = [[StratFileManager sharedManager] currentStratFile];
    StratFileWriter *stratFileWriter = [[StratFileWriter alloc] initWithStratFile:(StratFile*)stratFile];
    [stratFileWriter writeStratFile:YES];
    
    // get the resulting XML string
    NSData* xml = [stratFileWriter toData];
    [stratFileWriter release];

#if DEBUG
    NSString *filename = [stratFile.name stringByAppendingPathExtension:@"xml"];
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:filename];
    [xml writeToFile:path atomically:YES];
    DLog(@"Wrote stratfile to: %@", path);
#endif
    
    [request setHTTPBody:xml];
    
    // add uuid and dateModified to the url as query params
    NSTimeInterval timestamp = stratFile.dateModified.timeIntervalSince1970;
    NSDictionary *queryParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithDouble:floor(timestamp*1000)], @"dateModified",
                                 stratFile.uuid, @"uuid",
                                 nil];
    url = [NSURL URLWithString:[[request.URL absoluteString] stringByAppendingFormat:@"?%@", AFQueryStringFromParametersWithEncoding(queryParams, client.stringEncoding)]];
    [request setURL:url];
    
    // post the request
    __block CsvService *csvService = self;
    AFHTTPRequestOperation *operation = [client HTTPRequestOperationWithRequest:request
                                                                        success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                            id json = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
                                                                            // DLog(@"financial summary report: %@", json);
                                                                            DLog(@"received json, report ready");
                                                                            
                                                                            NSString *filename = [remoteReport.fullReportName stringByAppendingPathExtension:@"csv"];
                                                                            NSString *csvPath = [NSTemporaryDirectory() stringByAppendingPathComponent:filename];
                                                                            
                                                                            [_jsonToCsvProcessor exportToCsvWithJson:json remoteReport:remoteReport path:csvPath];
                                                                            
                                                                            NSData *csvData = [NSData dataWithContentsOfFile:csvPath];
                                                                            [_mailComposer addAttachmentData:csvData mimeType:@"text/csv" fileName:filename];
                                                                            
                                                                            [csvService incrementHudProgress];
                                                                            
                                                                        }
                                                                        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                            ELog(@"Couldn't get financial summary report: %@", error);
                                                                            
                                                                            [csvService incrementHudProgress];

                                                                        } ];
    [client enqueueHTTPRequestOperation:operation];
    
}

-(void)initHudProgress:(NSUInteger)progressMax
{
    _progress = 0;
    _progressMax = progressMax;
    _hud.progress = 0;
}

-(void)incrementHudProgress
{
    _progress = MIN(_progress+1, _progressMax);
    _hud.progress = (float)_progress/_progressMax;
    
    if (_progress == _progressMax) {
        [_hudMessageTimer invalidate];
        [self showCsvEmailComposer];
        [_hud hide:YES];
    }
}

-(void)waitingHudProgress
{
    _hudMessageIdx = _hudMessageIdx+1;
    if (_hudMessageIdx == _loadingMessages.count) {
        _hudMessageIdx = 0;
    }
    _hud.labelText = [_loadingMessages objectAtIndex:_hudMessageIdx];
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    ILog("Email result: %i; error: %@", result, error);
    [controller dismissModalViewControllerAnimated:YES];
}


@end
