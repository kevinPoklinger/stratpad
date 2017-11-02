//
//  YammerResultViewController.m
//  StratPad
//
//  Created by Julian Wood on 12-07-12.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "YammerResultViewController.h"
#import "SBJsonParser.h"
#import "NSDate-StratPad.h"
#import "ASIHTTPRequest.h"
#import "MenuNavController.h"
#import "NSString-Expanded.h"
#import "UIImage-Expanded.h"
#import "YammerManager.h"

@interface YammerResultViewController ()

@end

@implementation YammerResultViewController
@synthesize webView;
@synthesize btnDone;

- (id)initWithResponseString:(NSString*)responseString andError:(NSError**)error
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {        
        errorString_ = nil;
        if (error == nil) {
            SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
            NSDictionary *json = [jsonParser objectWithString:responseString];
            if (json) {
                
                self.title = LocalizedString(@"SUCCESS", nil);
                
                NSDictionary *message = [[json objectForKey:@"messages"] objectAtIndex:0];
                NSDictionary *attachment = [[message objectForKey:@"attachments"] objectAtIndex:0];
                                
                // download the thumbnail, because it is behind the API wall                
                NSString *remoteThumbURL = [attachment objectForKey:@"thumbnail_url"];
                if (!remoteThumbURL) {
                    remoteThumbURL = [attachment objectForKey:@"large_icon_url"];
                }
                [self downloadThumb:remoteThumbURL];
                
                // title
                title_ = [[attachment objectForKey:@"full_name"] copy];
                
                // find group name
                NSString *groupName = nil;
                id groupID = [attachment objectForKey:@"group_id"];
                for (NSDictionary *refDict in [json objectForKey:@"references"]) {
                    id gid = [refDict objectForKey:@"id"];
                    if ([groupID isEqual:gid]) {
                        groupName = [refDict objectForKey:@"full_name"];
                        break;
                    }
                }
                
                // network
                NSString *networkName = nil;
                NSInteger postNetworkId = [[message objectForKey:@"network_id"] integerValue];
                NSArray *cachedNetworks = [[YammerManager sharedManager] networks];
                for (YammerNetwork *network in cachedNetworks) {
                    if (network.networkId == postNetworkId) {
                        networkName = network.name;
                        break;
                    }
                }                
                
                // user
                NSString *username = nil;
                id userId = [message objectForKey:@"sender_id"];
                for (NSDictionary *refDict in [json objectForKey:@"references"]) {
                    id refid = [refDict objectForKey:@"id"];
                    if ([userId isEqual:refid]) {
                        username = [refDict objectForKey:@"full_name"];
                        break;
                    }
                }
                
                if (!networkName) {
                    // there must be a network, hopefully also in the cache
                    networkName = [[message objectForKey:@"network_id"] stringValue];
                    WLog(@"Couldn't find network name for id: %@", networkName);
                }
                    
                if (!groupName) {
                    // it's legal not to choose a group
                    meta_ = [[NSString stringWithFormat:LocalizedString(@"YAMMER_RESULT_UPLOADED_NO_GROUP", nil), [[NSDate date] formattedDate2]] retain];
                } else {
                    meta_ = [[NSString stringWithFormat:LocalizedString(@"YAMMER_RESULT_UPLOADED", nil), networkName, groupName] retain];
                }
                
                author_ = username ? [NSString stringWithFormat:LocalizedString(@"YAMMER_RESULT_AUTHOR", nil), username] : @"";
                [author_ retain];
                
                description_ = [[[message objectForKey:@"body"] objectForKey:@"plain"] copy];
                
                yammerURL_ = [[message objectForKey:@"web_url"] copy];
                
                DLog(@"title: %@", title_);
                DLog(@"meta: %@", meta_);
                DLog(@"description: %@", description_);
                DLog(@"url: %@", yammerURL_);
                DLog(@"thumb: %@", thumbURL_);
                DLog(@"author: %@", author_);
            
            } else {
                self.title = LocalizedString(@"ERROR", nil);
                errorString_ = [[NSString stringWithFormat:LocalizedString(@"YAMMER_RESULT_ERROR_PARSE", nil), jsonParser.error] retain];
                ELog(@"%@", errorString_);
            }
            
            [jsonParser release], jsonParser = nil;
            
        } else {
            self.title = LocalizedString(@"ERROR", nil);
            
            NSString *err = [[*error localizedDescription] stringByReplacingOccurrencesOfString:@"’" withString:@"'"];
            errorString_ = [[NSString stringWithFormat:LocalizedString(@"YAMMER_RESULT_ERROR_POST", nil), err] retain];
            ELog(@"%@", errorString_);
        }
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    webView.delegate = self;  
    [self loadHTML];
    
    UIImage *btnBlue = [[UIImage imageNamed:@"btn-large-blue.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:0];
    [btnDone setBackgroundImage:btnBlue forState:UIControlStateNormal];
    [btnDone setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnDone setTitleShadowColor:[[UIColor blackColor] colorWithAlphaComponent:0.3] forState:UIControlStateNormal];
    [btnDone.titleLabel setShadowOffset:CGSizeMake(0, -1)];
    [btnDone.titleLabel setFont:[UIFont boldSystemFontOfSize:19]];    
    [btnDone setTitle:LocalizedString(@"DONE", nil) forState:UIControlStateNormal];
    
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.hidesBackButton = YES;
}

- (void)viewDidUnload
{
    [self setWebView:nil];
    [self setBtnDone:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

// @override: this will make it so that the popover doesn't expand to full height
-(CGSize)contentSizeForViewInPopover
{
    return CGSizeMake(self.view.bounds.size.width, 100);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)dealloc {
    [webView release];
    [thumbURL_ release];
    [title_ release];
    [meta_ release];
    [description_ release];
    [yammerURL_ release];
    [errorString_ release];
    [author_ release];
    
    [btnDone release];
    [super dealloc];
}

#pragma mark - Actions

- (IBAction)done {
    [(MenuNavController*)self.navigationController dismissMenu];
}

#pragma mark - Thumb loading

- (void)downloadThumb:(NSString*)remoteThumbURL
{
    ASIHTTPRequest *request = [[YammerManager sharedManager] requestWithURL:[NSURL URLWithString:remoteThumbURL]];
    [request setDelegate:self];
    [request setDidFailSelector:@selector(thumbFailed:)];
    [request setDidFinishSelector:@selector(thumbFinished:)];
 	[request setTimeOutSeconds:10];    
	[request setShouldContinueWhenAppEntersBackground:YES];
    [request startAsynchronous];
    
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:[remoteThumbURL lastPathComponent]];
    thumbURL_ = [[NSURL fileURLWithPath:path] retain];
    [request setDownloadDestinationPath:path];
    DLog(@"Downloading thumb: %@ to destination: %@", remoteThumbURL, path);

}

- (void)thumbFinished:(ASIHTTPRequest *)request
{
    // load the thumbnail
    NSString *js = [NSString stringWithFormat:@" \
                    $('#thumbnail img').attr('src','%@'); \
                    ", thumbURL_];
    [self.webView stringByEvaluatingJavaScriptFromString:js];
}

- (void)thumbFailed:(ASIHTTPRequest *)request
{
    WLog(@"Couldn't load the thumbnail image: %@", request.error.localizedDescription);

    // use generic pdf icon
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Adobe_PDF_Icon" ofType:@"png"];
    NSString *url = [[NSURL fileURLWithPath:path] absoluteString];
    
    NSString *js = [NSString stringWithFormat:@" \
                    $('#thumbnail img').attr('src','%@'); \
                    ", url];
    [self.webView stringByEvaluatingJavaScriptFromString:js];
}

#pragma mark - Private

- (void)loadHTML
{    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"yammerResult" ofType:@"html"];
    NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
    [webView loadRequest:[NSURLRequest requestWithURL:url]];
    
    [url release];        
}


#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    DLog(@"request: %@", request);
    if ([[request.URL scheme] hasPrefix:@"file"]) {
        return YES;
    } else if ([request.URL.scheme hasPrefix:@"load"]) {
        if (!errorString_) {
            NSString *js = [NSString stringWithFormat:@" \
                            $('#title').text(\"%@\"); \
                            $('#meta').text(\"%@\"); \
                            $('#author').text(\"%@\"); \
                            $('#description').text(\"%@\"); \
                            $('#link a').attr('href', \"%@\"); \
                            ", 
                            [title_ stringByEscapingIllegalJavascriptCharacters], 
                            [meta_ stringByEscapingIllegalJavascriptCharacters], 
                            [author_ stringByEscapingIllegalJavascriptCharacters], 
                            [description_ stringByEscapingIllegalJavascriptCharacters], 
                            [yammerURL_ stringByEscapingIllegalJavascriptCharacters]];
            DLog(@"js: %@", js);
            [self.webView stringByEvaluatingJavaScriptFromString:js];
        } else {
            NSString *err = [[NSString stringWithFormat:@"<p>%@</p> <p>%@</p>", LocalizedString(@"YAMMER_ERROR", nil), errorString_] stringByEscapingIllegalJavascriptCharacters];
            NSString *js = [NSString stringWithFormat:@" \
                            $('#container').empty(); \
                            $('#container').html(\"%@\"); \
                            ", err];
            [self.webView stringByEvaluatingJavaScriptFromString:js];            
        }
        
        return NO;  
    } else {
        [[UIApplication sharedApplication] openURL:request.URL];
        return NO;
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    ELog(@"Error loading webview: %@", error);
}

@end
