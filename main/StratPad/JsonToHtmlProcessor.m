//
//  JsonToHTMLProcessor.m
//  StratPad
//
//  Created by Julian Wood on 2013-07-02.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//

#import "JsonToHtmlProcessor.h"
#import "NSUserDefaults+StratPad.h"
#import "NSDate-StratPad.h"
#import "EditionManager.h"
#import "StratFileManager.h"
#import "RegistrationManager.h"

@interface JsonToHtmlProcessor ()
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) id target;
@property (nonatomic, assign) SEL action;
@end

@implementation JsonToHtmlProcessor

- (id)init
{
    self = [super init];
    if (self) {
        DLog(@"Loading JsonToHtmlProcessor webview");
        
        _ready = NO;
        
        self.webView = [[UIWebView alloc] init];
        _webView.delegate = self;
        NSString *path = [[NSBundle mainBundle] pathForResource:@"FinancialSummaryReport" ofType:@"html"];
        NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
        
        [_webView loadRequest:[NSURLRequest requestWithURL:url]];
        
    }
    return self;
}

-(void)dealloc {
    // no super call because of ARC
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Public

-(void)exportToHtmlWithJson:(NSDictionary*)json remoteReport:(id<RemoteReport>)remoteReport path:(NSString*)path
{
    NSError *error = nil;
    NSData *dataKeysAndStrings = [NSJSONSerialization dataWithJSONObject:[remoteReport localizedStringsAndKeys] options:0 error:&error];
    NSString *jsonKeysAndStrings = [[NSString alloc] initWithData:dataKeysAndStrings encoding:NSUTF8StringEncoding];
    
    // convert to string
    NSData *dataContent = [NSJSONSerialization dataWithJSONObject:json options:0 error:&error];
    NSString *jsonContent = [[NSString alloc] initWithData:dataContent encoding:NSUTF8StringEncoding];
    
    // the financial reports have reportNames like: Summary Reports - Income Statement
    // we would like StratFile name - Income Statement
    NSString *reportTitle = [NSString stringWithFormat:@"%@ - %@", [remoteReport reportName], [[StratFileManager sharedManager] currentStratFile].name];
    NSString *htmlBody = [_webView stringByEvaluatingJavaScriptFromString:
                     [NSString stringWithFormat:@"%@(%@, '#%@', '%@', %@); htmlStringForBody('%@')", [remoteReport jsMethodNameToLoadTable], jsonContent, @"000000", [LocalizedManager sharedManager].localeIdentifier, jsonKeysAndStrings, reportTitle]];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    RegistrationStatus registrationStatus = [[NSUserDefaults standardUserDefaults] integerForKey:keyRegistrationStatus];
    NSString *author;
    if (registrationStatus != RegistrationStatusNone) {
        author = [NSString stringWithFormat:@"%@ %@ <%@>",
                            [defaults objectForKey:keyFirstName],
                            [defaults objectForKey:keyLastName],
                            [defaults objectForKey:keyEmail]];
    } else {
        author = @"Unregistered";
    }
    
    NSString *html = [NSString stringWithFormat:@"<!DOCTYPE html><html><head> \
                      <meta http-equiv=\"content-type\" content=\"text/html; charset=utf-8\"> \
                      <meta name=\"Author\" content=\"%@\"/> \
                      <meta name=\"Subject\" content=\"%@\"/> \
                      <meta name=\"CreationDate\" content=\"%@\"/> \
                      <meta name=\"Generator\" content=\"%@\"/> \
                      <link rel=\"stylesheet\" href=\"../financials-prince.css\"/> \
                      <title>%@</title> \
                      </head>%@</html>", author, [[StratFileManager sharedManager] currentStratFile].name, [[NSDate date] formattedDate1], [[EditionManager sharedManager] productShortName], remoteReport.reportName, htmlBody];
    
    BOOL success = [html writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    DLog(@"result: %@, %@", success?@"Success":@"Failure", path);
    
}

-(void)processWhenReady:(SEL)action target:(id)target
{
    if (_ready) {
        NSInvocation* invoc = [NSInvocation invocationWithMethodSignature:[target methodSignatureForSelector:action]];
        [invoc setTarget:target];
        [invoc setSelector:action];
        [invoc invoke];
    }
    else {
        self.action = action;
        self.target = target;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(process:)
                                                     name:@"jsonToHtmlProcessorReady"
                                                   object:self];
        
        
    }
}


#pragma mark - Private

- (void)process:(NSNotification*)notification
{
    NSInvocation* invoc = [NSInvocation invocationWithMethodSignature:[_target methodSignatureForSelector:_action]];
    [invoc setTarget:_target];
    [invoc setSelector:_action];
    [invoc invoke];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([[request.URL scheme] hasPrefix:@"ready"]) {
        DLog(@"JsonToCsvProcessor ready");
        _ready = YES;
        
        // send notification to this object that we are ready to process
        NSNotification *notification = [NSNotification notificationWithName:@"jsonToHtmlProcessorReady" object:self userInfo:nil];
        [[NSNotificationQueue defaultQueue] enqueueNotification:notification postingStyle:NSPostASAP];
        
        return NO;
    }
    
    return YES;
    
}

@end
