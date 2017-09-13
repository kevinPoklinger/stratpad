//
//  PdfService.m
//  StratPad
//
//  Created by Julian Wood on 2013-07-02.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//
//  curl -H "Content-Type: text/html" --header 'Authorization: token b4354c901f71614a2dc36687698cfc6c' -X POST -i -d @balancesheetexample.html "https://www.mobilesce.com/stratpad/pdf/financialsummaryreport.php?uuid=488EF38B-88BC-4A88-BE39-48CCA5F57440&dateModified=1344408629" -k > test.pdf

// you basically have to run this whole thing on the main thread
// the downloading will be sent to a background thread


#import "PdfService.h"
#import "RootViewController.h"
#import "Tracking.h"
#import "MBProgressHUD.h"
#import "AFHTTPClient.h"
#import "JsonToHtmlProcessor.h"
#import "AFURLConnectionOperation.h"
#import "IncomeStatementSummaryViewController.h"

//#define pdfServiceHost  @"https://www.mobilesce.com"
//#define endPoint        @"/stratpad/pdf/financialsummaryreport.php"
#define pdfServiceHost  @"https://pdf.stratpad.com"
#define endPoint        @"/pdf/html2pdf.php"

#define _AFNETWORKING_ALLOW_INVALID_SSL_CERTIFICATES_


@interface PdfService ()
@property (nonatomic, retain) JsonToHtmlProcessor *jsonToHtmlProcessor;
@property (nonatomic, retain) id<RemoteReport> remoteReport;
@property (nonatomic, retain) id target;
@property (nonatomic, assign) SEL action;
@property (nonatomic, assign) NSError *error;
@end

@implementation PdfService


- (void)dealloc
{
    [_target release];
    [_jsonToHtmlProcessor release];
    [_remoteReport release];
    
    [super dealloc];
}

-(id)fetchFinancialReportAsPDF:(id<RemoteReport>)remoteReport target:(id)target action:(SEL)action error:(NSError**)error
{
    self.error = *error;
    self.target = target;
    self.action = action;
    
    // first, we have to make sure our Processor (webview) is ready for action
    if (!_jsonToHtmlProcessor) {
        JsonToHtmlProcessor *htmlVC = [[JsonToHtmlProcessor alloc] init];
        self.jsonToHtmlProcessor = htmlVC;
        [htmlVC release];
    }
    
    self.remoteReport = remoteReport;
    
    [_jsonToHtmlProcessor processWhenReady:@selector(fetchAndSaveHtmlFile) target:self];
    
    return nil;
}

-(void)fetchAndSaveHtmlFile
{        
    [self loadHtmlReport:_remoteReport];
}

-(void)loadHtmlReport:(id<RemoteReport>)remoteReport
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
    __block PdfService *pdfService = self;
    AFHTTPRequestOperation *operation = [client HTTPRequestOperationWithRequest:request
                                                                        success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                            id json = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
                                                                            DLog(@"received json, report ready");
                                                                            
                                                                            NSString *filename = [remoteReport.fullReportName stringByAppendingPathExtension:@"html"];
                                                                            NSString *htmlPath = [NSTemporaryDirectory() stringByAppendingPathComponent:filename];
                                                                            
                                                                            [_jsonToHtmlProcessor exportToHtmlWithJson:json remoteReport:remoteReport path:htmlPath];
                                                                            
                                                                            // now we have to send this data to our pdf converter service
                                                                            [pdfService convertHtmlToPdf:htmlPath];
                                                                            
                                                                        }
                                                                        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                            ELog(@"Couldn't get financial summary report: %@", error);
                                                                            
                                                                            self.error = error;
                                                                            
                                                                        } ];
    [client enqueueHTTPRequestOperation:operation];
    
}

-(void)convertHtmlToPdf:(NSString*)htmlPath
{
    // send this data up to our pdf service
    
    //  curl -H "Content-Type: text/html" --header 'Authorization: token b4354c901f71614a2dc36687698cfc6c' -X POST -i -d @balancesheetexample.html "https://www.mobilesce.com/stratpad/pdf/financialsummaryreport.php?uuid=488EF38B-88BC-4A88-BE39-48CCA5F57440&dateModified=1344408629" -k > test.pdf

    NSURL *url = [NSURL URLWithString:pdfServiceHost];
    AFHTTPClient *client = [AFHTTPClient clientWithBaseURL:url];
    [client setDefaultHeader:@"Authorization" value:[NSString stringWithFormat:@"token %@", MBReportServerApiToken]];
    [client setDefaultHeader:@"Content-Type" value:@"text/html"];
    [client setDefaultHeader:@"Content-Transfer-Encoding" value:@"8BIT"]; // the idea here is to let the server know we're coming in utf-8
    
    NSMutableURLRequest *request = [client requestWithMethod:@"POST" path:endPoint parameters:nil];

    // add uuid and dateModified to the url as query params
    StratFile *stratFile = [[StratFileManager sharedManager] currentStratFile];
    NSTimeInterval timestamp = stratFile.dateModified.timeIntervalSince1970;
    NSDictionary *queryParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithDouble:floor(timestamp*1000)], @"dateModified",
                                 stratFile.uuid, @"uuid",
                                 nil];
    url = [NSURL URLWithString:[[request.URL absoluteString] stringByAppendingFormat:@"?%@", AFQueryStringFromParametersWithEncoding(queryParams, client.stringEncoding)]];
    [request setURL:url];

    NSData *htmlData = [NSData dataWithContentsOfFile:htmlPath];
    [request setHTTPBody:htmlData];
    
    __block PdfService *pdfService = self;
    AFHTTPRequestOperation *operation = [client HTTPRequestOperationWithRequest:request
                                                                        success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                            DLog(@"received pdf");
                                                                            
                                                                            NSString *filename = [[[htmlPath lastPathComponent] stringByDeletingPathExtension] stringByAppendingPathExtension:@"pdf"];
                                                                            NSString *pdfPath = [NSTemporaryDirectory() stringByAppendingPathComponent:filename];

                                                                            BOOL success = [(NSData*)responseObject writeToFile:pdfPath atomically:YES];
                                                                            
                                                                            DLog(@"sucess: %i, wrote pdf to %@", success, pdfPath);
                                                                            
                                                                            [pdfService.target performSelector:pdfService.action withObject:pdfPath];
                                                                        }
                                                                        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                            ELog(@"Couldn't get pdf for financial summary report: %@", error);
                                                                            
                                                                            self.error = error;
                                                                        } ];
    
    // allow use of a self-signed SSL certificate
    [operation setAuthenticationAgainstProtectionSpaceBlock:^BOOL(NSURLConnection *connection, NSURLProtectionSpace *protectionSpace) {
        return YES;
    }];
    
    [operation setAuthenticationChallengeBlock:^(NSURLConnection *connection, NSURLAuthenticationChallenge *challenge) {
        if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
            [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
        }
    }];
    
    [client enqueueHTTPRequestOperation:operation];
}

@end
