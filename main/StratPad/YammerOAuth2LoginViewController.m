//
//  YammerOAuth2LoginViewController.m
//  StratPad
//
//  Created by Julian Wood on 12-08-08.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "YammerOAuth2LoginViewController.h"
#import "NSString-Expanded.h"
#import "YammerManager.h"
#import "YammerMessageBuilderViewController.h"
#import "YammerCommentManager.h"

@interface YammerOAuth2LoginViewController ()

@end

@implementation YammerOAuth2LoginViewController
@synthesize textFieldEmail;
@synthesize textFieldPassword;
@synthesize btnSignIn;
@synthesize btnSignUp;
@synthesize lblErrorMessage;

- (id)initWithPath:(NSString *)path reportName:(NSString *)reportName
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        path_ = [path copy];
        reportName_ = [reportName copy];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = LocalizedString(@"YAMMER_SIGNIN_TITLE", nil);

    UIImage *btnBlue = [[UIImage imageNamed:@"btn-large-blue.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:0];
    [btnSignIn setBackgroundImage:btnBlue forState:UIControlStateNormal];
    [btnSignIn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnSignIn setTitleShadowColor:[[UIColor blackColor] colorWithAlphaComponent:0.3] forState:UIControlStateNormal];
    [btnSignIn.titleLabel setShadowOffset:CGSizeMake(0, -1)];
    [btnSignIn.titleLabel setFont:[UIFont boldSystemFontOfSize:19]];
    
    textFieldPassword.delegate = self;
    textFieldEmail.delegate = self;
    textFieldPassword.secureTextEntry = YES;
    lblErrorMessage.text = nil;
    btnSignIn.enabled = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:nil];

}

- (void)viewDidUnload
{
    [self setTextFieldEmail:nil];
    [self setTextFieldPassword:nil];
    [self setBtnSignIn:nil];
    [self setBtnSignUp:nil];
    [self setLblErrorMessage:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [textFieldEmail becomeFirstResponder];
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
    [reportName_ release];
    [path_ release];
    [textFieldEmail release];
    [textFieldPassword release];
    [btnSignIn release];
    [btnSignUp release];
    [lblErrorMessage release];
    [super dealloc];
}

#pragma mark - Signin request/response

- (IBAction)signIn
{
    [[YammerManager sharedManager] signInWithUsername:textFieldEmail.text
                                             password:textFieldPassword.text
                                               target:self
                                               action:@selector(signInFinished:error:)];
    
    // activity indicator
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    CGSize aSize = indicator.frame.size;
    
    indicator.frame = CGRectMake(btnSignIn.frame.size.width - aSize.width - 10,
                                 (btnSignIn.frame.size.height-aSize.height)/2,
                                 indicator.frame.size.width, indicator.frame.size.height);
    
    [btnSignIn addSubview:indicator];
    [indicator startAnimating];
    [indicator release];

    
}

- (IBAction)signUp
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.yammer.com/signup"]];
}

-(void)signInFinished:(NSDictionary*)dict error:(NSError*)error
{
    // remove activity indicator
    [[[btnSignIn subviews] lastObject] removeFromSuperview];
    
    if (!error) {
        DLog(@"dict: %@", dict);
        
        // save token for default network
        NSDictionary *tokenDict = [dict objectForKey:@"access_token"];
        NSString *accessToken = [tokenDict objectForKey:@"token"];
        NSString *permalink = [tokenDict objectForKey:@"network_permalink"];
        
        [[YammerManager sharedManager] saveAuthentication:permalink token:accessToken];
        
        // fire another event here so that we can update comment counts and publications, in case you weren't logged in
        [[YammerCommentManager sharedManager] fireYammerLoggedInEvent];

        // dismiss keyboard
        [textFieldEmail resignFirstResponder];
        [textFieldPassword resignFirstResponder];
        
        // show message builder with no login in the hierarchy
        YammerMessageBuilderViewController *vc = [[YammerMessageBuilderViewController alloc] initWithPath:path_ reportName:reportName_];
        
        NSMutableArray *vcs = [[self.navigationController viewControllers] mutableCopy];
        [vcs removeLastObject];
        [vcs addObject:vc];
        
        [self.navigationController setViewControllers:vcs animated:YES];
        [vcs release];
        [vc release];
    
    } else {
        // error
        lblErrorMessage.text = LocalizedString(@"YAMMER_SIGNIN_FAIL", nil);
        [UIView animateWithDuration:1.f
                              delay:5.f
                            options:UIViewAnimationCurveEaseInOut
                         animations:^{
                             lblErrorMessage.alpha = 0;
                         }
                         completion:^(BOOL finished) {
                             lblErrorMessage.text = nil;
                             lblErrorMessage.alpha = 1;
                         }];
    }
    
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isEqual:textFieldEmail]) {
        [textFieldPassword becomeFirstResponder];
    } else {
        if (btnSignIn.enabled) {
            [self signIn];
        }
    }
    return NO;
}

#pragma mark - Notifications

- (void)textFieldDidChange:(NSNotification *)notification
{
    btnSignIn.enabled = ![textFieldEmail.text isBlank] && ![textFieldPassword.text isBlank];
}


@end
