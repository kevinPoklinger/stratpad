//
//  JsonToCsvProcessor.m
//  StratPad
//
//  Created by Julian Wood on 2013-06-19.
//  Copyright (c) 2013 Julian Wood. All rights reserved.
//
//  Curiously, this just needs to be a UIViewController, rather than an NSObject, to get the UIWebView to work, so we can generate our csv.
//
//  ARC

#import "JsonToCsvProcessor.h"

@interface JsonToCsvProcessor ()
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) id target;
@property (nonatomic, assign) SEL action;
@end

@implementation JsonToCsvProcessor

- (id)init
{
    self = [super init];
    if (self) {
        DLog(@"Loading JsonToCsvProcessor webview");
        
        _ready = NO;
        
        self.webView = [[UIWebView alloc] init];
        _webView.delegate = self;
        NSString *path = [[NSBundle mainBundle] pathForResource:@"FinancialDetailsReport" ofType:@"html"];
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

-(void)exportToCsvWithJson:(NSDictionary*)json remoteReport:(id<RemoteReport>)remoteReport path:(NSString*)path
{
    NSError *error = nil;
    NSData *dataKeysAndStrings = [NSJSONSerialization dataWithJSONObject:[remoteReport localizedStringsAndKeys] options:0 error:&error];
    NSString *jsonKeysAndStrings = [[NSString alloc] initWithData:dataKeysAndStrings encoding:NSUTF8StringEncoding];
    
    // convert to string
    NSData *dataContent = [NSJSONSerialization dataWithJSONObject:json options:0 error:&error];
    NSString *jsonContent = [[NSString alloc] initWithData:dataContent encoding:NSUTF8StringEncoding];
        
    NSString *csv = [_webView stringByEvaluatingJavaScriptFromString:
                     [NSString stringWithFormat:@"Number.prototype.formatNumber = formatNumberForCSV; %@(%@, '#%@', '%@', %@); csvFormattedString()", [remoteReport jsMethodNameToLoadTable], jsonContent, @"000000", [LocalizedManager sharedManager].localeIdentifier, jsonKeysAndStrings]];
    
    BOOL success = [csv writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
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
                                                     name:@"jsonToCsvProcessorReady"
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
        NSNotification *notification = [NSNotification notificationWithName:@"jsonToCsvProcessorReady" object:self userInfo:nil];
        [[NSNotificationQueue defaultQueue] enqueueNotification:notification postingStyle:NSPostASAP];

        return NO;
    }
    
    return YES;
    
}


@end
