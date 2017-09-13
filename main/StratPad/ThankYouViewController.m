//
//  ThankYouViewController.m
//  StratPad
//
//  Created by Julian Wood on 2012-10-17.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "ThankYouViewController.h"
#import "RootViewController.h"
#import "EditionManager.h"
#import "NSUserDefaults+StratPad.h"

@interface ThankYouViewController ()
@property (retain, nonatomic) IBOutlet UILabel *lblEdition;
@property (retain, nonatomic) IBOutlet UILabel *lblContactInfo;
@property (retain, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation ThankYouViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = LocalizedString(@"REGISTER_THANKYOU_TITLE", nil);
        
    // update details
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _lblEdition.text = [NSString stringWithFormat:LocalizedString(@"REGISTER_DETAILS_VERSION", nil),
                       [[EditionManager sharedManager] productShortName],
                       [[EditionManager sharedManager] versionNumber]];
    _lblContactInfo.text = [NSString stringWithFormat:@"%@ %@ <%@>",
                           [defaults objectForKey:keyFirstName],
                           [defaults objectForKey:keyLastName],
                           [defaults objectForKey:keyEmail]];
    
    self.webView.backgroundColor = [UIColor clearColor];
    self.webView.opaque = NO;
    self.webView.delegate = self;
    [self loadHTML];
    disableScrolling(self.webView);
    self.preferredContentSize = CGSizeMake(850, 650);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

-(CGSize)contentSizeForViewInPopover
{
    return self.view.bounds.size;
}

- (void)dealloc {
    [_lblEdition release];
    [_lblContactInfo release];
    [_webView release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setLblEdition:nil];
    [self setLblContactInfo:nil];
    [self setWebView:nil];
    [super viewDidUnload];
}


#pragma mark - Actions

- (IBAction)emailAlex
{
    // email as an attachment
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    
    // subject and body text
    [picker setToRecipients:[NSArray arrayWithObject:@"Alex Glassey <alex@alexglassey.com>"]];
    [picker setSubject:LocalizedString(@"REGISTRATION_EMAIL_FEEDBACK_SUBJECT", nil)];
    [picker setMessageBody:LocalizedString(@"REGISTRATION_EMAIL_FEEDBACK_BODY", nil) isHTML:NO];
    
    
    // show the email view
    RootViewController *rootViewController = (RootViewController*)[[[UIApplication sharedApplication] keyWindow] rootViewController];
    [rootViewController presentModalViewController:picker animated:YES];
    [picker release];
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    ILog("Email result: %i; error: %@", result, error);
    [controller dismissModalViewControllerAnimated:YES];
}


#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([[request.URL scheme] hasPrefix:@"file"]) {
        return YES;
    }
    else if ([[request.URL scheme] hasPrefix:@"mailto"]) {
        [self emailAlex];
        return NO;
    }
    else {
        if ([request.URL.absoluteString rangeOfString:@"cloud"].location != NSNotFound) {
            //https://cloud.stratpad.com/index.html#signup/email/name
            ;
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSString *urls = request.URL.absoluteString;
            urls = [urls stringByReplacingOccurrencesOfString:@"email" withString:[defaults objectForKey:keyEmail]];
            urls = [urls stringByReplacingOccurrencesOfString:@"name" withString:
                    [ [NSString stringWithFormat:@"%@ %@", [defaults objectForKey:keyFirstName], [defaults objectForKey:keyLastName] ] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding ]
                    ];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urls]];
        } else {
            [[UIApplication sharedApplication] openURL:request.URL];
        }
        return NO;
    }
}

#pragma mark - Private

- (void)loadHTML
{
    NSString *path = [[[LocalizedManager sharedManager] currentBundle] pathForResource:@"ThankYou" ofType:@"html"];
    NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    [url release];
}

@end
