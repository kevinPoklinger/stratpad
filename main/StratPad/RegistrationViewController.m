//
//  RegistrationViewController.m
//  StratPad
//
//  Created by Julian Wood on 12-08-22.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "RegistrationViewController.h"
#import "NSString-Expanded.h"
#import "RegistrationManager.h"
#import "MenuNavController.h"
#import "UAKeychainUtils+StratPad.h"
#import "EditionManager.h"
#import "RootViewController.h"
#import "SettingsMenuViewController.h"
#import "UserNotificationDisplayManager.h"
#import "UILabelVAlignment.h"
#import "RegistrationKeyEntryViewController.h"

// identify the activityindicator view for easy retrieval
#define tagActivity     777

@interface RegistrationViewController ()

// form view
@property (retain, nonatomic) IBOutlet UIView *viewRegistrationForm;
@property (retain, nonatomic) IBOutlet UITextField *txtFirstName;
@property (retain, nonatomic) IBOutlet UITextField *txtLastName;
@property (retain, nonatomic) IBOutlet UITextField *txtEmail;
@property (retain, nonatomic) IBOutlet UIButton *btnRegister;
@property (retain, nonatomic) IBOutlet UILabelVAlignment *lblInstructions;
- (IBAction)registerEmail;

// info view
@property (retain, nonatomic) IBOutlet UIView *viewInfo;
@property (retain, nonatomic) IBOutlet UILabel *lblEdition;
@property (retain, nonatomic) IBOutlet UILabel *lblContactInfo;
@property (retain, nonatomic) IBOutlet UILabelVAlignment *lblMessage;
@property (retain, nonatomic) IBOutlet UIButton *btnForum;
- (IBAction)goForum;

@end


@implementation RegistrationViewController
@synthesize viewInfo;
@synthesize lblEdition;
@synthesize lblContactInfo;
@synthesize viewRegistrationForm;
@synthesize txtFirstName;
@synthesize txtLastName;
@synthesize txtEmail;
@synthesize btnRegister;
@synthesize lblInstructions;

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    // for form view
    UIImage *btnBlue = [[UIImage imageNamed:@"btn-large-blue.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:0];
    [btnRegister setBackgroundImage:btnBlue forState:UIControlStateNormal];
    [btnRegister setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnRegister setTitleShadowColor:[[UIColor blackColor] colorWithAlphaComponent:0.3] forState:UIControlStateNormal];
    [btnRegister.titleLabel setShadowOffset:CGSizeMake(0, -1)];
    [btnRegister.titleLabel setFont:[UIFont boldSystemFontOfSize:19]];
    
    txtFirstName.delegate = self;
    txtLastName.delegate = self;
    txtEmail.delegate = self;
    btnRegister.enabled = NO;
            
    BOOL isVerified = [[UAKeychainUtils valueForKey:keyChainVerified] boolValue];
    if (!isVerified) {
        // form
        self.title = LocalizedString(@"REGISTER_TITLE", nil);
        
        // allow user to enter the registration key themselves
        UIBarButtonItem *barBtnItemEnterKeyManually = [[UIBarButtonItem alloc] initWithTitle:LocalizedString(@"REGISTRATION_ENTER_KEY", nil)
                                                                                       style:UIBarButtonItemStyleBordered
                                                                                      target:self
                                                                                      action:@selector(enterKeyManually)];
        [self.navigationItem setRightBarButtonItem:barBtnItemEnterKeyManually];
        [barBtnItemEnterKeyManually release];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        // fill in fields
        [txtEmail setText:[defaults stringForKey:keyEmail]];
        [txtFirstName setText:[defaults stringForKey:keyFirstName]];
        [txtLastName setText:[defaults stringForKey:keyLastName]];

    }
    else {
        // thank you
        self.title = LocalizedString(@"REGISTER_DETAILS_TITLE", nil);

        // setup view sizes
        viewInfoSize_ = viewInfo.bounds.size;
        self.view.bounds = CGRectMake(0, 0, viewInfoSize_.width, viewInfoSize_.height);
        viewInfo.frame = CGRectMake(0, 0, viewInfoSize_.width, viewInfoSize_.height);
        
        // swap subviews
        [self.view addSubview:viewInfo];
        [viewRegistrationForm removeFromSuperview];
        
        // update details
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        lblEdition.text = [NSString stringWithFormat:LocalizedString(@"REGISTER_DETAILS_VERSION", nil),
                           [[EditionManager sharedManager] productShortName],
                           [[EditionManager sharedManager] versionNumber]];
        lblContactInfo.text = [NSString stringWithFormat:@"%@ %@ <%@>",
                               [defaults objectForKey:keyFirstName],
                               [defaults objectForKey:keyLastName],
                               [defaults objectForKey:keyEmail]];
        
        // allow user to change their registered email
        UIBarButtonItem *barBtnItemChangeEmail = [[UIBarButtonItem alloc] initWithTitle:LocalizedString(@"REGISTER_CHANGE_EMAIL_BUTTON", nil)
                                                                                  style:UIBarButtonItemStyleBordered
                                                                                 target:self
                                                                                 action:@selector(resetRegistration)];
        [self.navigationItem setRightBarButtonItem:barBtnItemChangeEmail];
        [barBtnItemChangeEmail release];
        
        // left align the button text, but keep the button large (to accommodate text)
        self.btnForum.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:nil];
    
    // move the forum button right below the text
    CGRect r = [self.lblMessage textRectForBounds:self.lblMessage.frame limitedToNumberOfLines:0];    
    CGRect f = self.btnForum.frame;
    self.btnForum.frame = CGRectMake(f.origin.x, CGRectGetMaxY(r)+24, f.size.width, f.size.height);
    
    // change the text in the instructions
    BOOL needsReminder = [[NSUserDefaults standardUserDefaults] integerForKey:keyRegistrationStatus] == RegistrationStatusSubmitted;
    self.lblInstructions.text = needsReminder ?  LocalizedString(@"SETTINGS_REGISTER_CHECK_EMAIL", nil): LocalizedString(@"SETTINGS_REGISTER_INSTRUCTIONS", nil);
    
}

- (void)viewDidUnload
{
    [self setTxtFirstName:nil];
    [self setTxtLastName:nil];
    [self setTxtEmail:nil];
    [self setBtnRegister:nil];
    [self setLblInstructions:nil];
    [self setLblEdition:nil];
    [self setLblContactInfo:nil];
    [self setViewRegistrationForm:nil];
    [self setViewInfo:nil];
    [self setBtnForum:nil];
    [self setLblMessage:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewDidAppear:(BOOL)animated
{
    BOOL hasEmail = [[NSUserDefaults standardUserDefaults] stringForKey:keyEmail] != nil;
    if (!hasEmail) {
        [txtFirstName becomeFirstResponder];
    }

    [super viewDidAppear:animated];
}

// @override: this will make it so that the popover doesn't expand to full height
-(CGSize)contentSizeForViewInPopover
{
    BOOL isVerified = [[UAKeychainUtils valueForKey:keyChainVerified] boolValue];
    if (isVerified) {
        // this is the exact size in the nib
        // it is also the exact size of the grey area in the popover, as measured by free ruler
        return viewInfoSize_;
    } else {
        // stay the same as the parent menu
        return CGSizeMake(self.view.bounds.size.width, 100);
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [txtFirstName release];
    [txtLastName release];
    [txtEmail release];
    [btnRegister release];
    [lblInstructions release];
    [lblEdition release];
    [lblContactInfo release];
    [viewRegistrationForm release];
    [viewInfo release];
    [_btnForum release];
    [_lblMessage release];
    [super dealloc];
}

#pragma mark - Action

- (IBAction)goForum {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://stratpadmembers.kajabi.com/dashboard"]];
}

- (IBAction)registerEmail
{
    // send to server
    [[RegistrationManager sharedManager] registerEmail:txtEmail.text
                                             firstName:txtFirstName.text
                                              lastName:txtLastName.text];
    
    // dismiss dialog and show a notification when complete
    [(MenuNavController*)self.navigationController dismissMenu];
}

-(void)resetRegistration
{
    // role an activity indicator
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicator.tag = tagActivity;
    
    CGSize aSize = indicator.frame.size;
    indicator.frame = CGRectMake((viewInfo.frame.size.width - aSize.width)/2,
                                 (viewInfo.frame.size.height - aSize.height)/2,
                                 indicator.frame.size.width, indicator.frame.size.height);
    [viewInfo addSubview:indicator];
    
    [indicator startAnimating];
    [indicator release];
    
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    
    // before we do anything, we have to make sure we invalidate on the server successfully
    [[RegistrationManager sharedManager] invalidateRegistration:self action:@selector(doReset:)];
}

-(void)enterKeyManually
{
    RegistrationKeyEntryViewController *vc = [[RegistrationKeyEntryViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
}

-(void)doReset:(NSError*)error
{

    // ignore errors - user should be allowed to enter a new email regardless
    
    // remove email
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:nil forKey:keyEmail];
    [defaults setValue:nil forKey:keyFirstName];
    [defaults setValue:nil forKey:keyLastName];
    
    // remove keychain items
    [UAKeychainUtils putValue:@"NO" forKey:keyChainVerified];
    
    // switch back to the form
    // swap subviews
    viewRegistrationForm.frame = self.view.frame;
    [self.view addSubview:viewRegistrationForm];
    [viewInfo removeFromSuperview];
    
    // remove reset button
    self.navigationItem.rightBarButtonItem = nil;
            
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (btnRegister.enabled && [textField isEqual:txtEmail]) {
        [self registerEmail];
    } else if ([textField isEqual:txtFirstName]) {
        [txtLastName becomeFirstResponder];
    } else if ([textField isEqual:txtLastName]) {
        [txtEmail becomeFirstResponder];
    }
    return NO;
}

#pragma mark - Notifications

- (void)textFieldDidChange:(NSNotification *)notification
{
    BOOL isBlank1 = txtFirstName.text == nil || [txtFirstName.text isBlank];
    BOOL isBlank2 = txtLastName.text == nil || [txtLastName.text isBlank];
    BOOL isBlank3 = txtEmail.text == nil || [txtEmail.text isBlank];
    BOOL allFieldsFilled = !isBlank1 && !isBlank2 && !isBlank3;
    btnRegister.enabled = allFieldsFilled;
}

@end
