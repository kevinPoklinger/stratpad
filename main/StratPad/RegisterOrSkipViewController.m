//
//  RegisterOrSkipViewController.m
//  StratPad
//
//  Created by Julian Wood on 12-08-22.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "RegisterOrSkipViewController.h"
#import "NSString-Expanded.h"
#import "MenuNavController.h"
#import "UAKeychainUtils+StratPad.h"
#import "EditionManager.h"
#import "RootViewController.h"
#import "UserNotificationDisplayManager.h"
#import "MBLoadingView.h"
#import "AppDelegate.h"

@interface RegisterOrSkipViewController ()

// form view
@property (retain, nonatomic) IBOutlet UITextField *txtFirstName;
@property (retain, nonatomic) IBOutlet UITextField *txtLastName;
@property (retain, nonatomic) IBOutlet UITextField *txtEmail;
@property (retain, nonatomic) IBOutlet UIButton *btnRegister;
@property (retain, nonatomic) IBOutlet UIButton *btnSkip;
@property (retain, nonatomic) IBOutlet UIWebView *webView;
- (IBAction)registerEmail;
- (IBAction)skip;

- (void)emailAlex;

@end


@implementation RegisterOrSkipViewController
@synthesize txtFirstName;
@synthesize txtLastName;
@synthesize txtEmail;
@synthesize btnRegister;
@synthesize btnSkip;

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = LocalizedString(@"REGISTER_TITLE", nil);
    
    UIImage *btnRegisterImg = [[UIImage imageNamed:@"btn-large-green-modern.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 15, 0, 15)];
    [btnRegister setBackgroundImage:btnRegisterImg forState:UIControlStateNormal];
    [btnRegister setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnRegister setTitleShadowColor:[[UIColor blackColor] colorWithAlphaComponent:0.4] forState:UIControlStateNormal];
    [btnRegister.titleLabel setShadowOffset:CGSizeMake(0, -1)];
    [btnRegister.titleLabel setFont:[UIFont boldSystemFontOfSize:19]];
    
    txtFirstName.delegate = self;
    txtLastName.delegate = self;
    txtEmail.delegate = self;
    btnRegister.enabled = NO;
    
    [txtLastName setHidden:YES];
    [btnSkip setHidden:YES];
    
    self.webView.backgroundColor = [UIColor clearColor];
    self.webView.opaque = NO;

    [self loadHTML];
    disableScrolling(self.webView);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

    
    CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + 44, self.view.frame.size.width, self.view.frame.size.height);
    _loadingView = [[MBLoadingView alloc] initWithFrame:self.view.frame];
    
    self.preferredContentSize = CGSizeMake(850, 650);
}

- (void)viewDidUnload
{
    [self setTxtFirstName:nil];
    [self setTxtLastName:nil];
    [self setTxtEmail:nil];
    [self setBtnRegister:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self setBtnSkip:nil];
    [self setWebView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)dealloc {
    [popoverController_ release];
    [txtFirstName release];
    [txtLastName release];
    [txtEmail release];
    [btnRegister release];
    [btnSkip release];
    [_webView release];
    [super dealloc];
}

-(CGSize)contentSizeForViewInPopover
{
    return CGSizeMake(850, 650);
}


#pragma mark - Action



- (IBAction)registerEmail
{
    if ([txtFirstName.text isBlank] == true) {
        [[UserNotificationDisplayManager sharedManager] showMessage:LocalizedString(@"REGISTER_REQUIRED", nil)];
        return;
    }
/*
    if ([txtLastName.text isBlank] == true) {
        [[UserNotificationDisplayManager sharedManager] showMessage:LocalizedString(@"REGISTER_REQUIRED", nil)];
        return;
    }
*/
    if ([txtEmail.text isBlank] == true) {
        [[UserNotificationDisplayManager sharedManager] showMessage:LocalizedString(@"REGISTER_REQUIRED", nil)];
        return;
    }
    
    // dismiss dialog and show a notification when complete
    //[self dismissPopover];

    // send to server
    [RegistrationManager sharedManager].mController = self;
    [[RegistrationManager sharedManager] registerEmail:txtEmail.text
                                             firstName:txtFirstName.text
                                              lastName:@"a"];
    
    [_loadingView showInView:self.view];
}

- (void)registerResult:(BOOL) bSuccess {
    
}

- (IBAction)skip
{
    [self dismissPopover];
    [[UserNotificationDisplayManager sharedManager] showMessage:LocalizedString(@"REGISTER_ANYTIME", nil)];
}

- (void)emailAlex
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

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (btnRegister.enabled && [textField isEqual:txtEmail]) {
        [self registerEmail];
    }
    else if ([textField isEqual:txtFirstName]) {
        //[txtLastName becomeFirstResponder];
        [txtEmail becomeFirstResponder];
    }
/*
    else if ([textField isEqual:txtLastName]) {
        [txtEmail becomeFirstResponder];
    }
*/
    return NO;
}

#pragma mark - Notifications

- (void)textFieldDidChange:(NSNotification *)notification
{
    BOOL isBlank1 = txtFirstName.text == nil || [txtFirstName.text isBlank];
    //BOOL isBlank2 = txtLastName.text == nil || [txtLastName.text isBlank];
    BOOL isBlank3 = txtEmail.text == nil || [txtEmail.text isBlank];
    //BOOL allFieldsFilled = !isBlank1 && !isBlank2 && !isBlank3;
    BOOL allFieldsFilled = !isBlank1 && !isBlank3;
    btnRegister.enabled = allFieldsFilled;
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    [self.webView stringByEvaluatingJavaScriptFromString:@"hide()"];
    CGRect frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, 850, 317);
    [_loadingView setFrame:frame];
    _loadingView.progress.center = CGPointMake(frame.origin.x + frame.size.width / 2, frame.origin.y + frame.size.height / 2);
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [self.webView stringByEvaluatingJavaScriptFromString:@"show()"];
    CGRect frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, 850, 694);
    [_loadingView setFrame:frame];
    _loadingView.progress.center = CGPointMake(frame.origin.x + frame.size.width / 2, frame.origin.y + frame.size.height / 2);
}


#pragma mark - UIPopoverControllerDelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    [[UserNotificationDisplayManager sharedManager] showMessage:LocalizedString(@"REGISTER_ANYTIME", nil)];

    [popoverController_ release];
	popoverController_ = nil;
}

#pragma mark - Public

- (void)showPopoverInView:(UIView*)view
{
    if (popoverController_) {
        [popoverController_ release]; popoverController_ = nil;
    }
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self];
    navController.modalInPopover = YES;
    navController.modalPresentationStyle = UIModalPresentationCurrentContext;
    popoverController_ = [[UIPopoverController alloc] initWithContentViewController:navController];
    [navController release];
    
    popoverController_.delegate = self;
    [popoverController_ presentPopoverFromRect:view.bounds
                                        inView:view
                      permittedArrowDirections:0 // no arrows
                                      animated:YES];
}


- (void)dismissPopover
{
    if (popoverController_) {
        [popoverController_ dismissPopoverAnimated:YES];
        [popoverController_ release];
        popoverController_ = nil;
    }
    else {
        // if it was appended to a nav controller
        UIViewController *vc = [[self.navigationController viewControllers] objectAtIndex:0];
        if ([vc respondsToSelector:@selector(dismissPopover)]) {
            [vc performSelector:@selector(dismissPopover)];
        }
    }
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
        [[UIApplication sharedApplication] openURL:request.URL];
        return NO;
    }
}

#pragma mark - Private

- (void)loadHTML
{
    NSString *path = [[[LocalizedManager sharedManager] currentBundle] pathForResource:@"RegisterOrSkip" ofType:@"html"];
    DLog(@"path: %@", path);
    NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    [url release];
}


@end
