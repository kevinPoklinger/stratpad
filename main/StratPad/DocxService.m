//
//  DocxService.m
//  StratPad
//
//  Created by Julian Wood on 2013-06-24.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//
//    curl --header "Authorization: token b4354c901f71614a2dc36687698cfc6c" --data @./summary-bizplan.json -X POST -H 'Content-type:application/json' -v https://docx.stratpad.com/summarybizplan -k > test.docx

#import "DocxService.h"
#import "AFHTTPClient.h"
#import "AFURLConnectionOperation.h"
#import "AFHTTPRequestOperation.h"
#import "FinancialDetailBaseViewController.h"
#import "StratFileManager.h"
#import "Settings.h"
#import "DataManager.h"
#import "BusinessPlanViewController.h"
#import "BusinessPlanReport.h"
#import "RootViewController.h"
#import "Tracking.h"
#import "NSDataAdditions.h"
#import "AllowingUsToProgressChart.h"
#import "ReachTheseGoalsChart.h"
#import "MBProgressHUD.h"
#import "GanttChartSplitter.h"
#import "ReachTheseGoalsChartSplitter.h"
#import "UserNotificationDisplayManager.h"

#define docxServiceHost         @"https://docx.stratpad.com"
#define endPointSummaryBizPlan  @"/summarybizplan"
#define endPointBizPlan         @"/bizplan"

#define _AFNETWORKING_ALLOW_INVALID_SSL_CERTIFICATES_


typedef enum {
    RequestStatusPreparing,
    RequestStatusUploading,
    RequestStatusUploaded,
    RequestStatusConverting,
    RequestStatusConverted,
    RequestStatusDownloading,
    RequestStatusDone
} RequestStatus;

@interface DocxService ()
@property (nonatomic, retain) BusinessPlanReport *businessPlanReport;
@property (nonatomic, retain) MBProgressHUD *hud;
@property (nonatomic, assign) RequestStatus requestStatus;
@end

@implementation DocxService

- (id)init
{
    self = [super init];
    if (self) {
        BusinessPlanReport *bp = [[BusinessPlanReport alloc] init];
        bp.businessPlanSkin = [BusinessPlanSkin skinForDocx];
        self.businessPlanReport = bp;
        [bp release];
        
        RootViewController *rootViewController = (RootViewController*)[[[UIApplication sharedApplication] keyWindow] rootViewController];
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:rootViewController.view];
        self.hud = hud;
        [hud release];
        
        [rootViewController.view addSubview:_hud];
    }
    return self;
}

- (void)dealloc
{
    [_businessPlanReport release];
    [_hud release];
    [super dealloc];
}

-(void)shareSummaryBusinessPlan
{
    {
        
        // have to send some json over to our docx service
        // json has some base64-encoded images, split up
        // save our repsonse to a file
        // load it back into a mail attachment
        
        self.requestStatus = RequestStatusConverting;
        
        _hud.mode = MBProgressHUDModeIndeterminate;
        _hud.labelText = LocalizedString(@"HUD_DOCX_PREPARE_MSG", nil);
        [_hud show:YES];
        
        // build json
        StratFile *stratFile = [[StratFileManager sharedManager] currentStratFile];
        Settings *settings = (Settings*)[DataManager objectForEntity:NSStringFromClass([Settings class])
                                                sortDescriptorsOrNil:nil
                                                      predicateOrNil:nil];
        NSString *localeIdentifier = [[[LocalizedManager sharedManager] localeIdentifier] stringByReplacingOccurrencesOfString:@"-" withString:@"_"];
        
        NSMutableDictionary *jsonDict = [NSMutableDictionary dictionary];
        [jsonDict setObject:LocalizedString(@"R9_REPORT_TITLE", nil) forKey:@"report"];
        [jsonDict setObject:stratFile.companyName forKey:@"company"];
        [jsonDict setObject:stratFile.name forKey:@"title"];
        [jsonDict setObject:localeIdentifier forKey:@"lang"];
        [jsonDict setObject:settings.currency forKey:@"currency"];
        
        BusinessPlanViewController *bpVC = [[BusinessPlanViewController alloc] init];
        NSString *sectionAContent = [bpVC generateSectionAContentForStratFile:stratFile];
        NSString *sectionBContent = [bpVC generateSectionBContentForStratFile:stratFile];
        [bpVC release];
        
        [jsonDict setObject:sectionAContent forKey:@"text_a"];
        [jsonDict setObject:sectionBContent forKey:@"text_b"];
        
        [jsonDict setObject:[self splitGanttImageDataEncoded] forKey:@"image_cs"];
        [jsonDict setObject:[self splitReachTheseGoalsChartImageDataEncoded] forKey:@"image_ds"];
        [jsonDict setObject:[NSArray arrayWithObject:[[self allowingUsToProgressChartImageData] base64Encoding]] forKey:@"image_es"];
        
        if (settings.consultantLogo) {
            NSData *data = UIImagePNGRepresentation(settings.consultantLogo);
            [jsonDict setObject:[data base64Encoding] forKey:@"logo"];
        }
        
        NSError *error = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&error];
        if (error) {
            ELog(@"Couldn't generate json: %@", error);
            return;
        }
        
#if DEBUG
        NSString *filename = @"bizplan.json";
        NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:filename];
        BOOL success = [jsonData writeToFile:path atomically:YES];
        DLog(@"Success: %i. Wrote bizplan json to: %@", success, path);
#endif
        
        NSURL *url = [NSURL URLWithString:docxServiceHost];
        AFHTTPClient *client = [AFHTTPClient clientWithBaseURL:url];
        [client setDefaultHeader:@"Authorization" value:[NSString stringWithFormat:@"token %@", MBReportServerApiToken]];
        [client setDefaultHeader:@"Content-Type" value:@"application/json"];

        NSMutableURLRequest *request = [client requestWithMethod:@"POST" path:endPointSummaryBizPlan parameters:nil];
        [request setHTTPBody:jsonData];
        
        // post the request
        NSString *docxPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"bizplan.docx"];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        operation.outputStream = [NSOutputStream outputStreamToFileAtPath:docxPath append:NO];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            DLog(@"Finished request successfully. Wrote bizplan to: %@", docxPath);
            [_hud hide:YES];
            [self mailBizPlan:docxPath];
            self.requestStatus = RequestStatusDone;
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            ELog(@"Couldn't get bizplan: %@", error);
            [_hud hide:YES];
            [[UserNotificationDisplayManager sharedManager] showErrorMessage:@"Sorry, couldn't get bizplan. %@", error];
        }];

        [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
            float progress = (float)totalBytesWritten / totalBytesExpectedToWrite;
            if (progress == 1.0) {
                self.requestStatus = RequestStatusUploaded;
            }
            [self performSelectorOnMainThread:@selector(updateProgress:)
                                   withObject:[NSNumber numberWithFloat:progress]
                                waitUntilDone:NO];
        }];
        [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
            float progress = (float)totalBytesRead / totalBytesExpectedToRead;
            if (progress >= 0.0) {
                self.requestStatus = RequestStatusConverted;
            }
            [self performSelectorOnMainThread:@selector(updateProgress:)
                                   withObject:[NSNumber numberWithFloat:progress]
                                waitUntilDone:NO];
        }];
        
        // allow use of a self-signed SSL certificate
        [operation setAuthenticationAgainstProtectionSpaceBlock:^BOOL(NSURLConnection *connection, NSURLProtectionSpace *protectionSpace) {
            return YES;
        }];
        
        [operation setAuthenticationChallengeBlock:^(NSURLConnection *connection, NSURLAuthenticationChallenge *challenge) {
            if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
                [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
            }
        }];

        _hud.mode = MBProgressHUDModeDeterminate;
        _hud.progress = 0;
        _hud.labelText = LocalizedString(@"HUD_DOCX_UPLOAD_MSG", nil);
        
        self.requestStatus = RequestStatusUploading;
        
        [client enqueueHTTPRequestOperation:operation];
    }
}

-(void)updateProgress:(NSNumber*)progress
{
    _hud.progress = progress.floatValue;
    if (_requestStatus == RequestStatusUploaded) {
        _hud.mode = MBProgressHUDModeIndeterminate;
        _hud.labelText = LocalizedString(@"HUD_DOCX_CONVERT_MSG", nil);
        self.requestStatus = RequestStatusConverting;
    }
    else if (_requestStatus == RequestStatusConverted) {
        _hud.mode = MBProgressHUDModeDeterminate;
        _hud.labelText = LocalizedString(@"HUD_DOCX_DOWNLOAD_MSG", nil);
        self.requestStatus = RequestStatusDownloading;
    }
}

-(void)mailBizPlan:(NSString*)docxPath
{    
    MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];    
    mailComposer.mailComposeDelegate = self;
    
    StratFile *stratFile = [[StratFileManager sharedManager] currentStratFile];
    
    // subject and body text
    NSString *subject = [NSString stringWithFormat:LocalizedString(@"SHARE_DOCX_SUBJECT", nil), stratFile.name];
    NSString *emailBody = [NSString stringWithFormat:LocalizedString(@"SHARE_DOCX_BODY", nil), stratFile.name];
    [mailComposer setSubject:subject];
    [mailComposer setMessageBody:emailBody isHTML:NO];
    
    [mailComposer addAttachmentData:[NSData dataWithContentsOfFile:docxPath]
                            mimeType:@"application/vnd.openxmlformats-officedocument.wordprocessingml.document"
                            fileName:[NSString stringWithFormat:@"%@ - %@.docx", stratFile.name, LocalizedString(@"SUMMARY_BUSINESS_PLAN_FILENAME", nil)]];
    
    // when we're done downloading, show the email view
    RootViewController *rootViewController = (RootViewController*)[[[UIApplication sharedApplication] keyWindow] rootViewController];
    [rootViewController presentModalViewController:mailComposer animated:YES];
    
    [Tracking logEvent:kTrackingEventDocxEmailed];
}

-(NSArray*)splitGanttImageDataEncoded
{
    // now we have to create the Gantt for the summary
    // looks like we create the Gantt, then create a GanttChartSplitter
    // then we'll have to draw the Gantt into some context and get a UIImage out of it
    
    // should be around 6" wide * 300dpi = 1800px, height is about 11.5-1-1-0.5=9 *300dpi = 2700px
    CGRect pageRect = CGRectMake(0, 0, 1800, 2700);
    MBDrawableGanttChart *ganttChart = [_businessPlanReport ganttChart:pageRect];
    
    GanttChartSplitter *splitter = [[GanttChartSplitter alloc] initWithFirstRect:pageRect andSubsequentRect:pageRect];
    NSArray *splitCharts = [splitter splitDrawable:ganttChart];
    [splitter release];
    
    NSMutableArray *ganttImages = [NSMutableArray arrayWithCapacity:splitCharts.count];
    for (int i=0, ct=splitCharts.count; i<ct; ++i) {
        MBDrawableGanttChart *splitChart = [splitCharts objectAtIndex:i];
        
        // we need a little extra for when the diamond is at the edge of the image
        UIGraphicsBeginImageContext(CGSizeMake(1816, splitChart.rect.size.height));
        [splitChart draw];
        UIImage *ganttImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        NSData *ganttData = UIImageJPEGRepresentation(ganttImage, 1.0);
        
#if DEBUG
        NSString *filename = [[NSString stringWithFormat:@"gantt-%i", i] stringByAppendingPathExtension:@"jpg"];
        NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:filename];
        BOOL success = [ganttData writeToFile:path atomically:YES];
        DLog(@"Success: %i. Wrote gantt image to: %@", success, path);
#endif
        
        [ganttImages addObject:[ganttData base64Encoding]];
        
    }

    return ganttImages;
}

-(NSArray*)splitReachTheseGoalsChartImageDataEncoded
{
    // this can exceed a page in height, though it is very unusual and takes a while
    CGRect pageRect = CGRectMake(0, 0, 1800, 2700);
    ReachTheseGoalsChart *chart = [_businessPlanReport reachTheseGoalsChart:pageRect];
    
    ReachTheseGoalsChartSplitter *splitter = [[ReachTheseGoalsChartSplitter alloc] initWithFirstRect:pageRect andSubsequentRect:pageRect];
    NSArray *splitCharts = [splitter splitDrawable:chart];
    [splitter release];
    
    NSMutableArray *chartImages = [NSMutableArray arrayWithCapacity:splitCharts.count];
    for (int i=0, ct=splitCharts.count; i<ct; ++i) {
        ReachTheseGoalsChart *splitChart = [splitCharts objectAtIndex:i];
        
        // we need a little extra for when the diamond is at the edge of the image
        UIGraphicsBeginImageContext(CGSizeMake(1816, splitChart.rect.size.height));
        [splitChart draw];
        UIImage *chartImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        NSData *chartData = UIImageJPEGRepresentation(chartImage, 1.0);
        
#if DEBUG
        NSString *filename = [[NSString stringWithFormat:@"reachTheseGoals-%i", i] stringByAppendingPathExtension:@"jpg"];
        NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:filename];
        BOOL success = [chartData writeToFile:path atomically:YES];
        DLog(@"Success: %i. Wrote reachTheseGoals image to: %@", success, path);
#endif
        
        [chartImages addObject:[chartData base64Encoding]];
        
    }
    
    return chartImages;    
}

-(NSData*)allowingUsToProgressChartImageData
{
    // this will always be the same size, and never exceed a page in height
    CGRect pageRect = CGRectMake(0, 0, 1800, 2700);
    AllowingUsToProgressChart *chart = [_businessPlanReport allowingUsToProgressChart:pageRect];
    [chart sizeToFit];
    
    UIGraphicsBeginImageContext(CGSizeMake(1816, chart.rect.size.height));
    [chart draw];
    UIImage *chartImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSData *chartData = UIImageJPEGRepresentation(chartImage, 1.0);
    
#if DEBUG
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"allowingUsToProgress.jpg"];
    BOOL success = [chartData writeToFile:path atomically:YES];
    DLog(@"Success: %i. Wrote allowingUsToProgress chart image to: %@", success, path);
#endif
    
    return chartData;
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    ILog("Email result: %i; error: %@", result, error);
    [controller dismissModalViewControllerAnimated:YES];
}



@end
