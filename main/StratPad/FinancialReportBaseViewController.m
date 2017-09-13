//
//  FinancialReportBaseViewController.m
//  StratPad
//
//  Created by Julian Wood on 2013-05-09.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//

#import "FinancialReportBaseViewController.h"
#import "MBLoadingView.h"
#import "AFHTTPClient.h"
#import "SkinManager.h"
#import "UIColor-Expanded.h"
#import "Reachability.h"
#import "PdfService.h"

typedef void (^CompletionBlock)(NSString* pdfPath);

@interface FinancialReportBaseViewController ()

@property (nonatomic, retain) MBLoadingView *loadingView;

// make sure that the webview is loaded before json
// because R9 can take a while to load, sometimes we'll get json before the webview
// even then, can still have problems - best to have the js poll our controller for the data
@property (nonatomic, assign) BOOL jsonLoaded;
@property (nonatomic, assign) BOOL reportLoaded;
@property (nonatomic, assign) BOOL domReady;

@property (nonatomic, retain) id json;

// what to do when we finish creating a pdf of all the financial reports (print or email them)
@property (nonatomic, copy) CompletionBlock completionBlock;

@end

@implementation FinancialReportBaseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:@"FinancialReportBaseViewController" bundle:nibBundleOrNil];
    if (self) {
        self.localizedStringsAndKeys = [NSDictionary dictionaryWithObjectsAndKeys:
                                        
                                        // IS
                                        LocalizedString(@"GENERAL_AND_ADMINISTRATIVE", nil), @"generalAndAdministrative",
                                        LocalizedString(@"RESEARCH_AND_DEVELOPMENT", nil), @"researchAndDevelopment",
                                        LocalizedString(@"SALES_AND_MARKETING", nil), @"salesAndMarketing",
                                        LocalizedString(@"REVENUE", nil), @"REVENUE",
                                        LocalizedString(@"COGS", nil), @"COGS",
                                        LocalizedString(@"GROSS_PROFIT", nil), @"GROSS_PROFIT",
                                        LocalizedString(@"EXPENSES", nil), @"EXPENSES",
                                        LocalizedString(@"netIncome", nil), @"NET",
                                        LocalizedString(@"is.ebitda", nil), @"is.ebitda",
                                        LocalizedString(@"is.ebit", nil), @"is.ebit",
                                        LocalizedString(@"is.interest", nil), @"is.interest",
                                        LocalizedString(@"is.depreciation", nil), @"is.depreciation",
                                        LocalizedString(@"is.ebt", nil), @"is.ebt",
                                        LocalizedString(@"is.incomeTaxes", nil), @"is.incomeTaxes",

                                        // CF
                                        LocalizedString(@"operations", nil), @"operations",
                                        LocalizedString(@"netIncome", nil), @"netIncome",
                                        LocalizedString(@"arChange", nil), @"arChange",
                                        LocalizedString(@"apChange", nil), @"apChange",
                                        LocalizedString(@"cashSubtotals", nil), @"cashFromOperations",
                                        LocalizedString(@"cashChanges", nil), @"changesToCash",
                                        LocalizedString(@"startCash", nil), @"startCash",
                                        LocalizedString(@"endCash", nil), @"endCash",
                                        LocalizedString(@"changesFromPrepaidSales", nil), @"changesFromPrepaidSales",
                                        LocalizedString(@"changesFromPrepaidPurchases", nil), @"changesFromPrepaidPurchases",
                                        
                                        LocalizedString(@"investmentsChange", nil), @"investmentsChange",
                                        LocalizedString(@"cashFromInvestments", nil), @"cashFromInvestments",
                                        LocalizedString(@"financingChange", nil), @"financingChange",
                                        LocalizedString(@"cashFromFinancing", nil), @"cashFromFinancing",
                                        LocalizedString(@"inventoryChange", nil), @"inventoryChange",
                                        LocalizedString(@"depreciationChange", nil), @"depreciationChange",

                                        
                                        // BS
                                        LocalizedString(@"assets", nil), @"assets",
                                        LocalizedString(@"cash", nil), @"cash",
                                        LocalizedString(@"ar", nil), @"ar",
                                        LocalizedString(@"ap", nil), @"ap",
                                        LocalizedString(@"totalAssets", nil), @"totalAssets",
                                        LocalizedString(@"liabilities", nil), @"liabilities",
                                        LocalizedString(@"equity", nil), @"equity",
                                        LocalizedString(@"totalLiabilities", nil), @"totalLiabilities",
                                        LocalizedString(@"retainedEarnings", nil), @"retainedEarnings",
                                        LocalizedString(@"totalEquity", nil), @"totalEquity",
                                        LocalizedString(@"totalLiabilitiesAndEquity", nil), @"totalLiabilitiesAndEquity",
                                        LocalizedString(@"currentAssets", nil), @"currentAssets",
                                        LocalizedString(@"currentLiabilities", nil), @"currentLiabilities",
                                        LocalizedString(@"prepaidSales", nil), @"prepaidSales",
                                        LocalizedString(@"prepaidPurchases", nil), @"prepaidPurchases",
                                        LocalizedString(@"longTermAssets", nil), @"longTermAssets",
                                        LocalizedString(@"currentPortionOfLtd", nil), @"currentPortionOfLtd",
                                        LocalizedString(@"longTermLiabilities", nil), @"longTermLiabilities",
                                        LocalizedString(@"capitalStock", nil), @"capitalStock",
                                        LocalizedString(@"accumulatedDepreciation", nil), @"accumulatedDepreciation",
                                        LocalizedString(@"employeeDeductions", nil), @"employeeDeductions",
                                        LocalizedString(@"taxesAndDeductions", nil), @"taxesAndDeductions",
                                        nil];

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    MBLoadingView *loadingView = [[MBLoadingView alloc] initWithFrame:self.view.bounds];
    self.loadingView = loadingView;
    [loadingView release];
    
    [_loadingView showInView:self.view];
    
    DLog(@"loading report");
    [self loadReport];
    
    // to get the webview transparent, set backgroundColor to clear and set opaque to NO, in the nib

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_completionBlock release];
    _webView.delegate = nil;
    [_json release];
    [_localizedStringsAndKeys release];
    [_headerView release];
    [_webView release];
    [super dealloc];
}

#pragma mark - report

-(void)loadReport
{
    Reachability *internet = [Reachability reachabilityForInternetConnection];
    if (!internet.isReachable) {
        NSString *textColor = [[[SkinManager sharedManager] colorForProperty:kSkinSection3FontColor] hexStringFromColor];
        NSString *html = [NSString stringWithFormat:@"<p style='font-family:helvetica; text-align:center; margin:100px; font-weight:bold; font-size: 24pt; color: %@;'>%@</p>", textColor, LocalizedString(@"NoNetwork", nil)];
        [self.webView loadHTMLString:html baseURL:nil];
        [_loadingView dismiss];
        return;
    }
    
    // todo: NSURLCache will give us a local cache of the table, though we still need to check with the server for a 304 not modified
    
    // *** load up the template
    // localized base path
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    NSURL *baseURL = [NSURL fileURLWithPath:resourcePath isDirectory:YES];
    
    NSString *path = [self pathToHtmlTemplate];
    
    // string
    NSError *error = nil;
    NSString *htmlString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    
    [self.webView loadHTMLString:htmlString baseURL:baseURL];
    
    // *** load up the json
    // curl -H "Content-Type: application/xml" --header 'Authorization: token b4354c901f71614a2dc36687698cfc6c' -X POST -i -d @GetToMarketFull.xml "https://jstratpad.appspot.com/reports/incomestatement/summary?uuid=488EF38B-88BC-4A88-BE39-48CCA5F57440&dateModified=1344408629"
    
    // todo: api version in the URL
    NSDictionary *config = [[NSBundle mainBundle] infoDictionary];
    NSURL *url = [NSURL URLWithString:[config objectForKey:@"MBReportServer"]];
    AFHTTPClient *client = [AFHTTPClient clientWithBaseURL:url];
    [client setDefaultHeader:@"Authorization" value:[NSString stringWithFormat:@"token %@", MBReportServerApiToken]];
    [client setDefaultHeader:@"Content-Type" value:@"application/xml"];
    
    NSMutableURLRequest *request = [client requestWithMethod:@"POST" path:[self reportUrlPath] parameters:nil];
    
    StratFile *stratFile = [[StratFileManager sharedManager] currentStratFile];
    StratFileWriter *stratFileWriter = [[StratFileWriter alloc] initWithStratFile:(StratFile*)stratFile];
    [stratFileWriter writeStratFile:YES];
        
    // get the resulting XML string
    NSData* xml = [stratFileWriter toData];
    [stratFileWriter release];
    
    [request setHTTPBody:xml];
    
    // add uuid and dateModified to the url as query params
    NSTimeInterval timestamp = stratFile.dateModified.timeIntervalSince1970;
    NSDictionary *queryParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithDouble:floor(timestamp*1000)], @"dateModified",
                                 stratFile.uuid, @"uuid",
                                 nil];
    url = [NSURL URLWithString:[[request.URL absoluteString] stringByAppendingFormat:[path rangeOfString:@"?"].location == NSNotFound ? @"?%@" : @"&%@", AFQueryStringFromParametersWithEncoding(queryParams, client.stringEncoding)]];
    [request setURL:url];
    
    // post the request
    AFHTTPRequestOperation *operation = [client HTTPRequestOperationWithRequest:request
                                                                        success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                            id json = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
//                                                                            DLog(@"financial summary report: %@ %@", self.class, json);
                                                                            DLog(@"received json, report ready");
                                                                            
                                                                            self.json = json;
                                                                            
                                                                            _jsonLoaded = YES;
                                                                            [self showReport];
                                                                                                                                                        
                                                                        }
                                                                        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                            ELog(@"Couldn't get financial summary report: %@", error);
                                                                            
                                                                            [self showError:error];
                                                                        } ];
    [client enqueueHTTPRequestOperation:operation];
    
}

-(void)showReport
{
    // problem is that the webview and/or the dom may not be ready for some js injection
    // we need to let the page itself tell us when it is ready, then feed it the json
    if (_jsonLoaded && _domReady && !_reportLoaded) {
        // fire json into our html
        SkinManager *skinMan = [SkinManager sharedManager];
        UIColor *color = [skinMan colorForProperty:kSkinSection3FontColor];
        
        NSError *error = nil;
        NSData *dataKeysAndStrings = [NSJSONSerialization dataWithJSONObject:[self localizedStringsAndKeys] options:0 error:&error];
        NSString *jsonKeysAndStrings = [[NSString alloc] initWithData:dataKeysAndStrings encoding:NSUTF8StringEncoding];
        
        // convert to string
        NSData *dataContent = [NSJSONSerialization dataWithJSONObject:_json options:0 error:&error];
        NSString *jsonContent = [[NSString alloc] initWithData:dataContent encoding:NSUTF8StringEncoding];
        
        [self.webView stringByEvaluatingJavaScriptFromString:
         [NSString stringWithFormat:@"%@(%@, '#%@', '%@', %@);", [self jsMethodNameToLoadTable], jsonContent, color.hexStringFromColor, [LocalizedManager sharedManager].localeIdentifier, jsonKeysAndStrings]];
        [jsonKeysAndStrings release];
        [jsonContent release];
        
        [_loadingView dismiss];
        _reportLoaded = YES;
    }
}

-(void)showError:(NSError*)error
{    
    // non-localized base path
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    NSURL *baseURL = [NSURL fileURLWithPath:resourcePath isDirectory:YES];
    
    NSString *htmlString = [NSString stringWithFormat:@"Error: %@", error];
    [self.webView loadHTMLString:htmlString baseURL:baseURL];
    
   [_loadingView dismiss];
}

#pragma mark - RemoteReport

-(NSString*)jsMethodNameToLoadTable
{
    WLog(@"Override");
    return nil;
}

-(NSString*)reportUrlPath
{
    WLog(@"Override");
    return nil;
}

-(NSString*)reportName
{
    WLog(@"Override");
    return nil;
}

-(NSString*)fullReportName
{
    WLog(@"Override");
    return nil;
}

#pragma mark - UIWebViewDelegate


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([[request.URL scheme] hasPrefix:@"ready"]) {
        self.domReady = YES;
        [self showReport];
        return NO;
    }
    
    return YES;
}

#pragma mark - protected

-(NSString*)pathToHtmlTemplate
{
    return [[NSBundle mainBundle] pathForResource:@"FinancialSummaryReport" ofType:@"html"];
}


#pragma mark - printing

- (void)exportToPDF:(void (^)(NSString* pdfPath))completionBlock
{
    // this needs to come from our PrinceXML installation
    
    // so what we have to do here is take our html, run the js inside, then take the resultant html string (we do this for csv)
    // with that html string, remove all script links, add a new css link
    // send it to our pdf converter, which uses prince to return a pdf
    // then, concatenate that pdf, or print it into our existing context
    
    // this is a signal that we've finished the current task (producing a pdf)
    self.completionBlock = completionBlock;
    
    // we actually have to do this on the main thread, because we are loading up a UIViewController with a UIWebView to do some json processing in js
    // all the downloads are placed on background threads anyway
    dispatch_async(dispatch_get_main_queue(), ^{
        NSError *error = nil;
        PdfService *service = [[PdfService alloc] init];
        [service fetchFinancialReportAsPDF:self target:self action:@selector(pdfReady:error:) error:&error];
        [service release];
    });
    
}

// YES if this executed ok; NO if there was an error
-(BOOL)pdfReady:(NSString*)pdfPath error:(NSError**)error
{
    DLog(@"path: %@", pdfPath);
    _completionBlock(pdfPath);
    return error == nil;
}



@end
